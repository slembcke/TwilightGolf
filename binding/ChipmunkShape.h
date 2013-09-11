// Abstract base class for collsion shape.
@interface ChipmunkShape : NSObject <ChipmunkBaseObject> {
	id data;
}

// Get a pointer to the base Chipmunk shape struct.
@property (readonly) cpShape *shape;

@property (retain) ChipmunkBody *body;
@property (readonly) cpBB bb;
@property cpFloat elasticity;
@property cpFloat friction;
@property cpVect surfaceVel;
@property (retain) cpCollisionType collisionType;
@property (retain) cpGroup group;
@property cpLayers layers;
@property (retain) id data;

- (cpBB)cacheBB;
- (bool)pointQuery:(cpVect)point;

@end

@interface ChipmunkCircleShape : ChipmunkShape {
	cpCircleShape _shape;
}

- (id)initWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset;

@property (readonly) cpFloat radius;
@property (readonly) cpVect offset;

@end


@interface ChipmunkSegmentShape : ChipmunkShape {
	cpSegmentShape _shape;
}

- (id)initWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius;

@property (readonly) cpVect a;
@property (readonly) cpVect b;
@property (readonly) cpVect normal;
@property (readonly) cpFloat radius;

@end


@interface ChipmunkPolyShape : ChipmunkShape {
	cpPolyShape _shape;
}

- (id)initWithBody:(ChipmunkBody *)body count:(int)count verts:(cpVect *)verts offset:(cpVect)offset;

@property (readonly) int count;
- (cpVect)getVertex:(int)index;

@end

@interface ChipmunkStaticCircleShape : ChipmunkCircleShape
@end

@interface ChipmunkStaticSegmentShape : ChipmunkSegmentShape
@end

@interface ChipmunkStaticPolyShape : ChipmunkPolyShape
@end
