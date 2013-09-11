#import "LevelWidgets.h"
#import "ChipmunkSpaceExtras.h"

NSData *
MakeSprite(int x, int y, int w, int h, ChipmunkBody *body, int frames, int skip)
{
	const GLshort size = 32;
	
	GLshort xmin = -w*size/2;
	GLshort xmax =  w*size/2;
	GLshort ymin = -h*size/2;
	GLshort ymax =  h*size/2;
	
	GLshort txmin = (x    )*size;
	GLshort txmax = (x + w)*size;
	GLshort tymin = (y    )*size;
	GLshort tymax = (y + h)*size;
		
	sprite spr = (sprite){
		{
			xmin, ymin, txmin, tymax,
			xmin, ymax, txmin, tymin,
			xmax, ymin, txmax, tymax,
			xmax, ymax, txmax, tymin,
		},
		body.body,
		{0,0},
		frames, skip,
	};
	
	return [NSData dataWithBytes:&spr length:sizeof(spr)];
}

NSData *
SpriteOffset(NSData *data, cpVect offset)
{
	sprite spr = *((const sprite *)[data bytes]);
	spr.offset = offset;
	
	return [NSData dataWithBytes:&spr length:sizeof(spr)];
}

NSData *
MakeRope(ChipmunkBody *a, ChipmunkBody *b, cpVect offset1, cpVect offset2, ropeType type)
{
	cpFloat len = cpvlength(cpvsub([a local2world:offset1], [b local2world:offset2]));
	return MakeRope2(a, b, offset1, offset2, len, type);
}

NSData *
MakeRope2(ChipmunkBody *a, ChipmunkBody *b, cpVect offset1, cpVect offset2, cpFloat len, ropeType type)
{
	rope rope = {
		a.body, b.body,
		offset1, offset2,
		len,
		type,
	};
	
	return [NSData dataWithBytes:&rope length:sizeof(rope)];
}

@implementation LevelStateDelegate (LevelWidgets)

- (void) changeSprite:(cpBody*) body to:(NSData*) newSprite{
	
	const sprite* spr;
	NSData* data;
	for(data in sprites){
		spr = ((const sprite *)[data bytes]);
		
		if(spr->body == body){
			break;
		}
		
	}
	sprite spr2 = *((const sprite *)[newSprite bytes]);
	spr2.offset = spr->offset;

	[sprites removeObject:data];
	[sprites addObject:[NSData dataWithBytes:&spr2 length:sizeof(spr2)]];
	
}


- (void)addShadowBox:(ChipmunkBody *)body offset:(cpVect)offset width:(GLfloat)x_scale height:(GLfloat)y_scale {
  static GLfloat shadowBoxVerts[] = {
    -1.0f, -1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,
     1.0f, -1.0f, 0.0f,
     1.0f, -1.0f, 1.0f,
     1.0f,  1.0f, 0.0f,
     1.0f,  1.0f, 1.0f,
    -1.0f,  1.0f, 0.0f,
    -1.0f,  1.0f, 1.0f,
    -1.0f, -1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,
  };
	
	GLsizei size = sizeof(shadowBoxVerts)/sizeof(*shadowBoxVerts)/3;
	shadowPolyLine shadow = {shadowBoxVerts, size, body.body, offset, x_scale, y_scale};
	[shadowPolylines addObject:[NSData dataWithBytes:&shadow length:sizeof(shadow)]];
}

- (void)addShadowCircle:(ChipmunkBody *)body offset:(cpVect)offset radius:(GLfloat)radius {
  static GLfloat shadowBoxVerts[] = {
		 1.0f,  0.0f, 0.0f,
		 1.0f,  0.0f, 1.0f,
		 0.7f,  0.7f, 0.0f,
		 0.7f,  0.7f, 1.0f,
		 0.0f,  1.0f, 0.0f,
		 0.0f,  1.0f, 1.0f,
		-0.7f,  0.7f, 0.0f,
		-0.7f,  0.7f, 1.0f,
		-1.0f,  0.0f, 0.0f,
		-1.0f,  0.0f, 1.0f,
		-0.7f, -0.7f, 0.0f,
		-0.7f, -0.7f, 1.0f,
		 0.0f, -1.0f, 0.0f,
		 0.0f, -1.0f, 1.0f,
		 0.7f, -0.7f, 0.0f,
		 0.7f, -0.7f, 1.0f,
		 1.0f,  0.0f, 0.0f,
		 1.0f,  0.0f, 1.0f,
  };
	
	GLsizei size = sizeof(shadowBoxVerts)/sizeof(*shadowBoxVerts)/3;
	shadowPolyLine shadow = {shadowBoxVerts, size, body.body, offset, radius, radius};
	[shadowPolylines addObject:[NSData dataWithBytes:&shadow length:sizeof(shadow)]];
}

static void
fireflyVelocityUpdate(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	Light *target = body->data;//[lights objectAtIndex:index];
	cpVect jitter = cpvmult(cpv(2*(cpFloat)rand()/(cpFloat)RAND_MAX - 1, 2*(cpFloat)rand()/(cpFloat)RAND_MAX - 1), 5.0f);
	cpVect turn = cpvadd(jitter, cpvmult(cpvnormalize(cpvsub(target.pos, body->p)), 20.0f));
	body->v = cpvmult(cpvnormalize(cpvadd(body->v, turn)), 150.0f);
//	cpBodyUpdateVelocity(body, gravity, damping, dt);
}

- (void)addFirefly:(Light *)target {
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:INFINITY];
	[space addObject:body]; [body release];
	body.pos = cpvadd(target.pos, cpv(100*(cpFloat)rand()/(cpFloat)RAND_MAX - 50, 100*(cpFloat)rand()/(cpFloat)RAND_MAX - 50));
	body.vel = cpv(100*(cpFloat)rand()/(cpFloat)RAND_MAX - 50, 100*(cpFloat)rand()/(cpFloat)RAND_MAX - 50);
	body.body->velocity_func = fireflyVelocityUpdate;
	body.body->data = target;
	
	[sprites addObject:MAKE_FIREFLY_SPRITE(body)];
}

static void
pixieVelocityUpdate(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	Light *target = body->data;//[lights objectAtIndex:index];
	
	cpVect turn = cpvmult(cpvnormalize(cpvsub(target.pos, body->p)), 8.0f);
	body->v = cpvmult(cpvnormalize(cpvadd(body->v, turn)), 50.0f);
//	cpBodyUpdateVelocity(body, gravity, damping, dt);
}

- (void)addPixie:(Light *)target {
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:INFINITY];
	[space addObject:body]; [body release];
	body.pos = cpvadd(target.pos, cpv(100*(cpFloat)rand()/(cpFloat)RAND_MAX - 50, 100*(cpFloat)rand()/(cpFloat)RAND_MAX - 50));
	body.vel = cpv(40*(cpFloat)rand()/(cpFloat)RAND_MAX - 20, 40*(cpFloat)rand()/(cpFloat)RAND_MAX - 20);
	body.body->velocity_func = pixieVelocityUpdate;
	body.body->data = target;
	
	[sprites addObject:MAKE_PIXIE_SPRITE(body)];
}

- (void)addGooOrbUnflipped:(cpVect)pos {
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = pos; // TODO mem leak
	
	ChipmunkShape *shape = [[ChipmunkStaticCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.elasticity = 0.0f;
	shape.friction = 1.0f;
	shape.collisionType = physicsGooOrbType;
	[space addStaticShape:shape];
	
	[sprites addObject:MAKE_GREEN_ORB_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
}


static GLfloat
flickerBall(int ticks, int salt)
{
	const int skip = 6;
	const int frames = 4;
	const GLfloat freq = M_PI/(GLfloat)(2*skip*(frames - 1));
	GLfloat value =  0.5f*sinf((GLfloat)ticks*freq) + 0.5f;
	
	return value*0.7f + 0.3f;
}

- (void)addPlayerBall:(cpVect)pos vel:(cpVect)vel{
  pos.y = 320 - pos.y;
  
	cpFloat m = 1.0f;
	cpFloat r = PLAYER_BALL_RADIUS;
	cpFloat moment = cpMomentForCircle(m, r, 0.0f, cpvzero);
	
	ballBody = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:moment];
	ballBody.pos = pos;
	ballBody.vel = vel;
	ballStartPos = pos;
	ballStartVel = vel;
	[space addObject:ballBody];

	if(NO_BALL_MODE) return; // LITE VERSION PREVIEW MODE
	
	ballShape = [[ChipmunkCircleShape alloc] initWithBody:ballBody radius:r offset:cpvzero];
	ballShape.elasticity = 0.7f;
	ballShape.friction = 0.1f;
	ballShape.group = physicsBallGroup;
	ballShape.collisionType = physicsBallType;
	[space addObject:ballShape];
	
	Light *light = [[Light alloc] initWithBody:ballBody offset:cpvzero radius:150.0f r:0.96f g:0.83f b:0.26f];
	[light setIntensity:0.7f];
	light->_flicker = flickerBall;
	[lights addObject:light]; [light release];
	
	[sprites addObject:MAKE_PLAYER_BALL_SPRITE(ballBody)];
	
//	for(int i=0; i<3; i++)
//		[self addPixie:light];
	
	[self addShadowCircle:ballBody offset:cpvzero radius:r];
}

- (void)addPlayerBall:(cpVect)pos {
	[self addPlayerBall:pos vel:cpvzero];
}

- (void)addEndArrow:(cpVect)pos angle:(cpFloat)angle {
	pos.y = 320 - pos.y;
	
	endArrowBody = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	endArrowBody.pos = pos;
	endArrowBody.angle = angle;
}

- (void)finishGoalOrb:(ChipmunkBody *)body radius:(cpFloat)r offset:(cpVect)offset {
	levelEndLight = [[Light alloc] initWithBody:body offset:offset radius:200.0f r:0.96f g:0.83f b:0.26f];
	[levelEndLight setIntensity:0.2f];
	levelEndLight->_flicker = flickerBall;
	[lights addObject:levelEndLight];
//	[levelEndLight release];
	
	goalOrbSprite = SpriteOffset(MAKE_GOAL_ORB_SPRITE(body), offset);
	[sprites addObject:goalOrbSprite];
//	[self addShadowCircle:body offset:offset radius:r];
	
//	for(int i=0; i<1; i++)
//		[self addPixie:levelEndLight];
}

- (ChipmunkBody*)addRollingGoalOrb:(cpVect)pos {
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
	shape.collisionType = physicsGoalType;
	shape.layers &= ~physicsBorderLayers;
  
	[space addObject:shape]; [shape release];
	
	[self finishGoalOrb:body radius:r offset:cpvzero];
	return body;
}

- (ChipmunkBody*)addChainedGoalOrb:(cpVect)pos length:(cpFloat)len {
  
	pos.y = 320 - pos.y;
  
	cpFloat m = 1.6f;
	cpFloat r = 14.0f;
	cpFloat moment = cpMomentForCircle(m, r, 0.0f, cpvzero);
  cpFloat hang = 11.0f;
	
  ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:moment];
	body.pos = cpvsub(pos, cpv(0, hang + len));
	body.vel = cpv(random() % 80 - 40,0);
	[self addChipmunkObject:body]; [body release];
  	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.elasticity = 0.1f;
	shape.friction = 0.4f;
	shape.collisionType = physicsGoalType;
	shape.layers &= ~physicsBorderLayers;
  [self addChipmunkObject:shape]; [shape release];
		
	cpVect anchr1 = cpv(0,hang);
	cpVect anchr2 = pos;
	ChipmunkConstraint *constraint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:anchr1 anchr2:anchr2 min:0 max:len];
	[self addChipmunkObject:constraint]; [constraint release];
		
	[ropes addObject:MakeRope(body, staticBody, anchr1, anchr2, ropeTypeChain)];
	[self finishGoalOrb:body radius:r offset:cpvzero];
	return body;
}


- (void)addGoalOrb:(cpVect)pos {
  pos.y = 320 - pos.y;
	pos.y += 10;// adjust for new graphics
	
	cpFloat r = 14.0f;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:staticBody radius:r offset:pos];
	shape.elasticity = 1.0f;
	shape.friction = 1.0f;
	shape.collisionType = physicsGoalType;
	[space addStaticShape:shape]; [shape release];
	
	[sprites addObject:SpriteOffset(MAKE_ORB_HOLDER_SPRITE(staticBody), cpvadd(pos, cpv(0,-24)))];
	Light *light = [[Light alloc] initWithBody:staticBody offset:cpvadd(pos, cpv(0,10-24)) radius:10+32.0f r:0.96f g:0.83f b:0.26f];
	[light setDrawShadows:FALSE];
	[lights addObject:light]; [light release];
	
	[self finishGoalOrb:staticBody radius:r offset:pos];
}

- (void)addRigidGoalOrb:(cpVect)pos {
  pos.y = 320 - pos.y;
	
	cpFloat r = 14.0f;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:staticBody radius:r offset:pos];
	shape.elasticity = 1.0f;
	shape.friction = 1.0f;
	shape.collisionType = physicsGoalType;
	[space addObject:shape]; [shape release];
	
	[self finishGoalOrb:staticBody radius:r offset:pos];
}

- (void)addBrokenLight:(cpVect)point length:(cpFloat)len {
	cpVect atPoint = point;
  atPoint.y = 320 - atPoint.y;

	cpFloat m = 0.1f;
	cpFloat r = 7.0f;
	cpFloat hang = 7.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:0.1f andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = cpvsub(atPoint, cpv(0, hang + len));
	body.vel = cpv(random() % 80 - 40,0);
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.elasticity = 0.8f;
	
	cpVect anchr1 = cpv(0,hang);
	cpVect anchr2 = atPoint;
	ChipmunkConstraint *constraint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:anchr1 anchr2:anchr2 min:0 max:len];
	[self addChipmunkObject:constraint]; [constraint release];
	
	[self addShadowBox:body offset:cpvzero width:3.0f height:6.0f];
	[sprites addObject:MAKE_DEAD_LIGHT_SPRITE(body)];
	[self addMoss:point big:FALSE];
	[ropes addObject:MakeRope(body, staticBody, anchr1, anchr2, ropeTypeVine)];
}

static GLfloat
flickerElectric(int ticks, int salt)
{
	unsigned long val = (unsigned long)(ticks/6) + salt;
	
	// hash the pointer up nicely
	val = (val+0x7ed55d16) + (val<<12);
	val = (val^0xc761c23c) ^ (val>>19);
	val = (val+0x165667b1) + (val<<5);
	val = (val+0xd3a2646c) ^ (val<<9);
	val = (val+0xfd7046c5) + (val<<3);
	val = (val^0xb55a4f09) ^ (val>>16);
	
	return (val%8==0 ? 0.7f : 1.0f);
}

- (Light*) addLight:(cpVect)point length:(cpFloat)len intensity:(float) v distance:(float) d {
	cpVect atPoint = point;
  atPoint.y = 320 - atPoint.y;
  
	cpFloat m = 0.1f;
	cpFloat r = 7.0f;
	cpFloat hang = 7.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:0.1f andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = cpvsub(atPoint, cpv(0, hang + len));
	body.vel = cpv(random() % 80 - 40,0);
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.elasticity = 0.8f;
	
	cpVect anchr1 = cpv(0,hang);
	cpVect anchr2 = atPoint;
	ChipmunkConstraint *constraint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:anchr1 anchr2:anchr2 min:0 max:len];
	[self addChipmunkObject:constraint]; [constraint release];
	
	Light *light = [[Light alloc] initWithBody:body offset:cpvzero radius:d r:v*(141.0f/256.0f) g:v*(255.0f/256.0f) b:v*(0.0f/256.0f)];
//	light->_flicker = flickerElectric;
	[lights addObject:light]; [light release];
	
	[self addShadowBox:body offset:cpvzero width:3.0f height:6.0f];
	[sprites addObject:MAKE_LIGHT_SPRITE(body)];
	[self addMoss:point big:FALSE];
	[ropes addObject:MakeRope(body, staticBody, anchr1, anchr2, ropeTypeVine)];
	
	for(int i=0; i<2; i++)
		[self addPixie:light];
  
  return light;
}

- (void)addStaticLight:(cpVect)atPoint intensity:(float) v distance:(float) d {
  atPoint.y = 320 - atPoint.y;

  Light *light = [[Light alloc] initWithBody:staticBody offset:atPoint radius:d r:v g:v b:v];
  [lights addObject:light]; [light release];
}

- (ChipmunkBody *)addBall:(cpVect)atPoint canRollAway:(bool)rollAway {
  atPoint.y = 320 - atPoint.y;
  
	cpFloat m = 2.0f;
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
  shape.friction = 0.8f;
	shape.elasticity = 0.05f;
	
	if(rollAway)
		shape.layers &= ~physicsBorderLayers;
	
  [space addObject:shape]; [shape release];
	
	[sprites addObject:MAKE_STONE_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  
  return body;
}

- (ChipmunkBody *)addSmallBox:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat r = 15;
	cpFloat m = 0.2f;
  
  cpVect verts[] = {
    cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;

  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;

	[self addShadowBox:body offset:cpvzero width:r height:r];
  [sprites addObject:MAKE_SMALL_BOX_SPRITE(body)];
  
  return body;
}


- (ChipmunkBody*)addBigBox:(cpVect)atPoint radius:(cpFloat)r {
	cpFloat m = 1.8f;		
	return [self addBigBox:atPoint radius:r mass:m];
}

- (ChipmunkBody*)addBigBox:(cpVect)atPoint radius:(cpFloat)r mass:(cpFloat) m {
	atPoint.y = 320 - atPoint.y;
	
	cpVect verts[] = {
		cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
	shape.layers &= ~physicsOutsideBorderLayer;
	shape.layers &= ~physicsBorderInsideBottomLayer;
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
	[sprites addObject:MAKE_BIG_BOX_SPRITE(body)];
	
	return body;
}

- (ChipmunkBody*)addBigBox:(cpVect)atPoint {
  return [self addBigBox:atPoint radius:28.0f];
}


- (ChipmunkBody*)addBoard:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float width = 12.0f;
  float height = 64.0f;
	cpFloat m = 3.0f;
	
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
    
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
	
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
  shape.group = physicsMechanicalGroup;
	shape.friction = 0.6f;
  shape.layers &= ~physicsOutsideBorderLayer;
	shape.layers &= ~physicsBorderInsideTopLayer;
	shape.layers &= ~physicsBorderInsideBottomLayer;
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_BOARD_SPRITE(body)];
  
  return body;
}

- (void)addArrowStone:(cpVect)pos pointAt:(cpVect)pointAt{
  pos.y = 320 - pos.y;
	pointAt.y = 320 - pointAt.y;
	
	cpFloat r = 14.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = pos; // TODO memory leak
	body.angle = cpvtoangle(cpvsub(pointAt, pos));

	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.collisionType = physicsPusherType;
	[space addStaticShape:shape]; [shape release];
	
	[sprites addObject:MAKE_ARROW_STONE_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
}


- (ChipmunkBody*)addGearStone:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat m = 2.0f;
	cpFloat r = 24.0f;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	body.pos = atPoint; 
  [self addChipmunkObject:body]; [body release];
  
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	shape.friction = 2.0f;
	shape.group = physicsMechanicalGroup;
	[self addChipmunkObject:shape]; [shape release];
	
  ChipmunkPivotJoint *pivot = [[ChipmunkPivotJoint alloc] initWithBodyA:body bodyB:staticBody pivot:atPoint];
  [self addChipmunkObject:pivot]; [pivot release];
  
	[sprites addObject:MAKE_GEAR_STONE_SPRITE(body)];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
  
  return body;
}

- (ChipmunkBody*)addDrawbridge:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float width = 10.0f;
  float height = 46.0f;
	cpFloat m = 3.0f;
  
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
 
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 1.0f;
	shape.group = physicsMechanicalGroup;
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
  
  return body;
}

- (ChipmunkBody*)addLeverShaft:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float width = 10.0f;
  float height = 46.0f;
	cpFloat m = 3.0f;
  
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
 
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 1.0f;
	shape.group = physicsMechanicalGroup;
	shape.layers &= ~(physicsBorderLayers | physicsTerrainLayer);
	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
  
  return body;
}


- (ChipmunkBody*)addSlidingDoor:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
  float width = 10.0f;
  float height = 46.0f;
	cpFloat m = 1.0f;
  
  cpVect verts[] = {
    cpv(-width,-height), cpv(-width,height), cpv(width,height), cpv(width,-height)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:INFINITY];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
  
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.3f;
	shape.group = physicsMechanicalGroup;
	shape.layers &= ~physicsTerrainLayer;
	shape.layers &= ~physicsOutsideBorderLayer;
	shape.layers &= ~physicsBorderInsideTopLayer;
	shape.layers &= ~physicsBorderInsideBottomLayer;

	
	[self addShadowBox:body offset:cpvzero width:width height:height];
  [sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
  
  return body;
}


- (ChipmunkBody*)addWhiteOrb:(cpVect)atPoint {
	atPoint.y = 320 - atPoint.y;
	
	cpFloat m = 1.0f;
	cpFloat r = 13.0f;
	cpFloat len = 50.0f;
	cpFloat hang = r;
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = cpvsub(atPoint, cpv(0, hang + len));
	
	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.9f;
 	shape.collisionType = physicsWhiteOrbType;
	
	cpVect anchr1 = cpv(0,hang);
	cpVect anchr2 = atPoint;
	ChipmunkConstraint *constraint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:anchr1 anchr2:anchr2 min:0 max:len];
	[self addChipmunkObject:constraint]; [constraint release];
	
	[self addShadowCircle:body offset:cpvzero radius:r];
	[sprites addObject:MAKE_WHITE_ORB_SPRITE(body)];
	[ropes addObject:MakeRope(body, staticBody, anchr1, anchr2, ropeTypeChain)];
	
	return body;
}

- (ChipmunkBody*)addCrystalTrigger:(cpVect)atPoint {
	atPoint.y = 320 - atPoint.y;
	
	cpFloat w = 14.0f;
	cpFloat h = 12.0f;
	
	cpVect verts[] = {
		cpv(-w,-h), cpv(-w,h), cpv(w,h), cpv(w,-h)
	};
	
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = atPoint;
	
	ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[space addStaticShape:shape]; [shape release];
	shape.friction = 0.7f;
	shape.elasticity = 1.0f;
 	shape.collisionType = physicsBlueCrystalType;
	
//	[self addShadowBox:body offset:cpvzero width:w height:h];
	[sprites addObject:MAKE_CRYSTAL_TRIGGER_SPRITE(body)];
	
	return body;
}

- (ChipmunkBody*) addWallChunk:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
  
	cpFloat m = 12.0f;
  cpFloat w = 17.0f;
  cpFloat h = 36.0f;

  cpVect verts[] = {
    cpv(-w,-h), cpv(-w,h), cpv(w,h), cpv(w,-h)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;
  
  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
	
	[self addShadowBox:body offset:cpvzero width:w height:h];
  [sprites addObject:MAKE_WALL_CHUNK_SPRITE(body)];
  
  return body;
}

- (void)addStone:(cpVect)pos {
  pos.y = 320 - pos.y;
	
	cpFloat r = 14.0f;
	
//	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
//	body.pos = pos; // TODO memory leak

	ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:staticBody radius:r offset:pos];
	shape.elasticity = 1.0f;
	shape.friction = 1.0f;
	[space addObject:shape];
	
	[sprites addObject:SpriteOffset(MAKE_STONE_SPRITE(staticBody), pos)]; // TODO make unique sprite
	
	[self addShadowCircle:staticBody offset:cpvzero radius:r];
}

- (ChipmunkBody *)addFallingBlock:(cpVect)atPoint {
  atPoint.y = 320 - atPoint.y;
	
  cpFloat r = 15;
	cpFloat m = 3.0f;
  
  cpVect verts[] = {
    cpv(-r,-r), cpv(-r,r), cpv(r,r), cpv(r,-r)
  };
  
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:m andMoment:cpMomentForPoly(m, 4, verts, cpvzero)];
	[self addChipmunkObject: body]; [body release];
	body.pos = atPoint;

  ChipmunkShape *shape = [[ChipmunkPolyShape alloc] initWithBody:body count:4 verts:verts offset:cpvzero];
	[self addChipmunkObject:shape]; [shape release];
	shape.friction = 0.7f;
	shape.layers &= ~physicsOutsideBorderLayer;
	shape.layers &= ~physicsBorderInsideTopLayer;
	shape.layers &= ~physicsBorderInsideBottomLayer;
	
	[self addShadowBox:body offset:cpvzero width:r height:r];
  [sprites addObject:MAKE_SMALL_BOX_SPRITE(body)];
	
	return body;
}

static GLfloat
flickerTorch(int ticks, int salt)
{
	unsigned long val = (unsigned long)(ticks>>2) + salt;
	
	// hash the pointer up nicely
	val = (val+0x7ed55d16) + (val<<12);
	val = (val^0xc761c23c) ^ (val>>19);
	val = (val+0x165667b1) + (val<<5);
	val = (val+0xd3a2646c) ^ (val<<9);
	val = (val+0xfd7046c5) + (val<<3);
	val = (val^0xb55a4f09) ^ (val>>16);
	
	const GLfloat values[16] = {
		0.98f,
		0.92f,
		0.90f,
		0.82f,
		0.82f,
		0.73f,
		0.68f,
		0.76f,
		0.82f,
		0.86f,
		0.92f,
		0.68f,
		0.77f,
		0.94f,
		0.96f,
		1.00f,
	};
	
	return values[val&0xf];
}

static cpVect
jitterTorch(int ticks, int salt)
{
	unsigned long val = (unsigned long)(ticks>>2) + salt;
	
	// hash the pointer up nicely
	val = (val+0x7ed55d16) + (val<<12);
	val = (val^0xc761c23c) ^ (val>>19);
	val = (val+0x165667b1) + (val<<5);
	val = (val+0xd3a2646c) ^ (val<<9);
	val = (val+0xfd7046c5) + (val<<3);
	val = (val^0xb55a4f09) ^ (val>>16);
	
	const cpVect values[16] = {
		cpv(-0.68, -0.89),
		cpv(-0.60, -0.26),
		cpv(-0.27, -0.74),
		cpv( 0.18, -0.61),
		cpv( 0.79,  0.02),
		cpv(-0.93, -0.74),
		cpv(-0.49,  0.06),
		cpv( 0.77, -0.10),
		cpv(-0.71,  0.58),
		cpv( 0.24, -0.41),
		cpv( 0.70,  0.61),
		cpv( 0.24, -0.80),
		cpv( 0.94, -0.94),
		cpv( 0.56, -0.26),
		cpv( 0.02,  0.71),
		cpv(-0.55, -0.58),
	};
	
	return cpvmult(values[val&0xf], 2.0f);
}

- (void)addTorch:(cpVect)pos {
  pos.y = 320 - pos.y;
	
	// TODO mem leak
	ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:INFINITY andMoment:INFINITY];
	body.pos = pos;
	
	Light *light = [[Light alloc] initWithBody:body offset:cpv(0,15) radius:200.0f r:1.0f g:0.7f b:0.0f];
	[light setIntensity:1.0f];
	light->_flicker = flickerTorch;
	light->_jitter = jitterTorch;
	[lights addObject:light]; [light release];
	
	[sprites addObject:MAKE_TORCH_SPRITE(body)];

	for(int i=0; i<4; i++)
		[self addFirefly:light];
	
  if(!torchLoop){
    torchLoop = createLoop(fireCrackleSound); 
    modulateLoopVolume(torchLoop, 0.12f, 0.00f, 1.0f);
  }
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
	
	ChipmunkRotaryLimitJoint *limiter = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:body min: body.angle - 2.0f max: body.angle];
	[self addChipmunkObject:limiter]; [limiter release];
		
	ChipmunkDampedRotarySpring* joint = [[ChipmunkDampedRotarySpring alloc] initWithBodyA:body bodyB:staticBody restAngle:body.angle  stiffness:10000.0f damping:2000.0f];
  [space addObject:joint]; [joint release];
  		
	[self addShadowBox:body offset:cpvzero width:width height:height];
	[sprites addObject:MAKE_DRAWBRIDGE_SPRITE(body)];
}

- (void)addFlipFlop:(cpVect)pos leverPos:(cpVect)leverPos bump:(cpFloat)bump {
	pos.y = 320.0f - pos.y;
	leverPos.y = 320.0f - leverPos.y;
	
	cpFloat flipOffset = 16.0f;
	ChipmunkBody *flipBody = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:500.0f];
	[space addObject:flipBody]; [flipBody release];
	flipBody.pos = cpv(pos.x, pos.y + flipOffset);
	flipBody.angVel = bump;
	
	ChipmunkShape *bottom = [[ChipmunkSegmentShape alloc] initWithBody:flipBody from:cpv(24,-flipOffset) to:cpv(-24,-flipOffset) radius:3.0f];
	[space addObject:bottom]; [bottom release];
	
	ChipmunkShape *top = [[ChipmunkSegmentShape alloc] initWithBody:flipBody from:cpv(0,-flipOffset) to:cpv(0, 24 - flipOffset) radius:3.0f];
	[space addObject:top]; [top release];
	
	[sprites addObject:SpriteOffset(MAKE_FLIP_FLOP_SPRITE(flipBody), cpv(0, 12 - flipOffset))];
	[self addShadowBox:flipBody offset:cpvzero width:3.0f height:12.0f];
	[self addShadowBox:flipBody offset:cpv(0, -12) width:24.0f height:3.0f];
	
	ChipmunkConstraint *flipPivot = [[ChipmunkPivotJoint alloc] initWithBodyA:flipBody bodyB:staticBody pivot:pos];
	[space addObject:flipPivot]; [flipPivot release];
	
	const cpFloat rotationAmount = 0.5f;
	ChipmunkConstraint *angleLimit = [[ChipmunkRotaryLimitJoint alloc] initWithBodyA:staticBody bodyB:flipBody min:-rotationAmount max:rotationAmount];
	[space addObject:angleLimit]; [angleLimit release];
	
	
	ChipmunkBody *lever = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:500.0f];
	[space addObject:lever];[lever release];
	lever.pos = leverPos;
	
	ChipmunkShape *leverShape = [[ChipmunkSegmentShape alloc] initWithBody:lever from:cpvzero to:cpv(0,-24) radius:3.0f];
	[space addObject:leverShape]; [leverShape release];
	
	[sprites addObject:SpriteOffset(MAKE_FLIP_FLOP_LEVER_SPRITE(lever), cpv(0, -12))];
	[self addShadowBox:lever offset:cpv(0.0f, -12.0f) width:3.0f height:12.0f];
	
	ChipmunkConstraint *leverPivot = [[ChipmunkPivotJoint alloc] initWithBodyA:staticBody bodyB:lever pivot:leverPos];
	[space addObject:leverPivot]; [leverPivot release];
	
	ChipmunkConstraint *gear = [[ChipmunkGearJoint alloc] initWithBodyA:lever bodyB:flipBody phase:0.0f ratio:-bump];
	[space addObject:gear]; [gear release];
}

- (void)addMoss:(cpVect)point big:(bool)big {
	[self addMoss:point big:big rot:0.0f];
}

- (void)addMoss:(cpVect)point big:(bool)big rot:(float)rot {
	point.y = 320.0f - point.y;
	NSData *sprite = SpriteOffset(big ? MAKE_BIG_MOSS_SPRITE(staticBody) : MAKE_SMALL_MOSS_SPRITE(staticBody), point);
	[sprites addObject:sprite];
}

@end
