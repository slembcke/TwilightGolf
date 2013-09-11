#import "LevelStateDelegate.h"

@implementation LevelFlipFlops

+ (NSString *)levelName {
	return @"Flip Flop";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.3f;
		goldPar = 2;
    silverPar = 3;

		
		int polylines[] = {
			 80, 208,
			304, 208,
			304, 288,
			  0, 288,
			  0, -50,
			-1,
			240,  36,
			700,  32,
			-1,
			144, 208,
			144, 192,
			336, 208,
			336, 700,
			-1,
			700, 192,
			400, 192,
			400, 700,
			-1,-1,
		};
		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"levelFlipFlops"];
		[self nextLevelDirection:physicsBorderInsideTopLayer];
		
		{ // Add some static lights.
//			[self addStaticLight:cpv(x,   0) intensity:1.0f distance:dist];
			[self renderStaticLightMap];
		}
		
		cpVect adj = cpv(-8, 8);
		[self addFlipFlop:cpvadd(adj, cpv(224,  64)) leverPos:cpv(128, 208) bump:  1.0f];
		[self addFlipFlop:cpvadd(adj, cpv(176, 112)) leverPos:cpv(256, 208) bump:  1.0f];
		[self addFlipFlop:cpvadd(adj, cpv(128, 160)) leverPos:cpv(192, 208) bump: -1.0f];
		
		[self addLight:cpv(27,  39) length:50.0f intensity:0.6f distance:100.0f];
		[self addMoss:cpv(85,  41) big:TRUE];
		
		[self addChuteHinge:cpv(32,208)];
		[self addTorch:cpv(432, 164)];
				
		[self addEndArrow:cpv(240, 160) angle:0.0f];
		goalOrbBody = [self addRollingGoalOrb:cpv(336,  16)];
		[self addPlayerBall:cpv(30, 240) vel:cpv(15, 0)];
	}
	
	return self;
}

@end
