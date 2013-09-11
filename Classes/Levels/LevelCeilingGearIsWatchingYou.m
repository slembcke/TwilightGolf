#import "LevelStateDelegate.h"

@implementation LevelCeilingGearIsWatchingYou

NSMutableArray* blowupable;
Light *light;
ChipmunkBody* drawBridge;

ALuint touchingOrbLoop;

+ (NSString *)levelName {
	return @"Ceiling Gear is Watching You";
}

- (void)update {
	modulateLoopVolume(touchingOrbLoop, fade, 0.00f, 0.9f);
  
  fade -= 0.05f;
  if(fade < 0.0f){
    fade = 0.0f;
  }
  // and:
  modulateLoopVolume(squeakLoop, cpfabs(drawBridge.angVel), 0.01f, 0.05f);
  
  [super update];
}

- (id)init {
	if(self = [super init]){
    ambientLevel = 0.15f;
    fade = 0.0f;
 		goldPar = 2;
    silverPar = 5;
    
    blowupable = [[NSMutableArray alloc] init];
    
		  
		int polylines[] = {
			-50, 320-176, 
      51, 320-176,
			177, 320-302,
      272, 320-302,
      272, 320-169,
      700, 320-169,
      -1,
			-50, 320-58,
			700, 320-58,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelCeilingGearIsWatchingYou"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		{
			float i = 0.5;
			[self addStaticLight:cpv(240,   360) intensity:i distance:400];
			[self addStaticLight:cpv(480, 0) intensity:i distance:300];
			[self addStaticLight:cpv(  0, 0) intensity:i distance:200];
			[self renderStaticLightMap];
		}
    
    ChipmunkBody* whiteOrb = [self addWhiteOrb:cpv(160, 130)];
		
		light = [[Light alloc] initWithBody:whiteOrb offset:cpvzero radius:250.0f r:0.5f g:0.5f b:0.5f];
		[lights addObject:light]; [light release];
		[light setIntensity:0.2f];
    
		[self addLight:cpv(35, 145) length:20.0f intensity:0.6f distance:200.0f];
        
		ChipmunkBody* motorizedBody = [self addGearStone:cpv(163, 90)];
		ChipmunkBody* secondGear = [self addGearStone:cpv(231, 90)];
		drawBridge = [self addDrawbridge:cpv(367, 203)];
    
		ChipmunkSimpleMotor* motor = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:motorizedBody rate:-3.0f];
		motor.maxForce = 5000;
		[self addChipmunkObject:motor]; [motor release];
    
		ChipmunkSimpleMotor* brake = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:secondGear rate:0.0f];
		brake.maxForce = 2000;
		[self addChipmunkObject:brake]; [brake release];
		
		ChipmunkGearJoint* gears = [[ChipmunkGearJoint alloc] initWithBodyA:secondGear bodyB:drawBridge phase:0.0f ratio:10.0f];
		[self addChipmunkObject:gears]; [gears release];
    
		ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:drawBridge bodyB:staticBody pivot:cpv(367, 320-247)];
		[self addChipmunkObject:pivot]; [pivot release];
		
		[self addEndArrow:cpv(430, 85) angle:0];
		[self addGoalOrb:cpv(430, 213)];
		[self addPlayerBall:cpv(20, 200) vel:cpv(20, 20)];
    
    [self addMoss:cpv(218,  17) big:TRUE];
    [self addMoss:cpv(399, 150) big:FALSE];
    
    [blowupable addObject:[self addBall:cpv(115, 243) canRollAway:false]];
    [blowupable addObject:[self addSmallBox:cpv(175, 243)]];

    squeakLoop = createLoop(squeakSound);
    touchingOrbLoop = createLoop(touchingOrbSound);

	}
	
	return self;
}




- (void) triggerWhiteOrb:(cpShape*) orb {
  [light setIntensity:1.0f];
  fade = 1.0f;

  NSEnumerator * enumerator = [blowupable objectEnumerator];
  ChipmunkBody* b;
  
  while(b = [enumerator nextObject])
  {
      b.vel = cpvadd(b.vel, cpv(random() % 30 - 15, 5));
  }
  
}

@end
