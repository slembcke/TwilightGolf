@interface ChipmunkBody : NSObject <ChipmunkBaseObject> {
	cpBody _body;
}

- (id)initWithMass:(cpFloat)mass andMoment:(cpFloat)moment;
- (id)init;

@property (readonly) cpBody *body;

@property cpFloat mass;
@property cpFloat moment;
@property cpVect pos;
@property cpVect vel;
@property cpVect force;
@property cpFloat angle;
@property cpFloat angVel;
@property cpFloat torque;

@property (readonly) cpVect rot;

- (cpVect)local2world:(cpVect)v;
- (cpVect)world2local:(cpVect)v;

- (void)resetForces;
- (void)applyForce:(cpVect)impulse offset:(cpVect)offset;
- (void)applyImpulse:(cpVect)impulse offset:(cpVect)offset;

- (void)addToSpace:(ChipmunkSpace *)space;
- (void)removeFromSpace:(ChipmunkSpace *)space;

@end
