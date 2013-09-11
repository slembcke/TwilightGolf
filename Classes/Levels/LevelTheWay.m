#import "LevelStateDelegate.h"

@implementation LevelTheWay

+ (NSString *)levelName {
	return @"The Way";
}

- (id)init {
	if(self = [super init]){
    goldPar = 1;
		silverPar = 2;
    
		int polylines[] = { // 332 394
			  0,  24,
			480,  24,
			 -1,
			  0, 288,
			 65, 288,// left column
			 65, 160,
			131, 160,
			131, 288,
			200, 288,// mid column
			200, 126,
			263, 126,
			263, 288,
			332, 288,// right column
			332, 160,
			394, 160,
			394, 288,
			480, 288,
			 -1,  -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelTheWay"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		[self addStaticLight:cpv(120, 200) intensity:0.5 distance:100];
		[self addStaticLight:cpv(240, 200) intensity:0.5 distance:100];
		[self addStaticLight:cpv(360, 200) intensity:0.5 distance:100];
		[self renderStaticLightMap];
		
		cpVect center = cpv(240, 60);
		cpVect pointAt = cpv(0, 150);
		for(int d=-180; d<=180; d+=60){
			cpFloat fall = d*d/1000.0f;
			cpVect pos = cpvadd(center, cpv( d, fall));
			[self addArrowStone:pos pointAt:pointAt];
			
			pointAt = pos;
		}
		
    [self addMoss:cpv(299, 288) big:TRUE];
 
		[self addArrowStone:cpv(165, 170) pointAt:cpv(165, 150)];
		[self addArrowStone:cpv(297, 170) pointAt:cpv(297, 150)];
		
		[self addEndArrow:cpv(440, 190) angle:0];
		[self addGoalOrb:cpv(440, 243)];
		[self addPlayerBall:cpv(25, 219) vel:cpv(0, 150)];
	}
	
	return self;
}

@end
