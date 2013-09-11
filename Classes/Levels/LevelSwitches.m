#import "LevelStateDelegate.h"

@implementation LevelSwitches

+ (NSString *)levelName {
	return @"Order Matters";
}

- (void)addChuteHinge:(cpVect)atPoint {
	atPoint.y = 320 - atPoint.y;
	
	float width = 10.0f;
	float height = 50.0f;
	cpFloat m = 0.2f;
	
	cpVect verts[] = {
		cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	body.angle = M_PI_2;
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.3f;
	shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
	
	ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:cpvadd(atPoint, cpv(-32, 0))];
	[self addChipmunkObject:pivot]; [pivot release];
	  
	joint = [[ChipmunkGearJoint alloc] initWithBodyA:body bodyB:staticBody phase:-M_PI_2 ratio:1.0f];
  joint.maxForce = 10000;
  [space addObject:joint]; [joint release];
  
	[self addShadowBox:body offset:cpvzero width:width height:height];
	[sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
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
PULSE_FUNC(5)

#define CRYSTAL_LIGHT_DIM 1.0f
- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 15;
    silverPar = 22;
    
    stage = 0;
    
		int polylines[] = {
			-50,  30,
      
      247,  33,
			247,  92,
			251,  96,
			264,  95,
    	264,  33,
      
      305,  30,
      366, 142,
			425,  30,      
			700,  30,
      -1,
			-50, 288,
			66, 288,
			66, 159,
			130, 159,
			130, 288,
			700, 288,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelSwitches"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];
		
    [self addStaticLight:cpv(250, 30) intensity:0.3f distance:250];
    [self addStaticLight:cpv(385,  11) intensity:0.3f distance:250];
    [self addStaticLight:cpv(-10, -40) intensity:0.5f distance:250];
		[self renderStaticLightMap];
        
    answerLight1 = [self addLight:cpv(106,30) length:25.0f intensity:0.9f distance:40.0f];
    [answerLight1 setIntensity:0.1f];
    [answerLight1 setDrawShadows:false];
    answerLight2 = [self addLight:cpv(135, 30) length:25.0f intensity:0.9f distance:40.0f];
    [answerLight2 setIntensity:0.1f];
    [answerLight2 setDrawShadows:false];
    answerLight3 = [self addLight:cpv(162, 30) length:25.0f intensity:0.9f distance:40.0f];
    [answerLight3 setIntensity:0.1f];
    [answerLight3 setDrawShadows:false];
    answerLight4 = [self addLight:cpv(189, 30) length:25.0f intensity:0.9f distance:40.0f];
    [answerLight4 setIntensity:0.1f];
    [answerLight4 setDrawShadows:false];
    answerLight5 = [self addLight:cpv(219, 30) length:25.0f intensity:0.9f distance:40.0f];
    [answerLight5 setIntensity:0.1f];
    [answerLight5 setDrawShadows:false];
    
    
    crystal1 = [self addCrystalTrigger:cpv(60, 240)];
    crystal1.angle = M_PI_2;
    crystal2 = [self addCrystalTrigger:cpv(173, 280)];
    crystal3 = [self addCrystalTrigger:cpv(330, 280)];
    crystal4 = [self addCrystalTrigger:cpv(388, 134)];
    crystal4.angle = -M_PI * 0.65f;
    crystal5 = [self addCrystalTrigger:cpv(463, 39)];
    crystal5.angle = M_PI;
    
		const float lightDist = 120.0f;
    Light * light;
    crystalLight1 = light = [[Light alloc] initWithBody:crystal1 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal3;
    
    crystalLight2 = light  = [[Light alloc] initWithBody:crystal2 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal4;
    
    crystalLight3 = light  = [[Light alloc] initWithBody:crystal3 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal1;
    
    crystalLight4 = light  = [[Light alloc] initWithBody:crystal4 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal5;
    
    crystalLight5 = light  = [[Light alloc] initWithBody:crystal5 offset:cpvzero radius:lightDist r:0.2f g:0.2f b:1.0f];
    [lights addObject:light]; [light release];
    [light setIntensity:CRYSTAL_LIGHT_DIM];
		light->_flicker = flickerCrystal2;
    
		[self addEndArrow:cpv(440, 190) angle:0];
    
    [self addPlayerBall:cpv(25, 50)];
    [self addChainedGoalOrb:cpv(278, 24) length:30.0f];

    [self addChuteHinge:cpv(292, 100)];
	}
	
	return self;
}

- (void) resetColors{
  
  [crystalLight1 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight1->_flicker = flickerCrystal3;
	crystalLight1->_r = 0.2f;
	crystalLight1->_g = 0.2f;
	crystalLight1->_b = 1.0f;
  
  [crystalLight2 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight2->_flicker = flickerCrystal4;
	crystalLight2->_r = 0.2f;
	crystalLight2->_g = 0.2f;
	crystalLight2->_b = 1.0f;
  
  [crystalLight3 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight3->_flicker = flickerCrystal1;
	crystalLight3->_r = 0.2f;
	crystalLight3->_g = 0.2f;
	crystalLight3->_b = 1.0f;
  
  [crystalLight4 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight4->_flicker = flickerCrystal5;
	crystalLight4->_r = 0.2f;
	crystalLight4->_g = 0.2f;
	crystalLight4->_b = 1.0f;
  
  [crystalLight5 setIntensity:CRYSTAL_LIGHT_DIM];
	crystalLight5->_flicker = flickerCrystal2;
	crystalLight5->_r = 0.2f;
	crystalLight5->_g = 0.2f;
	crystalLight5->_b = 1.0f;
  
  
  [self changeSprite:crystal1.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal1.body->data)];
  [self changeSprite:crystal2.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal2.body->data)];
  [self changeSprite:crystal3.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal3.body->data)];
  [self changeSprite:crystal4.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal4.body->data)];
  [self changeSprite:crystal5.body to:MAKE_CRYSTAL_TRIGGER_SPRITE(crystal5.body->data)];
}

- (void) fail{
  stage = 0;
   
  [self resetColors];
 
  [answerLight1 setIntensity:0.1f];
  [answerLight2 setIntensity:0.1f];
  [answerLight3 setIntensity:0.1f];
  [answerLight4 setIntensity:0.1f];
  [answerLight5 setIntensity:0.1f];
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
    if(stage >= 2){
      [self correct:crystal1 light:crystalLight1];
      [answerLight3 setIntensity:1.0f];
      stage = MAX(stage, 3);
    }else{
      [self fail];
      [self incorrect:crystal1 light:crystalLight1];
    }
  }
  if(orb->body == crystal2.body){
    if(stage >= 3){
      [self correct:crystal2 light:crystalLight2];
      [answerLight4 setIntensity:1.0f];
      stage = MAX(stage, 4);
    }else {
      [self fail];
      [self incorrect:crystal2 light:crystalLight2];
    }
  }
  if(orb->body == crystal3.body){
    if(stage >= 0){
      [self correct:crystal3 light:crystalLight3];
      [answerLight1 setIntensity:1.0f];
      stage = MAX(stage, 1);
    }else{
      [self fail];
      [self incorrect:crystal3 light:crystalLight3];
    }
  }
  if(orb->body == crystal4.body){
    if(stage >= 4){
      [self correct:crystal4 light:crystalLight4];
      [answerLight5 setIntensity:1.0f];
      stage = MAX(stage, 5);

      joint.maxForce=800.0f;
      joint.phase=0.0f;
    }else{
      [self fail];
      [self incorrect:crystal4 light:crystalLight4];
    }
  }
  if(orb->body == crystal5.body){
    if(stage >= 1){
      [self correct:crystal5 light:crystalLight5];
      [answerLight2 setIntensity:1.0f];
      stage = MAX(stage, 2);
    }else{
      [self fail];
      [self incorrect:crystal5 light:crystalLight5];
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
