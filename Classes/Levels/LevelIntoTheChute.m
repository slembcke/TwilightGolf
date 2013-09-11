#import "LevelStateDelegate.h"

@implementation LevelIntoTheChute

+ (NSString *)levelName {
	return @"Down the Hatch";
}

- (void)addFlipper:(cpVect)atPoint {
	atPoint.y = 320 - atPoint.y;
	
	float width = 10.0f;
	float height = 50.0f;
	cpFloat m = 0.7f;
	
	cpVect verts[] = {
		cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	body.angle = 4.8f;
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.3f;
	shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
	
	ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:cpvadd(atPoint, cpv(25, 0))];
	[self addChipmunkObject:pivot]; [pivot release];
	
	ChipmunkRotaryLimitJoint *limiter = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:body min:4.0 max:4.8f];
	[self addChipmunkObject:limiter]; [limiter release];
	
	ChipmunkRatchetJoint *ratchet = [[ChipmunkRatchetJoint alloc] initWithBodyA:staticBody bodyB:body phase:0.0f ratchet:-0.1f];
	[self addChipmunkObject:ratchet]; [ratchet release];
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
	[sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
}

- (id)init {
	if(self = [super init]){
    ambientLevel = 0.4f;
    goldPar = 2;
    silverPar = 6;
    
		int polylines[] = {
			-100, 178,
			0, 178, 
			76, 104,
			76, 30,
			464, 30,
			464, 500,
			-1,
			159, 97,
			400, 97,
			-1,
			-100, 293,
			386, 293,
			386, 235,
			396, 235,
			396, 500,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelIntoTheChute"];
		[self nextLevelDirection:physicsOutsideBorderLayer]; // we need to collide with this to win the level.
		
		[self addStaticLight:cpv(480, 288) intensity:0.3f distance:300];
		[self addStaticLight:cpv(480,   0) intensity:0.3f distance:300];
    
		[self addStaticLight:cpv(40, 304) intensity:0.3f distance:300];
		[self addStaticLight:cpv(272, 304) intensity:0.2f distance:300];
		[self addStaticLight:cpv(390, 250) intensity:0.4f distance:300];
    
    [self addStaticLight:cpv(-10, -10) intensity:0.5f distance:150];
		[self renderStaticLightMap];
    
//		[self addMoss:cpv(470, 304) big:TRUE];
		
		[self addTorch:cpv(120, 265)];
	  [self addTorch:cpv(300, 265)];

		[self addFlipper:cpv(120, 103)];
		[self addChuteHinge:cpv(416, 103)];
		
		goalOrbBody = [self addRollingGoalOrb:cpv(98, 74)];
		[self addPlayerBall:cpv(26, 239) vel:cpv(40,40)];
		ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);

 		[self addEndArrow:cpv(440, 260) angle:-M_PI_2];
	}
	
	return self;
}


@end
