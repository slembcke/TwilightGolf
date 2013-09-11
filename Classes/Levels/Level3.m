#import "LevelStateDelegate.h"

@implementation Level3

ChipmunkSimpleMotor* motor;

- (void)addFlipper:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  goldPar = 3;
	silverPar = 4;
  
  float width = 10.0f;
  float height = 46.0f;
	cpFloat m = 3.0f;
	
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = cpvadd(atPoint, cpv(0, -42));
  
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 3.0f;
  
  ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:atPoint];
  [self addChipmunkObject:pivot]; [pivot release];
  
  ChipmunkRotaryLimitJoint *limiter = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:body bodyB:staticBody min:-1.57f max:0.0f];
  [self addChipmunkObject:limiter]; [limiter release];
  
  motor = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:body rate:-2.5f];
  motor.maxForce = 500000;
  [self addChipmunkObject:motor]; [motor release];
  
  
  [self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
}


- (id)init { // TODO do something with this level, it's trivial and boring.
	if(self = [super init]){
		int polylines[] = {
			 0, 45, 
			 368, 45,
			419, 91,
			458, 125,
			458, 148,
			480, 162,
			-1,
			0, 273,
			111, 273,
			111, 188,
			368, 188,
			368, 273,
			480, 273,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"level3"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		[self addLight:cpv(123, 45) length:40.0f intensity:0.8f distance:270.0f];
		[self addBoard:cpv(233, 117)];
		[self addFlipper:cpv(17, 76)];
		
		[self addEndArrow:cpv(428, 180) angle:0];
		[self addGoalOrb:cpv(428, 230)];
		[self addPlayerBall:cpv(60, 200)];
	}
	
	return self;
}

- (void)update {
  [super update];
  if(ticks % 90 == 0){
    motor.rate = -motor.rate;
  }
}



@end
