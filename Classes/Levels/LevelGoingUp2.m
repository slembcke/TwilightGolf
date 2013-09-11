#import "LevelStateDelegate.h"

@implementation LevelGoingUp2

+ (NSString *)levelName {
	return @"Cross the Elevators";
}

- (ChipmunkBody *)addSmallBox:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat r = 15;
	cpFloat m = 3.0f;
  
  cpVect verts[] = {
    cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 1.1f;
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
  [sprites addObject:MAKE_SMALL_BOX_SPRITE(body)];
  
  return body;
}


- (void)addElevator:(cpVect)atPoint force:(int)force{
	atPoint.y = 320 - atPoint.y;
	
	float width = 10.0f;
	float height = 50.0f;
	cpFloat m = 1.0f;
	
	cpVect verts[] = {
		cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:INFINITY];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	body.angle = M_PI_2;
	
	int elevatorHeight = 50;
	{
		cpVect offset = cpv(-elevatorHeight, 0);	
		ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:offset];
		shape.friction = 0.4f;
		shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
		[space addObject:shape]; [shape release];
		
		[sprites addObject:SpriteOffset(MAKE_DRAWBRIDGE_SPRITE(body), offset)];
		
		[self addShadowBox:body offset:offset width:width height:height];
		
	}
	
	{
		cpVect offset = cpv(elevatorHeight, 0);
		ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:offset];
		shape.friction = 1.0f;
		shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
		[space addObject:shape]; [shape release];
		
		[sprites addObject:SpriteOffset(MAKE_DRAWBRIDGE_SPRITE(body), offset)];
		
		[self addShadowBox:body offset:offset width:width height:height];
		
	}
	
	ChipmunkConstraint * joint = [[ChipmunkGrooveJoint alloc] 
																 initWithBodyA:staticBody	bodyB:body groove_a:cpvadd(atPoint, cpv(0, -2 * elevatorHeight)) 
																 groove_b:atPoint anchr2:cpvzero];
	[space addObject:joint]; [joint release];

	joint = [[ChipmunkPivotJoint alloc] 
					 initWithBodyA:staticBody	bodyB:body pivot:cpv(atPoint.x, atPoint.y + 15.0f)];
	joint.maxForce = force;
	[space addObject:joint]; [joint release];
	
	
	joint = [[ChipmunkDampedSpring alloc] 
					 initWithBodyA:staticBody bodyB:body anchr1:cpv(atPoint.x, atPoint.y + 15.0f) anchr2:cpvzero restLength:0 stiffness:0.0f damping:2.2f];
	joint.maxForce = force;
	[space addObject:joint]; [joint release];
	

	[ropes addObject:MakeRope(body, body,  cpv(elevatorHeight, -41),  cpv(-elevatorHeight, -41), ropeTypeRope)];
	[ropes addObject:MakeRope(body, body,  cpv(elevatorHeight,  41),  cpv(-elevatorHeight,  41), ropeTypeRope)];

	[ropes addObject:MakeRope(body, body,  cpv(elevatorHeight,  0),  cpv(300, 0), ropeTypeChain)];
}


- (id)init {
	if(self = [super init]){
    ambientLevel = 0.4f;
    goldPar = 6;
    silverPar = 12;
		
		int polylines[] = {
			-100, 176,
			96, 176,
			96, 500,
			-1,
			204, -100,
			204, 112,
			224, 112,
			224, -100,
			-1,
			208, 500,
			208, 176,
			224, 176,
			224, 500,
			-1,
			336, 500,
			336, 288,
			500, 288,
			-1,
			-100, 80,
			96, 80,
			96, -100,
			-1,
			500, 176,
			336, 176,
			336, 208,
			500, 208,
			-1, -1,
		};
		
		[self addPolyLines:polylines];
		[self loadBG:@"levelGoingUp2"];
		[self nextLevelDirection:(physicsOutsideBorderLayer | physicsBorderInsideRightLayer)]; // we need to collide with this to win the level.
		
		[self addStaticLight:cpv(16, 128) intensity:0.3f distance:300];
		[self addStaticLight:cpv(464, 128) intensity:0.3f distance:300];
        
    [self addStaticLight:cpv(-10, -10) intensity:0.5f distance:150];
		[self renderStaticLightMap];
		
		[self addSmallBox:cpv(152,  58)];
		[self addSmallBox:cpv(80, 160)];

		[self addElevator:cpv(152, 133) force:600];
		[self addElevator:cpv(278, 133) force:600];

		[self addTorch:cpv(432,  150)];
		
		[self addGoalOrb:cpv(432, 242)];

		[self addPlayerBall:cpv(16, 128) vel:cpv(15.0f, 10.0f)];
		ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);
 		[self addEndArrow:cpv(380, 30) angle:0];

	}
	
	return self;
}


@end
