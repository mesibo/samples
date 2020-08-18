//  Copyright © 2016 Mesibo. All rights reserved.

#import "SampleAppWebApi.h"
#import "Mesibo/Mesibo.h"
#import "NSDictionary+NilObject.h"
#import "SampleAppListeners.h"


#import "SampleAppConfiguration.h"

#define KEY_TOKEN @"token"

/**
 * Web API to communicate with your own backend server(s).
 * Note - in this example, we are not authenticating. In real app, you should authenticate user first
 * using email or phone OTP.
 *
 * When user is successfully authenticated, your server should create a mesibo auth token using
 * mesibo server side api and send it back here.
 *
 * Refer to PHP server api for code sample.
 */


@interface SampleAppWebApi ( /* class extension */ )
{
    NSUserDefaults *mUserDefaults;
    NSString *mToken;
}

@end

@implementation SampleAppWebApi

+(SampleAppWebApi *)getInstance {
    static SampleAppWebApi *myInstance = nil;
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

-(void)initialize {

    mUserDefaults = [NSUserDefaults standardUserDefaults];
    mToken = [mUserDefaults objectForKey:KEY_TOKEN];
}

/**
 * Start mesibo only after you have a user access token
 */
-(void) startMesibo {

    
    [SampleAppListeners getInstance]; // will initiallize and register listener
     // early initialize for reverse lookup
    
    /** set path for storing db and other files */
    NSString *appdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [MesiboInstance setPath:appdir];
    
    /** set user access token  */
    [MesiboInstance setAccessToken:[SampleAPIInstance getToken]];
    
    /** [OPTIONAL] set up database to save and restore messages
     * Note: if you call this API before setting an access token, mesibo will
     * create a database exactly as you named it. However, if you call it
     * after setting Access Token like in this example, it will be uniquely
     * named for each user [Preferred].
     * */
    [MesiboInstance setDatabase:@"sampleapp.db" resetTables:0];
    
    /** [Optional] enable to disable secure connection */
    [MesiboInstance setSecureConnection:YES];
    
    /** start mesibo */
    [MesiboInstance start];
    
    /** start mesibo call */
    [MesiboCallInstance start];
    
}



-(NSString *) getToken {
    if([SampleAppWebApi isEmpty:mToken])
        return nil;
    
    return mToken;
}

-(NSString *) getApiUrl {
    return SAMPLEAPP_API_URL;
}


-(void)save {
    [mUserDefaults setObject:mToken forKey:@"token"];
    [mUserDefaults synchronize];
}


-(BOOL) parseResponse:(NSString *)response request:(NSDictionary*)request handler:(SampleAPI_onResponse) handler {
    NSMutableDictionary *returnedDict = nil;
    NSString *op = nil;
    int result = SAMPLEAPP_RESULT_FAIL;
    
    NSError *jsonerror = nil;
    
    //MUST not happen
    if(nil == response)
        return YES;
    
    //LOGD(@"Data %@", [NSString stringWithUTF8String:(const char *)[data bytes]]);
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
    
    if (jsonerror != nil) {
        if(nil != handler)
            handler(result, nil);
        return YES;
    }
    
    returnedDict = (NSMutableDictionary *)jsonObject;
    
    if(nil == returnedDict) {
        if(nil != handler)
            handler(result, nil);
        
        return YES;
        
    }
    
    op = (NSString *)[returnedDict objectForKeyOrNil:@"op"];
    NSString *res = (NSString *)[returnedDict objectForKeyOrNil:@"result"];
    if([res isEqualToString:@"OK"]) {
        result = SAMPLEAPP_RESULT_OK;
    } else {
        NSString *error = (NSString *)[returnedDict objectForKeyOrNil:@"error"];
        if([error isEqualToString:@"AUTHFAIL"]) {
            result = SAMPLEAPP_RESULT_AUTHFAIL;
            [self logout];
            return NO;
        }
    }
    
    if(SAMPLEAPP_RESULT_OK != result) {
        if(nil != handler)
            handler(result, returnedDict);
        return NO;
    }
    
    if([op isEqualToString:@"login"]) {
        mToken = (NSString *)[returnedDict objectForKeyOrNil:@"token"];
        
        
        if(![SampleAppWebApi isEmpty:mToken]) {
            [self save];
            
            [MesiboInstance reset];
            
            [self startMesibo];
            
            [self createContacts:returnedDict];
        }
        
    }
    
    if(handler)
        handler(result, returnedDict);
    
    return YES;
    
}


-(void) invokeApi:(NSDictionary *)post filePath:(NSString *)filePath handler:(SampleAPI_onResponse) handler {
    
    
    Mesibo_onHTTPProgress progressHandler = ^BOOL(MesiboHttp *http, int state, int progress) {
        
        if(100 == progress && state == MESIBO_HTTPSTATE_DOWNLOAD) {
            [self parseResponse:[http getDataString] request:post handler:handler];
        }
        
        if(progress < 0) {
            NSLog(@"invokeAPI failed");
            // 100 % progress will be handled by parseResponse
            if(nil != handler) {
                handler(SAMPLEAPP_RESULT_FAIL, nil);
            }
        }
        
        
        return YES;
        
    };
    
    MesiboHttp *http = [MesiboHttp new];
    http.url = SAMPLEAPP_API_URL;
    http.postBundle = post;
    http.uploadFile = filePath;
    http.uploadFileField = @"photo";
    http.listener = progressHandler;
    
    if(![http execute]) {
        
    }
}

+(BOOL) equals:(NSString *)s old:(NSString *)old {
    int sempty = (int) [s length];
    int dempty = (int) [old length];
    if(sempty != dempty) return NO;
    if(!sempty) return YES;
    
    return ([s caseInsensitiveCompare:old] == NSOrderedSame);
}

+(BOOL) isEmpty:(NSString *)string {
    if(/*[NSNull null] == string ||*/ nil == string || 0 == [string length])
        return YES;
    return NO;
}


-(void) createContacts:(NSDictionary *)response {
    NSArray *contacts = [response objectForKeyOrNil:@"contacts"];
    
    if(!contacts) return;
    
    for(int i=0; i < contacts.count; i++) {
        NSDictionary *c = [contacts objectAtIndex:i];
        
        NSString *name = [c objectForKeyOrNil:@"name"];
        NSString *phone = [c objectForKeyOrNil:@"phone"];
        
        [self addContact:name phone:phone];
    }
}

-(void) addContact:(NSString *)name phone:(NSString *)phone {
    if([SampleAppWebApi isEmpty:phone]) {
        return;
    }
    
    MesiboUserProfile *u = [[MesiboUserProfile alloc] init];
    
    if([SampleAppWebApi isEmpty:name]) {
        name = phone;
    }
    
    u.name = name;
    u.address = phone;
    
    [MesiboInstance setProfile:u refresh:NO];
    
}

-(void) logout {
    
    [MesiboInstance stop];
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setValue:@"logout" forKey:@"op"];
    
    //even if token value is wrong, logout will happen due to AUTHFAIL
    [post setValue:mToken forKey:@"token"];
    
    [self invokeApi:post filePath:nil handler:nil];
    
    mToken = @"";
    [self save];
    [MesiboInstance reset];
    
}

-(void) login:(NSString *)name phone:(NSString *)phone handler:(SampleAPI_onResponse) handler {
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setValue:@"login" forKey:@"op"];
    if(name)
        [post setValue:name forKey:@"name"];
    [post setValue:phone forKey:@"phone"];
    
    [post setValue:SAMPLEAPP_NAMESPACE forKey:@"ns"];
    
    NSString *packageName = [[NSBundle mainBundle] bundleIdentifier];
    [post setValue:packageName forKey:@"aid"];
    
    [self invokeApi:post filePath:nil handler:handler];
}

-(void) resetDB {
    [MesiboInstance resetDatabase:MESIBO_DBTABLE_ALL];
}


@end
