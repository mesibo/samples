//
//  MesiboUI.h
//  MesiboUI
//
//  Created by Sarfaraz Halai on 06/10/16.
//  Copyright © 2016 Sarfaraz Halai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Mesibo/Mesibo.h"
//#import "UITableViewWithReloadCallback.h"






@interface MesiboUI : NSObject

+(void) launchEditGroupDetails:(id) parent groupid:(uint32_t) groupid;

+(UIViewController *) getMesiboUIViewController ;

+(UIImage *) getDefaultImage:(BOOL) group;

+(void) launchMessageViewController:(UIViewController *) parent profile:(MesiboUserProfile*)profile ;

//+(void) getUITableViewInstance:(UITableViewWithReloadCallback *) table;

@end
