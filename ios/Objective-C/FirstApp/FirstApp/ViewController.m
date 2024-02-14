//
//  ViewController.m
//  FirstApp
//
//  Copyright © 2023 Mesibo. All rights reserved.
//

#import "ViewController.h"
#import "UIListener.h"

@interface ViewController () {
    NSString *mRemoteUser;
    MesiboProfile *mProfile;
    MesiboReadSession *mReadSession;
    
    NSDictionary *mUser1, *mUser2;
    UIListener *mUiListener;
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
    
    // Do any additional setup after loading the view.
}

-(void) mesiboInit:(NSString *)token remoteUserAddress:(NSString *)address remoteUserName:(NSString *)name {
    
    
    [MesiboInstance addListener:self];
    
    // set user authentication token obtained by creating user
    [MesiboInstance setAccessToken:token];
    [MesiboInstance setDatabase:@"mesibo"];
    [MesiboInstance start];
    
    /* OPTIONAL - initialize Messaging UI customization listener */
    mUiListener = [UIListener new];
    [MesiboUI setListener:mUiListener];
    
    /* OPTIONAL - customize various UI defaults */
    MesiboUiDefaults *defs = [MesiboUI getUiDefaults];
    defs.titleTextColor = 0xFF000000;
    defs.enableBackButton = YES;
    
    
    _mLoginUser1.enabled = NO;
    _mLoginUser2.enabled = NO;
    
    
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

-(void) Mesibo_onConnectionStatus:(NSInteger)status {
    // You will receive the connection status here
    
    NSLog(@"Connection status: %d", (int) status);
    
    NSString *str = [NSString stringWithFormat:@"Connection Status: %d", (int) status];
    
    _mConnectionStatus.text = str;
    
    if(MESIBO_STATUS_AUTHFAIL == (int) status) {
        NSString *message = [NSString stringWithFormat:@"The token is invalid. Ensure that you have used appid \"%@\" to generate Mesibo user access token", [MesiboInstance getAppIdForAccessToken]];
        
        [self alert:@"Invalid Token" message:message dismiss:NO];
    }
    
}

-(void) Mesibo_onMessage:(MesiboMessage *) msg {
    
    // A simple example of message processing
    /* Messaging documentation https://mesibo.com/documentation/api/messaging/ */
    if([msg isIncoming]) {
        /* Profile documentation https://mesibo.com/documentation/api/users-and-profiles/ */
        MesiboProfile *sender = msg.profile;
        
        /* Group Management - https://mesibo.com/documentation/api/group-management/ */
        // check if this message belongs to a group
        if([msg isGroupMessage]) {
            // the group profile
            MesiboProfile *group = msg.groupProfile;
        }
        
        // check if this message is realtime or read from the database
        if([msg isRealtimeMessage]) {
            [self alert:@"New Message" message:msg.message];
        }
        
    } else if([msg isOutgoing]) {
        
        /* messages you sent */
        
    } else if([msg isMissedCall]) {
        
    }
    
}

-(void) Mesibo_onMessageUpdate:(MesiboMessage *)msg {
    
}

-(void) Mesibo_onMessageStatus:(MesiboMessage *)msg {
    
    int messageStatuc = [msg getStatus];
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
    [self alert:@"Not Logged In" message:@"Login with a valid token first"];
    return NO;
}

- (IBAction)onSendMessage:(id)sender {
    if(![self isLoggedIn]) return;
    MesiboMessage *msg = [mProfile newMessage];
    msg.message = @"Hello from iOS, Objective-C";
    [msg send];
}

- (IBAction)onSetProfile:(id)sender {
    if(![self isLoggedIn]) return;
    MesiboProfile *sp = [MesiboInstance getSelfProfile];
    [sp setName:@"Joe from iOS"];
    [sp setString:@"status" value:@"I am using mesibo iOS first app"];
    [sp save];
}


- (IBAction)onShowUsersList:(id)sender {
    if(![self isLoggedIn]) return;
    
    MesiboUserListScreenOptions *opts = [MesiboUserListScreenOptions new];
    [MesiboUI launchUserList:self opts:opts];
}

- (IBAction)onShowMessages:(id)sender {
    if(![self isLoggedIn]) return;
    
    //requires pod mesibo-ui
    MesiboMessageScreenOptions *opts = [MesiboMessageScreenOptions new];
    opts.profile = mProfile;
    opts.navigation = YES;
    [MesiboUI launchMessaging:self opts:opts];
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
- (IBAction)onGroupCall:(id)sender {
    if(![self isLoggedIn]) return;
    
    int groupId = 0; // set appropriate groupId
    
    if(!groupId) return;
    
    MesiboProfile *groupProfile = [MesiboInstance getGroupProfile:groupId];
    
    [MesiboCallInstance groupCallUi:self profile:groupProfile video:YES audio:YES videoMute:YES audioMute:YES publish:YES];
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
    
    //Mesibo_onGroupCreated  will be invoked when the group is created
    
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

- (IBAction)onPhoneContactsSync:(id)sender {
    if(![self isLoggedIn]) return;
    [[MesiboInstance getPhoneContactsManager] start];
}

- (IBAction)onPhoneNumberInfo:(id)sender {
    if(![self isLoggedIn]) return;
    MesiboPhoneContact *contact = [[MesiboInstance getPhoneContactsManager] getPhoneNumberInfo:@"+18005551234" code:nil format:YES];
    
    NSString *name = contact.name;
    NSString *phone = contact.formattedPhoneNumber;
    NSString *country = contact.country;
}


-(void) alert:(NSString *)title message:(NSString *)message dismiss:(BOOL)dismiss{
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    [self presentViewController:avc animated:YES completion:nil];
    
    if(!dismiss) return;
    
    int duration = 2;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [avc dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void) alert:(NSString *)title message:(NSString *)message {
    [self alert:title message:message dismiss:YES];
}

@end
