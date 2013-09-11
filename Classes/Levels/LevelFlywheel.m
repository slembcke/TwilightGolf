#import "LevelStateDelegate.h"

const cpFloat doorSlideAmount = 64.0f;
const cpFloat gearRotationAmount = 1.0f*2.0f*M_PI;

@implementation LevelFlywheel

+ (NSString *)levelName {
	return @"Flywheel";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.1f;
    goldPar = 7;
		silverPar = 12;
    
		int polylines[] = {
			-50, 192,
			32, 192,
			32, 288,
			256, 288,
			256, 192,
			288, 192,
			288, 288,
			448, 288,
			448, -50,
			-1,
			144, -50,
			144, 128,
			336, 128,
			336, 224,
			400, 224,
			400, 192,
			352, 192,
			352,  96,
			176,  96,
			176, -50,
			-1,-1,
		};
		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"levelFlywheel"];
		[self nextLevelDirection:physicsBorderInsideTopLayer];
		
		// Add some static lights.
		[self addStaticLight:cpv(  0, 288) intensity:0.5f distance:300];
		[self addStaticLight:cpv(480, 288) intensity:0.5f distance:300];
		[self addStaticLight:cpv(272, 304) intensity:0.5f distance:300];
		[self addStaticLight:cpv(480,   0) intensity:0.5f distance:300];
		[self addStaticLight:cpv(160, 112) intensity:0.5f distance:200];
		[self addStaticLight:cpv(344, 112) intensity:0.5f distance:100];
		[self addStaticLight:cpv(344, 208) intensity:0.5f distance:100];
		[self renderStaticLightMap];
		
		[self addLight:cpv(96, 0) length:64 intensity:0.5f distance:250];
		[self addLight:cpv(384, 0) length:32 intensity:0.5f distance:250];
		[self addBrokenLight:cpv(400, 0) length:64];
		
		cpVect gearpos = cpv(208, 240);
		
		const cpFloat ratio = 5.0f;
		ChipmunkBody *flywheel = [self addGearStone:cpvadd(gearpos, cpv(-64,0))];
		flywheel.mass *= ratio;
		flywheel.moment *= ratio;
		
		ChipmunkBody *gear1 = [self addGearStone:gearpos];
		gear2 = [self addGearStone:cpvadd(gearpos, cpv(-128,0))];
		
		ChipmunkSimpleMotor *motor = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:gear1 rate:-3];
		motor.maxForce = 5000.0f;
		[space addObject:motor]; [motor release];

		ChipmunkSimpleMotor *brake = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:gear2 rate:0.6];
		brake.maxForce = 500.0f;
		[space addObject:brake]; [brake release];
		
		ChipmunkRotaryLimitJoint *limit = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:gear2 bodyB:staticBody min:-gearRotationAmount max:0];
		[space addObject:limit]; [limit release];
		
		cpVect doorPos = cpv(368, 240);
		ChipmunkBody *door = [self addSlidingDoor:doorPos];
		
		doorMotor = [[ChipmunkPivotJoint alloc] initWithBodyA:door bodyB:staticBody anchr1:cpvzero anchr2:door.pos];
		doorMotor.maxForce = 1000.0f;
		[space addObject:doorMotor]; [doorMotor release];
		
		ChipmunkGrooveJoint *doorGroove = [[ChipmunkGrooveJoint alloc] initWithBodyA:door bodyB:staticBody groove_a:cpvzero groove_b:cpv(0,-doorSlideAmount) anchr2:door.pos];
		[space addObject:doorGroove]; [doorGroove release];
		
		[self addEndArrow:cpv(304, 32) angle:M_PI_2];
		[self addGoalOrb:cpv(224, 48)];
		[self addPlayerBall:cpv(32, 20)];
	}
	
	return self;
}

- (void)update {
	doorMotor.anchr1 = cpv(0, -doorSlideAmount*gear2.angle/gearRotationAmount);
	
	[super update];
}

@end
