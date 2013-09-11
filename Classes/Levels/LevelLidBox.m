#import "LevelStateDelegate.h"

@implementation LevelLidBox

+ (NSString *)levelName {
	return @"Sarcophagus";
}

- (ChipmunkBody *)addSmallBox:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat r = 15;
	cpFloat m = 0.2f;
  
  cpVect verts[] = {
    cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
  
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
  shape.layers &= ~physicsOutsideBorderLayer;
	shape.layers &= ~physicsBorderInsideTopLayer;
	shape.layers &= ~physicsBorderInsideBottomLayer;
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
  [sprites addObject:MAKE_SMALL_BOX_SPRITE(body)];
  
  return body;
}



- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 3;
    silverPar = 5;
		
		int polylines[] = {
      
      -100,  22,
			452,  22,
			450,  50,
			407,  50,
			402, 122,
			380, 125,
			378, 210,
			500, 210,
      -1,
      298, 500,
			295, 314,
			298, 131,
			335, 133,
			333, 267,
			345, 287,
			480, 299,
			600, 299,
      -1,
      196, 203,
      44, 205,
			117, 275,
			196, 203,
			-1,-1,
		};
    
		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"levelLidBox"];
    [self nextLevelDirection:physicsBorderInsideBottomLayer | physicsBorderInsideRightLayer | physicsOutsideBorderLayer];
		
		[self addStaticLight:cpv(117, 234) intensity:0.55 distance:250];

		[self addStaticLight:cpv(50, -50) intensity:0.4 distance:350];
    [self addStaticLight:cpv(600, 5) intensity:0.4 distance:350];
    
    [self addStaticLight:cpv(460, 150) intensity:0.55 distance:100];
		[self addStaticLight:cpv(317, 152) intensity:0.6 distance:140];
    [self addStaticLight:cpv(337, 362) intensity:0.3 distance:200];
    
    [self renderStaticLightMap];
    
		[self addLight:cpv(	155,  30) length:15.0f intensity:0.5f distance:250.0f];
		
		const float boardMassCoef = 2.5f;
		ChipmunkBody *board = [self addBoard:cpv(384-50, 112-12)];
		board.angle = M_PI_2;
		board.mass *= boardMassCoef;
		board.moment *= boardMassCoef;
		
		const float blockMassCoef = 40.0f;
		ChipmunkBody *block = [self addSmallBox:cpv(328-42,  80-12)];
		block.mass *= blockMassCoef;
		block.moment *= blockMassCoef;
		
		cpVect anchr1 = cpv(0, 50);
		cpVect anchr2 = cpv(0, 10);
		ChipmunkSlideJoint *chain = [[ChipmunkSlideJoint alloc] initWithBodyA:board bodyB:block anchr1:anchr1 anchr2:anchr2 min:0.0f max:128.0f];
		[space addObject:chain]; [chain release];
		[ropes addObject:MakeRope2(board, block, anchr1, anchr2, 96.0f, ropeTypeChain)];
		
		[self addEndArrow:cpv(240, 160) angle:0.0f];
		[self addGoalOrb:cpv(440,252)];
		[self addPlayerBall:cpv(25, 110) vel:cpv(30, 5)];
    ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsBorderInsideLeftLayer | physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);

	}
	
	return self;
}

@end
