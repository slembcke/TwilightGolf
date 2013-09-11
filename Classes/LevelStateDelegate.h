#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

#import "GameState.h"

#import "ChipmunkObjC.h"
#import "Physics.h"
#import "Light.h"
#import "Sound.h"

bool NO_BALL_MODE;

typedef struct sprite {
	GLshort coords[16];
	cpBody *body;
	cpVect offset;
	int frames, skip;
} sprite;

typedef enum ropeType {
	ropeTypeChain,
	ropeTypeRope,
	ropeTypeRod,
	ropeTypeGoop,
	ropeTypeArrow,
  ropeTypeLaser,
  ropeTypeVine,
} ropeType;

typedef struct rope {
	cpBody *a, *b;
	cpVect offset1, offset2;
	cpFloat length;
	ropeType type;
} rope;

typedef enum medalType {
	medalGold,
	medalSilver,
	medalBronze,
	medalNone,
} medalType;

void renderSprites(NSArray *sprites, int ticks);

@interface LevelStateDelegate : NSObject {
	int ticks;
  int strokeCount;
	int nextBestStrokesCount;
  int goldPar;
	int silverPar;
	
	ChipmunkSpace *space;
	ChipmunkBody *staticBody;
	
	cpVect ballStartPos;
	cpVect ballStartVel;
	ChipmunkBody *ballBody;
	ChipmunkCircleShape *ballShape;
	NSMutableArray *playerJoints;
	
	ChipmunkBody *endArrowBody;
	ChipmunkBody *goalOrbBody; // don't retain/release
	NSData *goalOrbSprite; // don't retain/release
	Light *levelEndLight;
	int completedTicks;
	int fadeOutTicks;
	
	GLuint bgTexture;
	GLuint spriteTexture;
	GLuint tutorialTextTexture;
  
	NSMutableArray *sprites;
	NSMutableArray *uiSprites;
	NSMutableArray *uiTutorialText;
	NSMutableArray *ropes;
	NSMutableArray *playerRopes;
  
	int playerLayerUnlock;
	
	GLfloat ambientLevel;
	GLuint staticLightMapTexture;
	GLuint lightMapTexture;
	GLuint lightTexture;
	NSMutableArray *lights;
	NSMutableArray *shadowPolylines;
	GLuint lightFBO;
  
  ALuint torchLoop;	

	bool isTouched;
	cpVect touchStart;
	cpVect touchCurrent;
	int lastTouchTicks;
}

+ (GameState *)gamestateForLevel:(Class)klass;
+ (void)jumpToLevel:(Class)klass;

+ (NSString *)levelName;
+ (medalType)medal;
+ (bool) hasAllGolds;

- (void)renderNumber:(int)num at:(cpVect)pos;

- (void)addPolyLines:(int *)polylines;
- (void)loadBG:(NSString *)name;
- (void)nextLevelDirection:(int)layer;

- (void)update;
- (void)addChipmunkObject:(id <ChipmunkObject>)obj;

- (bool)button:(cpBB)bb;
- (void)touchDownAt:(cpVect)pos;
- (void)touchUp;
- (void)touchMoved:(cpVect)pos;

- (void)draw;
- (void)renderStaticLightMap;
- (void)renderArrow;

@end

#import "LevelWidgets.h"
#import "Levels.h"
