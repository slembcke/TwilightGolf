#import "LevelStateDelegate.h"

@implementation LevelSliders

+ (NSString *)levelName {
	return @"Sliders";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15;
    goldPar = 7;
		silverPar = 13;
    
    int polylines[] = {
      -100,  78,
			176,  78,
			177, 106,
			219, 106,
			220,  78,
			299,  78,
			299, 105,
			336, 105,
			336,  78,
			377,  78,
			377, 119,
      -100, 119,
      -1,
      
      -100, 283,
			146, 283,
			146, 203,
			242, 203,
			242, 280,
			355, 280,
			355, 203,
			434, 203,
			434,  77,
			500,  77,
			-1, -1,
      
      299,  92,
			336,  92,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelSliders"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
    
		[self addStaticLight:cpv(79, 111) intensity:0.55 distance:250];
		[self addStaticLight:cpv(266, 109) intensity:0.55 distance:120];
		[self addStaticLight:cpv(367, 112) intensity:0.55 distance:120];
    
		[self addStaticLight:cpv(194, 227) intensity:0.4 distance:130];
		[self addStaticLight:cpv(455,  98) intensity:0.4 distance:250];
		[self addStaticLight:cpv(404, 267) intensity:0.3 distance:80];
		
    [self renderStaticLightMap];

		[self addLight:cpv(29, 120) length:15.0f intensity:0.5f distance:250.0f];
		[self addLight:cpv(454, 9) length:25.0f intensity:0.5f distance:250.0f];
		 
    // const float boardMassCoef = 2.5f;
		ChipmunkBody *largeBlock = [self addBigBox:cpv(107, 164)];
		largeBlock.angle = M_PI_2;
		// largeBlock.mass *= boardMassCoef;
		// largeBlock.moment *= boardMassCoef;
		
		//const float blockMassCoef = 40.0f;
		ChipmunkBody *block = [self addBall:cpv(107,  61) canRollAway:FALSE];
		//block.mass *= blockMassCoef;
		//block.moment *= blockMassCoef;
		
    [self addSmallBox:cpv(268,  62)];
    
		ChipmunkSlideJoint *chain = [[ChipmunkSlideJoint alloc] initWithBodyA:largeBlock bodyB:block anchr1:cpv(10,0) anchr2:cpvzero min:0.0f max:95.0f];
		[space addObject:chain]; [chain release];
		[ropes addObject:MakeRope2(largeBlock, block, cpv(10,0), cpvzero, 100.0f, ropeTypeChain)];
		
		[self addGoalOrb:cpv(60, 236)];
		[self addPlayerBall:cpv(239,  60) vel:cpv(3, 15)];
	}
	
	return self;
}




@end
