#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "GameState.h"

GLuint viewFramebuffer;

/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
@interface EAGLView : UIView {
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    GameState *initialGameState;
		
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
//    GLuint viewRenderbuffer;//, viewFramebuffer;
    
//    NSTimer *animationTimer;
//    NSTimeInterval animationInterval;
}

+ (void)swapCurrentContext;

- (void)setLevel:(int)levelIndex;
- (void)startAnimation;

@end
