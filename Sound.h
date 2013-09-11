#import <OpenAL/al.h>

extern bool music_is_enabled;
void init_music(void);
void set_music(bool enabled);

extern ALuint strokeSound;
extern ALuint bumpSound;
extern ALuint crystalSound;
extern ALuint squeakSound;
extern ALuint stickyBallSound;
extern ALuint gotGoalSound;
extern ALuint touchingOrbSound;
extern ALuint slidingRocks;

extern ALuint arrowStoneSound;
extern ALuint fireCrackleSound;
extern ALuint doorThumpSound;
extern ALuint lightBulbRattleSound;
extern ALuint ratchetCrankSound;

extern bool sound_is_enabled;
void init_sound(void);
void set_sound(bool enabled);
void release_loops(void);

ALuint createLoop(ALuint buffer);
void modulateLoopVolume(ALuint source, float value, float min, float max);

void playSound(ALuint buffer, ALfloat volume, ALfloat pitch);
