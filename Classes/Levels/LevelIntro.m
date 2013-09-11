#import "LevelStateDelegate.h"

@implementation LevelIntro

+ (NSString *)levelName {
	return @"Heading In";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 2;
		silverPar = 3;
    
		int polylines[] = {
			-50, 170,
			116, 170,
			242, 295,
			700, 295,
			-1,
			107, -50,
			107, 115,
			700, 115,
			-1,-1,
		};
		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"levelIntro"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
		float v = 0.7f;

		// Add some static lights.
		[self addStaticLight:cpv(261,  57) intensity:v distance:190.0f];
		[self addStaticLight:cpv(  200, 320) intensity:v distance:200.0f];
		[self renderStaticLightMap];

		[self addStaticLight:cpv(-10, -10) intensity:v distance:300.0f];

		[self addBrokenLight:cpv(375, 115) length:38.0f];
		[self addLight:cpv(350, 115) length:30.0f intensity:0.6f distance:100.0f];
		[self addBrokenLight:cpv(325, 115) length:38.0f];

		[self addMoss:cpv(183, 114) big:true];

		[self addEndArrow:cpv(430, 200) angle:0.0f];
		[self addGoalOrb:cpv(430,250)];
		[self addPlayerBall:cpv(46, 144)];
	}
	
	return self;
}

@end
