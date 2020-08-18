//
//  MesiboCall.h
//  MesiboCall
//
//  Copyright © 2018 Mesibo. All rights reserved.
//
#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Mesibo/Mesibo.h"

#define MESIBOCALL_NOTIFY_INCOMING  0
#define MESIBOCALL_NOTIFY_MISSED    4

@protocol MesiboCallDelegate
-(BOOL) MesiboCall_onNotifyIncoming:(int)type profile:(MesiboUserProfile *)profile video:(BOOL)video;
-(void) MesiboCall_onShowViewController:(id)parent vc:(id)vc;
-(void) MesiboCall_onDismissViewController:(id)vc;
@end

#define MesiboCallInstance [MesiboCall sharedInstance]

@interface MesiboCallConfig : NSObject
//@property (strong, nonatomic) UIViewController *parent;
@property (strong, nonatomic) NSString *serviceName; //name of the service
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) UIColor *viewColor;
@property (strong, nonatomic) UIColor *endButtonColor;
@property (strong, nonatomic) UIColor *endButtonBorderColor;
@property (strong, nonatomic) UIColor *optionButtonBorderColor;
@property (strong, nonatomic) UIColor *optionButtonColor;
@property (strong, nonatomic) UIColor *optionButtonSelectedColor;
@property (strong, nonatomic) UIColor *textColorForName;
@property (strong, nonatomic) UIColor *textColorForCallStatus;
@property (strong, nonatomic) NSString *textForCallConnected;
@property (strong, nonatomic) NSString *textForCallEnd;
@property (strong, nonatomic) NSString *textForCallFailed;
@property (strong, nonatomic) UIImage *imageForBackGround;
@property (strong, nonatomic) UIColor *dialerPopBackground;
@property (strong, nonatomic) UIColor *dialerPopBorder;
@property (strong, nonatomic) UIColor *dialerOptionBorder;
@property (strong, nonatomic) UIColor *dialerOptionColor;
@property (strong, nonatomic) UIColor *dialerBorderColor;
@property (strong, nonatomic) UIColor *dialerBackgroundColor;
@property (strong, nonatomic) UIColor *dialerTextColor;
@property (strong, nonatomic) UIColor *hideTitleColor;
@property (nonatomic) int autoHideVideoControlsTimeout;

@property (nonatomic) BOOL checkNetworkConnection;

//@property (nonatomic) int timeLimitForUnansweredCall;
@property(nonatomic) double alphaValueForOptionEnable;
@property(nonatomic) double alphaValueForOptionDisable;
@property(nonatomic) double alphaValueForTitleEnable;
@property(nonatomic) double alphaValueForTitleDisable;
@property(nonatomic) float dialerAlphaValue;
@end




@interface MesiboCall : NSObject

+ (MesiboCall*) sharedInstance;

-(BOOL) call:(id)parent callid:(uint32_t)callid  address:(NSString *)address video:(BOOL)video incoming:(BOOL)incoming;

-(void) setListener:(id<MesiboCallDelegate>) delegate;

-(void) start;
-(void) answer:(BOOL)video initialVideo:(BOOL)initialVideo;
-(void) hangup;
-(void) showCallInProgress;
-(MesiboCallConfig *) getConfig;
-(void) resetProvider;
//-(void) checkPermission:(BOOL)video;
-(void) test:(id)parent;

@end

