//
//  ViewController.m
//  FirstApp
//
//  Copyright © 2026 Mesibo. All rights reserved.
//
//  This demo application implements real-time messaging, calls, and conferencing in an iOS
//  application. Please refer to the tutorial for details on getting started and obtaining the
//  user tokens:
//
//  https://docs.mesibo.com/tutorials/get-started/
//

#import "ViewController.h"
#import "UIListener.h"

/*************************************************************************************************
 Set the tokens of the two users here: create the users in the mesibo console with the addresses
 below and the App ID com.mesibo.firstapp (the bundle id of this app), and copy their tokens.
 Install the app on two devices, and log in as User-1 on one and as User-2 on the other.
 *************************************************************************************************/
static NSString * const USER1_TOKEN = @"<token-1>";
static NSString * const USER1_ADDRESS = @"123";
static NSString * const USER2_TOKEN = @"<token-2>";
static NSString * const USER2_ADDRESS = @"456";

#define TUTORIAL_URL @"https://docs.mesibo.com/tutorials/get-started/"


#pragma mark - welcome screen

/* What this demo does and what to do before using it; shown until the tokens are set. */
@interface WelcomeViewController : UIViewController
@end

@implementation WelcomeViewController

- (UILabel *)label:(NSString *)text size:(CGFloat)size bold:(BOOL)bold {
    UILabel *label = [UILabel new];
    label.text = text;
    label.numberOfLines = 0;
    label.textColor = UIColor.labelColor;
    label.font = bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // the tutorial link
    UIButton *tutorialLink = [UIButton buttonWithType:UIButtonTypeSystem];
    [tutorialLink setTitle:TUTORIAL_URL forState:UIControlStateNormal];
    tutorialLink.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    tutorialLink.titleLabel.font = [UIFont systemFontOfSize:16];
    [tutorialLink addTarget:self action:@selector(onTutorial) forControlEvents:UIControlEventTouchUpInside];

    UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [continueButton addTarget:self action:@selector(onContinue) forControlEvents:UIControlEventTouchUpInside];

    // the texts, the link and the button, top to bottom
    UILabel *tutorialLabel = [self label:@"Refer to the tutorial for instructions:" size:16 bold:NO];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self label:@"Welcome to your first mesibo app" size:24 bold:YES],
        [self label:@"This demo shows you how to add messaging, voice and video calls to your apps in just a few lines of code." size:16 bold:NO],
        [self label:@"To use this demo, log in to the mesibo console, create two users, set their tokens in ViewController, and run the app on two phones." size:16 bold:NO],
        tutorialLabel,
        tutorialLink,
        continueButton]];

    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    [stack setCustomSpacing:4 afterView:tutorialLabel];
    [stack setCustomSpacing:32 afterView:tutorialLink];

    // scrollable, for small screens and large text sizes
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stack];
    [self.view addSubview:scrollView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:40],
        [stack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [stack.leadingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.trailingAnchor constant:-24],
    ]];
}

- (void)onTutorial {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:TUTORIAL_URL] options:@{} completionHandler:nil];
}

- (void)onContinue {
    // nothing to do in the demo without the tokens
    if (![ViewController areTokensSet]) {
        [MesiboDialogs alert:self title:@"Tokens not set"
                     message:@"You have not set the tokens in the code yet. Set USER1_TOKEN and USER2_TOKEN in ViewController, and run the app again."];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


#pragma mark - demo screen

@interface ViewController () {
    NSString *mRemoteUser;
    MesiboProfile *mProfile;
    MesiboReadSession *mReadSession;
    UIListener *mUiListener;
    BOOL mWelcomeShown;
}

@end

@implementation ViewController

+ (BOOL)areTokensSet {
    return ![USER1_TOKEN hasPrefix:@"<"] && ![USER2_TOKEN hasPrefix:@"<"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // what to do before using the demo
    if (!mWelcomeShown && ![ViewController areTokensSet]) {
        mWelcomeShown = YES;

        WelcomeViewController *welcome = [WelcomeViewController new];
        welcome.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:welcome animated:NO completion:nil];
    }
}

-(void) mesiboInit:(NSString *)token remoteUserAddress:(NSString *)address {
    if (![ViewController areTokensSet]) {
        [self alert:@"Tokens not set" message:@"Set USER1_TOKEN and USER2_TOKEN in ViewController first" dismiss:NO];
        return;
    }

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
    defs.toolbarTextColor = 0xFF000000;
    defs.enableBackButton = YES;
    
    
    _mLoginUser1.enabled = NO;
    _mLoginUser2.enabled = NO;
    
    
    // save address for sending messages
    mRemoteUser = address;
    
    //set profile which is required by UI
    mProfile = [MesiboInstance getProfile:address groupid:0];
    
    
    //OPTIONAL, initialize calls
    // self: incoming calls go to the MesiboCallIncomingListener methods below
    [MesiboCall startWith:self name:@"mesibo first App" icon:nil callKit:YES];
    
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
        NSLog(@"Message from %@", [sender getNameOrAddress]);
        
        /* Group Management - https://mesibo.com/documentation/api/group-management/ */
        // check if this message belongs to a group
        if([msg isGroupMessage]) {
            // the group profile
            MesiboProfile *group = msg.groupProfile;
            NSLog(@"in the group %@", [group getName]);
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
    
    int messageStatus = [msg getStatus];
    NSLog(@"Message %llu status: %d", msg.mid, messageStatus);
}

// login as User-1 and send messages/calls to User-2
- (IBAction)onLoginUser1:(id)sender {
    [self mesiboInit:USER1_TOKEN remoteUserAddress:USER2_ADDRESS];
}

// login as User-2 and send messages/calls to User-1
- (IBAction)onLoginUser2:(id)sender {
    [self mesiboInit:USER2_TOKEN remoteUserAddress:USER1_ADDRESS];
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
    
    // pushed when this screen is in a navigation controller, else presented
    MesiboMessageScreenOptions *opts = [MesiboMessageScreenOptions new];
    opts.profile = mProfile;
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

#pragma mark - MesiboCallIncomingListener

/** an incoming call: return its properties (customize them here), or nil to reject it */
-(MesiboCallProperties *) MesiboCall_OnIncoming:(MesiboProfile *)profile video:(BOOL)video waiting:(BOOL)waiting {
    return [MesiboCallInstance createCallProperties:video];
}

/** return YES to show your own call screen instead of mesibo's */
-(BOOL) MesiboCall_OnShowUserInterface:(id)call properties:(MesiboCallProperties *)cp {
    return NO;
}

/** a call notification (e.g. MESIBOCALL_NOTIFY_MISSED); return YES to show the default one */
-(BOOL) MesiboCall_OnNotify:(int)type profile:(MesiboProfile *)profile video:(BOOL)video ts:(MesiboDateTime *)ts {
    return YES;
}

-(void) MesiboCall_OnError:(MesiboCallProperties *)cp error:(int)error {
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
    NSLog(@"Phone number info: %@, %@, %@", name, phone, country);
}

-(void) initLocation {
    MesiboLocationConfig *locationConfig = [MesiboLocationConfig new];
    locationConfig.minDistance = 250;
    
    MesiboLocationManager *locationMager = [MesiboLocationManager getInstance];
    [locationMager addListener:self];
    [locationMager start:locationConfig];
}

-(void) getLocation {
    MesiboProfileLocation *profileLocation = [mProfile location];
    MesiboLocation *location = [profileLocation get];
    NSLog(@"Location of %@: %f, %f", [mProfile getNameOrAddress], location.latitude, location.longitude);
}

#pragma mark - MesiboLocationListener

-(void) Mesibo_onDeviceLocation:(MesiboLocation *)location {
    NSLog(@"Device location: %f, %f", location.latitude, location.longitude);
}

-(void) Mesibo_onLocationReceived:(MesiboProfile *)profile {
    NSLog(@"Location received from %@", [profile getNameOrAddress]);
}

-(void) Mesibo_onLocationRequest:(MesiboProfile *)profile duration:(uint32_t)duration {
    NSLog(@"%@ requests your location for %u seconds", [profile getNameOrAddress], duration);
}

-(void) Mesibo_onLocationShared:(MesiboProfile *)profile duration:(uint32_t)duration {
    NSLog(@"%@ shares their location for %u seconds", [profile getNameOrAddress], duration);
}

-(void) Mesibo_onLocationError:(MesiboProfile *)profile error:(int)error {
    NSLog(@"Location error %d for %@", error, [profile getNameOrAddress]);
}

-(void) searchLocation {
    MesiboProfileSearch *profileSearch = [MesiboProfileSearch new];
    [profileSearch setListener:self];
    [profileSearch setDistance:1000];
    [profileSearch setMaxAge:3600];
    [profileSearch search];
}

#pragma mark - MesiboProfileSearchListener

-(void) Mesibo_onProfileSearchResults:(NSArray<MesiboProfile *> *)profiles search:(MesiboProfileSearch *)search {
    NSLog(@"Profiles nearby: %lu", (unsigned long)profiles.count);
}

-(void) Mesibo_onProfileSearchUpdate:(NSArray<MesiboProfile *> *)profiles search:(MesiboProfileSearch *)search {
    NSLog(@"Profiles nearby changed: %lu", (unsigned long)profiles.count);
}


-(void) alert:(NSString *)title message:(NSString *)message dismiss:(BOOL)dismiss {
    // an alert, not an action sheet: an action sheet needs an anchor on iPad
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    // one that does not close itself needs a button to close it
    if(!dismiss)
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];

    if(!dismiss) return;

    // closes itself after 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void) alert:(NSString *)title message:(NSString *)message {
    [self alert:title message:message dismiss:YES];
}

@end
