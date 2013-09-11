#import "LevelStateDelegate.h"

@implementation LevelOutside

+ (NSString *)levelName {
	return @"The Final Orb";
}

static GLfloat
flickerSunOff(int ticks, int salt)
{
	const int skip = 6;
	const int frames = 11;
	const GLfloat freq = M_PI/(GLfloat)(2*skip*(frames - 1));
	GLfloat value =  0.5f*sinf((GLfloat)ticks*freq) + 0.5f;
	
	return value*0.7f + 0.3f;
}

static GLfloat
flickerBright(int ticks, int salt)
{
	const int skip = 6;
	const int frames = 9;
	const GLfloat freq = M_PI/(GLfloat)(2*skip*(frames - 1));
	GLfloat value =  0.5f*sinf((GLfloat)ticks*freq) + 0.5f;
	
	return value*0.2f + 0.8f;
}

- (void)addFinalGoalOrb:(cpVect)pos {
  pos.y = 320 - pos.y;
	
	cpFloat r = 180.0f;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:staticBody radius:r offset:pos];
	shape.elasticity = 1.0f;
	shape.friction = 1.0f;
	shape.collisionType = physicsGoalType;
	[space addObject:shape]; [shape release];

  levelEndLight = [[Light alloc] initWithBody:staticBody offset:pos radius:450.0f r:0.96f g:0.83f b:0.26f];
  [levelEndLight setIntensity:0.9f];
  levelEndLight->_flicker = flickerSunOff;
  [lights addObject:levelEndLight];

}

static int polylines[] = {
-100, 260,
251, 260,
261, 301,
265, 303,
268, 313,
275, 305,
280, 306,
280, 500,
-1,
330, 500,
331, 306,
349, 305,
354, 260,
500, 260,
-1, -1,
};

- (void)completed {
	if(completedTicks) return;
	
	NSLog(@"level %@ completed in %0.1fs and %d strokes!\n", [self class], (float)ticks/60.0f, strokeCount);
  
	[levelEndLight setIntensity:1];
	completedTicks = ticks;
	  
	// float pitch = ((float)rand()/(float)RAND_MAX)*0.1f + 0.15f;
  // TODO: Special sound for this?
  playSound(gotGoalSound, 0.5f, 1.0f);
	
	// reset the UI sprites
	[uiSprites removeAllObjects];
  
  [uiSprites addObject:SpriteOffset(MakeSprite(7, 7, 5, 1, staticBody, 0, 0), cpv(240, 170))];
  if([LevelStateDelegate hasAllGolds]){
    [uiSprites addObject:SpriteOffset(MakeSprite(8, 8, 8, 1, staticBody, 0, 0), cpv(240, 130))];
  }else{
    [uiSprites addObject:SpriteOffset(MakeSprite(6, 9, 10, 1, staticBody, 0, 0), cpv(240, 130))];
  }
  
  glDeleteTextures(1, &bgTexture);
  [self loadBG:@"levelOutsideDaytime"];
	
  ambientLevel = 2.0f; // oversaturate the ambient to overpower the slight blue ambient tinge
	
	NSMutableArray *tempLightHolder = lights; // need to keep the torches around for the fireflies
	lights = [[NSMutableArray alloc] init];
  [self renderStaticLightMap];
	[lights release];
	lights = tempLightHolder;
}

- (void)renderNumber:(int)num at:(cpVect)pos {
  // Overridden to hide the stroke count.
  if(!completedTicks){
    [super renderNumber:num at:pos];
  }
}

+ (medalType)medal {
	return medalGold;
}

- (id)init {
	if(self = [super init]){
    ambientLevel = 0.3f;
    goldPar = 1;
    silverPar = 6;
    
		[self addPolyLines:polylines];
		[self loadBG:@"levelOutside"];
		[self nextLevelDirection:(physicsOutsideBorderLayer | physicsBorderInsideRightLayer)]; // we need to collide with this to win the level.
		
	//	[self addStaticLight:cpv(16, 128) intensity:0.3f distance:300];
//		[self addStaticLight:cpv(464, 128) intensity:0.3f distance:300];
//        
//    [self addStaticLight:cpv(-10, -10) intensity:0.5f distance:150];
		[self renderStaticLightMap];
		
		[self addTorch:cpv(70, 236)];
		[self addTorch:cpv(410, 236)];
		
		[self addFinalGoalOrb:cpv(250, -120)];

		[self addPlayerBall:cpv(303, 320) vel:cpv(-35.0f, 170.0f)];
		ballShape.layers &= ~(physicsBorderInsideBottomLayer | physicsOutsideBorderLayer);

 		[self addEndArrow:cpv(380, 30) angle:0];
	}
	
	return self;
}


@end
