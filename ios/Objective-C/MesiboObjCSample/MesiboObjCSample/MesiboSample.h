//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mesibo/Mesibo.h"


@interface MesiboSample : NSObject <MesiboDelegate>

+(MesiboSample *) getInstance;
-(void) start:(NSString *) accessToken;
-(void) sendMessage:(NSString *)to message:(NSString *)message;
-(void) readStoredMessagesForUser:(NSString *)address;
-(void) readStoredMessagesForGroup:(uint32_t )groupId;

@end
