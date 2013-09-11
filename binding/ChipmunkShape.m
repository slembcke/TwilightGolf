#import "ChipmunkObjC.h"
#import "ChipmunkSpaceExtras.h"

@implementation ChipmunkShape

@synthesize data;

- (void) dealloc {
	[self.body release];
	cpShapeDestroy(self.shape);
	[super dealloc];
}


- (cpShape *)shape {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (ChipmunkBody *)body {return (ChipmunkBody *)self.shape->body->data;}
- (void)setBody:(ChipmunkBody *)body {
	[self.body release];
	self.shape->body = body.body;
}

// accessor macros
// TODO memory management
#define getter(type, lower, upper, member) \
- (type)lower {return self.shape->member;}
#define setter(type, lower, upper, member) \
- (void)set##upper:(type)value {self.shape->member = value;};
#define both(type, lower, upper, member) \
getter(type, lower, upper, member) \
setter(type, lower, upper, member)

getter(cpBB, bb, BB, bb)
both(cpFloat, elasticity, Elasticity, e)
both(cpFloat, friction, Friction, u)
both(cpVect, surfaceVel, SurfaceVel, surface_v)
getter(id, collisionType, CollisionType, collision_type)
getter(id, group, Group, group)
both(cpLayers, layers, Layers, layers)

- (void)setCollisionType:(id)value {
	[self.collisionType release];
	self.shape->collision_type = [value retain];
}

- (void)setGroup:(id)value {
	[self.group release];
	self.shape->group = [value retain];
}

- (cpBB)cacheBB {return cpShapeCacheBB(self.shape);}

- (bool)pointQuery:(cpVect)point {
	return cpShapePointQuery(self.shape, point);
}

- (NSSet *)chipmunkObjects {return [NSSet setWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addShape:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeShape:self];}

@end


@implementation ChipmunkCircleShape

- (cpShape *)shape {return (cpShape *)&_shape;}

- (id)initWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset {
	if(self = [super init]){
		[body retain];
		cpCircleShapeInit(&_shape, body.body, radius, offset);
		self.shape->data = self;
	}
	
	return self;
}

- (cpFloat)radius {return cpCircleShapeGetRadius((cpShape *)&_shape);}
- (cpVect)offset {return cpCircleShapeGetOffset((cpShape *)&_shape);}

@end


@implementation ChipmunkSegmentShape

- (cpShape *)shape {return (cpShape *)&_shape;}

- (id)initWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius {
	if(self = [super init]){
		[body retain];
		cpSegmentShapeInit(&_shape, body.body, a, b, radius);
		self.shape->data = self;
	}
	
	return self;
}

- (cpVect)a {return cpSegmentShapeGetA((cpShape *)&_shape);}
- (cpVect)b {return cpSegmentShapeGetB((cpShape *)&_shape);}
- (cpVect)normal {return cpSegmentShapeGetNormal((cpShape *)&_shape);}
- (cpFloat)radius {return cpSegmentShapeGetRadius((cpShape *)&_shape);}

@end


@implementation ChipmunkPolyShape

- (cpShape *)shape {return (cpShape *)&_shape;}

- (id)initWithBody:(ChipmunkBody *)body count:(int)count verts:(cpVect *)verts offset:(cpVect)offset {
	if(self = [super init]){
		[body retain];
		cpPolyShapeInit(&_shape, body.body, count, verts, offset);
		self.shape->data = self;
	}
	
	return self;
}

- (int)count {return cpPolyShapeGetNumVerts((cpShape *)&_shape);}
- (cpVect)getVertex:(int)index {return cpPolyShapeGetVert((cpShape *)&_shape, index);}

@end

@implementation ChipmunkStaticCircleShape : ChipmunkCircleShape
@end

@implementation ChipmunkStaticSegmentShape : ChipmunkSegmentShape
@end

@implementation ChipmunkStaticPolyShape : ChipmunkPolyShape
@end
