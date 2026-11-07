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

/** a screen was created: add buttons and menu items */
- (BOOL)MesiboUI_onInitScreen:(MesiboScreen *)screen {
    if (MESIBO_SCREEN_USERLIST == screen.type) {
        // the chat list: add your own buttons or "more" menu items here
        // (screen.buttons, screen.menu)
        return NO;
    }

    if (MESIBO_SCREEN_MESSAGES == screen.type)
        [self updateCallButtons:screen];

    return NO;
}

/** an open screen is refreshed (+[MesiboUI updateScreens]), e.g. when a call starts or ends */
- (void)MesiboUI_onUpdateScreen:(MesiboScreen *)screen {
    [self updateCallButtons:screen];
}

/** a row was bound: change colors etc. as suitable for your app */
- (BOOL)MesiboUI_onUpdateRow:(MesiboScreen *)screen row:(MesiboRow *)row last:(BOOL)last {
    return NO;
}

/** a row was tapped: return YES if you handled it */
- (BOOL)MesiboUI_onClickedRow:(MesiboScreen *)screen row:(MesiboRow *)row {
    return NO;
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
