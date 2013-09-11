#import "LevelStateDelegate.h"

@implementation LevelTeeterTotter

NSMutableArray* blowupable;
Light *light;


ALuint touchingOrbLoop;

+ (NSString *)levelName {
	return @"Totter";
}

- (void)update {
	modulateLoopVolume(touchingOrbLoop, fade, 0.00f, 0.9f);
  
  fade -= 0.05f;
  if(fade < 0.0f){
    fade = 0.0f;
  }
  
  [super update];
}

- (void)addTeeter:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float width = 169.0f;
  float height = 18.0f;
	cpFloat m = 3.0f;
	
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
  
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 3.0f;
  shape.layers &= ~physicsTerrainLayer;
  
  ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:atPoint];
  [self addChipmunkObject:pivot]; [pivot release];
  
  ChipmunkRotaryLimitJoint *limiter = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:body bodyB:staticBody min:-0.55f max:0.55f];
  [self addChipmunkObject:limiter]; [limiter release];
  
  ChipmunkDampedRotarySpring* joint = [[ChipmunkDampedRotarySpring alloc] initWithBodyA:staticBody bodyB:body restAngle:0 stiffness:400000.0f damping:150000.0f];
  [space addObject:joint]; [joint release];
  
//  ChipmunkGearJoint* returnToNormal = [[ChipmunkGearJoint alloc] initWithBodyA:staticBody bodyB:body phase:0.0f ratio:1.0f];
//  returnToNormal.maxForce = 1000000;
//  [self addChipmunkObject:returnToNormal]; [returnToNormal release];  
  
  [self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_TEETER_SPRITE(body)];
}


- (id)init {
	if(self = [super init]){
		ambientLevel = 0.2f;
    fade = 0.0f;
    goldPar = 1;
    silverPar = 5;
    
    blowupable = [[NSMutableArray alloc] init];
    
		int polylines[] = {
      
      
      -100, 172,
      103, 172,
      103,  38,
      
//      218,  38,
//			264, 125,
//			315,  38,
      
			462,  38,
			462, 162,
			500, 162,
      -1,
      -100, 289,
      500, 289,
			-1, -1,
		};
    
		[self addPolyLines:polylines];
		[self loadBG:@"levelTeeterTotter"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		[self addStaticLight:cpv(444, 239) intensity:0.5 distance:300];
		[self addStaticLight:cpv(  0, 160) intensity:0.5 distance:300];
		[self addStaticLight:cpv(240, 320) intensity:0.5 distance:300];
		[self renderStaticLightMap];

    ChipmunkBody* whiteOrb = [self addWhiteOrb:cpv(78, 174)];
		
		light = [[Light alloc] initWithBody:whiteOrb offset:cpvzero radius:150.0f r:0.5f g:0.5f b:0.5f];
		[lights addObject:light]; [light release];
		[light setIntensity:0.2f];    
    
		[self addLight:cpv(175, 38) length:20.0f intensity:0.8f distance:130.0f];
//		[self addLight:cpv(175, -20) length:115.0f intensity:0.8f distance:130.0f];
		[self addTeeter:cpv(283, 145)];

		[blowupable addObject:[self addBigBox:cpv(331, 256) radius:25.0f mass:6.0f]];
		
    [self addEndArrow:cpv(444, 239) angle:0];
		goalOrbBody = [self addRollingGoalOrb:cpv(414,  73)];
		[self addPlayerBall:cpv(43, 268)];

    touchingOrbLoop = createLoop(touchingOrbSound);

    

    [self addMoss:cpv(269,  38) big:TRUE];
    
	}
	
	return self;
}

- (void) triggerWhiteOrb:(cpShape*) orb {
  fade = 1.0f;
  [light setIntensity:1.0f];
  
  NSEnumerator * enumerator = [blowupable objectEnumerator];
  ChipmunkBody* b;
  
  while(b = [enumerator nextObject])
  {
    b.vel = cpvadd(b.vel, cpv(random() % 30 - 15, 5));
  }
}


@end
