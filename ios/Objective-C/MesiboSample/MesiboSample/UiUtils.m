//  Copyright © 2017 Mesibo. All rights reserved.
//

#import "UiUtils.h"
#import <MesiboUI/MesiboUI.h>
#import "includes.h"

@implementation UiUtils


UINavigationController *_mNavigationController = nil;
+(void) launchVC_mainThread:(UIViewController *)parent vc:(UIViewController *)vc {
    
    if(!parent)
        parent = _mNavigationController;
    
    if(parent.navigationController)
        [parent.navigationController pushViewController:vc animated:YES];
    else
        [parent presentViewController:vc animated:YES completion:nil];
    
}

+(void) launchVC:(UIViewController *)parent vc:(UIViewController *)vc {
    
    BOOL mainThread = [MesiboInstance isUiThread];
    
    if(mainThread)
        [self launchVC_mainThread:parent vc:vc];
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self launchVC_mainThread:parent vc:vc];
        });
    }
}

+(void) launchMesiboUI:(UIViewController*) rootController withMainWindow: (UIWindow*) mainWindow {
    
    MesiboUiOptions *ui = [MesiboInstance getUiOptions];
    ui.emptyUserListMessage = @"No contacts! Invite your family and friends to try mesibo.";
        
    UIViewController *mesiboController = [MesiboUI getMesiboUIViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mesiboController];
    rootController = navigationController;
    _mNavigationController = rootController;
    [mainWindow setRootViewController:rootController];
    [mainWindow makeKeyAndVisible];
    
}

+(UIColor *) getColor:(UInt32) color {
    return [UIColor colorWithRed:((float)((color>>16)&0xFF))/255.0 green:((float)((color>>8)&0xFF))/255.0 blue:((float)((color)&0xFF))/255.0 alpha:((float)((color>>24)&0xFF))/255.0];
}

+ (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+ (void)showAlert:(NSString*)message withTitle :(NSString *) title {
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction
                                    actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        
                                        [alert removeFromParentViewController];
                                        
                                    }];
    
    [alert addAction:defaultAction];
    [[UiUtils topMostController]presentViewController:alert animated:YES completion:nil];
}

@end
