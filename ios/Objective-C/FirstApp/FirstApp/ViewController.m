//
//  ViewController.m
//  FirstApp
//
//  Copyright © 2022 Mesibo. All rights reserved.
//

#import "ViewController.h"



@interface ViewController () {
    NSString *mRemoteUser;
    MesiboProfile *mProfile;
    MesiboReadSession *mReadSession;
    
    NSDictionary *mUser1, *mUser2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Refer to the Get-Started guide to create two users and their access tokens
    mUser1 = @{
        @"token": @"<token-1>",
        @"name": @"User 1",
        @"address": @"123"};
    
    mUser2 = @{
        @"token": @"<token-2>",
        @"name": @"User 2",
        @"address": @"456"
    };
    
    
    _mUiButton.enabled = NO;
    _mAudioCallButton.enabled = NO;
    _mVideoCallButton.enabled = NO;
    
    
    // Do any additional setup after loading the view.
}

-(void) mesiboInit:(NSString *)token remoteUserAddress:(NSString *)address remoteUserName:(NSString *)name {

    [MesiboInstance addListener:self];

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
    mProfile = [MesiboInstance getProfile:address groupid:0];
    
    
    //OPTIONAL, initialize calls
    [MesiboCall startWith:nil name:@"mesibo first App" icon:nil callKit:YES];
    
    // following code will read messages from the database and
    // will also send read receipts for db and real-time messages
    
    // set app mode in foreground for read-receipt to be sent
    [MesiboInstance setAppInForeground:self screenId:0 foreground:YES];
    mReadSession = [mProfile createReadSession:self];
    [mReadSession enableReadReceipt:YES];
    [mReadSession read:100];
    
}

-(void) Mesibo_OnConnectionStatus:(int)status {
    // You will receive the connection status here
    
    NSLog(@"Connection status: %d", status);
    
    NSString *str = [NSString stringWithFormat:@"Connection Status: %d", status];
    
    _mConnectionStatus.text = str;
        
}

-(void) Mesibo_OnMessage:(MesiboMessage *) msg {
    
    // Sshowing alerts for real-time messages (and not the
    // ones from the database)
    if([msg isRealtimeMessage]) {
        [self alert:@"New Message" message:msg.message];
    }

}

-(void) Mesibo_OnMessageUpdate:(MesiboMessage *)msg {
    
}

-(void) Mesibo_OnMessageStatus:(MesiboMessage *)msg {

    NSString *str = [NSString stringWithFormat:@"Message Status: %d", [msg getStatus]];
    
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

-(BOOL) isLoggedIn {
        if(MESIBO_STATUS_ONLINE == [MesiboInstance getConnectionStatus]) return YES;
        [self alert:@"Not Logged-In" message:@"Login with a valid token first"];
        return NO;
}

- (IBAction)onSendMessage:(id)sender {
    if(![self isLoggedIn]) return;
    MesiboMessage *msg = [mProfile newMessage];
    msg.message = _mMessage.text;
    [msg send];
    _mMessage.text = @"";
    [_mMessage resignFirstResponder];
}

- (IBAction)onLaunchMessagingUIModule:(id)sender {
    if(![self isLoggedIn]) return;
    //requires pod mesibo-ui
    [MesiboUI launchMessageViewController:self profile:mProfile];
}

/* ensure to grant background mode and microphone permissions */
- (IBAction)onAudioCall:(id)sender {
    if(![self isLoggedIn]) return;
    [MesiboCallInstance callUi:self profile:mProfile video:NO];
}

- (IBAction)onVideoCall:(id)sender {
    if(![self isLoggedIn]) return;
    [MesiboCallInstance callUi:self profile:mProfile video:YES];
}

- (IBAction)updateProfile:(id)sender {
    if(![self isLoggedIn]) return;
    MesiboProfile *sp = [MesiboInstance getSelfProfile];
    [sp setName:_mName.text];
    [sp setStatus:@"I am using mesibo iOS first app"];
    [sp save];
    _mName.text = @"";
    [_mName resignFirstResponder];
}

-(void) addMembers:(MesiboProfile *)profile {
    NSMutableArray *members = [NSMutableArray new];
    [members addObject:mRemoteUser];
    
    MesiboGroupProfile *gp = [profile getGroupProfile];
    MesiboMemberPermissions *mp = [MesiboMemberPermissions new];
    mp.flags = MESIBO_MEMBERFLAG_ALL;
    mp.adminFlags = 0;
    [gp addMembers:members permissions:mp];
}

- (IBAction)createGroup:(id)sender {
    if(![self isLoggedIn]) return;
    
    MesiboGroupSettings *settings = [MesiboGroupSettings new];
    settings.name = @"My First Group";
    settings.flags = 0;
    
    [MesiboInstance createGroup:settings listener:self];
    
    //Mesibo_onGroupCreated  will be called when the group is created
   
}

-(void) Mesibo_onGroupCreated:(MesiboProfile *)profile {
    [self alert:@"New Group Created" message:[profile getName]];
    
    // add members to the group
    [self addMembers:profile];
}

-(void) Mesibo_onGroupJoined:(MesiboProfile *)groupProfile {
    
}

-(void) Mesibo_onGroupError:(MesiboProfile *)groupProfile error:(uint32_t)error {
    
}

-(void) Mesibo_onProfileUpdated:(MesiboProfile *)profile {
    [self alert:@"Profile Updated" message:[profile getName]];
}

-(BOOL) MesiboCall_onNotifyIncoming:(int)type profile:(MesiboProfile *)profile video:(BOOL)video {
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

-(void) alert:(NSString *)title message:(NSString *)message {
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];

    [self presentViewController:avc animated:YES completion:nil];

    int duration = 2;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [avc dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
