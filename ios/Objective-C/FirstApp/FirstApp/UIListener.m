//
//  UIListener.m
//  FirstApp
//
//  Messaging UI customization listener.
//  Refer to https://docs.mesibo.com/ui-modules/ for details.
//

#import "UIListener.h"
#import <mesibocall/MesiboCall.h>
#import <objc/runtime.h>

// tags of the call buttons we add, to find and replace them
#define CALLBUTTON_VIDEO        9001
#define CALLBUTTON_VOICE        9002
#define CALLBUTTON_INPROGRESS   9003

@implementation UIListener

- (instancetype)init {
    if ((self = [super init]))
        [MesiboUI setListener:self];
    return self;
}


#pragma mark - MesiboUIListener

/**
 * OPTIONAL - the texts, colors, etc. of the messaging UI (the same names on Android and iOS), set on
 * each new configuration (a theme applied). Refer to https://docs.mesibo.com/ui-modules/setting-defaults/
 */
- (void)MesiboUI_onConfig:(MesiboUiConfig *)config dark:(BOOL)dark {
    config.userList.showBackButton = YES;
}

/**
 * a screen was created: add buttons and menu items. Return YES for this screen's other callbacks
 * (MesiboUI_onUpdateScreen, MesiboUI_onAction, the row callbacks), NO for none.
 */
- (BOOL)MesiboUI_onInitScreen:(MesiboScreen *)screen {
    __weak MesiboScreen *s = screen;
    if (MESIBO_SCREEN_USERLIST == screen.type) {
        // the chat list: add your own buttons or "more" menu items here (screen.buttons,
        // screen.menu). End-to-end encryption: turned on or off there (mesibo keeps the choice)
        [screen.menu addObject:[MesiboMenuItem itemWithTitle:@"End-to-end encryption" image:[UIImage systemImageNamed:@"lock"]
                                                  identifier:@"e2ee" handler:^(MesiboMenuItem *item) {
            if (s.parent) [MesiboUI showEndToEndEncryptionConfiguration:s.parent];
        }]];

        // Customize: the look of the light or dark theme, saved by mesibo and used at once
        [screen.menu addObject:[MesiboMenuItem itemWithTitle:@"Customize" image:[UIImage systemImageNamed:@"paintbrush"]
                                                  identifier:@"customize" handler:^(MesiboMenuItem *item) {
            if (!s.parent)
                return;
            [MesiboUI launchCustomize:s.parent closed:^BOOL(NSString *json, BOOL dark) {
                [MesiboUI saveCustomization:json dark:dark];
                return YES;
            }];
        }]];
        return YES;
    }

    if (MESIBO_SCREEN_MESSAGES == screen.type) {
        // the end-to-end encryption of this chat (its state, the security code to compare), only
        // while it is on, and not for groups
        if ([[[Mesibo getInstance] e2ee] isEnabled] && ![screen.profile isGroup]) {
            [screen.menu addObject:[MesiboMenuItem itemWithTitle:@"End-to-end encryption" image:[UIImage systemImageNamed:@"lock.shield"]
                                                      identifier:@"e2ee" handler:^(MesiboMenuItem *item) {
                if (s.parent && s.profile)
                    [MesiboUI showEndToEndEncryptionInfo:s.parent profile:s.profile];
            }]];
        }
        [self updateCallButtons:screen];
        return YES;
    }

    if (MESIBO_SCREEN_PROFILE == screen.type) {
        // the buttons under the name
        [((MesiboProfileScreen *)screen).actions addObjectsFromArray:[self callItems:screen]];
    } else if (MESIBO_SCREEN_PROFILE_POPUP == screen.type) {
        // the popup's buttons, between Message and Info
        [screen.menu addObjectsFromArray:[self callItems:screen]];
    }

    return YES;
}

/**
 * Voice and video call buttons, for the profile screen and the profile popup (none for a group
 * the user left). During a call, they bring it back.
 */
- (NSArray<MesiboMenuItem *> *)callItems:(MesiboScreen *)screen {
    MesiboProfile *profile = screen.profile;
    if (nil == profile || ([profile isGroup] && ![profile isActive]))
        return @[];

    NSMutableArray<MesiboMenuItem *> *items = [NSMutableArray array];
    __weak MesiboScreen *s = screen;
    for (NSNumber *video in @[@NO, @YES]) {
        BOOL isVideo = video.boolValue;
        [items addObject:[MesiboMenuItem itemWithTitle:isVideo ? @"Video" : @"Voice"
                                                 image:[UIImage systemImageNamed:isVideo ? @"video.fill" : @"phone.fill"]
                                            identifier:isVideo ? @"videocall" : @"voicecall"
                                               handler:^(MesiboMenuItem *item) {
            if (nil == s.parent || nil == s.profile)
                return;

            // during a call: back to it
            if ([MesiboCallInstance isAnyCallInProgress]) {
                [MesiboCallInstance showCallInProgress:s.parent];
                return;
            }
            [MesiboCallInstance callUi:s.parent profile:s.profile video:isVideo];
        }]];
    }
    return items;
}

/** an open screen is refreshed (+[MesiboUI updateScreens]), e.g. when a call starts or ends */
- (void)MesiboUI_onUpdateScreen:(MesiboScreen *)screen {
    [self updateCallButtons:screen];
}

/** a row was bound: change colors etc. as suitable for your app */
- (void)MesiboUI_onUpdateRow:(MesiboScreen *)screen row:(MesiboRow *)row last:(BOOL)last {
}

/**
 * the user did something (action.type, MESIBO_ACTION_*): a row tapped, a profile to show, an
 * attachment, the camera, a voice message, a long press action, a message to send, ... Return YES
 * to let the UI do it as usual, NO when the app handled it. For example, to check a message before
 * it is sent (and change it, or return NO to stop it):
 *     if (MESIBO_ACTION_SEND == action.type) { ... action.message ... }
 */
- (BOOL)MesiboUI_onAction:(MesiboScreen *)screen action:(MesiboUiAction *)action {
    return YES;
}


#pragma mark - call buttons

- (UIBarButtonItem *)callButton:(NSString *)symbol tag:(NSInteger)tag label:(NSString *)label screen:(MesiboScreen *)screen {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:symbol]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(onCallButton:)];
    button.tag = tag;
    button.accessibilityLabel = label;

    // remember the screen, for the action
    objc_setAssociatedObject(button, @selector(onCallButton:), screen, OBJC_ASSOCIATION_ASSIGN);
    return button;
}

/** video and voice call buttons in chats; during a call, a button to return to it */
- (void)updateCallButtons:(MesiboScreen *)screen {
    // remove the buttons we added before
    NSIndexSet *ours = [screen.buttons indexesOfObjectsPassingTest:^BOOL(UIBarButtonItem *button, NSUInteger index, BOOL *stop) {
        return button.tag >= CALLBUTTON_VIDEO && button.tag <= CALLBUTTON_INPROGRESS;
    }];
    [screen.buttons removeObjectsAtIndexes:ours];

    if (MESIBO_SCREEN_MESSAGES != screen.type)
        return;

    if ([MesiboCallInstance isAnyCallInProgress]) {
        UIBarButtonItem *button = [self callButton:@"phone.connection" tag:CALLBUTTON_INPROGRESS label:@"Call in progress" screen:screen];
        button.tintColor = UIColor.systemGreenColor;
        [screen.buttons addObject:button];
        return;
    }

    // no calls in groups the user has left
    MesiboProfile *profile = screen.profile;
    if (nil == profile || ([profile isGroup] && ![profile isActive]))
        return;

    // shown left to right in the order added
    BOOL group = [profile isGroup];
    [screen.buttons addObject:[self callButton:(group ? @"video.badge.plus" : @"video") tag:CALLBUTTON_VIDEO
                                         label:(group ? @"Group video call" : @"Video call") screen:screen]];
    [screen.buttons addObject:[self callButton:(group ? @"phone.badge.plus" : @"phone") tag:CALLBUTTON_VOICE
                                         label:(group ? @"Group voice call" : @"Voice call") screen:screen]];
}

- (void)onCallButton:(UIBarButtonItem *)sender {
    MesiboScreen *screen = objc_getAssociatedObject(sender, @selector(onCallButton:));
    if (nil == screen.parent)
        return;

    if (CALLBUTTON_INPROGRESS == sender.tag) {
        [MesiboCallInstance showCallInProgress:screen.parent];
        return;
    }

    if (nil == screen.profile)
        return;

    [MesiboCallInstance callUi:screen.parent profile:screen.profile video:(CALLBUTTON_VIDEO == sender.tag)];
}

@end
