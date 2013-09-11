#import "LevelStateDelegate.h"
#import "ChipmunkSpaceExtras.h"


@interface OneWayPlatform : NSObject{
	cpVect n; // direction objects may pass through
	cpArray *passThruList; // list of objects passing through  
}

@property cpVect n;
@property cpArray *passThruList;

@end


@implementation OneWayPlatform
  @synthesize n;
  @synthesize passThruList;
@end

@implementation LevelPassthrough

OneWayPlatform* platform1;
OneWayPlatform* platform2;
OneWayPlatform* platform3;

+ (NSString *)levelName {
	return @"Passthrough";
}

static int
preSolve(cpArbiter *arb, cpSpace *space, void *ignore)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
	OneWayPlatform *platform = ((ChipmunkShape*) a->data).data;
	
	if(cpArrayContains(platform.passThruList, b)){
		// The object is in the pass thru list, ignore it until separates.
		return 0;
	} else {
		cpFloat dot = cpvdot(cpArbiterGetNormal(arb, 0), platform.n);
		
		if(dot < 0){
			// Add the object to the pass thrru list
			cpArrayPush(platform.passThruList, b);
			return 0;
		} else {
			return 1;
		}
	}

  //return 0;
}

static void
separate(cpArbiter *arb, cpSpace *space, void *ignore)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
  OneWayPlatform *platform = ((ChipmunkShape*) a->data).data;

	// remove the object from the pass thru list
	cpArrayDeleteObj(platform.passThruList, b);
}


- (ChipmunkShape*)addArrowBoard:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float height = 12.0f;
  float width = 48.0f;
	
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };

	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = atPoint;
	
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[space addStaticShape:shape]; [shape release];
  shape.group = physicsMechanicalGroup;
  shape.collisionType = physicsOneWayPlatformType;
	shape.friction = 0.6f;
  shape.elasticity = 1.0f;
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_ARROW_BOARD_SPRITE(body)];
  
  return shape;
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15;
    goldPar = 2;
		silverPar = 4;

    
    int polylines[] = {
      -100, 281,
      403, 281,
      403, 145,
      500, 145,
      -1,
      
      32,  66,
      32, 221,
      63, 221,
      63,  66,
      32,  66,
      -1,
      
      160, 145,
			307, 145,
			307, 175,
			160, 175,
      160, 145,
      -1,

      225,  -100,
			225,  67,
			160,  67,
			160,  97,
			320,  97,
			320,  -100,
      -1, -1
      
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelPassthrough"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
    
		[self addStaticLight:cpv(268,  81) intensity:0.55 distance:350];
		[self addStaticLight:cpv(460, 310) intensity:0.55 distance:250];
    
		[self addStaticLight:cpv(47, 139) intensity:0.55 distance:200];
		[self addStaticLight:cpv(163, 293) intensity:0.55 distance:200];
		[self addStaticLight:cpv(221, 162) intensity:0.55 distance:120];

    [self renderStaticLightMap];

		[self addLight:cpv(266, 178) length:15.0f intensity:0.5f distance:250.0f];
		[self addLight:cpv(400, -10) length:45.0f intensity:0.5f distance:250.0f];
    
    ChipmunkShape* shape = [self addArrowBoard:cpv(112, 160)];
    // We'll use the data pointer for the OneWayPlatform struct
    platform1 = [OneWayPlatform alloc];
    platform1.n = cpv(0, 1); // let objects pass upwards
    platform1.passThruList = cpArrayNew(0);
    shape.data = platform1;
    shape.body.angle = M_PI;
    
    shape = [self addArrowBoard:cpv(112,  83)];
    platform2 = [OneWayPlatform alloc];
    platform2.n = cpv(0, 1); // let objects pass upwards
    platform2.passThruList = cpArrayNew(0);
    shape.data = platform2;
    shape.body.angle = M_PI;
    
    shape = [self addArrowBoard:cpv(355, 161)];
    platform3 = [OneWayPlatform alloc];
    platform3.n = cpv(0, -1);
    platform3.passThruList = cpArrayNew(0);
    shape.data = platform3;
    
		[self addGoalOrb:cpv(452, 103)];
		[self addPlayerBall:cpv(25, 259) vel:cpv(30, 10)];
    
    cpSpaceAddCollisionHandler(space.space, physicsOneWayPlatformType, physicsBallType, NULL, preSolve, NULL, separate, NULL);
    
  }
	
	return self;
}

@end
