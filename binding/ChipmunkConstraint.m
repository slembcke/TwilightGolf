#import "ChipmunkObjC.h"
#import "ChipmunkSpaceExtras.h"

@implementation ChipmunkConstraint

- (void) dealloc {
	cpConstraint *constraint = self.constraint;
	[constraint->a->data release];
	[constraint->b->data release];
	cpConstraintDestroy(constraint);
	
	[super dealloc];
}

- (cpConstraint *)constraint {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// accessor macros
#define getter(type, lower, upper) \
- (type)lower {return self.constraint->lower;}
#define setter(type, lower, upper) \
- (void)set##upper:(type)value {self.constraint->lower = value;};
#define both(type, lower, upper) \
getter(type, lower, upper) \
setter(type, lower, upper)

both(cpFloat, maxForce, MaxForce)
both(cpFloat, biasCoef, BiasCoef)
both(cpFloat, maxBias, MaxBias)

- (NSSet *)chipmunkObjects {return [NSSet setWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addConstraint:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeConstraint:self];}

@end

// accessor macros
#define getter2(type, struct, lower, upper) \
- (type)lower {return struct##Get##upper((cpConstraint *)&_constraint);}
#define setter2(type, struct, lower, upper) \
- (void)set##upper:(type)value {struct##Set##upper((cpConstraint *)&_constraint, value);};
#define both2(type, struct, lower, upper) \
getter2(type, struct, lower, upper) \
setter2(type, struct, lower, upper)


@implementation ChipmunkPinJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2 {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpPinJointInit(&_constraint, a.body, b.body, anchr1, anchr2);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpVect, cpPinJoint, anchr1, Anchr1)
both2(cpVect, cpPinJoint, anchr2, Anchr2)
both2(cpFloat, cpPinJoint, dist, Dist)

@end


@implementation ChipmunkSlideJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2 min:(cpFloat)min max:(cpFloat)max {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpSlideJointInit(&_constraint, a.body, b.body, anchr1, anchr2, min, max);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpVect, cpSlideJoint, anchr1, Anchr1)
both2(cpVect, cpSlideJoint, anchr2, Anchr2)
both2(cpFloat, cpSlideJoint, min, Min)
both2(cpFloat, cpSlideJoint, max, Max)

@end


@implementation ChipmunkPivotJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2 {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpPivotJointInit(&_constraint, a.body, b.body, anchr1, anchr2);
		self.constraint->data = self;
	}
	
	return self;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b pivot:(cpVect)pivot {
	return [self initWithBodyA:a bodyB:b anchr1:[a world2local:pivot] anchr2:[b world2local:pivot]];
}

both2(cpVect, cpPivotJoint, anchr1, Anchr1)
both2(cpVect, cpPivotJoint, anchr2, Anchr2)

@end


@implementation ChipmunkGrooveJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b groove_a:(cpVect)groove_a groove_b:(cpVect)groove_b anchr2:(cpVect)anchr2 {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpGrooveJointInit(&_constraint, a.body, b.body, groove_a, groove_b, anchr2);
		self.constraint->data = self;
	}
	
	return self;
}

@end


@implementation ChipmunkDampedSpring

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2 restLength:(cpFloat)restLength stiffness:(cpFloat)stiffness damping:(cpFloat)damping {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpDampedSpringInit(&_constraint, a.body, b.body, anchr1, anchr2, restLength, stiffness, damping);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpVect, cpDampedSpring, anchr1, Anchr1)
both2(cpVect, cpDampedSpring, anchr2, Anchr2)
both2(cpFloat, cpDampedSpring, restLength, RestLength)
both2(cpFloat, cpDampedSpring, stiffness, Stiffness)
both2(cpFloat, cpDampedSpring, damping, Damping)

@end


@implementation ChipmunkDampedRotarySpring

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiffness damping:(cpFloat)damping {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpDampedRotarySpringInit(&_constraint, a.body, b.body, restAngle, stiffness, damping);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpFloat, cpDampedRotarySpring, restAngle, RestAngle)
both2(cpFloat, cpDampedRotarySpring, stiffness, Stiffness)
both2(cpFloat, cpDampedRotarySpring, damping, Damping)

@end


@implementation ChipmunkRotaryLimitJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b min:(cpFloat)min max:(cpFloat)max {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpRotaryLimitJointInit(&_constraint, a.body, b.body, min, max);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpFloat, cpRotaryLimitJoint, min, Min)
both2(cpFloat, cpRotaryLimitJoint, max, Max)

@end


@implementation ChipmunkSimpleMotor

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b rate:(cpFloat)rate {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpSimpleMotorInit(&_constraint, a.body, b.body, rate);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpFloat, cpSimpleMotor, rate, Rate)

@end


@implementation ChipmunkGearJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratio:(cpFloat)ratio {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpGearJointInit(&_constraint, a.body, b.body, phase, ratio);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpFloat, cpGearJoint, phase, Phase)
both2(cpFloat, cpGearJoint, ratio, Ratio)

@end


@implementation ChipmunkRatchetJoint

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratchet:(cpFloat)ratchet {
	if(self = [super init]){
		[a retain];
		[b retain];
		cpRatchetJointInit(&_constraint, a.body, b.body, phase, ratchet);
		self.constraint->data = self;
	}
	
	return self;
}

both2(cpFloat, cpRatchetJoint, angle, Angle)
both2(cpFloat, cpRatchetJoint, phase, Phase)
both2(cpFloat, cpRatchetJoint, ratchet, Ratchet)

@end
