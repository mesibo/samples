#import "NSDictionary+NilObject.h"

@implementation NSDictionary (NilObject)

-(id) objectForKeyOrNil:(id)aKey {
    id object = [self objectForKey:aKey];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}
@end

