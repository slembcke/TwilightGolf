@interface ChipmunkSpace : NSObject {
	cpSpace _space;
	NSMutableSet *_children;
}

- (id)init;

@property (readonly) cpSpace *space;

- (void)addObject:(id <ChipmunkObject>)obj;
- (void)removeObject:(id <ChipmunkObject>)obj;

- (void)step:(cpFloat)dt;

@end
