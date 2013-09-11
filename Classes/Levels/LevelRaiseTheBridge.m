#import "LevelStateDelegate.h"

@implementation LevelRaiseTheBridge

+ (NSString *)levelName {
	return @"Raise the Bridge";
}

- (id)init {
	if(self = [super init]){
    ambientLevel = 0.15f;
    goldPar = 2;
    silverPar = 4;
    
		int polylines[] = {
			-50, 176, 
			 51, 176,
			177, 302,
      272, 302,
      272, 169,
      700, 169,
      -1,
			-50, 58,
			700, 58,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelRaiseTheBridge"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		{
			float i = 0.5;
			[self addStaticLight:cpv(240,   0) intensity:i distance:400];
			[self addStaticLight:cpv(480, 360) intensity:i distance:300];
			[self addStaticLight:cpv(  0, 320) intensity:i distance:200];
			[self renderStaticLightMap];
		}

		[self addLight:cpv(195, 60) length:20.0f intensity:0.6f distance:200.0f];

		ChipmunkBody* motorizedBody = [self addGearStone:cpv(163, 215)];
		ChipmunkBody *secondGear = [self addGearStone:cpv(231, 215)];
		drawBridge = [self addDrawbridge:cpv(367, 114)];
		
		ChipmunkRotaryLimitJoint *limit = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:drawBridge min:0.0f max:10.0f];
		[space addObject:limit]; [limit release];

		ChipmunkSimpleMotor* motor = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:motorizedBody rate:3.0f];
		motor.maxForce = 5000;
		[self addChipmunkObject:motor]; [motor release];

		ChipmunkSimpleMotor* brake = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:secondGear rate:0.0f];
		brake.maxForce = 700;
		[self addChipmunkObject:brake]; [brake release];
		
		ChipmunkGearJoint* gears = [[ChipmunkGearJoint alloc] initWithBodyA:secondGear bodyB:drawBridge phase:0.0f ratio:-20.0f];
		[self addChipmunkObject:gears]; [gears release];

		ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:drawBridge bodyB:staticBody pivot:cpv(367, 166)];
		[self addChipmunkObject:pivot]; [pivot release];
    
    [self addMoss:cpv(400,  58) big:TRUE];

		[self addEndArrow:cpv(430, 85) angle:0];
		[self addGoalOrb:cpv(430, 123)];
		[self addPlayerBall:cpv(20, 140)];
		
    squeakLoop = createLoop(squeakSound);
	}
	
	return self;
}


- (void)update {
	modulateLoopVolume(squeakLoop, cpfabs(drawBridge.angVel), 0.02f, 0.1f);
  
  [super update];
}


@end
