#import "LevelStateDelegate.h"

@implementation LevelSwitchesEasy

+ (NSString *)levelName {
	return @"Power Crystals";
}

- (void)addChuteHinge:(cpVect)atPoint {
	atPoint.y = 320 - atPoint.y;
	
//	float width = 10.0f;
//	float height = 50.0f;
//	cpFloat m = 0.2f;

}

#define PHASE 9.0f
#define FLICKER_MIN 0.3
#define FLICKER_ADD 0.7

#define PULSE_FUNC(i) \
static GLfloat flickerCrystal##i(int ticks, int salt){ \
	const GLfloat phase = (i##.0f/PHASE)*2.0f*M_PI; \
	const GLfloat freq = (3.0f*M_PI)/(3.0f*60.0f); \
	const GLfloat value = fmax(0.0f, sinf((GLfloat)ticks*freq - phase)); \
	return value*value*value*FLICKER_ADD + FLICKER_MIN; \
}

PULSE_FUNC(1)
PULSE_FUNC(2)
PULSE_FUNC(3)
PULSE_FUNC(4)

#define CRYSTAL_LIGHT_DIM 1.0f
- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 4;
    silverPar = 6;
    
    stage = 0;
    
		int polylines[] = {
      
      -50, 70,
      85,  70,
      85, 170,
      16, 170,
      16, 264,
			336, 264,
			338, 230,
			429, 227,
			430, 264,
      500, 264,
      
      -1,
      
			430,   -100,
			430,  94,
			339,  94,
			339,  -100,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelSwitchesEasy"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
    [self addStaticLight:cpv(-30, 118) intensity:0.3f distance:190];
    [self addStaticLight:cpv(386,   6) intensity:0.3f distance:140];
    [self addStaticLight:cpv(382, 308) intensity:0.5f distance:140];
		[self renderStaticLightMap];

    crystal1 = [self addCrystalTrigger:cpv(64, 253)];
    crystal2 = [self addCrystalTrigger:cpv(138, 253)];
    crystal3 = [self addCrystalTrigger:cpv(208, 253)];
    crystal4 = [self addCrystalTrigger:cpv(283, 253)];
      
		const float lightDist = 120.0f;
    Light * light;
    crystalLight1 = light = [[Light alloc] initWithBody:crystal1 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal2;
    
    crystalLight2 = light  = [[Light alloc] initWithBody:crystal2 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal3;
    
    crystalLight3 = light  = [[Light alloc] initWithBody:crystal3 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal1;
    
    crystalLight4 = light  = [[Light alloc] initWithBody:crystal4 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal4;
    
    int y1 = 160-52;
    int y2 = 160+52;
    int x = 384;
		door1 = [self addSlidingDoor:cpv(x, y1)];
		door2 = [self addSlidingDoor:cpv(x, y2)];
		
		ChipmunkConstraint *groove;
		groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door1 groove_a:cpv(x, -50) groove_b:cpv(x, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot1 = [[ChipmunkPivotJoint alloc] initWithBodyA:door1 bodyB:staticBody pivot:cpv(x, 320-y1)];
    pivot1.maxBias = 12.0f;
		[self addChipmunkObject:pivot1]; [pivot1 release];

    groove = [[ChipmunkGrooveJoint alloc] initWithBodyA:staticBody bodyB:door2 groove_a:cpv(x, -50) groove_b:cpv(x, 700) anchr2:cpvzero];
		[self addChipmunkObject:groove]; [groove release];
		pivot2 = [[ChipmunkPivotJoint alloc] initWithBodyA:door2 bodyB:staticBody pivot:cpv(x, 320-y2)];
    pivot2.maxBias = 12.0f;
		[self addChipmunkObject:pivot2]; [pivot2 release];
    
		[self addEndArrow:cpv(442, 165) angle:0];
    
    [self addPlayerBall:cpv(26,  40)];
    [self addChainedGoalOrb:cpv(461, -10) length:155.0f];

    
    
	}
	
	return self;
}

- (void) resetColors{
  
  [crystalLight1 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight1->_flicker = flickerCrystal2;
	crystalLight1->_r = 0.2f;
	crystalLight1->_g = 0.2f;
	crystalLight1->_b = 1.0f;
  
  [crystalLight2 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight2->_flicker = flickerCrystal3;
	crystalLight2->_r = 0.2f;
	crystalLight2->_g = 0.2f;
	crystalLight2->_b = 1.0f;
  
  [crystalLight3 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight3->_flicker = flickerCrystal1;
	crystalLight3->_r = 0.2f;
	crystalLight3->_g = 0.2f;
	crystalLight3->_b = 1.0f;
  
  [crystalLight4 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight4->_flicker = flickerCrystal4;
	crystalLight4->_r = 0.2f;
	crystalLight4->_g = 0.2f;
	crystalLight4->_b = 1.0f;
    
  [self changeSprite:crystal1.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal1.body->data)];
  [self changeSprite:crystal2.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal2.body->data)];
  [self changeSprite:crystal3.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal3.body->data)];
  [self changeSprite:crystal4.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal4.body->data)];
}

- (void) fail{
  stage = 0;
   
  [self resetColors];
}


static GLfloat
flickerDefault(int ticks, int salt)
{
	return 1.0f;
}

- (void) correct:(ChipmunkBody*) crystal light:(Light*) light {
  light->_flicker = flickerDefault;
  light->_r = 0.1f;
  light->_g = 1.0f;
  light->_b = 0.1f;
  
  [self changeSprite:crystal.body to:MAKE_GREEN_CRYSTAL_TRIGGER_SPRITE(crystal.body->data)];
}

- (void) incorrect:(ChipmunkBody*) crystal light:(Light*) light {
  [self changeSprite:crystal.body to:MAKE_RED_CRYSTAL_TRIGGER_SPRITE(crystal.body->data)];
  light->_flicker = flickerDefault;
  light->_r = 1.0f;
  light->_g = 0.1f;
  light->_b = 0.1f;
  
  lastRed = 20;
}

- (void) triggerBlueCrystal:(cpShape*) orb{
  if(stage == 5){
    return;
  }
  
  if(orb->body == crystal1.body){
    if(stage >= 1){
      [self correct:crystal1 light:crystalLight1];
      stage = MAX(stage, 2);
    }else{
      [self fail];
      [self incorrect:crystal1 light:crystalLight1];
    }
  }
  if(orb->body == crystal2.body){
    if(stage >= 2){
      [self correct:crystal2 light:crystalLight2];
      stage = MAX(stage, 3);
    }else {
      [self fail];
      [self incorrect:crystal2 light:crystalLight2];
    }
  }
  if(orb->body == crystal3.body){
    if(stage >= 0){
      [self correct:crystal3 light:crystalLight3];
      stage = MAX(stage, 1);
    }else{
      [self fail];
      [self incorrect:crystal3 light:crystalLight3];
    }
  }
  if(orb->body == crystal4.body){
    if(stage >= 3){
      [self correct:crystal4 light:crystalLight4];
      stage = MAX(stage, 4);

      pivot1.anchr1 = cpv(0, -60);
      pivot2.anchr1 = cpv(0,  60);

    }else{
      [self fail];
      [self incorrect:crystal4 light:crystalLight4];
    }
  }

}

- (void) update{
  [super update];
  
  if(lastRed > 0){
    lastRed -= 1;
    if(lastRed <= 0){
      [self resetColors];
    }
  }
}

@end
