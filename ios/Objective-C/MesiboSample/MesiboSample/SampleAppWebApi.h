//  Copyright © 2018 Mesibo. All rights reserved.


#import <Foundation/Foundation.h>
#import "Mesibo/Mesibo.h"
#import "MesiboCall/MesiboCall.h"


@interface SampleAppWebApiResponse : NSObject
@property (nonatomic) NSString *result;
@property (nonatomic) NSString *op;
@property (nonatomic) NSString *error;
@property (nonatomic) NSString *token;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *photo;
@property (nonatomic) NSString *invite;
@property (nonatomic) uint32_t gid;
@property (nonatomic) int type;
@end

#define SAMPLEAPP_RESULT_OK         0
#define SAMPLEAPP_RESULT_FAIL       1
#define SAMPLEAPP_RESULT_AUTHFAIL   2


typedef void (^SampleAPI_onResponse)(int result, NSDictionary *response);

#define SampleAPIInstance [SampleAppWebApi getInstance]

@interface SampleAppWebApi : NSObject

+(SampleAppWebApi *) getInstance;

-(void) initialize;
-(NSString *) getToken;
-(NSString *) getApiUrl;

-(void) startMesibo;

-(void) resetDB;
-(void) logout;
-(void) login:(NSString *)name phone:(NSString *)phone handler:(SampleAPI_onResponse) handler;

-(void) addContact:(NSString *)name phone:(NSString *)phone;


+(BOOL) isEmpty:(NSString *)string; //utility
+(BOOL) equals:(NSString *)s old:(NSString *)old;

@end
