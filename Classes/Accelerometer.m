#import "Accelerometer.h"

@implementation Accelerometer

static Accelerometer *shared_instance = nil;
static float alpha = 1.0f;
static float x = 0.0f;
static float y = 0.0f;
static float z = 0.0f;

+ (void)initialize {
	static bool done = FALSE;
	if(!done){
		NSLog(@"Creating shared accelerometer");
		shared_instance = [[self alloc] init];
		
		done = TRUE;
	}
}

+ (void)installWithInterval:(NSTimeInterval)interval andAlpha:(float)alphaValue {
	NSLog(@"Installing accelerometer delegate");
	alpha = alphaValue;
	
	UIAccelerometer *meter = [UIAccelerometer sharedAccelerometer];
	meter.delegate = shared_instance;
	meter.updateInterval = interval;
}

+ (cpVect)getChipmunkVect {
	return cpv(x, y);
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)accel {
	x = x*(1.0f - alpha) + accel.x*alpha;
	y = y*(1.0f - alpha) + accel.y*alpha;
	z = z*(1.0f - alpha) + accel.z*alpha;
}

@end

cpVect
GetAcceleration()
{
	cpVect v = [Accelerometer getChipmunkVect];
	if(v.x == 0.0f && v.y == 0.0f)
		v = cpv(-1, 0);
	
	
	return cpv(-v.y, v.x);
}