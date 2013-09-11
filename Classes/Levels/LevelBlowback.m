#import "LevelStateDelegate.h"

@implementation LevelBlowback

NSMutableArray* blowupable;
Light *light;


ALuint touchingOrbLoop;

- (void)update {
	modulateLoopVolume(touchingOrbLoop, fade, 0.00f, 0.9f);
  
  fade -= 0.05f;
  if(fade < 0.0f){
    fade = 0.0f;
  }
  
  [super update];
}

+ (NSString *)levelName {
	return @"Blow the Wall";
}

- (id)init { 
  
  fade = 0.0f;
  goldPar = 2;
	silverPar = 4;
  
  if(self = [super init]){
		ambientLevel = 0.2f;
    blowupable = [[NSMutableArray alloc] init];
		int polylines[] = {
      -50, 34, 
      480, 34, 
      -1,
			-50, 271,
			480, 271,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelBlowBack"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		[self addLight:cpv(195, 34) length:20.0f intensity:0.2f distance:280.0f];

		ChipmunkBody* whiteOrb = [self addWhiteOrb:cpv(160, 130)];
		
		light = [[Light alloc] initWithBody:whiteOrb offset:cpvzero radius:250.0f r:0.5f g:0.5f b:0.5f];
		[lights addObject:light]; [light release];
		[light setIntensity:0.2f];

		[blowupable addObject:[self addBigBox:cpv(275, 241)]];
		[blowupable addObject:[self addBigBox:cpv(275, 184)]];
		[blowupable addObject:[self addBigBox:cpv(275, 129)]];
		[blowupable addObject:[self addBigBox:cpv(275, 73)]];
		
		[blowupable addObject:[self addWallChunk:cpv(230, 231)]];
		[blowupable addObject:[self addWallChunk:cpv(230, 160)]];
		[blowupable addObject:[self addWallChunk:cpv(230, 89)]];

    [self addMoss:cpv(325,  35) big:FALSE];
  
		[self addEndArrow:cpv(430, 170) angle:0];
		[self addGoalOrb:cpv(430, 220)];
		[self addPlayerBall:cpv(20, 140) vel:cpv(20, 10)];
    
    touchingOrbLoop = createLoop(touchingOrbSound);
	}
	
	return self;
}

- (void) triggerWhiteOrb:(cpShape*) orb {
  [light setIntensity:1.0f];

  NSEnumerator * enumerator = [blowupable objectEnumerator];
  ChipmunkBody* b;
  
  fade = 1.0f;
  
  while(b = [enumerator nextObject])
  {
      b.vel = cpvadd(b.vel, cpv(random() % 30 - 15, 5));
  }
}


@end
