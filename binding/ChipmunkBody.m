#import "ChipmunkObjC.h"
#import "ChipmunkSpaceExtras.h"

@implementation ChipmunkBody

- (id)initWithMass:(cpFloat)mass andMoment:(cpFloat)moment {
	if(self = [super init]){
		cpBodyInit(&_body, mass, moment);
		self.body->data = self;
	}
	
	return self;
}

- (id)init {
	return [self initWithMass:1.0f andMoment:1.0f];
}

- (void) dealloc {
	cpBodyDestroy(&_body);
	[super dealloc];
}


- (cpBody *)body {return &_body;}


// accessor macros
#define getter(type, lower, upper) \
- (type)lower {return cpBodyGet##upper(&_body);}
#define setter(type, lower, upper) \
- (void)set##upper:(type)value {cpBodySet##upper(&_body, value);};
#define both(type, lower, upper) \
getter(type, lower, upper) \
setter(type, lower, upper)


both(cpFloat, mass, Mass)
both(cpFloat, moment, Moment)
both(cpVect, pos, Pos)
both(cpVect, vel, Vel)
both(cpVect, force, Force)
both(cpFloat, angle, Angle)
both(cpFloat, angVel, AngVel)
both(cpFloat, torque, Torque)
getter(cpVect, rot, Rot)

- (cpVect)local2world:(cpVect)v {return cpBodyLocal2World(&_body, v);}
- (cpVect)world2local:(cpVect)v {return cpBodyWorld2Local(&_body, v);}

- (void)resetForces {cpBodyResetForces(&_body);}
- (void)applyForce:(cpVect)force offset:(cpVect)offset {cpBodyApplyForce(&_body, force, offset);}
- (void)applyImpulse:(cpVect)j offset:(cpVect)offset {cpBodyApplyImpulse(&_body, j, offset);}

- (NSSet *)chipmunkObjects {return [NSSet setWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addBody:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeBody:self];}

@end
