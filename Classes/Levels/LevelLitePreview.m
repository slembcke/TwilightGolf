#import "LevelStateDelegate.h"

extern GLuint loadPNG(NSString *name);

#define SIZE 20
#define HOME_X SIZE
#define HOME_Y SIZE

static const cpBB homeBB = {
	HOME_X - SIZE,
	HOME_Y - SIZE,
	HOME_X + SIZE,
	HOME_Y + SIZE,
};

#define buyX 240
#define buyY 160
static const cpBB buyBB = {
	buyX - 9*16,
	buyY - 1*16,
	buyX + 9*16,
	buyY + 1*16,
};

@implementation LevelLitePreview

+ (NSString *)levelName {
	return @"A First Barrier";
}

- (id)init {
	if(self = [super init]){
		frostTexture = loadPNG(@"frosted_glass.png");
		
		levels = [NSArray arrayWithObjects:
			[LevelTeeter class],
			[LevelTheWay class],
			[LevelBlowback class],
			[LevelGravity class],
			[LevelStayOnTarget class],
			[LevelDilithiumCrystal class],
			[LevelTheWay2 class],
			[LevelCrumble2 class],
			[LevelGoop class],
			[LevelCeilingGearIsWatchingYou class],
			[LevelDoorsOfDoom class],
			[LevelLifter class],
			[LevelTurnTurnTurn class],
			[LevelTeeterTotter class],
			[LevelRotator class],
			[LevelIntoTheChute class],
			[LevelFlywheel class],
			[LevelGoingUp class],
			[LevelGoingUp2 class],
			[LevelFlipFlops2 class],
			[LevelOutside class],
			NULL
		];
		
		[uiSprites removeAllObjects];
    [uiSprites addObject:SpriteOffset(MakeSprite(15, 13, 1, 1, staticBody, 0, 0), cpv(HOME_X, HOME_Y))];
		[uiSprites addObject:SpriteOffset(MakeSprite(8, 10, 9, 1, staticBody, 0, 0), cpv(buyX, buyY))];
	}
	
	return self;
}

- (void) dealloc
{
	glDeleteTextures(1, &frostTexture);
	[delegate release];
	
	[super dealloc];
}

- (void)update {
	if(ticks % (60*4) == 0){
		[delegate release];
		
		NO_BALL_MODE = TRUE;
		sranddev();
		delegate = [[[levels objectAtIndex:rand()%[levels count]] alloc] init];
		NO_BALL_MODE = FALSE;
	}
	
	
	[delegate update];
	ticks++;
}

static void drawFrostTexture(){
	const GLfloat verts[] = {
		0, 0,
		0, 320,
		480, 0,
		480, 320,
	};
	
	const GLfloat tcoords[] = {
		0, 512,
		0, 0,
		512, 512,
		512, 0,
	};
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glTexCoordPointer(2, GL_FLOAT, 0, tcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)draw {
	[delegate draw];
	
	glBindTexture(GL_TEXTURE_2D, frostTexture);
	drawFrostTexture();
	
	glBindTexture(GL_TEXTURE_2D, spriteTexture);
	renderSprites(uiSprites, ticks);
}

- (void)touchUp {
	if(!isTouched) return; // workaround for OS 2.0 event order bug
	isTouched = FALSE;
	
	if([self button:homeBB]){
		[GameState stopWithValue:[LevelStateDelegate gamestateForLevel:[Levels level:0]]];
	} else if([self button:buyBB]){
		NSLog(@"buy");
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=333218006"]];
	}
}

- (void)touchMoved:(cpVect)pos {
	if(!isTouched){
		isTouched = TRUE;
		touchStart = cpv(pos.y, pos.x);
	}
	
	touchCurrent = cpv(pos.y, pos.x);
	lastTouchTicks = ticks;
}

@end
