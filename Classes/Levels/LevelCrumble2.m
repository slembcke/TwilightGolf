#import "LevelStateDelegate.h"

@implementation LevelCrumble2


static cpVect
blockPos()
{
	return cpv(rand()%400 + 40, -(rand()%300));
}

+ (NSString *)levelName {
	return @"Crumbling II";
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.1f;
		blocks = [[NSMutableArray alloc] init];
    goldPar = 2;
    silverPar = 6;
    
		srand(98743);
		
		int polylines[] = { //62 74
//			-50, 245, // left bottom
//			 97, 245,
//			 97, 700,
//			-1,
//			383, 700, // right bottom
//			383, 245,
//			700, 245,
//			-1,
			-50,  62, // left funnel
			 74,  62,
			 74,  46,
			  0, -50,
			-1,
			700,  62, // right funnel
			409,  62,
			409,  46,
			480, -50,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelCrumble"]; // TODO different image?
		[self nextLevelDirection:physicsOutsideBorderLayer];

		{
			float i = 0.5f;
			float d = 150;
			[self addStaticLight:cpv( 30,  30) intensity:i distance:d];
			[self addStaticLight:cpv(450,  30) intensity:i distance:d];
			[self renderStaticLightMap];
		}
		
		[self addLight:cpv(240,70) length:20.0f intensity:0.5f distance:250.0f];
		[self addStone:cpv(240,55)];
		[self addMoss:cpv(463,  64) big:TRUE];

		for(int i=0; i<300; i++)
			[self update];
		
		[self addEndArrow:cpv(240, 300) angle:-M_PI_2];
		[blocks addObject:[self addRollingGoalOrb:blockPos()]];
		
		[self addPlayerBall:cpv(25, 180) vel:cpv(100, 30)];
		ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);
		[blocks addObject:ballBody];
	}
	
	return self;
}

- (void)update {
	if(ticks%20 == 0 && [blocks count] < 15){
		[blocks addObject:[self addFallingBlock:blockPos()]];
	}
	
	for(ChipmunkBody *block in blocks){
		if(block.pos.y < -20.0f){
			cpVect pos = blockPos();
			pos.y = 320.0f - pos.y;
			
			block.pos = pos;
			block.vel = cpv(0, -100);
		}
	}
	
	[super update];
}

@end
