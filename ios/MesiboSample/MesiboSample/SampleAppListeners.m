//  Copyright © 2017 Mesibo. All rights reserved.

#import "SampleAppListeners.h"
#import "SampleAppWebApi.h"
#import "NSDictionary+NilObject.h"
#import "UIManager.h"
#import "UiUtils.h"

@implementation SampleAppListeners

+(SampleAppListeners *)getInstance {
    static SampleAppListeners *myInstance = nil;
    if(nil == myInstance) {
        @synchronized(self) {
            if (nil == myInstance) {
                myInstance = [[self alloc] init];
                [myInstance initialize];
            }
        }
    }
    return myInstance;
}

-(void) initialize {
    [MesiboInstance addListener:self];
    [MesiboCallInstance setListener:self];
}

-(void) Mesibo_OnMessage:(MesiboParams *)params data:(NSData *)data {    
    if([MesiboInstance isReading:params])
        return;
    
    if([data length] == 0) {
        return;
    }


    //Notify user about message
}

-(void) Mesibo_onFile:(MesiboParams *)params file:(MesiboFileInfo *)file {
    
    
}

-(void) Mesibo_onLocation:(MesiboParams *)params location:(MesiboLocation *)location {
    
}

// so that we get contact while user has started typing
-(void) Mesibo_onActivity:(MesiboParams *)params activity:(int)activity {
}

-(void) Mesibo_OnConnectionStatus:(int)status {
    
    NSLog(@"Connection status: %d", status);
    
    if (MESIBO_STATUS_SIGNOUT == status) {
        //TBD, inform user
        [UiUtils showAlert:@"You have been loggeed out from this device since you loggedin from another device." withTitle:@"Logged out"];
        
        [SampleAPIInstance logout];
        
    } else if (MESIBO_STATUS_AUTHFAIL == status) {
        [SampleAPIInstance logout];
    }
    
    if(MESIBO_STATUS_ONLINE == status) {
       
    }
}

-(BOOL) Mesibo_onUpdateUserProfiles:(MesiboUserProfile *)profile {
   
    
    return NO;
}

- (void)Mesibo_onShowProfile:(id)parent profile:(MesiboUserProfile *)profile {

}


-(void) Mesibo_onSetGroup:(id)parent profile:(MesiboUserProfile *)profile type:(int)type members:(NSArray *)members handler:(Mesibo_onSetGroupHandler)handler {
    
}

-(void) Mesibo_onGetGroup:(id)parent groupid:(uint32_t)groupid handler:(Mesibo_onSetGroupHandler)handler {
    //[SampleAPIInstance getGroup:groupid handler:handler];
}


-(NSArray *) Mesibo_onGetGroupMembers:(id)parent groupid:(uint32_t)groupid {
    return nil;
}

/** Message filtering
 * This function is called every time a message received. This function should return true if
 * message to be acceped or false to drop it
 *
 * In this example, we are using it to get contact and real-time notifications from the server (refer
 * php example). PHP sanmple code sends a special message with type '1' when new contact signs up
 * or need to send any push notification. All such messages are processed and filtered here.
 */

-(BOOL) Mesibo_OnMessageFilter:(MesiboParams *)params direction:(int)direction data:(NSData *)data {
    // using it for notifications
    if(1 != params.type)
        return YES;
    
    if(![data length])
        return NO;
    
    NSError *jsonerror = nil;
    NSMutableDictionary *returnedDict = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
    
    if (jsonerror != nil) {
        return NO;
    }
    
    if (![jsonObject isKindOfClass:[NSArray class]]) {
        //LOGD(@"its probably a dictionary");
        returnedDict = (NSMutableDictionary *)jsonObject;
    }
    
    if(!returnedDict)
        return NO;
    
    NSString *name = (NSString *)[returnedDict objectForKeyOrNil:@"name"];
    NSString *phone = (NSString *)[returnedDict objectForKeyOrNil:@"phone"];
                       
    [SampleAPIInstance addContact:name phone:phone];
    
    return NO;
    
}

/* [OPTIONAL] implement these methods if Mesibo UI is used
 * Refer to API documentation for more details
 * */
-(void) Mesibo_onForeground:(id)parent screenId:(int)screenId foreground:(BOOL)foreground {
    //userlist is in foreground
    if(foreground && 0 == screenId) {
        //notify count clear
    }
    
}


-(NSArray *) Mesibo_onGetMenu:(id)parent type:(int) type profile:(MesiboUserProfile *)profile {
    
    NSArray*btns = nil;
    
    if(type == 0) {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ic_message_white"] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0, 0, 44, 44)];
        [button setTag:0];
        
        UIButton *button1 =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button1 setImage:[UIImage imageNamed:@"ic_more_vert_white"] forState:UIControlStateNormal];
        [button1 setFrame:CGRectMake(0, 0, 44, 44)];
        [button1 setTag:1];
        
#if 0
        UIButton *button2 =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button2 setImage:[UIImage imageNamed:@"ic_favorite_border_white"] forState:UIControlStateNormal];
        [button2 setFrame:CGRectMake(0, 0, 44, 44)];
        [button2 setTag:2];
#endif
        
        btns = @[button, button1];
    } else {
        if(profile && !profile.groupid) {
            UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"ic_call_white"] forState:UIControlStateNormal];
            [button setFrame:CGRectMake(0, 0, 44, 44)];
            [button setTag:0];
            
            UIButton *vbutton =  [UIButton buttonWithType:UIButtonTypeCustom];
            [vbutton setImage:[UIImage imageNamed:@"ic_videocam_white"] forState:UIControlStateNormal];
            [vbutton setFrame:CGRectMake(0, 0, 44, 44)];
            [vbutton setTag:1];
            
            btns = @[vbutton, button];
        }
        
    }
    
    return btns;
    
}

- (BOOL)Mesibo_onMenuItemSelected:(id)parent type:(int)type profile:(MesiboUserProfile *)profile item:(int)item {
    // userlist menu are active
    if(type == 0) { // USERLIST
        if(item == 1) {   //item == 0 is reserved
            
        }
        
    } else { // MESSAGEBOX
        if(item == 0) {
            NSLog(@"Menu btn from messagebox pressed");
            [MesiboCallInstance call:parent callid:0 address:profile.address video:NO incoming:NO];
        }else if (item ==1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MesiboCallInstance call:parent callid:0 address:profile.address video:YES incoming:NO];
                
            });
        }
    }
    
    return true;
}

- (void) Mesibo_onDeleteProfile:(id)parent profile:(MesiboUserProfile *)profile handler:(Mesibo_onSetGroupHandler)handler {
}

-(BOOL) MesiboCall_onNotifyIncoming:(int)type profile:(MesiboUserProfile *)profile video:(BOOL)video {
    return YES;
}


-(void) MesiboCall_onShowViewController:(id)parent vc:(id)vc {
    [UiUtils launchVC:parent vc:vc];
}

-(void) MesiboCall_onDismissViewController:(id)vc {
    
}


@end
