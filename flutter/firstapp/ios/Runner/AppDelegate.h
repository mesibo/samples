#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "../Classes/MesiboPlugin.h"
#import <Mesibo/Mesibo.h>
#import "MesiboUi/MesiboUi.h"
#import "MesiboCall/MesiboCall.h"

@interface AppDelegate : FlutterAppDelegate <MesiboPluginMesiboPluginApi, MesiboDelegate, MesiboCallIncomingListener>

@end
