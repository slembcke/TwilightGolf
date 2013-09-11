@interface ChipmunkConstraint : NSObject <ChipmunkBaseObject> {
//	id data;
}

// Get a pointer to the base Chipmunk constraint struct.
@property (readonly) cpConstraint *constraint;

@property cpFloat maxForce;
@property cpFloat biasCoef;
@property cpFloat maxBias;

@end


@interface ChipmunkPinJoint : ChipmunkConstraint {
	cpPinJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2;

@property cpVect anchr1;
@property cpVect anchr2;
@property cpFloat dist;

@end


@interface ChipmunkSlideJoint : ChipmunkConstraint {
	cpSlideJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2 min:(cpFloat)min max:(cpFloat)max;

@property cpVect anchr1;
@property cpVect anchr2;
@property cpFloat min;
@property cpFloat max;

@end


@interface ChipmunkPivotJoint : ChipmunkConstraint {
	cpPivotJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2;
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b pivot:(cpVect)pivot;

@property cpVect anchr1;
@property cpVect anchr2;

@end


@interface ChipmunkGrooveJoint : ChipmunkConstraint {
	cpGrooveJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b groove_a:(cpVect)groove_a groove_b:(cpVect)groove_b anchr2:(cpVect)anchr2;

// TODO groove setters

@end


@interface ChipmunkDampedSpring : ChipmunkConstraint {
	cpDampedSpring _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchr1:(cpVect)anchr1 anchr2:(cpVect)anchr2 restLength:(cpFloat)restLength stiffness:(cpFloat)stiffness damping:(cpFloat)damping;

@property cpVect anchr1;
@property cpVect anchr2;
@property cpFloat restLength;
@property cpFloat stiffness;
@property cpFloat damping;

@end


@interface ChipmunkDampedRotarySpring : ChipmunkConstraint {
	cpDampedRotarySpring _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiffness damping:(cpFloat)damping;

@property cpFloat restAngle;
@property cpFloat stiffness;
@property cpFloat damping;

@end


@interface ChipmunkRotaryLimitJoint : ChipmunkConstraint {
	cpRotaryLimitJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b min:(cpFloat)min max:(cpFloat)max;

@property cpFloat min;
@property cpFloat max;

@end


@interface ChipmunkSimpleMotor : ChipmunkConstraint {
	cpSimpleMotor _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b rate:(cpFloat)rate;

@property cpFloat rate;

@end


@interface ChipmunkGearJoint : ChipmunkConstraint {
	cpGearJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratio:(cpFloat)ratio;

@property cpFloat phase;
@property cpFloat ratio;

@end


@interface ChipmunkRatchetJoint : ChipmunkConstraint {
	cpRatchetJoint _constraint;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratchet:(cpFloat)ratchet;

@property cpFloat angle;
@property cpFloat phase;
@property cpFloat ratchet;

@end
