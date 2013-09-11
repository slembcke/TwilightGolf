#import <AudioToolbox/AudioToolbox.h>
#import <OpenAL/alc.h>
#import <QuartzCore/QuartzCore.h>

#import "GLGameAppDelegate.h"
#import "EAGLView.h"
#import "MorePaneController.h"

#import "Accelerometer.h"

#import "chipmunk.h"
#import "Sound.h"

bool LITE_VERSION = FALSE;
bool FAST_OPENGL = FALSE;

@interface MusicPerformanceAlertDelegate : NSObject
@end

@implementation MusicPerformanceAlertDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"hasSeenPerformanceWarning"];
	set_music(buttonIndex != [alertView cancelButtonIndex]);
}
@end


@implementation GLGameAppDelegate

+ (void)initialize {
	LITE_VERSION = [[[NSBundle mainBundle] bundleIdentifier] hasSuffix:@"Lite"];
	if(LITE_VERSION){
		NSLog(@"Finished starting Twilight Golf Lite");
	} else {
		NSLog(@"Finished starting Twilight Golf");
	}
}

+ (GLGameAppDelegate *)appDelegate {
	return [UIApplication sharedApplication].delegate;
}

- (void)setView:(UIView *)view {
	for(UIView *view in window.subviews) [view removeFromSuperview];
	[window addSubview:view];
	
	CATransition *anim = [CATransition animation];
  [anim setDelegate:self]; // This delegate will inform animationDidStart and animationDidStop as appropriate.
	[anim setType:kCATransitionFade];
	[anim setDuration:0.5];
	[anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[window layer] addAnimation:anim forKey:nil];	
}

static void
audioInterrupt(void *unused, UInt32 state)
{
//	printf("audio interrupt %d\n", state);
}

- (void)fadeSplashStartGame:(NSTimer *)theTimer {
	[self runGame:0];
}

extern int LIGHT_MAP_SIZE;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[NSUserDefaults standardUserDefaults] registerDefaults:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:TRUE], @"playMusic",
			[NSNumber numberWithBool:TRUE], @"playSound",
			[NSNumber numberWithInt:0], @"savedLevel",
			[[NSDictionary alloc] init], @"medals",
			[NSNumber numberWithBool:FALSE], @"hasSeenPerformanceWarning",
			nil
		]
	];
	
	EAGLContext *glcontext = [[EAGLContext alloc] initWithAPI:2]; // detect OpenGL 2.0
	FAST_OPENGL = glcontext != nil;
	[glcontext release];
	
#ifndef DEBUG
	if(FAST_OPENGL){ // 3GS render texture size override
		LIGHT_MAP_SIZE = 512;
		NSLog(@"Fast OpenGL detected, using enhanced shadow resolution.");
	} else {
		NSLog(@"Using default shadow resolution.");
	}
#endif
	
	// init OpenAL and audio state
	ALCdevice *device = alcOpenDevice(NULL);
	ALCcontext *context = alcCreateContext(device, NULL);
	alcMakeContextCurrent(context);
	
	AudioSessionInitialize(NULL, NULL, audioInterrupt, NULL);
	UInt32 sessionCategory = kAudioSessionCategory_LiveAudio;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	init_music();
	init_sound();
	
	[Accelerometer installWithInterval:1.0f/60.0f andAlpha:0.1f];
	
	[self setView:splashView];
	[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(fadeSplashStartGame:) userInfo:nil repeats:FALSE];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenPerformanceWarning"] == FALSE){
		MusicPerformanceAlertDelegate *del = [[MusicPerformanceAlertDelegate alloc] init];
		UIAlertView *alert = [[UIAlertView alloc]
			initWithTitle:@"Music Setings"
			message:@"Turning off ambient music can make the game run smoother on older devices. You can change your mind later from the options screen."
			delegate:del cancelButtonTitle:@"No Music" otherButtonTitles:@"Music On", nil];
		[alert show];
	}
}

extern void stop_music(void);
- (void)applicationWillTerminate:(UIApplication *)application {
	stop_music();
	alcDestroyContext(alcGetCurrentContext());
}

- (void)startAnimation:(NSTimer *)theTimer {
	[glView startAnimation];
}

- (void)runGame:(int)levelIndex {
	[glView setLevel:levelIndex];
	[self setView:glView];
	[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(startAnimation:) userInfo:nil repeats:FALSE];
}

- (void)showPrefs {
	[self setView:morePane];
}

- (void)showPlayHaven {
	[self setView:playHavenPane];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}

@end
