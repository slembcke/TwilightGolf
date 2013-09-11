#import "LevelStateDelegate.h"

@implementation LevelStayOnTarget2

+ (NSString *)levelName {
	return @"...Stay on Target... II";
}

- (ChipmunkShape*)addArrowStone:(cpVect)offset to:(ChipmunkBody*) body{
  offset.y = 320 - offset.y;
	cpFloat r = 14.0f;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:offset];
	shape.collisionType = physicsPusherType;
  shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
	[space addObject:shape]; [shape release];
	
	[sprites addObject:SpriteOffset(MAKE_ARROW_STONE_SPRITE(body), offset)];
	
	[self addShadowCircle:body offset:offset radius:r];
  return shape;
}

- (ChipmunkShape*)addStickyStone:(cpVect)offset to:(ChipmunkBody*) body{
  offset.y = 320 - offset.y;
	cpFloat r = 14.0f;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:offset];
	shape.elasticity = 0.0f;
	shape.friction = 1.0f;
	shape.collisionType = physicsGooOrbType;
  shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
	[space addObject:shape]; [shape release];
	
	[sprites addObject:SpriteOffset(MAKE_GREEN_ORB_SPRITE(body), offset)];
	
	[self addShadowCircle:body offset:offset radius:r];
  return shape;
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.1f;
    goldPar = 2;
    silverPar = 4;
    
		int polylines[] = { //62 74
//			-50, 245, // left bottom
//			 97, 245,
//			 97, 700,
//			-1,
			342, 500, // right bottom
			342, 245,
			700, 245,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelStayOnTarget2"];
		[self nextLevelDirection:(physicsBorderInsideRightLayer | physicsOutsideBorderLayer)];
   
		[self addLight:cpv(50,0) length:50.0f intensity:0.5f distance:250.0f];
		[self addLight:cpv(430,0) length:50.0f intensity:0.5f distance:250.0f];
		
		{ 
			left = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:INFINITY];
			left.pos = cpv(160, 320);
			left.angle = M_PI;
			[space addObject:left]; [left release];
			
			pivotLeft = [[ChipmunkPivotJoint alloc] initWithBodyA:left bodyB:staticBody pivot:left.pos];
			[self addChipmunkObject:pivotLeft]; [pivotLeft release];

			[self addArrowStone:cpv(0,-45) to:left];
			[self addArrowStone:cpv(0,5) to:left];
			[self addArrowStone:cpv(0,55) to:left];
			[self addArrowStone:cpv(0,205) to:left];
			[self addArrowStone:cpv(0,255) to:left];
			[self addArrowStone:cpv(0,305) to:left];
			[self addArrowStone:cpv(0,355) to:left];
			[self addArrowStone:cpv(0,405) to:left];
    }
		
		{ 
			right = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:INFINITY];
			right.pos = cpv(320, 320);
			right.angle = M_PI;
			[space addObject:right]; [right release];
			
			pivotRight = [[ChipmunkPivotJoint alloc] initWithBodyA:right bodyB:staticBody pivot:right.pos];
			[self addChipmunkObject:pivotRight]; [pivotRight release];
			
			[self addArrowStone:cpv(0,-195) to:right];
			[self addArrowStone:cpv(0,-145) to:right];
			[self addArrowStone:cpv(0,-95) to:right];
			[self addArrowStone:cpv(0,-45) to:right];
			[self addArrowStone:cpv(0,5) to:right];
			[self addArrowStone:cpv(0,55) to:right];
			[self addArrowStone:cpv(0,205) to:right];
			[self addArrowStone:cpv(0,255) to:right];
			[self addArrowStone:cpv(0,305) to:right];
    }
		
		{ 
			mid = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:INFINITY];
			mid.pos = cpv(240, 320);
			mid.angle = M_PI;
			[space addObject:mid]; [mid release];
			
			pivotMid = [[ChipmunkPivotJoint alloc] initWithBodyA:mid bodyB:staticBody pivot:mid.pos];
			[self addChipmunkObject:pivotMid]; [pivotMid release];
			
			for(int i = -160; i < 400; i+= 80){
				[self addStickyStone:cpv(0,i) to:mid];
			}
    }
		
		[self addEndArrow:cpv(440, 145) angle:0];
		[self addGoalOrb:cpv(440, 195)];
		[self addPlayerBall:cpv(25, 130) vel:cpv(20,20)];
    ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);

	}
	
	return self;
}

- (cpVect)anchorPos:(int)distance atSpeed:(float)speed{
	distance = distance / fabs(speed);
	if((ticks % (distance * 2)) / distance){
		return cpv(0, speed);
	}else{
		return cpv(0, -speed);
	}
}

- (void)update {
  [super update];
  
	pivotLeft.anchr1 = cpvadd(pivotLeft.anchr1, [self anchorPos:100 atSpeed:0.7f]);
	pivotMid.anchr1 = cpvadd(pivotMid.anchr1, [self anchorPos:200 atSpeed:-0.3f]);
	pivotRight.anchr1 = cpvadd(pivotRight.anchr1, [self anchorPos:205 atSpeed:-1.2f]);

}


@end
