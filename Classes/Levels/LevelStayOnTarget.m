#import "LevelStateDelegate.h"

@implementation LevelStayOnTarget

+ (NSString *)levelName {
	return @"Stay On Target...";
}

- (ChipmunkBody*)addFloater:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float width = 10.0f;
  float height = 46.0f;
	cpFloat m = 3.0f;
  
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:INFINITY];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
  body.angle = cpvtoangle(cpv(0, 1));

  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 1.0f;
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
  
  return body;
}



- (ChipmunkBody*)addArrowStone:(cpVect)pos{
  pos.y = 320 - pos.y;
	cpFloat r = 14.0f;
  
  ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:INFINITY];
  body.pos = pos;
  body.angle = cpvtoangle(cpv(-1, 0));
 	[space addObject:body]; [body release];
 
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.collisionType = physicsPusherType;
  shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
  [space addObject:shape];
	
	[sprites addObject:MAKE_ARROW_STONE_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  return body;
}

- (void)addJointGroup:(NSMutableArray*)group object:(ChipmunkBody*)body{
  //make a joint.
  ChipmunkPivotJoint* pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:body.pos];
  [self addChipmunkObject:pivot]; [pivot release];
 
  [group addObject:pivot];
}

ChipmunkPivotJoint* floaterPivot;

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.1f;
    goldPar = 1;
    silverPar = 4;
    
    leftGroup = [[NSMutableArray alloc] init];
    rightGroup = [[NSMutableArray alloc] init];
		
		int polylines[] = { //62 74
			-50, 245, // left bottom
			 97, 245,
			 97, 700,
			-1,
			383, 700, // right bottom
			383, 245,
			700, 245,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelCrumble"];
		[self nextLevelDirection:(physicsBorderInsideRightLayer | physicsOutsideBorderLayer)];
   
		[self addLight:cpv(50,0) length:50.0f intensity:0.5f distance:250.0f];
		[self addLight:cpv(430,0) length:50.0f intensity:0.5f distance:250.0f];
				
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,5)]]; // fix to use offset sprites
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,55)]];
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,205)]];
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,255)]];
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,305)]];
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,355)]];
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,405)]];
		[self addJointGroup:leftGroup object:[self addArrowStone:cpv(210,-45)]];
		
    [self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,5)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,55)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,205)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,255)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,305)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,355)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,405)]];
		[self addJointGroup:rightGroup object:[self addArrowStone:cpv(270,-45)]];
    
    floater = [self addFloater:cpv(40, 225)];
    floaterPivot = [[ChipmunkPivotJoint alloc] initWithBodyA:floater bodyB:staticBody pivot:floater.pos];
    floaterPivot.maxForce = 100000.0f;
    [self addChipmunkObject:floaterPivot]; [floaterPivot release];
		
		[self addEndArrow:cpv(440, 145) angle:0];
		[self addGoalOrb:cpv(440, 198)];
		[self addPlayerBall:cpv(25, 130) vel:cpv(6,0)];
    ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);
	}
	
	return self;
}

- (void)update {
  [super update];
  
  int direction1 = (ticks % 200) / 100;
  if(direction1 == 0){
    direction1 = -1;
  }
  int direction2 = (ticks % 120) / 60;
  if(direction2 == 0){
    direction2 = -1;
  }
  
  for(ChipmunkPivotJoint* pivot in leftGroup){
    pivot.anchr1 = cpvadd( pivot.anchr1, cpv(0, direction1));
  }
  for(ChipmunkPivotJoint* pivot in rightGroup){
    pivot.anchr1 = cpvadd( pivot.anchr1, cpv(0, (direction2 * 2.7f)));
  }
  
  int direction3 = (ticks % 350) / 175;
  if(direction3 == 0){
    direction3 = -1;
  }
  floaterPivot.anchr1 = cpvadd( floaterPivot.anchr1, cpv((direction3 * 0.5f), 0));
  //floater.vel = cpv(0, direction3);
}


@end
