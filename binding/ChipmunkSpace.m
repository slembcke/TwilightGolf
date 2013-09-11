#import "ChipmunkObjC.h"

@implementation ChipmunkSpace

- (id)init {
	if(self = [super init]){
		_children = [[NSMutableSet alloc] init];
		cpSpaceInit(&_space);
	}
	
	return self;
}

- (void) dealloc {
	for(id obj in _children){
		[obj release];
	}
	
	cpSpaceDestroy(&_space);
	
	[super dealloc];
}

- (cpSpace *)space {
	return &_space;
}

- (void)addObject:(id <ChipmunkObject>)obj {
	for(id <ChipmunkBaseObject> base in [obj chipmunkObjects]){
		[base addToSpace:self];
	}
}

- (void)removeObject:(id <ChipmunkObject>)obj {
	for(id <ChipmunkBaseObject> base in [obj chipmunkObjects]){
		[base removeFromSpace:self];
	}
}

- (void)step:(cpFloat)dt {
	cpSpaceStep(&_space, dt);
}

#pragma mark Specific add/remove

- (void)addBody:(ChipmunkBody *)obj {
	[_children addObject:obj];
	cpSpaceAddBody(&_space, obj.body);
}

- (void)removeBody:(ChipmunkBody *)obj {
	[_children removeObject:obj];
	cpSpaceRemoveBody(&_space, obj.body);
}


- (void)addShape:(ChipmunkShape *)obj {
	[_children addObject:obj];
	cpSpaceAddShape(&_space, obj.shape);
}

- (void)removeShape:(ChipmunkShape *)obj {
	[_children removeObject:obj];
	cpSpaceRemoveShape(&_space, obj.shape);
}

- (void)addStaticShape:(ChipmunkShape *)obj {
	[_children addObject:obj];
	cpSpaceAddStaticShape(&_space, obj.shape);
}

- (void)removeStaticShape:(ChipmunkShape *)obj {
	[_children removeObject:obj];
	cpSpaceRemoveStaticShape(&_space, obj.shape);
}

- (void)addConstraint:(ChipmunkConstraint *)obj {
	[_children addObject:obj];
	cpSpaceAddConstraint(&_space, obj.constraint);
}

- (void)removeConstraint:(ChipmunkConstraint *)obj {
	[_children removeObject:obj];
	cpSpaceRemoveConstraint(&_space, obj.constraint);
}

@end
