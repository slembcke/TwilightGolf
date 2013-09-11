#import <Foundation/Foundation.h>

#import <OpenGLES/ES1/gl.h>
#import "ChipmunkObjC.h"

typedef struct shadowPolyline {
	GLfloat *verts;
	GLsizei count;
	cpBody *body;
	cpVect offset;
	GLfloat x_scale, y_scale;
	
	bool pixies;
} shadowPolyLine;

@interface Light : NSObject {
	ChipmunkBody *_body;
	cpVect _offset;
	
	GLfloat _radius;
	GLfloat _intensity;
	bool _drawShadows;
	
@public
	GLfloat _r, _g, _b;
	GLfloat (*_flicker)(int ticks, int salt);
	cpVect (*_jitter)(int ticks, int salt);
}

@property(readonly) cpVect pos;

- (void) setColorr:(GLfloat)r g:(GLfloat)g b:(GLfloat)b;
- (id)initWithBody:(ChipmunkBody *)body offset:(cpVect)offset radius:(GLfloat)radius r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b;
- (void)drawWithShadows:(NSArray *)shadows staticBody:(ChipmunkBody *)staticBody ticks:(int)ticks;
- (void)setDrawShadows:(bool)value;
- (void)setIntensity:(GLfloat)intensity;

@end
