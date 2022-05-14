#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>

@implementation AppDelegate {
    FlutterMethodChannel *channel;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
    FlutterViewController *vc = self.window.rootViewController;
        
   //FlutterBinaryMessenger *bm =(FlutterBinaryMessenger *)vc;
    
    MesiboPluginMesiboPluginApiSetup(vc, self);
    channel = [FlutterMethodChannel methodChannelWithName:@"mesibo.com/callbacks" binaryMessenger:vc];
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (void)setupToken:(nonnull NSString *)token error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    [MesiboInstance addListener:self];

        // set user authentication token obtained by creating user
    [MesiboInstance setAccessToken:token];
    [MesiboInstance setDatabase:@"mesibo" resetTables:0];
    [MesiboInstance start];
    
    [MesiboCall startWith:nil name:@"mesibo first App" icon:nil callKit:NO];

}

- (void)showMessagesPeer:(nonnull NSString *)peer error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    MesiboProfile *profile = [MesiboInstance getProfile:peer groupid:0];
    
    FlutterViewController *vc = self.window.rootViewController;
    
    [MesiboUI launchMessageViewControllerWithNavigation:vc profile:profile uidelegate:nil];
}

- (void)showUserListWithError:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    FlutterViewController *vc = self.window.rootViewController;
    
    [MesiboUI launchMesiboUIViewController:vc uidelegate:nil back:YES];
}

- (void)audioCallPeer:(nonnull NSString *)peer error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    FlutterViewController *vc = self.window.rootViewController;
    
    [MesiboCallInstance callUi:vc address:peer video:NO];
}

- (void)videoCallPeer:(nonnull NSString *)peer error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    FlutterViewController *vc = self.window.rootViewController;
    
    [MesiboCallInstance callUi:vc address:peer video:YES];
}

- (void)sendMessagePeer:(nonnull NSString *)peer message:(nonnull NSString *)message error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
}


-(void) invokeCallback:(NSString *)name args:(id) args {
    [channel invokeMethod:name arguments:args];
}

-(void) Mesibo_OnConnectionStatus:(int)status {
    // You will receive the connection status here

    NSMutableDictionary *args = [NSMutableDictionary new];
    [args setObject:[NSNumber numberWithInt:status] forKey:@"status"];
    
    [self invokeCallback:@"Mesibo_onConnectionStatus" args:args];
    
    NSLog(@"Connection status: %d", status);

    NSString *str = [NSString stringWithFormat:@"Connection Status: %d", status];

    //_mConnectionStatus.text = str;

}

-(void) Mesibo_OnMessage:(MesiboParams *)params data:(NSData *)data {

    // You will receive messages here
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    

}

-(void) Mesibo_OnMessage:(MesiboMessage *)message {

}

-(void) Mesibo_OnMessageStatus:(MesiboParams *)params {

}


@end
