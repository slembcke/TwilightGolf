#import <Foundation/Foundation.h>

#import "LevelStateDelegate.h"

#define PLAYER_BALL_RADIUS 14.0f


#define MAKE_SMALL_BOX_SPRITE(body) MakeSprite(2, 8, 1, 1, body, 0, 0)
#define MAKE_PLAYER_BALL_SPRITE(body) MakeSprite(0, 0, 1, 1, body, 4, 6)
#define MAKE_ORB_HOLDER_SPRITE(body) MakeSprite(4, 2, 2, 2, body, 0, 0)
#define MAKE_GOAL_ORB_SPRITE(body) MakeSprite(1, 0, 1, 1, body, 4, 6)
#define MAKE_BOARD_SPRITE(body) MakeSprite(0, 8, 1, 4, body, 0, 0)
#define MAKE_ARROW_BOARD_SPRITE(body) MakeSprite(7, 5, 3, 1, body, 0, 0)
#define MAKE_BOARD_SIDEWAYS_SPRITE(body) MakeSprite(3, 8, 4, 1, body, 0, 0)
#define MAKE_TEETER_SPRITE(body) MakeSprite(0, 12, 11, 2, body, 0, 0)
#define MAKE_ARROW_STONE_SPRITE(body) MakeSprite(0, 4, 1, 1, body, 0, 0)
#define MAKE_STONE_SPRITE(body) MakeSprite(5, 5, 1, 1, body, 0, 0)
#define MAKE_BIG_BOX_SPRITE(body) MakeSprite(0, 5, 2, 2, body, 0, 0)
#define MAKE_DRAWBRIDGE_SPRITE(body) MakeSprite(1, 8, 1, 4, body, 0, 0)
#define MAKE_GEAR_STONE_SPRITE(body) MakeSprite(2, 5, 3, 3, body, 0, 0)
#define MAKE_BLUE_ORB_SPRITE(body) MakeSprite(2, 0, 1, 1, body, 4, 3)
#define MAKE_RED_ORB_SPRITE(body) MakeSprite(7, 0, 1, 1, body, 4, 3)
#define MAKE_WHITE_ORB_SPRITE(body) MakeSprite(8, 0, 1, 1, body, 4, 3)
#define MAKE_GREEN_ORB_SPRITE(body) MakeSprite(9, 0, 1, 1, body, 4, 3)
#define MAKE_WALL_CHUNK_SPRITE(body) MakeSprite(3, 9, 2, 3, body, 0, 0)
#define MAKE_LIGHT_SPRITE(body) MakeSprite(1, 4, 1, 1, body, 0, 0)
#define MAKE_DEAD_LIGHT_SPRITE(body) MakeSprite(2, 4, 1, 1, body, 0, 0)
#define MAKE_TORCH_SPRITE(body) MakeSprite(6, 0, 1, 2, body, 4, 4)
#define MAKE_BLINK_ARROW_SPRITE(body) MakeSprite(2, 9, 1, 1, body, 2, 30)
#define MAKE_CRYSTAL_TRIGGER_SPRITE(body) MakeSprite(5, 7, 1, 1, body, 0, 0)
#define MAKE_RED_CRYSTAL_TRIGGER_SPRITE(body) MakeSprite(0, 7, 1, 1, body, 0, 0)
#define MAKE_GREEN_CRYSTAL_TRIGGER_SPRITE(body) MakeSprite(1, 7, 1, 1, body, 0, 0)
#define MAKE_FLIP_FLOP_SPRITE(body) MakeSprite(3, 4, 2, 1, body, 0, 0)
#define MAKE_FLIP_FLOP_LEVER_SPRITE(body) MakeSprite(5, 4, 1, 1, body, 0, 0)
#define MAKE_SMALL_MOSS_SPRITE(body) MakeSprite(7, 4, 1, 1, body, 0, 0)
#define MAKE_BIG_MOSS_SPRITE(body) MakeSprite(8, 4, 2, 1, body, 0, 0)
#define MAKE_FIREFLY_SPRITE(body) MakeSprite(10, 4, 1, 1, body, 0, 0)
#define MAKE_PIXIE_SPRITE(body) MakeSprite(11, 4, 1, 1, body, 0, 0)
// #define MAKE_HAND_SPRITE(body) MakeSprite(5, 6, 1, 1, body, 0, 0)

NSData * MakeSprite(int, int, int, int, ChipmunkBody*, int, int);
NSData *SpriteOffset(NSData *data, cpVect offset);

NSData *MakeRope(ChipmunkBody *a, ChipmunkBody *b, cpVect offset1, cpVect offset2, ropeType type);
NSData *MakeRope2(ChipmunkBody *a, ChipmunkBody *b, cpVect offset1, cpVect offset2, cpFloat len, ropeType type);

@interface LevelStateDelegate (LevelWidgets)

- (void)addShadowBox:(ChipmunkBody *)body offset:(cpVect)offset width:(GLfloat)x_scale height:(GLfloat)y_scale;
- (void)addShadowCircle:(ChipmunkBody *)body offset:(cpVect)offset radius:(GLfloat)radius;

- (void)addPlayerBall:(cpVect)pos;
- (void)addPlayerBall:(cpVect)pos vel:(cpVect)vel;
- (void)addEndArrow:(cpVect)pos angle:(cpFloat)angle;
- (void)addGoalOrb:(cpVect)pos;
- (void)addRigidGoalOrb:(cpVect)pos;
- (ChipmunkBody*)addRollingGoalOrb:(cpVect)pos;
- (ChipmunkBody*)addChainedGoalOrb:(cpVect)pos length:(cpFloat)len;
- (ChipmunkBody *)addBall:(cpVect)atPoint canRollAway:(bool)rollAway;
- (Light*) addLight:(cpVect)atPoint length:(cpFloat)ropeLen intensity:(float) v distance:(float) d;
- (void)addBrokenLight:(cpVect)atPoint length:(cpFloat)ropeLen;
- (void)addStaticLight:(cpVect)atPoint intensity:(float) v distance:(float) d;
- (ChipmunkBody*)addSmallBox:(cpVect)atPoint;
- (ChipmunkBody*)addBigBox:(cpVect)atPoint;
- (ChipmunkBody*)addBigBox:(cpVect)atPoint radius:(cpFloat)r;
- (ChipmunkBody*)addBigBox:(cpVect)atPoint radius:(cpFloat)r mass:(cpFloat) m;
- (ChipmunkBody*)addBoard:(cpVect)atPoint;- (void)addArrowStone:(cpVect)pos pointAt:(cpVect)pointAt;
- (ChipmunkBody*)addGearStone:(cpVect)atPoint;
- (ChipmunkBody*)addDrawbridge:(cpVect)atPoint;
- (ChipmunkBody*)addLeverShaft:(cpVect)atPoint;
- (ChipmunkBody*)addWhiteOrb:(cpVect)atPoint;
- (ChipmunkBody*)addWallChunk:(cpVect)atPoint;
- (void)addStone:(cpVect)pos;
- (ChipmunkBody *)addFallingBlock:(cpVect)atPoint;
- (ChipmunkBody*)addSlidingDoor:(cpVect)atPoint;
- (void)addTorch:(cpVect)pos;
- (ChipmunkBody*)addCrystalTrigger:(cpVect)atPoint;
- (void) changeSprite:(cpBody*) body to:(NSData*) newSprite;
- (void)addGooOrbUnflipped:(cpVect)pos;
- (void)addChuteHinge:(cpVect)atPoint;
- (void)addFlipFlop:(cpVect)pos leverPos:(cpVect)leverPos bump:(cpFloat)bump;
- (void)addMoss:(cpVect)point big:(bool)big rot:(float)rot;
- (void)addMoss:(cpVect)point big:(bool)big;

@end
