#import "LevelStateDelegate.h"

@implementation LevelLaserBeams

+ (NSString *)levelName {
	return @"Beams";
}

static cpVect laserStartPos = {67, 320 - 174};
static cpVect laserEndPos = {209, 320 - 308};

static const cpFloat x1 = 340.0f + 12.0f;
static const cpFloat x2 = 340.0f - 12.0f;
static const cpFloat y = 320.0f - 113.0f;


- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 4;
    silverPar = 7;		
		
		int polylines[] = {
			-50, 176, 
			 51, 176,
			177, 302,
      272, 302,
      272, 169,
      700, 169,
      -1,
			-50, 58,
			700, 58,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelRaiseTheBridge"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		{
			float i = 0.5;
			[self addStaticLight:cpv(240,   0) intensity:i distance:400];
			[self addStaticLight:cpv(480, 360) intensity:i distance:300];
			[self addStaticLight:cpv(  0, 320) intensity:i distance:200];
			[self renderStaticLightMap];
		}
		
		// Setup the laser pieces
		laserEmitter = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
		laserEmitter.angle = -M_PI_4;
		laserEmitter.pos = laserStartPos;
		[sprites addObject:SpriteOffset(MAKE_FLIP_FLOP_LEVER_SPRITE(laserEmitter), cpv(0, -12))];
		laserEnd = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
		laserEnd.pos = laserEndPos;
		[sprites addObject:MAKE_PIXIE_SPRITE(laserEnd)];
		[sprites addObject:MAKE_PIXIE_SPRITE(laserEnd)]; // cheap trick to make it double bright
		[ropes addObject:MakeRope(staticBody, laserEnd, laserStartPos, cpvzero, ropeTypeLaser)];
		
		door1 = [self addSlidingDoor:cpv(x1, 320 - y)];
		door2 = [self addSlidingDoor:cpv(x2, 320 - y)];
		
		ChipmunkConstraint *groove;
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door1 groove_a:cpv(x1, -70) groove_b:cpv(x1, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot1 = [[ChipmunkPivotJoint alloc] initWithBodyA:door1 bodyB:staticBody pivot:cpv(x1, y)];
    pivot1.maxBias = 30.0f;
		pivot1.maxForce = 2000.0f;
		[self addChipmunkObject:pivot1]; [pivot1 release];

    groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door2 groove_a:cpv(x2, -70) groove_b:cpv(x2, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot2 = [[ChipmunkPivotJoint alloc] initWithBodyA:door2 bodyB:staticBody pivot:cpv(x2, y)];
    pivot2.maxBias = 30.0f;
		pivot2.maxForce = 2000.0f;
		[self addChipmunkObject:pivot2]; [pivot2 release];
		
		for(int i=0; i<5; i++)
			[self addSmallBox:cpv(220, 285 - i*32)];
		
		[self addEndArrow:cpv(430, 85) angle:0];
		[self addGoalOrb:cpv(430, 123)];
		[self addPlayerBall:cpv(20, 140)];
	}
	
	return self;
}

- (void)update {
	cpSegmentQueryInfo info;
	if(!cpSpacePointQueryFirst(space.space, laserStartPos, -1, 0)){
		cpSpaceSegmentQueryFirst(space.space, laserStartPos, laserEndPos, -1, 0, &info);
	} else {
		info.t = 0.0f;
	}
	
	laserEnd.pos = cpSegmentQueryHitPoint(laserStartPos, laserEndPos, info);
	cpFloat laserRatio = cpSegmentQueryHitDist(laserStartPos, laserEndPos, info)/cpvdist(laserStartPos, laserEndPos);
	
	cpFloat openAmount = 70.0f*(1.0f - laserRatio);
	pivot1.anchr2 = cpv(x1, y + openAmount);
	pivot2.anchr2 = cpv(x2, y - openAmount);
	
  [super update];
}

- (void) dealloc
{
	[laserEnd release];
	
	[super dealloc];
}


@end
