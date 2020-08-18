//  Copyright © 2016 Mesibo. All rights reserved.

#import <UIKit/UIKit.h>
#import <mesibo/mesibo.h>
#import "SampleAppFileTransferHandler.h"




@interface AppDelegate : UIResponder <UIApplicationDelegate, MesiboDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) SampleAppFileTransferHandler *fileTranserHandler;

@end
