
#import "UIManager.h"
#import "UiUtils.h"

@interface UIManager() {
    UIActivityIndicatorView *mIndicator;
    int mSystemVersion;
    
}

@end

@implementation UIManager

+(UIManager *)getInstance {
    static UIManager *myInstance = nil;
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
    CGFloat width = [UIScreen mainScreen].bounds.size.width ;
    
    CGFloat height= [UIScreen mainScreen].bounds.size.height ;
    
    mIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    mIndicator.frame = CGRectMake(0.0, 0.0, width, height);
    mIndicator.layer.cornerRadius = 0;
    mIndicator.layer.masksToBounds = YES;
    mIndicator.opaque = NO;
    mIndicator.hidesWhenStopped = YES;
    mIndicator.tag = 10000;
    mIndicator.backgroundColor = [UiUtils getColor:0xffcccccc];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    mSystemVersion = [[systemVersion substringToIndex:1] intValue];
}


-(void) addProgress:(UIView *)view {
    [view addSubview:mIndicator];
    [mIndicator bringSubviewToFront:view];
    //mIndicator.center = view.center;
}

-(void) showProgress {
    [mIndicator startAnimating];
}

-(void) hideProgress {
    if(mIndicator.isAnimating)
        [mIndicator stopAnimating];
}

-(BOOL) runningVersionAndAbove:(int)version {
    if(mSystemVersion >= version)
        return YES;
    return NO;
}
@end
