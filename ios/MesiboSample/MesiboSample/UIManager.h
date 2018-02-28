
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIManagerInstance [UIManager getInstance]

@interface UIManager : NSObject


+(UIManager *)getInstance;


-(void) addProgress:(UIView *)view;
-(void) showProgress;
-(void) hideProgress;

-(BOOL) runningVersionAndAbove:(int)version;
@end
