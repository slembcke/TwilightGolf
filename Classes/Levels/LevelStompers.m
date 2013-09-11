#import "LevelStateDelegate.h"

@implementation LevelStompers

- (void)addFlail:(cpVect)pos {
	cpVect posUnflipped = pos;
	pos.y = 320.0f - pos.y;
	
	ChipmunkBody *rotator = [self addGearStone:posUnflipped];
	
	ChipmunkSimpleMotor *motor = [[ChipmunkSimpleMotor alloc] initWithBodyA:rotator bodyB:staticBody rate:5.0f];
	motor.maxForce = 5000000.0f;
	[space addObject:motor]; [motor release];
	
	ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:rotator bodyB:staticBody pivot:pos];
	[space addObject:pivot]; [pivot release];
	
	cpFloat flailLength = 60.0f;
	cpFloat flailAnchr1Off = 12.0f;
	cpFloat flailAnchr2Off = 20.0f;
	
	cpVect flail1Pos = [rotator local2world:cpv(0, -flailLength)];
	flail1Pos.y = 320.0f - flail1Pos.y;
	ChipmunkBody *flail1 = [self addSmallBox:flail1Pos];
	ChipmunkSlideJoint *slide1 = [[ChipmunkSlideJoint alloc] initWithBodyA:flail1 bodyB:rotator anchr1:cpv(0,  flailAnchr1Off) anchr2:cpv(0, -flailAnchr2Off) min:0.0f max:40.0f];
	[space addObject:slide1]; [slide1 release];
	
	cpVect flail2Pos = [rotator local2world:cpv(0,  flailLength)];
	flail2Pos.y = 320.0f - flail2Pos.y;
	ChipmunkBody *flail2 = [self addSmallBox:flail2Pos];
	ChipmunkSlideJoint *slide2 = [[ChipmunkSlideJoint alloc] initWithBodyA:flail2 bodyB:rotator anchr1:cpv(0, -flailAnchr1Off) anchr2:cpv(0,  flailAnchr2Off) min:0.0f max:40.0f];
	[space addObject:slide2]; [slide2 release];
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.1f;
		
		
//		int polylines[] = {
//			-1,-1,
//		};
//		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"temp"];
		[self nextLevelDirection:physicsBorderInsideTopLayer];
		
		{ // Add some static lights.
//			[self addStaticLight:cpv(x,   0) intensity:1.0f distance:dist];
			[self renderStaticLightMap];
		}
		
		[self addFlail:cpv(100,80)];
		[self addFlail:cpv(100,240)];
		[self addFlail:cpv(240,80)];
		[self addFlail:cpv(240,240)];
		[self addFlail:cpv(380,80)];
		[self addFlail:cpv(380,240)];
		
		[self addEndArrow:cpv(240, 160) angle:0.0f];
		[self addGoalOrb:cpv(440,270)];
		[self addPlayerBall:cpv(240, 160)];
	}
	
	return self;
}

@end
