#import "LevelStateDelegate.h"
#import "ChipmunkSpaceExtras.h"

@implementation LevelLauncher

+ (NSString *)levelName {
	return @"Launcher";
}



- (void)addStuckWhiteOrb:(cpVect)atPoint {
  
  atPoint.y = 320 - atPoint.y;
  
	cpFloat r = 14.0f;

  ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = atPoint; // TODO memory leak
  
  ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
  shape.friction = 0.8f;
	
  shape.collisionType = physicsWhiteOrbType;

  [space addStaticShape:shape]; [shape release];
	
  [sprites addObject:SpriteOffset(MAKE_WHITE_ORB_SPRITE(body), cpvzero)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  
}

static void
cpSpaceAddCollisionPairFunc(cpSpace *space, cpCollisionType a, cpCollisionType b, cpCollisionPreSolveFunc func, void *data)
{
	cpSpaceAddCollisionHandler(space, a, b, NULL, func, NULL, NULL, data);
}

typedef cpCollisionPreSolveFunc cpCollFunc;

static bool
triggerCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *orb; cpArbiterGetShapes(arb, &ball, &orb);

	[((id)level) triggerWhiteOrb: orb];
	
  return TRUE;
}



- (void) triggerWhiteOrb:(cpShape*) orb {
  pivot1.anchr1 = cpvadd( pivot1.anchr1, cpv(0, -180));
}


- (ChipmunkBody *)addFreeWhiteOrb:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
	cpFloat m = 2.0f;
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
  shape.friction = 0.8f;
	shape.elasticity = 0.05f;
	
	shape.layers &= ~physicsBorderLayers;
  shape.collisionType = physicsWhiteOrbType;
  
  cpSpaceRemoveCollisionHandler(space.space, physicsWhiteOrbType, physicsBallType);
  cpSpaceAddCollisionPairFunc(space.space, physicsWhiteOrbType, physicsWhiteOrbType, (cpCollFunc)triggerCallback, self);
  
  [space addObject:shape]; [shape release];
	
	[sprites addObject:MAKE_WHITE_ORB_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  
  return body;
}


- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15;
    goldPar = 2;
		silverPar = 5;
    
    int polylines[] = {
      -100, 184,
      99, 184,
      97, 215,
      -100, 420,
      -1,


      35, 350,
			187, 194,
			204, 201,
			204, 500,
      -1,
      
      -100,  31,
      380, 31,
      380, 113,
      500, 113,
      -1,
    
      500, 207,
      384, 207,
      384, 500,
      -1, -1
      
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelLauncher"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
    
		[self addStaticLight:cpv(150, -60) intensity:0.55 distance:350];
		[self addStaticLight:cpv(460, 10) intensity:0.55 distance:250];
		[self addStaticLight:cpv(460, 310) intensity:0.55 distance:250];
    
		[self addStaticLight:cpv(500, 165) intensity:0.6 distance:250];
		[self addStaticLight:cpv(-20,  75) intensity:0.4 distance:250];

		[self addStaticLight:cpv(40, 232) intensity:0.55 distance:200];
		[self addStaticLight:cpv(163, 293) intensity:0.55 distance:200];

		[self addStaticLight:cpv(61, 297) intensity:0.3 distance:150];
    
    [self renderStaticLightMap];

		[self addLight:cpv(214, 33) length:15.0f intensity:0.5f distance:250.0f];
		[self addLight:cpv(25, 33) length:25.0f intensity:0.5f distance:250.0f];
			

    door1 = [self addSlidingDoor:cpv(411, 164)];
		
		ChipmunkConstraint *groove;
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door1 groove_a:cpv(411, (320-164)-50) groove_b:cpv(411, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot1 = [[ChipmunkPivotJoint alloc] initWithBodyA:door1 bodyB:staticBody pivot:cpv(411, 320-164)];
		[self addChipmunkObject:pivot1]; [pivot1 release];
		pivot1.maxForce = 4000;
    pivot1.maxBias = 10.0f;
    
    [self addFreeWhiteOrb:cpv(80, 156)];
    [self addStuckWhiteOrb:cpv(374,  76)];
 	
    [self addBall:cpv(100,156) canRollAway:TRUE];
    
    // launcher:
    
    launcher = [self addSmallBox:cpv(51, 297)];
    launcher.moment = INFINITY;
		launcher.angle = M_PI / 4.0f;
    
    
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:launcher groove_a:cpv(51, (320-297)) groove_b:cpv(130, 320-220) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		launcherJoint = [[ChipmunkPivotJoint alloc] initWithBodyA:launcher bodyB:staticBody pivot:cpv(51, 320-297)];
		[self addChipmunkObject:launcherJoint]; [launcherJoint release];
		launcherJoint.maxForce = 20000;
        
		[self addGoalOrb:cpv(457, 157)];
		[self addPlayerBall:cpv(32, 156) vel:cpv(3, 15)];
    
    
  }
	
	return self;
}


- (void)update {
  [super update];
  
  // moves from (51, 297) to (130, 220)
  int t = ticks % 120;
  float a = t < 100 ? 1.0f - (t / 100.0f) : (t - 100) / 20.0f;
  
  launcherJoint.anchr2 = cpvlerp(cpv(51, 320-297), cpv(130, 320-220), a);
 }




@end
