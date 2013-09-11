#import "Light.h"

#import "time.h"
#import "math.h"


static void
shadowMask(GLfloat x, GLfloat y, NSArray *shadows, cpBody *ignoreBody)
{
	glPushMatrix(); {
		// set up the shadow matrix
		GLfloat mat[16] = {
			1.0f, 0.0f, 0.0f, 0.0f,
			0.0f, 1.0f, 0.0f, 0.0f,
			   x,    y, 0.0f, 1.0f,
				-x,   -y, 0.0f, 0.0f,
		};
		glLoadMatrixf(mat);
		
		glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
		
		for(NSData *data in shadows){
			const shadowPolyLine *shadow = [data bytes];
			cpBody *body = shadow->body;
			
			// don't cast shadows when the light is connected to the same
			if(body == ignoreBody) continue;
			
			cpVect pos = body->p;
			cpVect offset = shadow->offset;
			cpVect rot = body->rot; // rotation and scale
			GLfloat xs = shadow->x_scale;
			GLfloat ys = shadow->y_scale;
			
			GLfloat a =  rot.x;
			GLfloat b =  rot.y;
			GLfloat c = -rot.y;
			GLfloat d =  rot.x;
			GLfloat e = offset.x*a + offset.y*c + pos.x;
			GLfloat f = offset.x*b + offset.y*d + pos.y;
			
			glPushMatrix(); {
				GLfloat matrix[16] = {
					xs*a, xs*b, 0.0f, 0.0f,
					ys*c, ys*d, 0.0f, 0.0f,
					0.0f, 0.0f, 1.0f, 0.0f,
					   e,    f, 0.0f, 1.0f,
				};
				glMultMatrixf(matrix);

				glVertexPointer(3, GL_FLOAT, 0, shadow->verts);
				glDrawArrays(GL_TRIANGLE_STRIP, 0, shadow->count);
			} glPopMatrix();
		}
	} glPopMatrix();
}

static void
lightMap(GLfloat x, GLfloat y, GLfloat rad, GLfloat r, GLfloat g, GLfloat b)
{
	const GLfloat verts[] = {
		-1, -1,
		-1,  1,
		 1, -1,
		 1,  1,
	};
	
	const GLfloat tcoords[] = {
		0, 1,
		0, 0,
		1, 1,
		1, 0,
	};
	
	glPushMatrix(); {
		GLfloat mat[16] = {
			 rad, 0.0f, 0.0f, 0.0f,
			0.0f,  rad, 0.0f, 0.0f,
			0.0f, 0.0f, 1.0f, 0.0f,
				 x,   y, 0.0f, 1.0f,
		};

		glMultMatrixf(mat);
	
		glColor4f(r, g, b, 1.0f);
		glVertexPointer(2, GL_FLOAT, 0, verts);
		glTexCoordPointer(2, GL_FLOAT, 0, tcoords);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	} glPopMatrix();
}

@implementation Light

static GLfloat
flickerDefault(int ticks, int salt)
{
	return 1.0f;
}

static cpVect
jitterDefault(int ticks, int salt)
{
	return cpvzero;
}

- (id)initWithBody:(ChipmunkBody *)body offset:(cpVect)offset radius:(GLfloat)radius r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b {
	if(self = [super init]){
		_body = body;
		_offset = offset;
		
		_radius = radius;
		_r = r;
		_g = g;
		_b = b;
		_drawShadows = TRUE;
		_intensity = 1.0f;
		_flicker = flickerDefault;
		_jitter = jitterDefault;
	}
	
	return self;
}

- (void) setColorr:(GLfloat)r g:(GLfloat)g b:(GLfloat)b{
  _r = r;
  _g = g;
  _b = b; 
}

- (void)setDrawShadows:(bool)value {
	_drawShadows = value;
}

- (void)setIntensity:(GLfloat)intensity {
	_intensity = intensity;
}

- (cpVect)pos {
	return [_body local2world:_offset];
}

- (void)drawWithShadows:(NSArray *)shadows staticBody:(ChipmunkBody *)staticBody ticks:(int)ticks {
	if(!_intensity) return; // don't render the light if it's off
	
	cpVect pos = cpvadd(self.pos, _jitter(ticks, (int)self));
	
	if(_drawShadows){
		glDisable(GL_BLEND);
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
		
		lightMap(pos.x, pos.y, _radius, 0.0f, 1.0f, 0.0f);
		shadowMask(pos.x, pos.y, shadows, (_body == staticBody ? NULL : _body.body));
	}
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc((_drawShadows ? GL_DST_ALPHA : GL_ONE), GL_ONE);
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	GLfloat coef = _intensity*_flicker(ticks, (int)self);
	lightMap(pos.x, pos.y, _radius, coef*_r, coef*_g, coef*_b);
}

@end
