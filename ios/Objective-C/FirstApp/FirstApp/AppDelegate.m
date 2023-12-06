//
//  AppDelegate.m
//  FirstApp
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import "AppDelegate.h"
#import <Intents/Intents.h>
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler {
    
    INInteraction *interaction = userActivity.interaction;
    INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
    INPerson *contact = startAudioCallIntent.contacts[0];
    INPersonHandle *personHandle = contact.personHandle;
    NSString *phoneNum = personHandle.value;
    //[CallManager sharedInstance].delegate = self;
    //[[CallManager sharedInstance] startCallWithPhoneNumber:phoneNum];
    return YES;
}


@end
