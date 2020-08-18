//  Copyright © 2017 Mesibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mesibo/mesibo.h>
#import <UIKit/UIKit.h>
#import "includes.h"

@interface UiUtils : NSObject

+(void) launchVC:(UIViewController *)parent vc:(UIViewController *)vc;
+(void) launchMesiboUI:(UIViewController*) rootController withMainWindow: (UIWindow*) mainWindow;

+ (UIColor *) getColor:(UInt32) color;
+ (void)showAlert:(NSString*)message withTitle :(NSString *) title;
@end
