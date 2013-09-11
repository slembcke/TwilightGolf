#import "LevelStateDelegate.h"

@implementation LevelTurnTurnTurn

+ (NSString *)levelName {
	return @"Spinners";
}

- (ChipmunkBody*)addWindmill:(cpVect)atPoint {
 
  atPoint.y = 320 - atPoint.y;
	
  cpFloat m = 2.0f;
	cpFloat r = 24.0f;
  
  // board sizes.
  float width = 12.0f;
  float height = 64.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	body.pos = atPoint; 
  [self addChipmunkObject:body]; [body release];

  
  ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:atPoint];
  [self addChipmunkObject:pivot]; [pivot release];
  
  // ---------  finish the gear.
  
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.friction = 8.0f;
	shape.group = physicsMechanicalGroup;
	[self addChipmunkObject:shape]; [shape release];
  
	[sprites addObject:MAKE_GEAR_STONE_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  
  // ------- board one:  
	cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
  shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
  shape.group = physicsMechanicalGroup;
	shape.friction = 3.0f;
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_BOARD_SPRITE(body)];
  
   // ------- board two:  
  cpVect verts2[] = {
    cpv(-height,-width), cpv(-height,width), cpv(height,width), cpv(height,-width)
  };
    
  shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts2 offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
  shape.group = physicsMechanicalGroup;
	shape.friction = 3.0f;
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_BOARD_SIDEWAYS_SPRITE(body)];
  
  return body;
}


- (id)init {
	if(self = [super init]){
    ambientLevel = 0.15f;
		goldPar = 3;
    silverPar = 7;
    
		int polylines[] = {
			-50, 267, 
      384, 267,
			384, 700,
      -1,
      219, -100,
      219, 185,
      321, 185,
      321, -100,
      -1,
      465, -100,
      465, 94,
      700, 94,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelTurnTurnTurn"];
		[self nextLevelDirection:physicsOutsideBorderLayer];
		
		{
			float i = 0.5;
			[self addStaticLight:cpv(240,   0) intensity:i distance:400];
			[self addStaticLight:cpv(480, 360) intensity:i distance:300];
			[self addStaticLight:cpv(  0, 320) intensity:i distance:200];
			[self renderStaticLightMap];
		}

    
		[self addLight:cpv(50, 0) length:20.0f intensity:0.6f distance:200.0f];
    
    ChipmunkConstraint *joint;
		
    leverShaft = [self addLeverShaft:cpv(93,230)];
		leverShaft.angle = M_PI/8.0f;
		cpVect crankPivot = [leverShaft local2world:cpv(0, -35)];
		
//		lever = [self addGearStone:cpv(crankPivot.x, 320 - crankPivot.y)];
    
    cpVect topPoint = cpv(394, 73);
    cpVect bottomPoint = cpv(394, 190);
    
		ChipmunkBody* topMill = [self addWindmill:topPoint];
		ChipmunkBody* bottomMill = [self addWindmill:bottomPoint];
        
		// crankshaft pivot
		joint = [[ChipmunkPivotJoint alloc] initWithBodyA:leverShaft bodyB:staticBody pivot:crankPivot];
		[space addObject:joint]; [joint release];

		// crankshaft limit
		joint = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:leverShaft min:-M_PI/4.0f max:M_PI/4.0f];
		[space addObject:joint]; [joint release];
		
//		// crank gear
//		joint = [[ChipmunkGearJoint alloc] initWithBodyA:shaft bodyB:lever phase:0.0f ratio:1.0f];
//		[space addObject:joint]; [joint release];
    
		ChipmunkGearJoint* returnToNormal = [[ChipmunkGearJoint alloc] initWithBodyA:staticBody bodyB:leverShaft phase:0.0f ratio:1.0f];
    returnToNormal.maxForce = 5000;
		[self addChipmunkObject:returnToNormal]; [returnToNormal release];

    motor1 = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:topMill rate:0.0f];
		motor1.maxForce = 50000;
		[self addChipmunkObject:motor1]; [motor1 release];
    
    motor2 = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:bottomMill rate:0.0f];
		motor2.maxForce = 50000;
		[self addChipmunkObject:motor2]; [motor2 release];
    
    [self addMoss:cpv(147,   -2) big:TRUE];
    
		[self addEndArrow:cpv(430, 270) angle:-M_PI/4.0f];
		goalOrbBody = [self addRollingGoalOrb:cpv(430, 5)];
		[self addPlayerBall:cpv(20, 180) vel:cpv(5,10)];
    ballShape.layers &= ~(physicsOutsideBorderLayer|physicsBorderInsideBottomLayer);
	}
	
	return self;
}

- (void)update {
  motor1.rate = -leverShaft.angle / 3.0f;
  motor2.rate = leverShaft.angle / 3.0f;
  
  [super update];
}



@end
