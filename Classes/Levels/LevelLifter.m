#import "LevelStateDelegate.h"

@implementation LevelLifter

+ (NSString *)levelName {
	return @"Heavy Lifter";
}

- (void)addHangingBridge:(cpVect)pos {
		ChipmunkBody *body = [self addDrawbridge:pos];
		body.angle = M_PI_2;
		
		cpFloat hang = 81.0f;
		ChipmunkConstraint *joint;
		
		cpVect anchr1, anchr2;
		
		anchr1 = cpv(0, -32);
		anchr2 = [body local2world:cpv(hang, -32)];
		joint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:anchr1 anchr2:anchr2 min:0 max:hang];
		[space addObject:joint]; [joint release];
		[ropes addObject:MakeRope(body, staticBody, anchr1, anchr2, ropeTypeRope)];
		
		anchr1 = cpv(0, 32);
		anchr2 = [body local2world:cpv(hang, 32)];
		joint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:anchr1 anchr2:anchr2 min:0 max:hang];
		[space addObject:joint]; [joint release];
		[ropes addObject:MakeRope(body, staticBody, anchr1, anchr2, ropeTypeRope)];
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 6;
    silverPar = 13;
    
		int polylines[] = {
			-50, 160,
			110, 160,
			110, 224,
			146, 224,
			146, 160,
			208, 160,
			208, 288,
			400, 288,
			400, 192,
			700, 192,
			-1,
			 48, -50,
			 48,  32,
			700,  32,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelLifter"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		{
			float i = 0.5f;
			float d = 350;
			[self addStaticLight:cpv(128, 360) intensity:i distance:d];
			[self addStaticLight:cpv(480, 320) intensity:i distance:d];
			[self addStaticLight:cpv(240,   0) intensity:i distance:d];
			[self renderStaticLightMap];
		}
    
    [self addTorch:cpv(239, 263)];
    
		//set up the ratchety thing
		
		shaft = [self addDrawbridge:cpv(368,6*32)];
		cpVect crankPivot = [shaft local2world:cpv(0, -32)];
		
		ChipmunkBody *crank = [self addGearStone:cpv(crankPivot.x, 320 - crankPivot.y)];
		ChipmunkBody *gear = [self addGearStone:cpv(crankPivot.x - 64, 320 - crankPivot.y)];
		
		ChipmunkBody *lever = [self addDrawbridge:cpv(3*32,3*32 + 16)];
		lever.angle = -M_PI_2;
		cpVect leverPivot = [lever local2world:cpv(0, -32)];
		
		ChipmunkConstraint *joint;
		
		// crankshaft pivot
		joint = [[ChipmunkPivotJoint alloc] initWithBodyA:shaft bodyB:staticBody pivot:crankPivot];
		[space addObject:joint]; [joint release];
		
		// crankshaft limit
		joint = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:shaft min:0 max:M_PI/8.0f];
		[space addObject:joint]; [joint release];
		
		// crank ratchet
		joint = [[ChipmunkRatchetJoint alloc] initWithBodyA:shaft bodyB:crank phase:0.0f ratchet:0.1f];
		[space addObject:joint]; [joint release];
		
		// crankshaft return spring
		joint = [[ChipmunkDampedRotarySpring alloc] initWithBodyA:staticBody bodyB:shaft restAngle:0 stiffness:50000.0f damping:0];
		[space addObject:joint]; [joint release];
		
		// crank brake
		joint = [[ChipmunkSimpleMotor alloc] initWithBodyA:crank bodyB:staticBody rate:0.0f];
		joint.maxForce = 4000.0f;
		[space addObject:joint]; [joint release];
		
		// lever pivot
		joint = [[ChipmunkPivotJoint alloc] initWithBodyA:lever bodyB:staticBody pivot:leverPivot];
		[space addObject:joint]; [joint release];
		
		// crank gear
		const cpFloat gearRatio = -5.0f;
		joint = [[ChipmunkGearJoint alloc] initWithBodyA:crank bodyB:lever phase:gearRatio*M_PI_2 ratio:-gearRatio];
		[space addObject:joint]; [joint release];
		
		// crank limit
		joint = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:crank min:0 max:-M_PI_4*gearRatio];
		joint.maxForce = 100000;
		[space addObject:joint]; [joint release];
		
		// gear to gear
		joint = [[ChipmunkGearJoint alloc] initWithBodyA:crank bodyB:gear phase:0 ratio:-1];
		[space addObject:joint]; [joint release];
				
		// non-mechanical stuff
		
		[self addSmallBox:cpv(128,176)];
		[self addHangingBridge:cpv(240, 112)];
		[self addHangingBridge:cpv(384, 112)];
		
    [self addMoss:cpv(131,  32) big:TRUE];
    [self addMoss:cpv(423,  33) big:FALSE];
		
		[self addEndArrow:cpv(440, 112) angle:0];
		ChipmunkBody *goalBody = [self addRollingGoalOrb:cpv(128,208)];
		[self addPlayerBall:cpv(25, 17) vel:cpv(3,-10)];
		
		cpVect anchr1 = cpv(0,32);
		cpVect anchr2 = cpv(0,PLAYER_BALL_RADIUS);
		cpFloat len = cpvlength(cpvsub([lever local2world:anchr1], [goalBody local2world:anchr2]));
		joint = [[ChipmunkSlideJoint alloc] initWithBodyA:lever bodyB:goalBody anchr1:anchr1 anchr2:anchr2 min:0.0f max:len];
		[space addObject:joint]; [joint release];
		[ropes addObject:MakeRope(lever, goalBody, anchr1, anchr2, ropeTypeRope)];

    ratchetLoop = createLoop(ratchetCrankSound);

  }
	
	return self;
}

//

- (void)update {

	modulateLoopVolume(ratchetLoop, cpfmax(0.0f, -shaft.angVel), 0.01f, 0.25f);
  
  [super update];
}
@end
