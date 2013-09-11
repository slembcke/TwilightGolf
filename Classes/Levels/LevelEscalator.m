#import "LevelStateDelegate.h"

@implementation LevelEscalator

+ (NSString *)levelName {
	return @"Escalator";
}

- (ChipmunkShape*)addStair:(cpVect)offset to:(ChipmunkBody*) body{

  offset.y = 320 - offset.y;
	
	float width = 60.0f;
	float height = 12.0f;
	
	cpVect verts[] = {
		cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
	};
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:offset];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.8f;
	shape.group = physicsMechanicalGroup;
	shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
  
	[self addShadowBox:body offset:offset width:width height:height];
  [sprites addObject:SpriteOffset(MAKE_BOARD_SIDEWAYS_SPRITE(body), offset)];
	
  return shape;
}


- (void) makeStairs{
  stairs = [[ChipmunkBody alloc] initWithMass:10.0f andMoment:INFINITY];
  [space addObject:stairs]; [stairs release];
  
  int i = 0;
  int c= 70;
  int x = 210 -c;
  int y = 258 + c;
  [self addStair:cpv(x+ (i * c), y- (i * c)) to:stairs];
  i++;
  [self addStair:cpv(x+ (i * c), y- (i * c)) to:stairs];
  i++;
  [self addStair:cpv(x+ (i * c), y- (i * c)) to:stairs];
  i++;
  [self addStair:cpv(x+ (i * c), y- (i * c)) to:stairs];
  i++;
  [self addStair:cpv(x+ (i * c), y- (i * c)) to:stairs];
  i++;
//  

  ChipmunkConstraint * groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:stairs groove_a:cpv(-10, -10) groove_b:cpv(80, 80) anchr2:cpvzero];
  [self addChipmunkObject:groove]; [groove release];

  pivot1 = [[ChipmunkPivotJoint alloc] initWithBodyA:stairs bodyB:staticBody pivot:cpvzero];
  pivot1.anchr2 = cpv(70, 70);
  [self addChipmunkObject:pivot1]; [pivot1 release];
  pivot1.maxForce = 40000;
  pivot1.maxBias = 14.0f;
  pivot1.biasCoef = 1.0f;
  
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15;
    goldPar = 2;
		silverPar = 3;
    
    int polylines[] = {
			 -100, 29, 
       500, 29,
      -1,
			-100, 100,
      269, 100,
      267, 118,
      183, 191,
      -100, 191,
      -1,
			
      -100, 290,
      230, 290,
      464,  60,
      480,  29,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelEscalator"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		[self addStaticLight:cpv(280, 390) intensity:0.4 distance:250];
		[self addStaticLight:cpv(369, 301) intensity:0.55 distance:80];
		[self addStaticLight:cpv(465, 220) intensity:0.55 distance:80];
		[self addStaticLight:cpv(500, 150) intensity:0.4 distance:250];
		[self addStaticLight:cpv(95, 147) intensity:0.6 distance:200];
    [self addStaticLight:cpv(140, -50) intensity:0.3 distance:400];
		
    [self renderStaticLightMap];

		[self addLight:cpv(272,  34) length:15.0f intensity:0.5f distance:250.0f];
		
    [self makeStairs];
    
    cpVect leverPos = cpv(111, 320-192);
    lever = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:500.0f];
    [space addObject:lever];[lever release];
    lever.pos = leverPos;
    
    ChipmunkShape *leverShape = [[ChipmunkSegmentShape alloc] initWithBody:lever from:cpvzero to:cpv(0,-24) radius:3.0f];
    [space addObject:leverShape]; [leverShape release];
    
    // crankshaft limit
		ChipmunkConstraint * joint = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:lever min:-M_PI/4.0f max:M_PI/4.0f];
		[space addObject:joint]; [joint release];
		
    joint = [[ChipmunkDampedRotarySpring alloc] initWithBodyA:staticBody bodyB:lever restAngle:0.0f stiffness:-50.0f damping:100.0f];
		[space addObject:joint]; [joint release];
    
    [sprites addObject:SpriteOffset(MAKE_FLIP_FLOP_LEVER_SPRITE(lever), cpv(0, -12))];
    [self addShadowBox:lever offset:cpv(0.0f, -12.0f) width:3.0f height:12.0f];
    
    ChipmunkConstraint *leverPivot = [[ChipmunkPivotJoint alloc] initWithBodyA:staticBody bodyB:lever pivot:leverPos];
    [space addObject:leverPivot]; [leverPivot release];
    
    
		[self addGoalOrb:cpv(117,  52)];
		[self addPlayerBall:cpv(36, 252) vel:cpv(20, 10)];
	}
	
	return self;
}


- (void)update {
  [super update];

  pivot1.maxBias = lever.angle * 30.0f;
  
  int c = 69;
    
  if(stairs.pos.x >= c){
    stairs.pos = cpvsub(stairs.pos, cpv(c, c));
  }
  if(stairs.pos.x <= 0.0f){
    stairs.pos = cpvadd(stairs.pos, cpv(c, c));
  }
  
}



@end
