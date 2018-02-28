//
//  ImagePickerHelper.h
//  Social
//
//  Created by Mesibo on 13/05/16.
//  Copyright © 2016 _TringMe_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#define PICK_CAMERA_IMAGE 0
#define PICK_IMAGE_GALLERY 1
#define PICK_VIDEO_GALLERY 2
#define PICK_VIDEO_RECORDING 3
#define PICK_AUDIO_FILES 4
#define PICK_LOCATION 5
#define PICK_DOCUMENTS 6
#define PICK_FACEBOOK_IMAGES 7


typedef BOOL (^MesiboImageEditorBlock)(UIImage *image, NSString *caption);
typedef void (^MesiboMediaFilesBlock)(UIImage *image);

@interface ImagePickerFile : NSObject

@property (atomic) NSString *filePath;
@property (atomic) NSString *mp4Path;
@property (strong,nonatomic) UIImage *image;
@property (atomic) NSString *message;
@property (atomic) NSString *title;
@property (atomic) int fileType;
@property (atomic) int mp4state;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic) int zoom;
@property (nonatomic) int size;
@property (nonatomic) NSString *url;
@property (nonatomic) id phasset;
@property (atomic) NSString *localIdentifier;
@property (nonatomic) void (^mp4TranscodingHandler)(ImagePickerFile * file);

-(void) setMp4TranscodingHandler:(void (^)(ImagePickerFile *))handler;
-(void) setMp4Ready:(BOOL)ready;
@end

@interface AlbumsData : NSObject

@property (strong , nonatomic) NSString* mAlbumID;
@property (strong , nonatomic) NSString* mAlbumProfilePicPath;
@property (strong , nonatomic) NSString* mAlbumName;
@property (assign , nonatomic) NSInteger mAlbumPhotoCount;
@property (strong , nonatomic) NSMutableArray* mPhotoGList; // Array of photoData

@end

@interface PhotoData : NSObject

@property NSString *mDateCreated;
@property NSString *mId;
@property NSString *mIconPath;
@property NSString *mSourcePath;

@end




@interface ImagePicker : NSObject
{
    void (^_completionHandler)(ImagePickerFile * file);
    
}


@property (strong ,nonatomic) UIViewController * mParent;
//@property (strong, nonatomic) NSMutableArray  *mAlbumListed;



-(void)pickMedia:(int) PICK_MEDIA :(void(^)(ImagePickerFile *file))handler ;


-(void)getImageEditor:(UIImage *) image  title:(NSString*)title hideEditControl:(BOOL)hideControls showCaption:(BOOL)showCaption showCropOverlay:(BOOL)showCropOverlay squareCrop:(BOOL)squareCrop maxDimension:(int) maxDimension withBlock: (MesiboImageEditorBlock)handler;

+ (ImagePicker *)sharedInstance;

-(void) showPhotoInViewer:(UIViewController *)presentController withImage : (UIImage*) photoImage withTitle:(NSString*) title;

-(void) showMediaFiles : (UIViewController *)presentController withMediaData :(NSArray *) data withTitle:(NSString*) title;

-(void) callBackFromFacebook:(UIImage*) imageFacebook;

-(void) showMediaFilesInViewer:(UIViewController *)presentController withInitialIndex:(int)index withData : (NSArray*) filesArray withTitle:(NSString*) title;

+(void) showFile:(UIViewController *)parent path:(NSString *)path title:(NSString *)title type:(int)type;
@end
