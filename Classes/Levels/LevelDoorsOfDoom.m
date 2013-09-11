#import "LevelStateDelegate.h"

@implementation LevelDoorsOfDoom

+ (NSString *)levelName {
	return @"Doors of Doom";
}

- (id)init {
  if(self = [super init]){
    ambientLevel = 0.15f;
    goldPar = 5;
		silverPar = 12;
		
    int polylines[] = {
      -100, 32, 
      441, 32,
      441, 263,
      422, 263,
      422, 286,
      109, 286,
      109, 500,
      -1,
      -100, 106,
      359, 106,
			359, 191,
			344, 206,
      10, 206,
      10, 500,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelDoorsOfDoom"];
		[self nextLevelDirection:physicsBorderInsideBottomLayer];
	
		[self addStaticLight:cpv(100, 160) intensity:0.2f distance:300.0f];
		[self addStaticLight:cpv(240,   0) intensity:0.4f distance:240.0f];
//		[self addStaticLight:cpv(480, 160) intensity:0.3f distance:160.0f];
		[self addStaticLight:cpv(240, 320) intensity:0.1f distance:240.0f];
		[self addStaticLight:cpv(25, 350) intensity:0.6f distance:140.0f];
		[self renderStaticLightMap];
		
		[self addLight:cpv(418,31) length:20.0f intensity:0.4f distance:200.0f];
    
	  [self addTorch:cpv(240, 260)];
		
		door1 = [self addSlidingDoor:cpv(188, 67)];
		door2 = [self addSlidingDoor:cpv(301, 67)];
		door3 = [self addSlidingDoor:cpv(188, 250)];
		door4 = [self addSlidingDoor:cpv(301, 250)];
		
		ChipmunkConstraint *groove;
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door1 groove_a:cpv(188, -50) groove_b:cpv(188, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot1 = [[ChipmunkPivotJoint alloc] initWithBodyA:door1 bodyB:staticBody pivot:cpv(188, 320-67)];
		[self addChipmunkObject:pivot1]; [pivot1 release];
		pivot1.maxForce = 4000;
		
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door2 groove_a:cpv(301, -50) groove_b:cpv(301, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot2 = [[ChipmunkPivotJoint alloc] initWithBodyA:door2 bodyB:staticBody pivot:cpv(301, 320-67)];
		[self addChipmunkObject:pivot2]; [pivot2 release];
		pivot2.maxForce = 4000;
		
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door3 groove_a:cpv(188, -50) groove_b:cpv(188, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot3 = [[ChipmunkPivotJoint alloc] initWithBodyA:door3 bodyB:staticBody pivot:cpv(188, 320-250)];
		[self addChipmunkObject:pivot3]; [pivot3 release];
		pivot3.maxForce = 4000;
		
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door4 groove_a:cpv(301, -50) groove_b:cpv(301, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot4 = [[ChipmunkPivotJoint alloc] initWithBodyA:door4 bodyB:staticBody pivot:cpv(301, 320-250)];
		[self addChipmunkObject:pivot4]; [pivot4 release];
		pivot4.maxForce = 4000;
		
		bigBox = [self addBigBox:cpv(135, 68 )];
		//[self addBigBox:cpv(275, 187)];
		
    [self addMoss:cpv(122,  32) big:FALSE];

		[self addEndArrow:cpv(50, 250) angle:-M_PI_2];
		[self addChainedGoalOrb:cpv(35, 202) length:30.0f];
		[self addPlayerBall:cpv(34, 70)];
	}
 
  slideLoop = createLoop(slidingRocks);

	return self;
}

- (void)update {
  [super update];
  int direction = (ticks % 200) / 100;
  if(direction == 0){
    direction = -1;
  }
  
  pivot1.anchr1 = cpvadd( pivot1.anchr1, cpv(0, direction));
  pivot2.anchr1 = cpvadd( pivot2.anchr1, cpv(0, direction));
  pivot3.anchr1 = cpvadd( pivot3.anchr1, cpv(0, direction));
  pivot4.anchr1 = cpvadd( pivot4.anchr1, cpv(0, direction));
  if(bigBox.vel.y < 10.0f){
    modulateLoopVolume(slideLoop, cpfabs(fabs(bigBox.vel.x)), 1.0f, 100.0f);
  }else{
    modulateLoopVolume(slideLoop, 0.0f, 0.0f, 1.0f);
  }
}

@end
