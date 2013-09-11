#import "LevelStateDelegate.h"

// also needs to be here, I guess?
cpShape *orb11, *orb22, *orb33, *orb44;

@implementation LevelDilithiumCrystal

+ (NSString *)levelName {
	return @"Repulsors";
}


static cpVect gravityPoints[] = {
	{200, 100},
	{280, 100},
	{180, 170},
	{300, 170},
};


static cpVect
forceToPoint(cpBody *body, cpVect point, int b)
{
	point.y = 320 - point.y;
	
	cpVect delta = cpvsub(point, body->p);
	if(cpvlengthsq(delta) > 8000.0f) return cpvzero;
	
	cpFloat len = cpvlength(delta)/140.0f;
	cpVect n = cpvmult(delta, 1.0f/len);
	
  cpFloat multiplier = 1.0f;
  if(b){
    multiplier *= -2.0f;
  }
  
	return cpvmult(n, cpfmin(0.1f/(len*len*len), multiplier));
}


static void 
customVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect orbForce = cpvzero;

  orbForce = cpvadd(orbForce, forceToPoint(body, gravityPoints[0], orb11->collision_type == physicsRedOrbType));
  orbForce = cpvadd(orbForce, forceToPoint(body, gravityPoints[1], orb22->collision_type == physicsRedOrbType));
  orbForce = cpvadd(orbForce, forceToPoint(body, gravityPoints[2], orb33->collision_type == physicsRedOrbType));
  orbForce = cpvadd(orbForce, forceToPoint(body, gravityPoints[3], orb44->collision_type == physicsRedOrbType));
  
	cpBodyUpdateVelocity(body, cpvadd(gravity, orbForce), damping, dt);
}


- (cpShape*) addGravityOrbRed:(cpVect)pos {
	pos.y = 320 - pos.y;
	
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = pos; // TODO memory leak
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.collisionType = physicsRedOrbType;
	[space addObject:shape];
	
	[sprites addObject:MAKE_RED_ORB_SPRITE(body)];  
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  return shape.shape;
}

- (id)init {
	if(self = [super init]){
    goldPar = 2;
    silverPar = 5;
    
		int polylines[] = {
			-200, 82, 
			188, 82, 
			188, -100, 
			-1,
			-200, 239, 
			175, 239, 
			175, 500, 
			-1,
			500, 82, 
			295, 82, 
			295, -100, 
			-1,
			500, 239, 
			303, 239, 
			303, 500, 
			-1, -1,
		};
		
		[self addPolyLines:polylines];
		[self loadBG:@"levelDilithiumCrystal"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		{
			float i = 0.5;
			[self addStaticLight:cpv(  0,   0) intensity:i distance:300];
			[self addStaticLight:cpv(480,   0) intensity:i distance:300];
			[self addStaticLight:cpv(  0, 320) intensity:i distance:300];
			[self addStaticLight:cpv(480, 320) intensity:i distance:300];
			[self renderStaticLightMap];
		}
		
		// ChipmunkBody* crystalTrigger = [self addCrystalTrigger:cpv(446, 219)];

//		light = [[Light alloc] initWithBody:crystalTrigger offset:cpvzero radius:150.0f r:0.1f g:0.1f b:0.9f];
//		[lights addObject:light]; [light release];
//		[light setIntensity:0.15f];

    orb11 = orb1 = [self addGravityOrbRed:gravityPoints[0]];
    orb22 = orb2 = [self addGravityOrbRed:gravityPoints[1]];
    orb33 = orb3 = [self addGravityOrbRed:gravityPoints[2]];
    orb44 = orb4 = [self addGravityOrbRed:gravityPoints[3]];
  
		[self addMoss:cpv(384,  85) big:TRUE];
		[self addMoss:cpv(36,  85) big:FALSE];
		
		
		// [self addLever:cpv(240, 60)];
		[self addPlayerBall:cpv(20, 140) vel:cpv(40, 40)];
		[self addEndArrow:cpv(440, 190) angle:0];
		
		goalOrbBody = [self addRollingGoalOrb:cpv(240, 40)];
		
		ballBody.body->velocity_func = customVelocity;
		goalOrbBody.body->velocity_func = customVelocity;
	}
	
	return self;
}

- (void) triggerBlueOrb:(cpShape*) orb {
//  if(ticks - lastSwitch < 100){
//    return;
//  } 
//	
//  [self changeSprite:orb->body to:MAKE_RED_ORB_SPRITE(orb->body->data)];
//  orb->collision_type = physicsRedOrbType;
//  lastSwitch = ticks;
}

- (void) triggerRedOrb:(cpShape*) orb {
//  if(ticks - lastSwitch < 20){
//    return;
//  } 
	
  [self changeSprite:orb->body to:MAKE_BLUE_ORB_SPRITE(orb->body->data)];
  orb->collision_type = physicsBlueOrbType;
  lastSwitch = ticks;
}


@end
