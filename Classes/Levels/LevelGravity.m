#import "LevelStateDelegate.h"

@implementation LevelGravity

+ (NSString *)levelName {
	return @"Gravity Wells";
}

static cpVect gravityPoints[] = {
	{77,63},
	{292,227},
	{75,217},
	{239,50},
	{429,244},
	{216,147},
};
static int numGravityPoints = sizeof(gravityPoints)/sizeof(*gravityPoints);

static cpVect stones[] = {
	{369,70},
	{102,140},
	{162,63},
	{304,140},
	{183,251},
	{420,167},
};
static int numStones = sizeof(stones)/sizeof(*stones);

static cpVect
forceToPoint(cpBody *body, cpVect point)
{
	cpVect delta = cpvsub(point, body->p);
	if(cpvlengthsq(delta) > 5000.0f) return cpvzero;
	
	cpFloat len = cpvlength(delta)/100.0f;
	cpVect n = cpvmult(delta, 1.0f/len);
	
	return cpvmult(n, cpfmin(0.1f/(len*len*len), 3.0f));
}

static void 
customVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect orbForce = cpvzero;
	
	for(int i=0; i<numGravityPoints; i++)
		orbForce = cpvadd(orbForce, forceToPoint(body, gravityPoints[i]));
	
	cpBodyUpdateVelocity(body, cpvadd(gravity, orbForce), damping, dt);
}


- (void)addGravityOrbUnflipped:(cpVect)pos {
//  pos.y = 320 - pos.y;
	
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = pos; // TODO memory leak

//	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
//	shape.elasticity = 1.0f;
//	shape.friction = 1.0f;
//	[space addObject:shape];
	
	[sprites addObject:MAKE_BLUE_ORB_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 1;
    silverPar = 3;
    
		int polylines[] = {
			-50,  24,
			700,  24,
			 -1,
			-50, 288,
			700, 288,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelGravityOrbs"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		for(int i=0; i<numGravityPoints; i++)
			[self addGravityOrbUnflipped:gravityPoints[i]];
						
		for(int i=0; i<numStones; i++){
			cpVect pos = stones[i];
			pos.y = 320 - pos.y;
			[self addArrowStone:pos pointAt:cpv(-1000, 160)];
		}
    [self addMoss:cpv(182,  26) big:TRUE];
        
		[self addEndArrow:cpv(440, 190) angle:0];
		[self addGoalOrb:cpv(440, 242)];
		
		[self addPlayerBall:cpv(25, 50)];
	
		ballBody.body->velocity_func = customVelocity;
	}
	
	return self;
}

@end
