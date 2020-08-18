//
//  MesiboSample.m
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mesibo/mesibo.h"
#import "MesiboSample.h"

@implementation MesiboSample

+(MesiboSample *)getInstance {
    static MesiboSample *myInstance = nil;
    if(nil == myInstance) {
        @synchronized(self) {
            if (nil == myInstance) {
                myInstance = [[self alloc] init];
            }
        }
    }
    return myInstance;
}

-(void) start:(NSString *) accessToken {
    [MesiboInstance setAccessToken:accessToken];
    [MesiboInstance setDatabase:@"mesibo.db" resetTables:0];
    [MesiboInstance addListener:self];
    [MesiboInstance start];
    
}

-(void) sendMessage:(NSString *)to message:(NSString *)message {
    MesiboParams *p = [MesiboParams new];
    
    p.flag = MESIBO_FLAG_DELIVERYRECEIPT | MESIBO_FLAG_READRECEIPT;
    p.expiry = 3600*24*7;
    p.peer = to;
    [MesiboInstance sendMessage:p msgid:[MesiboInstance random] string:message];
}

-(void) readStoredMessagesForUser:(NSString *)address {
    MesiboReadSession *readSession = [MesiboReadSession new];
    [readSession initSession:address groupid:0 query:nil delegate:self];
    [readSession enableSummary:NO];
    [readSession enableReadReceipt:YES];
    [readSession read:100];
}

-(void) readStoredMessagesForGroup:(uint32_t)groupId {
    MesiboReadSession *readSession = [MesiboReadSession new];
    [readSession initSession:nil groupid:groupId query:nil delegate:self];
    [readSession enableSummary:NO];
    [readSession enableReadReceipt:YES];
    [readSession read:100];
}

-(void) Mesibo_OnMessage:(MesiboParams *)params data:(NSData *)data {
    
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
        
        
    } else if (MESIBO_STATUS_AUTHFAIL == status) {
    }
    
    if(MESIBO_STATUS_ONLINE == status) {
    }
    
}


@end
