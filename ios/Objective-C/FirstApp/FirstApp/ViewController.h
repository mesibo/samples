//
//  ViewController.h
//  FirstApp
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mesibo/Mesibo.h>
#import <mesiboui/MesiboUI.h>
#import <mesibocall/MesiboCall.h>

@interface ViewController : UIViewController <MesiboDelegate, MesiboCallIncomingListener,
                                              MesiboLocationListener, MesiboProfileSearchListener>

@property (weak, nonatomic) IBOutlet UIButton *mLoginUser1;
@property (weak, nonatomic) IBOutlet UIButton *mLoginUser2;
@property (weak, nonatomic) IBOutlet UILabel *mConnectionStatus;

/** YES when USER1_TOKEN and USER2_TOKEN are set (ViewController.m) */
+ (BOOL)areTokensSet;

@end

