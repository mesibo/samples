//
//  MesiboUI.h
//  MesiboUI
//
//  Copyright © 2018 Mesibo. All rights reserved.
//
#ifndef __MESIBOUI_H
#define __MESIBOUI_H
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Mesibo/Mesibo.h"
//#import "UITableViewWithReloadCallback.h"

@interface MesiboCell : UITableViewCell {
    
}
@end

@protocol MesiboMessageViewDelegate <NSObject>
@required
- (UITableView *) getMesiboTableView;
- (CGFloat)MesiboTableView:(UITableView *)tableView heightForMessage:(MesiboMessage *)message;
- (MesiboCell *)MesiboTableView:(UITableView *)tableView cellForMessage:(MesiboMessage *)message;
- (MesiboCell *)MesiboTableView:(UITableView *)tableView show:(MesiboMessage *)message;
@optional
@end


@interface MesiboUI : NSObject

+(void) launchEditGroupDetails:(id) parent groupid:(uint32_t) groupid;

+(UIViewController *) getMesiboUIViewController ;
+ (UIViewController *) getMesiboUIViewController:(id)uidelegate;

+(UIImage *) getDefaultImage:(BOOL) group;

+(void) launchMessageViewController:(UIViewController *) parent profile:(MesiboUserProfile*)profile ;

+(void) launchMessageViewController:(UIViewController *) parent profile:(MesiboUserProfile*)profile uidelegate:(id)uidelegate;

//+(void) getUITableViewInstance:(UITableViewWithReloadCallback *) table;

@end


#endif
