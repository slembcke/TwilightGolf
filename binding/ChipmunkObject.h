// Protocol used for primitive or composite Chipmunk objects.
// Used by ChipmunkSpace addObject
@protocol ChipmunkObject

- (NSSet *)chipmunkObjects;

@end

// Build a flattened set of ChipmunkBaseObjects from a list of ChipmunkObjects.
NSSet * ChipmunkObjectFlatten(id <ChipmunkObject> firstObject, ...);


// Protocol used for primitive Chipmunk objects (bodies, shapes, constraints)
@protocol ChipmunkBaseObject <ChipmunkObject>

- (void)addToSpace:(ChipmunkSpace *)space;
- (void)removeFromSpace:(ChipmunkSpace *)space;

@end
