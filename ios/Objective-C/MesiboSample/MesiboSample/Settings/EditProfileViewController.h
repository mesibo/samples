//
//  EditProfileViewController.h
//  LoginProcess
//
//  Created by Sarfaraz Halai on 03/12/16.
//  Copyright © 2016 Sarfaraz Halai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UIGestureRecognizerDelegate>


- (void) setStatusLabel:(NSString *)mStatusText;
- (void) setSelfUserName:(NSString *)mSelfUserNameText;
@end
