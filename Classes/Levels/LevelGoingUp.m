#import "LevelStateDelegate.h"

@implementation LevelGoingUp

+ (NSString *)levelName {
	return @"Going Up?";
}

- (ChipmunkBody *)addSmallBox:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat r = 15;
	cpFloat m = 1.2f;
  
  cpVect verts[] = {
    cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
  [sprites addObject:MAKE_SMALL_BOX_SPRITE(body)];
  
  return body;
}


- (void)addElevator:(cpVect)atPoint {
	atPoint.y = 320 - atPoint.y;
	
	float width = 10.0f;
	float height = 50.0f;
	cpFloat m = 0.7f;
	
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
		shape.friction = 0.3f;
		shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
		[space addObject:shape]; [shape release];
		
		[sprites addObject:SpriteOffset(MAKE_DRAWBRIDGE_SPRITE(body), offset)];
		
		[self addShadowBox:body offset:offset width:width height:height];
		
	}
	
	{
		cpVect offset = cpv(elevatorHeight, 0);
		ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:offset];
		shape.friction = 0.3f;
		shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
		[space addObject:shape]; [shape release];
		
		[sprites addObject:SpriteOffset(MAKE_DRAWBRIDGE_SPRITE(body), offset)];
		
		[self addShadowBox:body offset:offset width:width height:height];
		
	}
	
	ChipmunkConstraint * joint = [[ChipmunkGrooveJoint alloc] 
																 initWithBodyA:staticBody	bodyB:body groove_a:cpvadd(atPoint, cpv(0, -150)) 
																 groove_b:atPoint anchr2:cpvzero];
	[space addObject:joint]; [joint release];

	joint = [[ChipmunkDampedSpring alloc] 
					 initWithBodyA:staticBody	bodyB:body anchr1:cpv(atPoint.x, atPoint.y + 15.0f)	anchr2:cpvzero restLength:0 stiffness:4.0f	damping:1.0f];
	[space addObject:joint]; [joint release];
	
	[ropes addObject:MakeRope(body, body,  cpv(elevatorHeight, -41),  cpv(-elevatorHeight, -41), ropeTypeRope)];
	[ropes addObject:MakeRope(body, body,  cpv(elevatorHeight,  41),  cpv(-elevatorHeight,  41), ropeTypeRope)];

	[ropes addObject:MakeRope(body, body,  cpv(elevatorHeight,  0),  cpv(300, 0), ropeTypeChain)];
}


- (id)init {
	if(self = [super init]){
    ambientLevel = 0.4f;
    goldPar = 4;
    silverPar = 7;
    
		int polylines[] = {
			32,   -100,
			32, 112,
			192, 112,
			192, 144,
			32, 144,
			32, 400,
			-1,
			96, 500,
			96, 224,
			192, 224,
			192, 500,
			-1,
			304, 500,
			304, 224,
			448, 224,
			448, 144,
			304, 144,
			304, 112,
			500, 112,			
			-1, -1,
			
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
		[self loadBG:@"levelGoingUp"];
		[self nextLevelDirection:(physicsOutsideBorderLayer | physicsBorderInsideRightLayer)]; // we need to collide with this to win the level.
		
		[self addStaticLight:cpv(16, 128) intensity:0.3f distance:300];
		[self addStaticLight:cpv(464, 128) intensity:0.3f distance:300];
        
    [self addStaticLight:cpv(-10, -10) intensity:0.5f distance:150];
		[self renderStaticLightMap];
		
		[self addSmallBox:cpv(336, 208)];
		[self addSmallBox:cpv(352, 208)];
		[self addSmallBox:cpv(368, 208)];
		
		[self addElevator:cpv(247, 185)];
		
		[self addTorch:cpv(112, 88)];
		
		[self addGoalOrb:cpv(432, 68)];

		[self addPlayerBall:cpv(52, 320) vel:cpv(35.0f, 170.0f)];
		ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);
 		[self addEndArrow:cpv(380, 30) angle:0];

	}
	
	return self;
}


@end
