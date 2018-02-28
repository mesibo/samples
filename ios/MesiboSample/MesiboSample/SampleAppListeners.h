//  Copyright © 2017 Mesibo. All rights reserved.

#import <Foundation/Foundation.h>
#import "Mesibo/Mesibo.h"
#import "MesiboCall/MesiboCall.h"

#define SampleAppListenersInstance [SampleAppListeners getInstance]


@interface SampleAppListeners : NSObject <MesiboDelegate, MesiboCallDelegate>

+(SampleAppListeners *) getInstance;

@end
