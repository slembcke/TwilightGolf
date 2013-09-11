#import "LevelStateDelegate.h"

@implementation LevelTheWay2

+ (NSString *)levelName {
	return @"The Way II";
}

static cpVect gravityPoints[] = {
	{112,160},
	{240,160},
	{368,160},
};
static int numGravityPoints = sizeof(gravityPoints)/sizeof(*gravityPoints);

static cpVect
forceToPoint(cpBody *body, cpVect point)
{
	cpVect delta = cpvsub(point, body->p);
//	if(cpvlengthsq(delta) > 5000.0f) return cpvzero;
	
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
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = pos; // TODO memory leak

	[sprites addObject:MAKE_BLUE_ORB_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
}

- (id)init {
	if(self = [super init]){
    goldPar = 4;
    silverPar = 7;
    
		int polylines[] = { // 332 394
			-50,  32,
			208,  32,
			208, 160,
			272, 160,
			272,  32,
			700,  32,
			 -1,
			-50, 288,
			 80, 288,
			 80, 160,
			144, 160,
			144, 288,
			336, 288,
			336, 160,
			400, 160,
			400, 288,
			700, 288,
			 -1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelTheWay2"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		for(int i=0; i<numGravityPoints; i++)
			[self addGravityOrbUnflipped:gravityPoints[i]];
		
    [self addGooOrbUnflipped:cpv(160, 112)];
    [self addGooOrbUnflipped:cpv(192, 210)];
    [self addGooOrbUnflipped:cpv(288, 210)];
    [self addGooOrbUnflipped:cpv(320, 112)];

    [self addTorch:cpv(240, 263)];
    
		[self addEndArrow:cpv(440, 190) angle:0];
		[self addGoalOrb:cpv(440, 242)];
		[self addPlayerBall:cpv(40, 320 - 64)];
		ballBody.body->velocity_func = customVelocity;
	}
	
	return self;
}

@end
