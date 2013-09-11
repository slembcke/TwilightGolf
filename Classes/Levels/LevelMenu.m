#import "LevelStateDelegate.h"

#import "GLGameAppDelegate.h"

#define newGameX 360
#define newGameY 160
#define continueX 120
#define continueY 160
#define moreX 120
#define moreY 260
#define buyX 250
#define buyY 40
#define gamesX 420
#define gamesY 290

static const cpBB newGameBB = {
	newGameX - 5*16,
	newGameY - 1*16,
	newGameX + 5*16,
	newGameY + 1*16,
};

static const cpBB continueBB = {
	continueX - 4*16,
	continueY - 1*16,
	continueX + 4*16,
	continueY + 1*16,
};

static const cpBB moreBB = {
	moreX - 3*16,
	moreY - 1*16,
	moreX + 3*16,
	moreY + 1*16,
};

static const cpBB buyBB = {
	buyX - 9*16,
	buyY - 1*16,
	buyX + 9*16,
	buyY + 1*16,
};

static const cpBB gamesBB = {
	gamesX - 3*16,
	gamesY - 2*16,
	gamesX + 3*16,
	gamesY + 2*16,
};

@implementation LevelMenu

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.2f;
		goldPar = 1;
    
		int polylines[] = {
			-100, 238,
			376, 238,
			466, 316,
			466, 500,
      -1,
			257,  -100,
			257,  94,
			500,  94,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelMenu"];
		
		[self addStaticLight:cpv(460, -50) intensity:0.4f distance:200.0f];
		[self renderStaticLightMap];
    
		[self addLight:cpv(450,  97) length:20.0f intensity:0.3f distance:200.0f];
    [self addBrokenLight:cpv(301,  97) length:38.0f];
    
    [self addTorch:cpv(292, 217)];

		[self addPlayerBall:cpv(1 - PLAYER_BALL_RADIUS, 216)  vel:cpv(70, 70)];
		ballShape.layers &= ~(physicsBorderLayers & ~physicsBorderInsideTopLayer);

		[uiSprites removeAllObjects];
		[uiSprites addObject:SpriteOffset(MakeSprite( 0, 14, 6, 1, staticBody, 0, 0), cpv(newGameX, newGameY))];
		[uiSprites addObject:SpriteOffset(MakeSprite( 6, 14, 5, 1, staticBody, 0, 0), cpv(continueX, continueY))];
		[uiSprites addObject:SpriteOffset(MakeSprite(11, 13, 3, 1, staticBody, 0, 0), cpv(moreX, moreY))];
		[uiSprites addObject:SpriteOffset(MakeSprite(5, 10, 3, 2, staticBody, 0, 0), cpv(gamesX, gamesY))];

		if(LITE_VERSION){
			[uiSprites addObject:SpriteOffset(MakeSprite(8, 10, 9, 1, staticBody, 0, 0), cpv(buyX, buyY))];
		}
	}
	
	return self;
}

+ (medalType)medal {
	return medalGold;
}

- (void)renderNumber:(int)num at:(cpVect)pos {
  // Overridden to hide the stroke count.
}

- (void)touchUp {
	[super touchUp];
	
	if([self button:newGameBB]){
		[LevelStateDelegate jumpToLevel:[Levels nextLevel:[self class]]];
	} else if([self button:continueBB]){
		[LevelStateDelegate jumpToLevel:[Levels savedLevel]];
	} else if([self button:moreBB]){
		[[GLGameAppDelegate appDelegate] showPrefs];
		[GameState stopWithValue:nil];
	} else if([self button:gamesBB]){
		[[GLGameAppDelegate appDelegate] showPlayHaven];
		[GameState stopWithValue:nil];
	} else if(LITE_VERSION && [self button:buyBB]){
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=333218006"]];
	}
}

@end
