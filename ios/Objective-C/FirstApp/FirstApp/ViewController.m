//
//  ViewController.m
//  FirstApp
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import "ViewController.h"



@interface ViewController () {
    NSString *mRemoteUser;
    MesiboUserProfile *mProfile;
    MesiboReadSession *mReadSession;
    
    NSDictionary *mUser1, *mUser2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Refer to the Get-Started guide to create two users and their access tokens
    mUser1 = @{
        @"token": @"xyz",\
        @"name": @"User 1",\
        @"address": @"123"};
    
    mUser2 = @{
        @"token": @"pqr",\
        @"name": @"User 2",\
        @"address": @"456"};
    
    
    _mUiButton.enabled = NO;
    _mAudioCallButton.enabled = NO;
    _mVideoCallButton.enabled = NO;
    
    
    // Do any additional setup after loading the view.
}

-(void) mesiboInit:(NSString *)token remoteUserAddress:(NSString *)address remoteUserName:(NSString *)name {
    
    [MesiboInstance addListener:self];

    [MesiboInstance setSecureConnection:YES];
    // set user authentication token obtained by creating user
    [MesiboInstance setAccessToken:token];
    [MesiboInstance setDatabase:@"mydb" resetTables:0];
    [MesiboInstance start];
    
    
    _mLoginUser1.enabled = NO;
    _mLoginUser2.enabled = NO;
    
    _mUiButton.enabled = YES;
    _mAudioCallButton.enabled = YES;
    _mVideoCallButton.enabled = YES;
    
    // save address for sending messages
    mRemoteUser = address;
    
    //set profile which is required by UI
    mProfile = [MesiboUserProfile new];
    mProfile.name = name;
    mProfile.address = address;
    [MesiboInstance setProfile:mProfile refresh:NO];
    
    //OPTIONAL, initialize calls
    [MesiboCall startWith:nil name:@"mesibo first App" icon:nil callKit:YES];
    
    // following code will read messages from the database and
    // will also send read receipts for db and real-time messages
    
    // set app mode in foreground for read-receipt to be sent
    [MesiboInstance setAppInForeground:self screenId:0 foreground:YES];
    mReadSession = [MesiboReadSession new];
    [mReadSession initSession:mRemoteUser groupid:0 query:nil delegate:self];
    [mReadSession enableReadReceipt:YES];
    [mReadSession read:100];
    
}

-(void) Mesibo_OnConnectionStatus:(int)status {
    // You will receive the connection status here
    
    NSLog(@"Connection status: %d", status);
    
    NSString *str = [NSString stringWithFormat:@"Connection Status: %d", status];
    
    _mConnectionStatus.text = str;
        
}

-(void) Mesibo_OnMessage:(MesiboParams *)params data:(NSData *)data {
    
    // You will receive messages here
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Sshowing alerts for real-time messages (and not the
    // ones from the database)
    if(MESIBO_ORIGIN_REALTIME == params.origin && 0 == params.type) {
        [self alert:message];
    }

}

-(void) Mesibo_OnMessage:(MesiboMessage *)message {
    
}

-(void) Mesibo_OnMessageStatus:(MesiboParams *)params {

    NSString *str = [NSString stringWithFormat:@"Message Status: %d", params.status];
    
    _mMessageStatus.text = str;
    
}

// login as User-1 and send messages/calls to User-2
- (IBAction)onLoginUser1:(id)sender {
    [self mesiboInit:mUser1[@"token"] remoteUserAddress:mUser2[@"address"] remoteUserName:mUser2[@"name"]];
}

// login as User-2 and send messages/calls to User-1
- (IBAction)onLoginUser2:(id)sender {
    [self mesiboInit:mUser2[@"token"] remoteUserAddress:mUser1[@"address"] remoteUserName:mUser1[@"name"]];
}

- (IBAction)onSendMessage:(id)sender {
    MesiboParams *params = [MesiboParams new];
    params.peer = mRemoteUser;
    params.flag = MESIBO_FLAG_READRECEIPT | MESIBO_FLAG_DELIVERYRECEIPT;

    uint32_t mid = [MesiboInstance random];
    [MesiboInstance sendMessage:params msgid:mid string:_mMessage.text];
    _mMessage.text = @"";
}

- (IBAction)onLaunchMessagingUIModule:(id)sender {
    //requires pod mesibo-ui
    [MesiboUI launchMessageViewController:self profile:mProfile];
}

/* ensure to grant background mode and microphone permissions */
- (IBAction)onAudioCall:(id)sender {
    [MesiboCallInstance callUi:self address:mRemoteUser video:NO];
}

- (IBAction)onVideoCall:(id)sender {
    [MesiboCallInstance callUi:self address:mRemoteUser video:YES];
}

-(BOOL) MesiboCall_onNotifyIncoming:(int)type profile:(MesiboUserProfile *)profile video:(BOOL)video {
    return YES;
}

-(void) MesiboCall_onShowViewController:(id)parent vc:(id)vc {
    
    UIViewController *uvc = (UIViewController *)vc;
    
        
    if(uvc.isBeingPresented)
        return;
    
    if(!parent) parent = self;
        
    [MesiboInstance runInThread:YES handler:^{
            [parent presentViewController:vc animated:YES completion:nil];
    }];

}

-(void) MesiboCall_onDismissViewController:(id)vc {
    
}

-(void) alert:(NSString *)message {
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"New Message" message:message preferredStyle:UIAlertControllerStyleActionSheet];

    [self presentViewController:avc animated:YES completion:nil];

    int duration = 2;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [avc dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
