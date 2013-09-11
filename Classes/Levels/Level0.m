#import "LevelStateDelegate.h"

/*
@implementation Level0

- (id)init {
	if(self = [super init]){
		[self addPlayerBall:cpv(240, 160)];
		
		int polylines[] = {
			 36,  30,
			 36, 273, 
			 79, 273,
			190, 227,
			256, 227,
			319, 284,
			413, 196,
			422, 132,
			317,  30,
			 36,  30,
			-1,
			165, 135,
			189, 111,
			251, 106,
			281, 135,
			255, 163,
			192, 168,
			165, 135,
			-1, -1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"level1"];
		
		// add a swinging light
		{
			cpFloat m = 0.1f;
			cpFloat r = 10.0f;
			cpFloat len = 40.0f - r;
			
			ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:0.1f andMoment:cpMomentForCircle(m, r, 0.0f, cpvzero)];
			[self addChipmunkObject: body];
			body.pos = cpv(220, 250);
			body.vel = cpv(40,0);
			
			ChipmunkShape *shape = [[ChipmunkCircleShape alloc] initWithBody:body radius:r offset:cpvzero];
			[self addChipmunkObject:shape];
			shape.elasticity = 0.8f;
			
			ChipmunkConstraint *constraint = [[ChipmunkSlideJoint alloc] initWithBodyA:body bodyB:staticBody anchr1:cpv(0,r) anchr2:cpvadd(body.pos, cpv(0, len)) min:0 max:len];
			[self addChipmunkObject:constraint];
			
			float v = 0.7f;
			Light *light = [[Light alloc] initWithBody:body offset:cpvzero radius:200.0f r:v g:v b:v];
			[lights addObject:light];
			
			[body release];
			[shape release];
			[constraint release];
			[light release];
		}
	}
	
	return self;
}

@end*/
