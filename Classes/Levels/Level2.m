#import "LevelStateDelegate.h"

@implementation Level2

+ (NSString *)levelName {
	return @"A First Barrier";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15;
    goldPar = 1;
		silverPar = 2;
    
		int polylines[] = {
			 0, 298, 
			 77, 298,
			173, 203,
			304, 203,
			402, 298,
			480, 298,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"level2"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		[self addStaticLight:cpv(240, 320) intensity:1 distance:300];
		[self renderStaticLightMap];

		[self addLight:cpv(360, 0) length:70.0f intensity:0.5f distance:350.0f];
		
		[self addSmallBox:cpv(240, 187)];
		[self addSmallBox:cpv(240, 155)];
		[self addSmallBox:cpv(240, 123)];
		[self addSmallBox:cpv(240, 91)];
		[self addSmallBox:cpv(240, 59)];
		[self addSmallBox:cpv(240, 27)];
		
		[self addEndArrow:cpv(450, 215) angle:0.0f];
		[self addChainedGoalOrb:cpv(450, 0) length:120.0f];
		[self addPlayerBall:cpv(23, 117) vel:cpv(30, 20)];
	}
	
	return self;
}

@end
