#import "LevelStateDelegate.h"

@implementation LevelFlywheel

+ (NSString *)levelName {
	@throw [[NSException alloc] init];
	return @"RENAME ME";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 20;
    silverPar = 28;		
		
//		int polylines[] = {
//			-1,-1,
//		};
//		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"temp"];
		[self nextLevelDirection:physicsBorderInsideTopLayer];
		
//		{ // Add some static lights.
//			[self addStaticLight:cpv(x,   0) intensity:1.0f distance:dist];
//			[self renderStaticLightMap];
//		}
		
		
		[self addEndArrow:cpv(240, 160) angle:0.0f];
		[self addGoalOrb:cpv(440,270)];
		[self addPlayerBall:cpv(240, 160)];
	}
	
	return self;
}

@end
