// Redundant API used to implement higher level functionality such as addObject.
@interface ChipmunkSpace ()

// Specific add/remove methods used by the add/remove object methods.
- (void)addBody:(ChipmunkBody *)obj;
- (void)removeBody:(ChipmunkBody *)obj;

- (void)addShape:(ChipmunkShape *)obj;
- (void)removeShape:(ChipmunkShape *)obj;

- (void)addStaticShape:(ChipmunkShape *)obj;
- (void)removeStaticShape:(ChipmunkShape *)obj;

- (void)addConstraint:(ChipmunkConstraint *)obj;
- (void)removeConstraint:(ChipmunkConstraint *)obj;

@end
