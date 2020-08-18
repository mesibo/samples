//  Copyright © 2017 Mesibo. All rights reserved.


#import "AppDelegate.h"
#import "SampleAppWebApi.h"

#import "UIManager.h"
#import "UiUtils.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <Intents/Intents.h>

#import "SampleAppConfiguration.h"
#import "SampleAppListeners.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    MesiboCall *mesiboCall;

}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    application.applicationIconBadgeNumber = 0;
    
    [GMSServices provideAPIKey:GOOGLE_MAP_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_KEY];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    [[UINavigationBar appearance] setBarTintColor:[UiUtils getColor:SAMPLEAPP_TOOLBARCOLOR]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    
    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName: [UiUtils getColor:0xffffffff],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
                                 };
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    [self MesiboInit];
    
    /** Initialize web api to communicate with your own backend servers */
    SampleAPIInstance;
    
    [self launchUI];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [MesiboInstance setAppInForeground:self screenId:0 foreground:YES];
    [MesiboCallInstance showCallInProgress];
}


- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
   
}

-(void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
}


-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler {
    
    INInteraction *interaction = userActivity.interaction;
    INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
    INPerson *contact = startAudioCallIntent.contacts[0];
    INPersonHandle *personHandle = contact.personHandle;
    NSString *phoneNum = personHandle.value;
    [MesiboCallInstance call:nil callid:0 address:phoneNum video:NO incoming:NO];
    return YES;
}


-(void) launchUI {
    
    if([[SampleAppWebApi getInstance] getToken]) {
        [SampleAPIInstance startMesibo];
        [UiUtils launchMesiboUI:self.window.rootViewController withMainWindow:self.window];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
    
    [self.window setRootViewController:vc];
    [self.window makeKeyAndVisible];
    
    
}

-(void) MesiboInit {

    /** [Optional] add listener for file transfer handler
     * you only need if you plan to send and receive files using mesibo
     * */
    _fileTranserHandler = [[SampleAppFileTransferHandler alloc] init];
    [_fileTranserHandler initialize];
    
    [MesiboInstance addListener:self];
    
    /* initialize sampleapp listner and register */
    [SampleAppListeners getInstance];
    
    /* retain an instance */
    mesiboCall = [MesiboCall sharedInstance];
    
}

@end
