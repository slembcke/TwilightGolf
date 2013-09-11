#import "LevelStateDelegate.h"
#import "EAGLView.h"

#import "drawSpace.h"
#import "ChipmunkSpaceExtras.h"

#import "GameState.h"

bool NO_BALL_MODE = FALSE;

int LIGHT_MAP_SIZE = 128;

//cpBB sceneBB = {
//	-2.0f*PLAYER_BALL_RADIUS,
//	-2.0f*PLAYER_BALL_RADIUS,
//	480 + 2.0f*PLAYER_BALL_RADIUS,
//	320 + 2.0f*PLAYER_BALL_RADIUS
//};

#define SIZE 20
#define RESET_X (480 - SIZE)
#define RESET_Y SIZE

static const cpBB resetBB = {
	RESET_X - SIZE,
	RESET_Y - SIZE,
	RESET_X + SIZE,
	RESET_Y + SIZE,
};

#define HOME_X SIZE
#define HOME_Y SIZE

static const cpBB homeBB = {
	HOME_X - SIZE,
	HOME_Y - SIZE,
	HOME_X + SIZE,
	HOME_Y + SIZE,
};

#define CONTINUE_X 240
#define CONTINUE_Y 70
#define CONTINUE_W 128
#define CONTINUE_H 23

static const cpBB continueBB = {
	CONTINUE_X - CONTINUE_W,
	CONTINUE_Y - CONTINUE_H,
	CONTINUE_X + CONTINUE_W,
	CONTINUE_Y + CONTINUE_H,
};

#define FADE_TICKS (30)



GLuint
loadPNG(NSString *name){
	UIImage *ui_image = [UIImage imageNamed:name];
	CGImageRef image = ui_image.CGImage;

	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);

	if(ui_image) {
		int bytes = width*height*4;
		GLubyte *texelData = (GLubyte *)calloc(bytes, 1);

		// Create a bitmap context and render the image into it.
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGContextRef imageContext = CGBitmapContextCreate(texelData, width, height, 8, width * 4, rgb, kCGImageAlphaPremultipliedLast);
		CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
		CGContextRelease(imageContext);
		CGColorSpaceRelease(rgb);
		
		GLuint texture;
		glGenTextures(1, &texture);
		glBindTexture(GL_TEXTURE_2D, texture);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texelData);
		free(texelData);
		
		return texture;
	} else {
		NSLog(@"Failed to load %@", name);
		abort();
		return 0;
	}
}

static GLuint
loadPVRTC(NSString *name, GLsizei size)
{
	GLsizei bytes = size*size*4/8;
	char *data = calloc(1, bytes);
	
	const char *path = [[[NSBundle mainBundle] pathForResource:name ofType:@"pvrtc"] UTF8String];
	FILE *f = fopen(path, "r");
	assert(f);
	fread(data, bytes, 1, f);
	fclose(f);
	
	GLuint tex;
	glGenTextures(1, &tex);
	
	glBindTexture(GL_TEXTURE_2D, tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, size, size, 0, bytes, data);
	
	free(data);
	return tex;
}

static GLuint
makeBlankTexture(int w, int h)
{
	GLsizei bytes = w*h*4;
	char *data = calloc(1, bytes);
	
	GLuint tex;
	glGenTextures(1, &tex);
	
	glBindTexture(GL_TEXTURE_2D, tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
	free(data);
	return tex;
}

@implementation LevelStateDelegate

+ (GameState *)gamestateForLevel:(Class)klass {
	assert(klass);
	
	LevelStateDelegate *delegate = [[klass alloc] init];
	GameState *state = 	[[TickLimitedGameState alloc] initWithStep:1.0f/60.0f delegate:delegate];
	[delegate release];
	
	return state;
}

+ (void)jumpToLevel:(Class)klass {
	[GameState stopWithValue:[LevelStateDelegate gamestateForLevel:klass]];
}

+ (NSString *)levelName {
	// TODO make it an abort!
	return [NSString stringWithFormat:@"Unamed Level (%@)", [self description]];
}

+ (medalType)medal {
	NSDictionary *medals = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"medals"];
	NSNumber *num = [medals objectForKey:[self description]];
	
	return (num ? [num intValue] : medalNone);
}

+ (bool) hasAllGolds {
  for(Class level in [Levels levels]){
    if([level medal] != medalGold){
      return FALSE;
    }
  }
  return TRUE;
}

int polylineLength(int *pline){
	int i = 0;
	for(; pline[i] != -1; i += 2){}
	
	return i/2;
}

- (void)addStaticSegmentFrom:(cpVect)from to:(cpVect)to radius:(cpFloat)radius layers:(cpLayers)layers type:(NSString*)type {
	ChipmunkShape *shape = [[ChipmunkSegmentShape alloc] initWithBody:staticBody from:from to:to radius:radius];
	[space addStaticShape:shape];
	shape.elasticity = 1.0f;
	shape.friction = 1.0f;
	shape.layers = layers;
	shape.collisionType = type;

	[shape release];
}

- (void)addPolyLines:(int *)polylines { // holy crap, shoot me
	int i = -1;
	while(polylines[i+1] != -1){
		i++;
		
		int count = polylineLength(&polylines[i]);
		GLfloat *verts = calloc(6*count, sizeof(GLfloat));
		
		cpVect prev;
		bool notFirst = FALSE;
		
		for(int j=0; polylines[i] != -1; i += 2, j++){ // per polyline
			int x = polylines[i];
			int y = 320 - polylines[i+1];
			cpVect current = cpv(x, y);
			verts[j*6 + 0] = x;
			verts[j*6 + 1] = y;
			verts[j*6 + 2] = 1;
			verts[j*6 + 3] = x;
			verts[j*6 + 4] = y;
			verts[j*6 + 5] = 0;
			
			if(notFirst){
				[self addStaticSegmentFrom:current to:prev radius:3.0f layers:physicsTerrainLayer type:nil];
			}
			
			prev = current;
			notFirst = TRUE;
		}
		
		shadowPolyLine shadow = {verts, count*2, staticBody.body, cpvzero, 1.0f, 1.0f};
		[shadowPolylines addObject:[NSData dataWithBytes:&shadow length:sizeof(shadow)]];
	}
}

- (void)showEndArrow {
	if(!endArrowBody){
		NSLog(@"You need to add an end arrow position");
		abort();
	}
	
	[uiSprites addObject:MAKE_BLINK_ARROW_SPRITE(endArrowBody)];
}

- (void)completed {
	if(completedTicks) return;
	
	if(!silverPar)
		NSLog(@"silverPar not set for %@", self);
		
	// set the medal
	medalType medal = medalNone;
	if(strokeCount <= goldPar){
		medal = medalGold;
	} else if(strokeCount <= silverPar){
		medal = medalSilver;
		nextBestStrokesCount = goldPar;
	} else {
		medal = medalBronze;
		nextBestStrokesCount = silverPar;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"medals"]];
	NSString *key = [[self class] description];
	if(![dictionary objectForKey:key] || [[dictionary objectForKey:key] intValue] > medal){
		[dictionary setObject:[NSNumber numberWithInt:medal] forKey:key];
		[defaults setValue:dictionary forKey:@"medals"];
		[defaults synchronize];
	}
	
	NSLog(@"level %@ completed in %0.1fs and %d strokes!\n", [self class], (float)ticks/60.0f, strokeCount);

	[levelEndLight setIntensity:1];
	//ballShape.layers ^= playerLayerUnlock;
	completedTicks = ticks;
	
	const sprite *sprite = [goalOrbSprite bytes];

  ChipmunkBody *body = sprite->body->data;
  cpVect offset = sprite->offset;
  [sprites addObject:SpriteOffset(MAKE_PLAYER_BALL_SPRITE(body), offset)];
  [sprites removeObject:goalOrbSprite];
  
	float pitch = ((float)rand()/(float)RAND_MAX)*0.1f + 0.15f;
  playSound(gotGoalSound, 0.5f, pitch);
	
	// reset the UI sprites
	[uiSprites removeAllObjects];
  int y = 144;
  
  if(nextBestStrokesCount){
		[uiSprites addObject:SpriteOffset(MakeSprite(10, medal - 1, 1, 1, staticBody, 0, 0), cpv(176, y))]; // medal image
		[uiSprites addObject:SpriteOffset(MakeSprite(11, 12, 2, 1, staticBody, 0, 0), cpv(208, y))]; // par:
    y += 32;
	}

  [uiSprites addObject:SpriteOffset(MakeSprite(10, 15, 4, 1, staticBody, 0, 0), cpv(176, y))];
	[uiSprites addObject:SpriteOffset(MakeSprite(10, medal, 1, 1, staticBody, 0, 0), cpv(256 + 8, y))]; // medal image
  
  [uiSprites addObject:SpriteOffset(MakeSprite(11, 14, 4, 1, staticBody, 0, 0), cpv(176, y + 32))];

	[uiSprites addObject:SpriteOffset(MakeSprite(15, 14, 1, 1, staticBody, 0, 0), cpv(RESET_X, RESET_Y))];
	[uiSprites addObject:SpriteOffset(MakeSprite( 8, 11, 8, 1, staticBody, 0, 0), cpv(CONTINUE_X, CONTINUE_Y))];

	
//	[self showEndArrow]; // also modifies uiSprites
}

- (void)resetPlayerJoints {
	for(ChipmunkConstraint *joint in playerJoints)
		[space removeObject:joint];
	[playerJoints removeAllObjects];
	[playerRopes removeAllObjects];
}

static bool
hitGoalCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	[level completed];
	return TRUE;
}


static inline cpFloat
hit_velocity(cpBody *a, cpBody *b, cpVect p, cpVect n){
	cpVect r1 = cpvsub(p, a->p);
	cpVect r2 = cpvsub(p, b->p);
	cpVect v1_sum = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
	cpVect v2_sum = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
	
	return cpvdot(cpvsub(v2_sum, v1_sum), n);
}

static bool
bumpSoundCallback(cpArbiter *arb, cpSpace *space, void *unused)
{
	cpShape *a, *b; cpArbiterGetShapes(arb, &a, &b);
	cpContact *contacts = arb->contacts;
	
	const cpFloat min = 10.0f;
	const cpFloat max = 300.0f;
	cpFloat nspeed = cpfabs(hit_velocity(a->body, b->body, contacts[0].p, contacts[0].n));

	if(nspeed > min){
		ALfloat volume = fmax(fminf((nspeed - min)/(max - min), 1.0f), 0.0f);
		playSound(bumpSound, volume, 1.0f);
	}
	
	return TRUE;
}

static bool
levelEndCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *border; cpArbiterGetShapes(arb, &ball, &border);
	
	if(level->completedTicks){
		[level->space removeObject:ball->data];
		[level->space removeObject:ball->body->data];
//		[LevelStateDelegate jumpToLevel:[Levels nextLevel:[level class]]];
	}
	return FALSE;
}

static bool
pusherCallback(cpArbiter *arb, cpSpace *space, void *unused)
{
	cpShape *ball, *pusher; cpArbiterGetShapes(arb, &ball, &pusher);
  playSound(arrowStoneSound, 1.0f, 1.0f);
  
	ball->body->v = cpvmult(pusher->body->rot, 200.0f);
	return FALSE;
}

static bool
blueOrbCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *orb; cpArbiterGetShapes(arb, &ball, &orb);
	
	// direct this to the level, perhaps.
	[((id)level) triggerBlueOrb: orb];

	return TRUE;
}

static bool
blueCrystalCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *crystal; cpArbiterGetShapes(arb, &ball, &crystal);
	cpContact *contacts = arb->contacts;
	
	const cpFloat min = 10.0f;
	const cpFloat max = 300.0f;
	cpFloat nspeed = cpfabs(hit_velocity(ball->body, crystal->body, contacts[0].p, contacts[0].n));

	if(nspeed > min){
		ALfloat volume = fmax(fminf((nspeed - min)/(max - min), 1.0f), 0.0f);
		playSound(crystalSound, volume, 1.0f);
	}
	
	// direct this to the level, perhaps.
	[((id)level) triggerBlueCrystal: crystal];	
	return TRUE;
}

static bool
redOrbCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *orb; cpArbiterGetShapes(arb, &ball, &orb);
	  
	// direct this to the level, perhaps.
	[((id)level) triggerRedOrb: orb];	
	return TRUE;
}

static bool
whiteOrbCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *orb; cpArbiterGetShapes(arb, &ball, &orb);
	cpContact *contacts = arb->contacts;
	cpFloat normal_coef = arb->swappedColl ? -1.0f : 1.0f;
	
  // direct this to the level, perhaps.
	[((id)level) triggerWhiteOrb: orb];
	
	for(ChipmunkConstraint* joint in level->playerJoints){
		if(joint.constraint->b == orb->body) return FALSE;
	}
	
	cpFloat dot = normal_coef*cpvdot(cpvnormalize(cpvsub(orb->body->v, ball->body->v)), contacts[0].n);
	if(dot > -0.8f) return TRUE;
	
	ChipmunkPinJoint *joint = [[ChipmunkPinJoint alloc] initWithBodyA:ball->body->data bodyB:orb->body->data anchr1:cpvzero anchr2:cpvzero];
	joint.dist = cpCircleShapeGetRadius(ball) + cpCircleShapeGetRadius(orb) - 1.0f;
	[level->playerJoints addObject:joint];
	[level->space addObject:joint];
	[joint release];
  
	return TRUE;
}

static bool
gooOrbCallback(cpArbiter *arb, cpSpace *space, LevelStateDelegate *level)
{
	cpShape *ball, *orb; cpArbiterGetShapes(arb, &ball, &orb);
	cpContact *contacts = arb->contacts;
	cpFloat normal_coef = arb->swappedColl ? -1.0f : 1.0f;
	
	for(ChipmunkConstraint* joint in level->playerJoints){
		if(joint.constraint->b == orb->body) return TRUE;
	}
	
	ChipmunkBody *a = ball->body->data, *b = orb->body->data;
	cpVect point = contacts[0].p;
	cpVect anchr1 = [a world2local:point], anchr2 = [b world2local:point];
	ChipmunkDampedSpring *joint = [[ChipmunkDampedSpring alloc] initWithBodyA:a bodyB:b anchr1:anchr1 anchr2:anchr2 restLength:0 stiffness:2 damping:0.5];
	[level->playerJoints addObject:joint];
	[level->space addObject:joint];
	[joint release];
	
	cpVect n = contacts[0].n;
	cpVect r1 = [a world2local:cpvsub(point, cpvmult(n,  8.0f*normal_coef))];
	cpVect r2 = [b world2local:cpvsub(point, cpvmult(n, -8.0f*normal_coef))];
//	NSLog(@"ball:(%0.2f, %0.2f) orb:(%0.2f, %0.2f) n:(%0.2f, %0.2f) %0.1f", r1.x, r1.y, r2.x, r2.y, n.x, n.y, normal_coef);
	[level->playerRopes addObject:MakeRope(a, b, r1, r2, ropeTypeGoop)];
  
  playSound(stickyBallSound, 0.4f, 1.0f);
  
	return TRUE;
}

static void
cpSpaceAddCollisionPairFunc(cpSpace *space, cpCollisionType a, cpCollisionType b, cpCollisionPreSolveFunc func, void *data)
{
	cpSpaceAddCollisionHandler(space, a, b, NULL, func, NULL, NULL, data);
}

typedef cpCollisionPreSolveFunc cpCollFunc;

- (id)init {
	if(self = [super init]){
		// must release loops here as the new state is inited before the old one is released
		release_loops();
		
		lights = [[NSMutableArray alloc] init];
		sprites = [[NSMutableArray alloc] init];
		uiSprites = [[NSMutableArray alloc] init];
		ropes = [[NSMutableArray alloc] init];
		playerRopes = [[NSMutableArray alloc] init];
		shadowPolylines = [[NSMutableArray alloc] init];
		playerJoints = [[NSMutableArray alloc] init];
    
    strokeCount = 0;
		lastTouchTicks = INT_MAX;
		
		space = [[ChipmunkSpace alloc] init];
		space.space->gravity = cpv(0.0f, -100.0f);
		space.space->iterations = 5;
//		space.space->elasticIterations = 5;
		
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, nil, (cpCollFunc)bumpSoundCallback, NULL);
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsGoalType, (cpCollFunc)hitGoalCallback, self); // TODO finish level noise
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsPusherType, (cpCollFunc)pusherCallback, self);
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsBlueOrbType, (cpCollFunc)blueOrbCallback, self); // TODO make orb noises
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsRedOrbType, (cpCollFunc)redOrbCallback, self);
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsWhiteOrbType, (cpCollFunc)whiteOrbCallback, self);
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsBlueCrystalType, (cpCollFunc)blueCrystalCallback, self);
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsGooOrbType, (cpCollFunc)gooOrbCallback, self); // TODO make goo noise
		
		cpSpaceAddCollisionPairFunc(space.space, physicsBallType, physicsOutsideBorderType, (cpCollFunc)levelEndCallback, self);
		
		staticBody = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
		
		{ // add boundary box
			cpFloat r = 10.0f;
			
			cpFloat xmin =   0.0f - (r + 2.0f*PLAYER_BALL_RADIUS);
			cpFloat xmax = 480.0f + (r + 2.0f*PLAYER_BALL_RADIUS);
			cpFloat ymin =   0.0f - (r + 2.0f*PLAYER_BALL_RADIUS);
			cpFloat ymax = 320.0f + (r + 2.0f*PLAYER_BALL_RADIUS);
			
			[self addStaticSegmentFrom:cpv(xmin, ymin) to:cpv(xmin, ymax) radius:r layers:physicsOutsideBorderLayer type:physicsOutsideBorderType];
			[self addStaticSegmentFrom:cpv(xmin, ymax) to:cpv(xmax, ymax) radius:r layers:physicsOutsideBorderLayer type:physicsOutsideBorderType];
			[self addStaticSegmentFrom:cpv(xmax, ymax) to:cpv(xmax, ymin) radius:r layers:physicsOutsideBorderLayer type:physicsOutsideBorderType];
			[self addStaticSegmentFrom:cpv(xmax, ymin) to:cpv(xmin, ymin) radius:r layers:physicsOutsideBorderLayer type:physicsOutsideBorderType];
		}
		
		{
			cpFloat r = 10.0f;

			cpFloat xmin =   0.0f - r;
			cpFloat xmax = 480.0 + r;
			cpFloat ymin =   0.0f - r;
			cpFloat ymax = 320.0 + r;
			
			[self addStaticSegmentFrom:cpv(xmin, ymin) to:cpv(xmin, ymax) radius:r layers:physicsBorderInsideLeftLayer type:nil];
			[self addStaticSegmentFrom:cpv(xmin, ymax) to:cpv(xmax, ymax) radius:r layers:physicsBorderInsideTopLayer type:nil];
			[self addStaticSegmentFrom:cpv(xmax, ymax) to:cpv(xmax, ymin) radius:r layers:physicsBorderInsideRightLayer type:nil];
			[self addStaticSegmentFrom:cpv(xmax, ymin) to:cpv(xmin, ymin) radius:r layers:physicsBorderInsideBottomLayer type:nil];
		}
		
		spriteTexture = loadPNG(@"spritesheet.png");
    
		ambientLevel = 0.3f;
		lightTexture = loadPNG(@"light-point.png");
		glGenerateMipmapOES(GL_TEXTURE_2D);
		staticLightMapTexture = makeBlankTexture(LIGHT_MAP_SIZE, LIGHT_MAP_SIZE);
		lightMapTexture = makeBlankTexture(LIGHT_MAP_SIZE, LIGHT_MAP_SIZE);
		
		// generate lightFBO
		glGenFramebuffersOES(1, &lightFBO);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, lightFBO);
		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, lightMapTexture, 0);
		
		GLenum fboErr = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
		if(fboErr != GL_FRAMEBUFFER_COMPLETE_OES){
			printf("FBO error: %x\n", fboErr);
		}
		
		[self renderStaticLightMap];
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
    
    // add UI elements:
    [uiSprites addObject:SpriteOffset(MakeSprite(15, 14, 1, 1, staticBody, 0, 0), cpv(RESET_X, RESET_Y))];
    [uiSprites addObject:SpriteOffset(MakeSprite(15, 13, 1, 1, staticBody, 0, 0), cpv(HOME_X, HOME_Y))];
    [uiSprites addObject:SpriteOffset(MakeSprite(11, 14, 4, 1, staticBody, 0, 0), cpv(350, 300))];
	}
	
	return self;
}

- (void) dealloc {
//	NSLog(@"dealloc level");
	
	[space release];
	[staticBody release];
	[ballBody release];
	[ballShape release];
	[levelEndLight release];
	[sprites release];
	[uiSprites release];
	[ropes release];
	[playerRopes release];
	[lights release];
	[shadowPolylines release];
	[playerJoints release];
	
	glDeleteTextures(1, &bgTexture);
	glDeleteTextures(1, &spriteTexture);
	glDeleteTextures(1, &tutorialTextTexture);
	glDeleteTextures(1, &lightMapTexture);
	glDeleteTextures(1, &lightTexture);
	
	glDeleteBuffers(1, &lightFBO);
	
	[super dealloc];
}


- (void)addChipmunkObject:(id <ChipmunkObject>)obj {
	[space addObject:obj];
}

- (void)update {
	ticks++;
	
	// completed the level end fade, move on
	if(fadeOutTicks && fadeOutTicks + FADE_TICKS <= ticks){
		[LevelStateDelegate jumpToLevel:[Levels nextLevel:[self class]]];
	}
	
	[space step:(1.0f/60.0f)];
	
	// If the ball has been added and it's out of bounds
	if(ballBody && (
			ballBody.pos.y < -PLAYER_BALL_RADIUS ||
			ballBody.pos.x < -PLAYER_BALL_RADIUS ||
			ballBody.pos.y > 320 + PLAYER_BALL_RADIUS ||
			ballBody.pos.x > 480 + PLAYER_BALL_RADIUS
		)
	){
		ballBody.pos = ballStartPos;
		ballBody.vel = ballStartVel;
		ballBody.angVel = 0.0f;
		[self resetPlayerJoints];
    
    // one stroke penalty for the reset.
		if(!completedTicks){
			strokeCount += 1;
		}
	}
	
	if(!completedTicks && goalOrbBody){
		cpVect pos = goalOrbBody.pos;
		if(
			pos.y < -PLAYER_BALL_RADIUS
//			|| pos.y > 320 + PLAYER_BALL_RADIUS
			|| pos.x < -PLAYER_BALL_RADIUS
			|| pos.x > 480 + PLAYER_BALL_RADIUS
		){
			goalOrbBody = nil; // don't check it again.
			[uiSprites replaceObjectAtIndex:0 withObject:SpriteOffset(MakeSprite(15, 14, 1, 1, staticBody, 2, 30), cpv(RESET_X, RESET_Y))];
		}
	}
}

void drawLightMapTexture(){
	const GLfloat verts[] = {
		0, 0,
		0, 1,
		1, 0,
		1, 1,
	};
	
	const GLfloat tcoords[] = {
		0, 0,
		0, 1,
		1, 0,
		1, 1,
	};
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glTexCoordPointer(2, GL_FLOAT, 0, tcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

void drawBGTexture(){
	const GLfloat verts[] = {
		0, 0,
		0, 1,
		1, 0,
		1, 1,
	};
	
	const GLfloat rx = 16.0f/512.0f;
	const GLfloat ry = 96.0f/512.0f;
	const GLfloat tcoords[] = {
		0 + rx, 1 - ry,
		0 + rx, 0 + ry,
		1 - rx, 1 - ry,
		1 - rx, 0 + ry,
	};
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glTexCoordPointer(2, GL_FLOAT, 0, tcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)loadBG:(NSString *)name {
	if([name isEqualToString:@"temp"]){
		bgTexture = loadPNG(@"levelTemporary.png");
	} else {
		bgTexture = loadPVRTC(name, 512);
	}
}

- (void)nextLevelDirection:(int) layer{
	playerLayerUnlock = layer;
}

void flippedOrtho(GLfloat w, GLfloat h){
	const GLfloat sx = 2.0f/w;
	const GLfloat sy = 2.0f/h;
	
	const GLfloat matrix[16] = {
		 0.0f,  -sx, 0.0f, 0.0f,
		   sy, 0.0f, 0.0f, 0.0f,
		 0.0f, 0.0f, 1.0f, 0.0f,
		-1.0f, 1.0f, 0.0f, 1.0f,
	};
	
	glLoadMatrixf(matrix);
}

void printErr(){
	for(GLenum err; (err = glGetError());)
		NSLog(@"Run loop end GL err: 0x%x", err);
	
	for(ALuint err; (err = alGetError());)
		NSLog(@"Run loop end AL err: 0x%x", err);
}

void
renderSprites(NSArray *sprites, int ticks)
{
	GLshort coords[16] = {};
	
	const GLsizei stride = 4*sizeof(GLshort);
	glVertexPointer(2, GL_SHORT, stride, coords);
	glTexCoordPointer(2, GL_SHORT, stride, coords + 2);
	
	for(NSData *data in sprites){
		glPushMatrix();
		{
			const sprite *sprite = [data bytes];
			cpBody *body = sprite->body;
			cpVect pos = body->p;
			cpVect rot = body->rot;
			
			cpVect offset = sprite->offset;
			cpFloat tranx = rot.x*offset.x - rot.y*offset.y + pos.x;
			cpFloat trany = rot.y*offset.x + rot.x*offset.y + pos.y;
			
			GLfloat matrix[16] = {
				 rot.x, rot.y, 0.0f, 0.0f,
				-rot.y, rot.x, 0.0f, 0.0f,
					0.0f,  0.0f, 1.0f, 0.0f,
				 tranx, trany, 0.0f, 1.0f,
			};
			glMultMatrixf(matrix);
			
			// copy in new coord data
			memcpy(coords, sprite->coords, sizeof(coords));
			if(sprite->frames){
				// ping-pong
				unsigned int mod = sprite->frames*2 - 2;
				unsigned int frame = (ticks/sprite->skip + (unsigned int)sprite)%(mod);
				frame = (frame < sprite->frames ? frame : mod - frame);
				
				int ymin = coords[7];
				int ymax = coords[3];
				int delta = ymax - ymin;
				
				coords[7] = coords[15] = ymin + delta*frame;
				coords[3] = coords[11] = ymax + delta*frame;
			}
			
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
		glPopMatrix();
	}
}

static void
renderRope(cpVect a, cpVect b, cpFloat length, ropeType type, GLfloat coords[16])
{
	const GLfloat txmax = 512.0f - 16.0f*(GLfloat)type;
	const GLfloat txmin = txmax - 16.0f;
	const GLfloat tymin = 0.0f;// 1.0f*32.0f;
	const GLfloat tymax = tymin + cpfmin(256.0f, length);
		
	const GLfloat coords2[16] = {
		0.0f, -0.5f, txmin, tymin,
		0.0f,  0.5f, txmax, tymin,
		1.0f, -0.5f, txmin, tymax,
		1.0f,  0.5f, txmax, tymax,
	};
	memcpy(coords, coords2, sizeof(coords2));
	
	cpVect d = cpvsub(b, a);
	cpFloat s = 16.0f/cpvlength(d);
	
	glPushMatrix(); {
		GLfloat matrix[16] = {
			 d.x,  d.y, 0.0f, 0.0f,
			-d.y*s,  d.x*s, 0.0f, 0.0f,
			0.0f, 0.0f, 1.0f, 0.0f,
			 a.x,  a.y, 0.0f, 1.0f,
		};
		glMultMatrixf(matrix);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	} glPopMatrix();
}

- (void)renderArrow {
	if(isTouched){
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	} else {
		GLfloat v = cpfclamp(1.0f - (ticks - lastTouchTicks)/30.0f, 0.0f, 1.0f);
		if(!v) return;
		
		glColor4f(v, v, v, v);
	}
	
	GLfloat coords[16];
	
	const GLsizei stride = 4*sizeof(GLfloat);
	glVertexPointer(2, GL_FLOAT, stride, coords);
	glTexCoordPointer(2, GL_FLOAT, stride, coords + 2);
	
	cpVect a = touchCurrent;
	cpVect b = touchStart;
	renderRope(a, b, cpvdist(a, b), ropeTypeArrow, coords);
}

static void
renderRopes(NSArray *ropes)
{
	GLfloat coords[16];
	
	const GLsizei stride = 4*sizeof(GLfloat);
	glVertexPointer(2, GL_FLOAT, stride, coords);
	glTexCoordPointer(2, GL_FLOAT, stride, coords + 2);
	
	for(NSData *data in ropes){
		const rope *rope = [data bytes];
		cpVect a = cpBodyLocal2World(rope->a, rope->offset1);
		cpVect b = cpBodyLocal2World(rope->b, rope->offset2);
		renderRope(a, b, rope->length, rope->type, coords);
	}
}

- (cpVect)releaseVelocity {
	return cpvsub(touchCurrent, touchStart);
}

static inline int
queryReject(cpShape *a, cpShape *b)
{
	return
		// BBoxes must overlap
		!cpBBintersects(a->bb, b->bb)
		// Don't collide shapes attached to the same body.
		|| a->body == b->body
		// Don't collide objects in the same non-zero group
		|| (a->group && b->group && a->group == b->group)
		// Don't collide objects that don't share at least on layer.
		|| !(a->layers & b->layers);
}

static void
queryFunc(cpShape *a, cpShape *b, bool *didCollide)
{
	// Reject any of the simple cases
	if(queryReject(a,b)) return;
	
	// Shape 'a' should have the lower shape type. (required by cpCollideShapes() )
	if(a->klass->type > b->klass->type){
		cpShape *temp = a;
		a = b;
		b = temp;
	}
	
	// Narrow-phase collision detection.
	cpContact contacts[CP_MAX_CONTACTS_PER_ARBITER];
	int numContacts = cpCollideShapes(a, b, (void *)contacts);
	if(!numContacts) return; // Shapes are not colliding.
	
	(*didCollide) = TRUE;
}

static bool
checkCollision(cpSpace *space, cpShape *shape)
{
	cpShapeCacheBB(shape);
	
	bool didCollide = FALSE;
	cpSpaceHashQuery(space->staticShapes, shape, shape->bb, (cpSpaceHashQueryFunc)queryFunc, &didCollide);
	cpSpaceHashQuery(space->activeShapes, shape, shape->bb, (cpSpaceHashQueryFunc)queryFunc, &didCollide);
	
	return didCollide;
}

- (void)renderPath:(cpVect)vel showCollision:(bool)showCollision {
	const GLshort size = 32;
	const GLshort halfSize = size/2;
	
	const GLshort txmin = (3)*size;
	const GLshort txmax = (4)*size;
	const GLshort tymin = (2)*size;
	const GLshort tymax = (3)*size;
		
	GLshort coords[16] = {
		-halfSize, -halfSize, txmin, tymin,
		-halfSize,  halfSize, txmin, tymax,
		 halfSize, -halfSize, txmax, tymin,
		 halfSize,  halfSize, txmax, tymax,
	};
	
	const GLsizei stride = 4*sizeof(GLshort);
	glVertexPointer(2, GL_SHORT, stride, coords);
	glTexCoordPointer(2, GL_SHORT, stride, coords + 2);
	
	const cpFloat dt = 1.0f/60.0f;
	cpBody body = *(ballBody.body);
	cpCircleShape shape = *((cpCircleShape *)ballShape.shape);
	shape.shape.body = &body;
  
  // This line is for adding impulses instead of directly setting velocity.
  // cpBodyApplyImpulse(&body, [self releaseImpulse], cpvzero);

	body.v = vel;
	
	for(int i=1; i<200; i++){
		body.position_func(&body, dt);
		body.velocity_func(&body, space.space->gravity, 1.0f, dt);
		
		// break when it goes off the screen
		if(checkCollision(space.space, (cpShape *)&shape)){
			if(true){
				const GLshort size = 32;
				const GLshort halfSize = size/2;
				
				const GLshort txmin = (3)*size;
				const GLshort txmax = (4)*size;
				const GLshort tymin = ( 1)*size;
				const GLshort tymax = ( 2)*size;
					
				GLshort coords[16] = {
					-halfSize, -halfSize, txmin, tymin,
					-halfSize,  halfSize, txmin, tymax,
					 halfSize, -halfSize, txmax, tymin,
					 halfSize,  halfSize, txmax, tymax,
				};
				
				GLfloat v = (1.0f - (GLfloat)i/200.0f)*(showCollision ? 1.0f : 0.5f);
				glColor4f(v, v, v, v);
				glVertexPointer(2, GL_SHORT, stride, coords);
				glTexCoordPointer(2, GL_SHORT, stride, coords + 2);
				glPushMatrix(); {
					glTranslatef(body.p.x, body.p.y, 0.0f);
					glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				} glPopMatrix();
			}
			
			break;
		} else if(i%15 != 0){
			continue;
		}
		
		GLfloat v = (1.0f - (GLfloat)i/200.0f)*(showCollision ? 1.0f : 0.35f);
		glColor4f(v, v, v, v);
		glPushMatrix(); {
			glTranslatef(body.p.x, body.p.y, 0.0f);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		} glPopMatrix();
	}
}

- (void)renderStaticLightMap {
	GLuint tempFBO;
	glGenFramebuffersOES(1, &tempFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, tempFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, staticLightMapTexture, 0);
	
	GLenum fboErr = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
	if(fboErr != GL_FRAMEBUFFER_COMPLETE_OES){
		printf("FBO error: %x\n", fboErr);
	}
	
	// render
	glViewport(0, 0, LIGHT_MAP_SIZE, LIGHT_MAP_SIZE);
	glEnableClientState(GL_VERTEX_ARRAY);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, 480, 0, 320, -1, 1);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
//	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	const GLfloat blueness = 0.8f;
	glClearColor(blueness*ambientLevel, blueness*ambientLevel, ambientLevel, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// draw lightmap
	glBindTexture(GL_TEXTURE_2D, lightTexture);
	for(Light *light in lights){
		[light drawWithShadows:shadowPolylines staticBody:staticBody ticks:ticks];
	}
	
	[lights removeAllObjects];
	
	// cleanup
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
	glDeleteFramebuffersOES(1, &tempFBO);
}

- (void)renderNumber:(int)num at:(cpVect)pos {
	static GLshort coords[160] = {
		-16, -16,   0, 512,
		-16,  16,   0, 480,
		 16, -16,  32, 512,
		 16,  16,  32, 480,
		-16, -16,  32, 512,
		-16,  16,  32, 480,
		 16, -16,  64, 512,
		 16,  16,  64, 480,
		-16, -16,  64, 512,
		-16,  16,  64, 480,
		 16, -16,  96, 512,
		 16,  16,  96, 480,
		-16, -16,  96, 512,
		-16,  16,  96, 480,
		 16, -16, 128, 512,
		 16,  16, 128, 480,
		-16, -16, 128, 512,
		-16,  16, 128, 480,
		 16, -16, 160, 512,
		 16,  16, 160, 480,
		-16, -16, 160, 512,
		-16,  16, 160, 480,
		 16, -16, 192, 512,
		 16,  16, 192, 480,
		-16, -16, 192, 512,
		-16,  16, 192, 480,
		 16, -16, 224, 512,
		 16,  16, 224, 480,
		-16, -16, 224, 512,
		-16,  16, 224, 480,
		 16, -16, 256, 512,
		 16,  16, 256, 480,
		-16, -16, 256, 512,
		-16,  16, 256, 480,
		 16, -16, 288, 512,
		 16,  16, 288, 480,
		-16, -16, 288, 512,
		-16,  16, 288, 480,
		 16, -16, 320, 512,
		 16,  16, 320, 480,
	};
	
	const GLsizei stride = 4*sizeof(GLshort);
	glVertexPointer(2, GL_SHORT, stride, coords);
	glTexCoordPointer(2, GL_SHORT, stride, coords + 2);
	
	char buff[256];
	snprintf(buff, 256, "%d", num);
	
	glPushMatrix(); {
		glTranslatef(pos.x, pos.y, 0.0f);
		
		for(int i=0, count=strlen(buff); i<count; i++){
			glDrawArrays(GL_TRIANGLE_STRIP, (buff[i] - '0')*4, 4);
			glTranslatef(18.0f, 0.0f, 0.0f);
		}
	} glPopMatrix();
}

- (void)renderUI {
	renderSprites(uiSprites, ticks);
	if(completedTicks){
    int addition = 0;
		if(nextBestStrokesCount){
			[self renderNumber:nextBestStrokesCount at:cpv(256, 144)];
      addition = 32;
		}
		[self renderNumber:strokeCount at:cpv(256, 176 + addition)];
	} else {
		[self renderNumber:strokeCount at:cpv(425, 300)];
	}
}

- (void)draw {
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, lightFBO);
	glViewport(0, 0, LIGHT_MAP_SIZE, LIGHT_MAP_SIZE);
	glEnableClientState(GL_VERTEX_ARRAY);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, 1, 0, 1, -1, 1);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
//	glClearColor(ambientLevel, ambientLevel, ambientLevel, 0.0f);
//	glClear(GL_COLOR_BUFFER_BIT);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, staticLightMapTexture);
	drawLightMapTexture();
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, 480, 0, 320, -1, 1);
//	glMatrixMode(GL_TEXTURE);
//	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
//	glLoadIdentity();
	
	// draw lightmap
	glBindTexture(GL_TEXTURE_2D, lightTexture);
	for(Light *light in lights){
		[light drawWithShadows:shadowPolylines staticBody:staticBody ticks:ticks];
	}

	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glViewport(0, 0, 320, 480);
	glMatrixMode(GL_PROJECTION);
	flippedOrtho(1, 1);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, lightMapTexture);
	drawLightMapTexture();
	
	glEnable(GL_BLEND);
//	glBlendFunc(GL_ONE, GL_ONE);
//	glBindTexture(GL_TEXTURE_2D, staticLightMapTexture);
//	drawLightMapTexture();
	
	glBlendFunc(GL_DST_COLOR, GL_ZERO);
	glBindTexture(GL_TEXTURE_2D, bgTexture);
	drawBGTexture();
	
	// Draw sprites
	glMatrixMode(GL_PROJECTION);
	flippedOrtho(480, 320);
	glMatrixMode(GL_TEXTURE);
	glScalef(1.0f/512.0f, 1.0f/512.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glBindTexture(GL_TEXTURE_2D, spriteTexture);

	glColor4f(1.0f, 1.0f, 1.0f, 1.0f); // ambient light
	renderRopes(ropes);
	renderRopes(playerRopes);
	renderSprites(sprites, ticks);
//	[self renderArrow];
	if(completedTicks || fadeOutTicks){
		int fadeTicks = (fadeOutTicks ? FADE_TICKS - ticks + fadeOutTicks : ticks - completedTicks);
		GLfloat v = cpfclamp((GLfloat)fadeTicks/(GLfloat)FADE_TICKS, 0.0f, 1.0f);
		
		glColor4f(v,v,v,v);
		glPushMatrix();
		glTranslatef(240.0f, 160.0f, 0.0f);
		GLfloat scale = 2.0f - v;
		glScalef(scale, scale, 1.0f);
		glTranslatef(-240.0f, -160.0f, 0.0f);
		
		[self renderUI];
		
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glPopMatrix();
	} else {
		[self renderUI];
	}
	
	if(ballShape){ // no ball when in Lite preview mode
		if(isTouched){
			[self renderPath:[self releaseVelocity] showCollision:true];
		} else {
			[self renderPath:ballBody.vel showCollision:false];
		}
	}
		
	#ifdef DEBUG
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		drawSpace(space.space);
	#endif
	
	printErr();
}

- (bool)button:(cpBB)bb {
	return cpBBcontainsVect(bb, touchStart) && cpBBcontainsVect(bb, touchCurrent);
}

- (void)touchDownAt:(cpVect)pos {
	#ifdef DEBUG
		cpFloat gridSize = 1.0f;
		
		cpFloat x = cpffloor(pos.y/gridSize + 0.5f)*gridSize;
		cpFloat y = 320.0f - cpffloor(pos.x/gridSize + 0.5f)*gridSize;
		printf("\t\t\t%3.0f, %3.0f,\n", x, y);
	#endif
}

- (void)touchUp {
	if(!isTouched) return; // workaround for OS 2.0 event order bug
	isTouched = FALSE;
	
	// reset button
  if([self button:resetBB]){
		[GameState stopWithValue:[LevelStateDelegate gamestateForLevel:[self class]]];
	} else if([self button:homeBB]){
		[GameState stopWithValue:[LevelStateDelegate gamestateForLevel:[Levels level:0]]];
	} else if(completedTicks && ticks > completedTicks + FADE_TICKS){
		fadeOutTicks = ticks;
	}
  
	[self resetPlayerJoints];
	
	// add a stroke
	if(!completedTicks)
		strokeCount += 1;
	
	// hit the ball
	playSound(strokeSound, 0.5f, 1.0f);

  ballBody.vel = [self releaseVelocity];
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
