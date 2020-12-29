//
//  ViewController.h
//  FirstApp
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mesibo/Mesibo.h>
#import "MesiboUi/MesiboUi.h"
#import "MesiboCall/MesiboCall.h"

@interface ViewController : UIViewController <MesiboDelegate, MesiboCallIncomingListener>

@property (weak, nonatomic) IBOutlet UITextField *mMessage;
@property (weak, nonatomic) IBOutlet UIButton *mLoginUser1;
@property (weak, nonatomic) IBOutlet UIButton *mLoginUser2;
@property (weak, nonatomic) IBOutlet UILabel *mConnectionStatus;
@property (weak, nonatomic) IBOutlet UILabel *mMessageStatus;
@property (weak, nonatomic) IBOutlet UIButton *mUiButton;
@property (weak, nonatomic) IBOutlet UIButton *mAudioCallButton;
@property (weak, nonatomic) IBOutlet UIButton *mVideoCallButton;



@end

