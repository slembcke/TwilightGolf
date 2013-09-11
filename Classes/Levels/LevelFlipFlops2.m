#import "LevelStateDelegate.h"

@implementation LevelFlipFlops2

+ (NSString *)levelName {
	return @"Flip Flop Again";
}

- (ChipmunkBody*)addDecoyOrb:(cpVect)pos {
	pos.y = 320 - pos.y;
	
	cpFloat m = 1.6f;
	cpFloat r = 14.0f;
	cpFloat moment = cpMomentForCircle(m, r, 0.0f, cpvzero);
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:moment];
	body.pos = pos;
	[space addObject:body]; [body release];

	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.elasticity = 0.1f;
	shape.friction = 0.4f;
	shape.layers &= ~physicsBorderLayers;
	
	[space addObject:shape]; [shape release];
	
	[sprites addObject:MakeSprite(3, 0, 1, 1, body, 0, 0)];
	[self addShadowCircle:body offset:cpvzero radius:r];

	return body;
}

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.1f;
		goldPar = 2;
    silverPar = 4;

		int polylines[] = {
			144, 144,
			  0, 160,
			  0, 288,
			304, 288,
			304, 208,
			 80, 208,
			216, 176,
			336, 208,
			336, 320,
			-1,
			192,  36,
			-50,  32,
			-1,
			700, 192,
			400, 192,
			400, 700,
			-1,-1,
		};
		[self addPolyLines:polylines]; // TODO mem leak
		[self loadBG:@"levelFlipFlops2"];
		[self nextLevelDirection:physicsBorderInsideTopLayer];
		
//		{ // Add some static lights.
//			[self addStaticLight:cpv(x,   0) intensity:1.0f distance:dist];
//			[self renderStaticLightMap];
//		}
		
		cpVect adj = cpv(-8, 8);
		[self addFlipFlop:cpvadd(adj, cpv(224,  64)) leverPos:cpv(128, 208) bump:  1.0f];
		[self addFlipFlop:cpvadd(adj, cpv(176, 112)) leverPos:cpv(256, 208) bump:  1.0f];
		[self addFlipFlop:cpvadd(adj, cpv(224, 160)) leverPos:cpv(192, 208) bump:  1.0f];
    
    [self addLight:cpv(100,  39) length:30.0f intensity:0.6f distance:100.0f];
    [self addLight:cpv(352,   5) length:60.0f intensity:0.6f distance:100.0f];
//		[self addMoss:cpv(85,  41) big:TRUE];
    
		[self addChuteHinge:cpv(32,208)];
		[self addTorch:cpv(432, 164)];
				
		[self addEndArrow:cpv(240, 160) angle:0.0f];
		for(int i=0; i<5; i++){
			cpVect pos = cpv(160 + -32*i,  16);
			if(i==3){
				goalOrbBody = [self addRollingGoalOrb:pos];
			} else {
				[self addBall:pos canRollAway:true];
			}
		}
		[self addPlayerBall:cpv(32, 240) vel:cpv(15, 0)];
	}
	
	return self;
}

@end
