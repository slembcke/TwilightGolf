#import "LevelStateDelegate.h"

@implementation LevelRotator

+ (NSString *)levelName {
	return @"Rotational Doom";
}

static void 
customVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpBodyUpdateVelocity(body, cpvzero, 1.0f, dt);
}

- (void)addRotatorStone:(cpFloat)angle dist:(cpFloat)dist speed:(cpFloat)speed {
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = cpv(240, 160);
	body.angle = angle;
	body.angVel = speed;
	body.body->velocity_func = customVelocity;
	[space addObject:body]; [body release];
	
	cpVect offset = cpv(dist, 0);
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:offset];
	shape.collisionType = physicsPusherType;
	[space addObject:shape]; [shape release];
	
	[sprites addObject:SpriteOffset(MAKE_ARROW_STONE_SPRITE(body), offset)];
	
	[self addShadowCircle:body offset:offset radius:r];
}

- (void)addRotatorRing:(cpFloat)radius count:(int)count speed:(cpFloat)speed {
	for(int i=1; i<count; i++){
		if(i == count/2) continue;
		cpFloat angle = 2.0f*M_PI*(cpFloat)i/(cpFloat)count;
		[self addRotatorStone:angle dist:radius speed:speed];
	}
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 1;
    silverPar = 6;
    
		int polylines[] = { //62 74
			-50, 245, // left bottom
			 97, 245,
			 97, 700,
//			-1,
//			383, 700, // right bottom
//			383, 245,
//			700, 245,
//			-1,
//			-50,  62, // left funnel
//			 74,  62,
//			 74,  46,
//			  0, -50,
//			-1,
//			700,  62, // right funnel
//			409,  62,
//			409,  46,
//			480, -50,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelCrumble"];
		[self nextLevelDirection:physicsOutsideBorderLayer];

		{
			float i = 0.5f;
			float d = 150;
//			[self addStaticLight:cpv( 30,  30) intensity:i distance:d];
//			[self addStaticLight:cpv(450,  30) intensity:i distance:d];
			[self addStaticLight:cpv(  30, 290) intensity:i distance:d];
//			[self addStaticLight:cpv(450, 290) intensity:i distance:d];
			[self renderStaticLightMap];
		}
		
		[self addRotatorRing:50 count:6 speed:0.9f];
		[self addRotatorRing:100 count:12 speed:-0.7f];
		
		[self addEndArrow:cpv(240, 300) angle:-M_PI_2];
		[self addRigidGoalOrb:cpv(240, 160)];
		[self addPlayerBall:cpv(25, 160) vel:cpv(2, 2)];
		ballShape.layers &= ~(physicsBorderInsideBottomLayer|physicsOutsideBorderLayer);
	}
	
	return self;
}

@end
