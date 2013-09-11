#import "LevelStateDelegate.h"

@implementation LevelCams

+ (NSString *)levelName {
	return @"Cams";
}

- (ChipmunkBody*)addCam:(cpVect)atPoint {
	cpFloat m = 1.0f;
	cpFloat r = 28.0f;
	
	atPoint.y = 320 - atPoint.y;
	
	cpVect verts[] = {
		cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:INFINITY];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
	shape.layers = ~physicsTerrainLayer;
	
	cpVect groove_end = cpvadd(atPoint, cpv(r*2.0, 0.0));
	ChipmunkConstraint *joint = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:body groove_a:atPoint groove_b:groove_end anchr2:cpvzero];
	[self addChipmunkObject:joint]; [joint release];
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
	[sprites addObject:MAKE_BIG_BOX_SPRITE(body)];
	
	return body;
}

- (ChipmunkBody*)addVerticalCam:(cpVect)atPoint {
	cpFloat m = 1.0f;
	cpFloat r = 28.0f;
	
	atPoint.y = 320 - atPoint.y;
	
	cpVect verts[] = {
		cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:INFINITY];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
	shape.layers = ~physicsTerrainLayer;
	
	cpVect groove_end = cpvadd(atPoint, cpv(0.0, r*2.0));
	ChipmunkConstraint *joint = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:body groove_a:atPoint groove_b:groove_end anchr2:cpvzero];
	[self addChipmunkObject:joint]; [joint release];
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
	[sprites addObject:MAKE_BIG_BOX_SPRITE(body)];
	
	return body;
}

- (ChipmunkBody*)addGearStone:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat m = 1.0f;
	cpFloat r = 24.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	body.pos = atPoint; 
  [self addChipmunkObject:body]; [body release];
  
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.friction = 2.0f;
	shape.layers = 0;
	[self addChipmunkObject:shape]; [shape release];
	
  ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:atPoint];
  [self addChipmunkObject:pivot]; [pivot release];
  
	[sprites addObject:MAKE_GEAR_STONE_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  
  return body;
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15;
    goldPar = 8;
		silverPar = 13;
    
    int polylines[] = {
			 -100, 282, 
       500, 282,
      -1,
      
      80,  -100,
      80,  96,
			150,  96,
			150, 192,
			179, 192,
			179,  96,
			240,  96,
			240,  80,
			179,  80,
			179,  -100,
      -1,
			
			324,  -100,
			324, 162,
			256, 162,
			256, 181,
			416, 181,
			416,  -100,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelCams"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		[self addStaticLight:cpv(165,  91) intensity:0.4 distance:250];
		[self addStaticLight:cpv(94,  17) intensity:0.55 distance:80];
		[self addStaticLight:cpv(334, 171) intensity:0.55 distance:80];
		[self addStaticLight:cpv(268, 173) intensity:0.55 distance:80];
		[self addStaticLight:cpv(345,  12) intensity:0.4 distance:250];
		[self addStaticLight:cpv(390, 307) intensity:0.6 distance:200];
    [self addStaticLight:cpv(104, 500) intensity:0.3 distance:400];
		
    [self renderStaticLightMap];

		[self addLight:cpv(380, 180) length:15.0f intensity:0.5f distance:250.0f];
		[self addLight:cpv(101, 96) length:15.0f intensity:0.5f distance:250.0f];
		
		ChipmunkConstraint *joint;
		ChipmunkBody *cam1, *cam2, *rotor;
		
		cam1 = [self addCam:cpv(152, 44)];
		cam2 = [self addVerticalCam:cpv(36, 151)];
		rotor = [self addGearStone:cpv(36, 44)];
		
		joint = [[ChipmunkPinJoint alloc] initWithBodyA:cam1 bodyB:rotor anchr1:cpvzero anchr2:cpv(-25, 0)];
		[self addChipmunkObject:joint]; [joint release];
		[ropes addObject:MakeRope(cam1, rotor, cpvzero, cpv(-25, 0), ropeTypeRod)];
		
		joint = [[ChipmunkPinJoint alloc] initWithBodyA:cam2 bodyB:rotor anchr1:cpvzero anchr2:cpv(0, -25)];
		[self addChipmunkObject:joint]; [joint release];
		[ropes addObject:MakeRope(cam2, rotor, cpvzero, cpv(0, -25), ropeTypeRod)];
		
		joint = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:rotor rate:1000.0f];
		joint.maxForce = 100.0f;
		[self addChipmunkObject:joint]; [joint release];
		
		cam1 = [self addCam:cpv(285, 128)];
		cam2 = [self addVerticalCam:cpv(449, 213)];
		rotor = [self addGearStone:cpv(449, 128)];
		
		joint = [[ChipmunkPinJoint alloc] initWithBodyA:cam1 bodyB:rotor anchr1:cpvzero anchr2:cpv(-25, 0)];
		[self addChipmunkObject:joint]; [joint release];
		[ropes addObject:MakeRope(cam1, rotor, cpvzero, cpv(-25, 0), ropeTypeRod)];
		
		joint = [[ChipmunkPinJoint alloc] initWithBodyA:cam2 bodyB:rotor anchr1:cpvzero anchr2:cpv(0, -25)];
		[self addChipmunkObject:joint]; [joint release];
		[ropes addObject:MakeRope(cam2, rotor, cpvzero, cpv(0, -25), ropeTypeRod)];
		
		joint = [[ChipmunkSimpleMotor alloc] initWithBodyA:staticBody bodyB:rotor rate:1000.0f];
		joint.maxForce = 100.0f;
		[self addChipmunkObject:joint]; [joint release];
		
		[self addRollingGoalOrb:cpv(209,  60)];
		[self addPlayerBall:cpv(29, 250) vel:cpv(40, 10)];
	}
	
	return self;
}




@end
