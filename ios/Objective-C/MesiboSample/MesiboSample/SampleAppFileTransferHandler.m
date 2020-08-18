//  Copyright © 2016 Mesibo. All rights reserved.


#import "SampleAppFileTransferHandler.h"
#import "SampleAppWebApi.h"
#import <Photos/Photos.h>

/** Mesibo allows you to used your own servers for file transfer so that there are no arbitrary limitations
 *
 * All you have to do is to
 * 1) create a listner and register with mesibo which will assist mesibo in uploading and downloading file.
 * 2) Mesibo will invoke listener with file path every time it need to upload a file. This listener will upload
 * and let mesibo know about the URL it was uploaded to so that it can be downloaded by recipients as
 * and when requires
 * 3) In case of download, mesibo will invoke listener with URL of the file.
 *
 * We are using Mesibo HTTP API in this example. You can use any HTTP API but you will find many
 * advantage in using Mesibo HTTP API, especially transfer speed, simplicity and cross-platform (same API for
 * both Android and iOS)
 */

@implementation SampleAppFileTransferHandler

- (void) initialize {
    [MesiboInstance addListener:self];
}

-(BOOL) uploadFile:(MesiboFileInfo *)file {
    
    /* [OPTIONAL] check the required network connectivity for automatic or manual file download */
    if(MESIBO_CONNECTIVITY_WIFI != [MesiboInstance getNetworkConnectivity] && !file.userInteraction)
        return NO;
    
    //TBD, check max file size
    MesiboParams *params = [file getParams];
    
    /* [OPTIONAL] any POST data to send with the file */
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:@"upload" forKey:@"op"];
    [post setValue:[SampleAPIInstance getToken] forKey:@"token"];
    [post setValue:[@(params.mid) stringValue] forKey:@"mid"];
    
    Mesibo_onHTTPProgress handler = ^BOOL(MesiboHttp *http, int state, int progress) {
        
        int status = [file getStatus];

        /* If the transfer was failed earlier - reset it */
        if(MESIBO_FILESTATUS_RETRYLATER != status) {
            status = MESIBO_FILESTATUS_INPROGRESS;
            if(progress < 0)
                status = MESIBO_FILESTATUS_FAILED;
        }
        
        if(100 == progress && MESIBO_HTTPSTATE_DOWNLOAD == state) {
            NSError *jsonerror = nil;
            //uint64_t elapsed = [MesiboInstance getTimestamp] - http.ts;
            //NSLog(@"uploaded in: %@" , elapsed);
            
            NSData *data = [[http getDataString] dataUsingEncoding:NSUTF8StringEncoding];
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            NSDictionary *returnedDict = (NSMutableDictionary *)jsonObject;
            NSString *fileUrl =  [returnedDict valueForKey:@"file"];
            
            if(fileUrl)
                [file setUrl:fileUrl];
            else {
                progress = -1;
                status = MESIBO_FILESTATUS_FAILED;
            }
        }
        
        if(progress < 100 || (100 == progress && MESIBO_HTTPSTATE_DOWNLOAD == state))
           [MesiboInstance updateFileTransferProgress:file progress:progress status:status];
        
        return ((100 == progress && MESIBO_HTTPSTATE_DOWNLOAD == state) || MESIBO_FILESTATUS_RETRYLATER != status);
    };
    
    MesiboHttp *http = [MesiboHttp new];
    http.url = [SampleAPIInstance getApiUrl];
    http.uploadPhAsset = file.asset;
    http.uploadLocalIdentifier = file.localIdentifier;
    http.uploadFile = [file getPath];
    http.postBundle = post;
    http.uploadFileField = @"photo";
    http.listener =  handler;
    [file setFileTransferContext:http];

    return [http execute];
}

-(BOOL) downloadFile:(MesiboFileInfo *)file {
    NSString *url = [file getUrl];
    
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        url = [@"https://mesibo.com/samplefiles/" stringByAppendingString:url];
    }
    
    Mesibo_onHTTPProgress handler = ^BOOL(MesiboHttp *http, int state, int progress) {
        
        int status = [file getStatus];
        
        if(MESIBO_FILESTATUS_RETRYLATER != status) {
            status = MESIBO_FILESTATUS_INPROGRESS;
            if(progress < 0)
                status = MESIBO_FILESTATUS_FAILED;
        }
        
        [MesiboInstance updateFileTransferProgress:file progress:progress status:status];
        
        return (100 == progress || MESIBO_FILESTATUS_RETRYLATER != status);
    };
    
    MesiboHttp *http = [MesiboHttp new];
    http.url = url;
    http.downloadFile = [file getPath];
    http.resume = YES;
    http.listener =  handler;
    [file setFileTransferContext:http];
    return [http execute];
    
}

/** This function is called when mesibo need to transfer (upload or download) a file.
 * All you have to do is to
 * 1) upload or download file as requested in file.mode
 * 2) In case of upload, if upload is successful, set the URL of the uploaded file which will
 * be sent to receiver
 */
-(BOOL) Mesibo_onStartFileTransfer:(MesiboFileInfo *)file {
    
    if(MESIBO_FILEMODE_DOWNLOAD == file.mode) {
        return [self downloadFile:file];
    }
    
    return [self uploadFile:file];
}

/** This function is called when mesibo need to abort a file transfer.
 */
-(BOOL) Mesibo_onStopFileTransfer:(MesiboFileInfo *)file {
    MesiboHttp *http = [file getFileTransferContext];
    if(http) {
        [http cancel];
    }
    return YES;
}

@end
