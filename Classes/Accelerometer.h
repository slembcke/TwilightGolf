#import <UIKit/UIKit.h>

#import "chipmunk.h"

@interface Accelerometer : NSObject <UIAccelerometerDelegate>

+ (void)installWithInterval:(NSTimeInterval)interval andAlpha:(float)alpha;
+ (cpVect)getChipmunkVect;

@end
