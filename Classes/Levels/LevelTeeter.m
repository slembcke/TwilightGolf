#import "LevelStateDelegate.h"

@implementation LevelTeeter

+ (NSString *)levelName {
	return @"Teeter";
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
  
  ChipmunkRotaryLimitJoint *limiter = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:body bodyB:staticBody min:-0.55f max:0];
  [self addChipmunkObject:limiter]; [limiter release];
  
  [self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_TEETER_SPRITE(body)];
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.2f;
		goldPar = 4;
		silverPar = 6;
		
		int polylines[] = {
			 -100, 54, 
			 86, 54,
			86, 281,
			208, 281,
			266, 176,
			319, 281,
			442, 281,
			442, 156,
			700, 156,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelTeeter"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		[self addStaticLight:cpv(480, 160) intensity:0.5 distance:300];
		[self addStaticLight:cpv(  0, 160) intensity:0.5 distance:300];
		[self addStaticLight:cpv(240, 320) intensity:0.5 distance:300];
		[self renderStaticLightMap];

		[self addMoss:cpv(167, 283) big:FALSE rot:M_PI];

		[self addLight:cpv(155, -20) length:60.0f intensity:0.8f distance:130.0f];
//		[self addLight:cpv(175, -20) length:115.0f intensity:0.8f distance:130.0f];
		[self addTeeter:cpv(266, 176)];
		
		[self addBigBox:cpv(315, 130) radius:25.0f mass:5.0f];
		
		[self addEndArrow:cpv(460, 70) angle:0];
		[self addGoalOrb:cpv(391, 233)];
    [self addPlayerBall:cpv(18, 36) vel:cpv(5, 0)];

	}
	
	return self;
}

@end
