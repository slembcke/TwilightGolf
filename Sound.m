#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "Sound.h"

static AVAudioPlayer *music;
bool music_is_enabled = FALSE;

void
init_music(void)
{
	// Disable the music since it was licensced.
//	NSURL *musicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DarkArtifact" ofType:@"aac"]];
////	NSError *err;
//	music = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:NULL];
//	music.volume = 0.5f;
//	music.numberOfLoops = -1;
//	
//	set_music([[NSUserDefaults standardUserDefaults] boolForKey:@"playMusic"]);
}

void
set_music(bool enabled)
{
	music_is_enabled = enabled;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:enabled forKey:@"playMusic"];
	[defaults synchronize];
	
	if([music isPlaying] != music_is_enabled){
		if(music_is_enabled){
			[music play];
		} else {
			[music stop];
		}
	}
}

void
stop_music(void){
	[music stop];
}

// read a little endian, 44.1kHz, 16bit mono sound into an OpenAL buffer
// make them with: afconvert -f caff -d LEI16 infile outfile
static ALuint
load_sound(NSString *name)
{
	OSStatus err = noErr;
	
  // NSLog(@"Attempting to open with name: %@", name);
  
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"caf"];
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
	  
	// open the file
	AudioFileID audioFile = 0;
	err = AudioFileOpenURL(url, kAudioFileReadPermission, 0, &audioFile);
	if(err != noErr) NSLog(@"cannot open file: %@", path);
	
	// get data bytes
	UInt64 audioBytes64 = 0;
	UInt32 propertySize = sizeof(UInt64);
	err = AudioFileGetProperty(audioFile, kAudioFilePropertyAudioDataByteCount, &propertySize, &audioBytes64);
	if(err != noErr) NSLog(@"cannot find file size");
	UInt32 audioBytes = audioBytes64; // gross...
	
	// read sound
	unsigned char *audioData = calloc(audioBytes, 1);
	err = AudioFileReadBytes(audioFile, false, 0, &audioBytes, audioData);
	if(err != noErr) NSLog(@"cannot load effect: %@", path);
	AudioFileClose(audioFile);
	
	// load into OpenAL
	ALuint buffer;
	alGenBuffers(1, &buffer);
	alBufferData(buffer, AL_FORMAT_MONO16, audioData, audioBytes, 22050);
	free(audioData);
	
	ALenum alerr;
	while((alerr = alGetError()))
		printf("alerrload %d\n", alerr);
	
	return buffer;
}

#define NUM_CHANNELS 5
bool sound_is_enabled = FALSE;
ALuint channels[NUM_CHANNELS] = {};
NSMutableArray *loops = nil;

ALuint strokeSound = 0;
ALuint bumpSound = 0;
ALuint crystalSound = 0;
ALuint squeakSound = 0;
ALuint gotGoalSound = 0;
ALuint stickyBallSound = 0;
ALuint touchingOrbSound = 0;
ALuint slidingRocks = 0;

ALuint arrowStoneSound = 0;
ALuint fireCrackleSound = 0;
ALuint doorThumpSound = 0;
ALuint lightBulbRattleSound = 0;
ALuint ratchetCrankSound = 0;

void
init_sound(void)
{
	alGenSources(NUM_CHANNELS, channels);
	loops = [[NSMutableArray alloc] init];
	
	strokeSound = load_sound(@"stroke");
	bumpSound = load_sound(@"bump");
	crystalSound = load_sound(@"crystal");
	squeakSound = load_sound(@"squeak");
	gotGoalSound = load_sound(@"zenbell");
  stickyBallSound = load_sound(@"slurp");
  touchingOrbSound = load_sound(@"lowPulse");
	slidingRocks = load_sound(@"slidingStone2");

  arrowStoneSound = load_sound(@"lowSwoosh"); // or highSwoosh
	fireCrackleSound = load_sound(@"fireCrackle");
	doorThumpSound = load_sound(@"reallyBigThud");
	lightBulbRattleSound = load_sound(@"slidingRock");
	ratchetCrankSound = load_sound(@"ratchetRegular"); //or ratchetNoisy

	set_sound([[NSUserDefaults standardUserDefaults] boolForKey:@"playSound"]);
}

void
set_sound(bool enabled)
{
	sound_is_enabled = enabled;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:enabled forKey:@"playSound"];
	[defaults synchronize];
	
	alListenerf(AL_GAIN, enabled ? 1.0f : 0.0f);
}

void
release_loops(void)
{
	for(NSData *data in loops)
		alDeleteSources(1, (ALuint *)[data bytes]);
	
	[loops removeAllObjects];
}

ALuint
createLoop(ALuint buffer)
{
	ALuint source;
	alGenSources(1, &source);
	
	alSourcei(source, AL_BUFFER, buffer);
	alSourcei(source, AL_LOOPING, AL_TRUE);
//	alSourcePlay(source);
	
	[loops addObject:[NSData dataWithBytes:&source length:sizeof(source)]];
	return source;
}

void
modulateLoopVolume(ALuint source, float value, float min, float max)
{
	ALfloat volume = fmax(0.0f, fmin(1.0f, (value - min)/(max - min)));
	
	ALint state;
	alGetSourcei(source, AL_SOURCE_STATE, &state);
	if(volume){
		if(state != AL_PLAYING){
			alSourcePlay(source);
		}
		alSourcef(source, AL_GAIN, volume);
	} else {
		if(state == AL_PLAYING){
			alSourceStop(source);
		}
	}
}

void
playSound(ALuint buffer, ALfloat volume, ALfloat pitch)
{
	ALuint source = 0;
	
	// find open channel
	for(int i=0; i<NUM_CHANNELS; i++){
		ALint state;
		alGetSourcei(channels[i], AL_SOURCE_STATE, &state);
		if(state != AL_PLAYING){
			source = channels[i];
			break;
		}
	}
	if(!source) return; // no open channel
	
	alSourcei(source, AL_BUFFER, buffer);
	alSourcef(source, AL_GAIN, volume);
	alSourcef(source, AL_PITCH, pitch);
	alSourcePlay(source);
	
	for(ALenum err; (err = alGetError());)
		NSLog(@"playSound() AL err: 0x%x\n", err);
}

//void
//playSoundNote(ALuint buffer, int note)
//{
//	ALfloat pitch = powf(2.0f, (float)note/8.0f);
//	playSound(buffer, pitch);
//}
//
//void
//playSoundRandNote(ALuint buffer, int variation)
//{
//	int note = rand()%variation - variation/2;
//	playSoundNote(buffer, note);
//}
