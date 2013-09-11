#import "GLGameAppDelegate.h"
#import "Levels.h"


@implementation Levels

NSArray *levels;
+ (void)initialize {
	static bool done = FALSE;
	if(done) return;
	
	NSMutableArray *ary = [[NSMutableArray alloc] init];

#ifdef DEBUG  
#endif
  
  [ary addObject:[LevelMenu class]]; // Level 0 must be the menu for continue to work
	[ary addObject:[LevelTutorial class]];
	[ary addObject:[LevelIntro class]];
	if(LITE_VERSION){
		[ary addObject:[Level2 class]];
    [ary addObject:[LevelEscalator class]];	
    [ary addObject:[LevelRaiseTheBridge class]];
		[ary addObject:[LevelCrumble class]];
    [ary addObject:[LevelCams class]];	
    [ary addObject:[LevelSwitchesEasy class]];
		[ary addObject:[LevelStayOnTarget2 class]]; 
    [ary addObject:[LevelFlipFlops class]];
		[ary addObject:[LevelLitePreview class]];
	} else {
		[ary addObject:[Level2 class]];
		[ary addObject:[LevelTeeter class]];
		[ary addObject:[LevelEscalator class]];
		[ary addObject:[LevelRaiseTheBridge class]];
		[ary addObject:[LevelTheWay class]];
		[ary addObject:[LevelBlowback class]];
		[ary addObject:[LevelCrumble class]];
		[ary addObject:[LevelGravity class]];
		[ary addObject:[LevelStayOnTarget class]];
		[ary addObject:[LevelDilithiumCrystal class]];
    [ary addObject:[LevelSwitchesEasy class]];
		[ary addObject:[LevelTheWay2 class]];
		[ary addObject:[LevelCrumble2 class]];
		[ary addObject:[LevelGoop class]];
    [ary addObject:[LevelLidBox class]];
    [ary addObject:[LevelLauncher class]];
		[ary addObject:[LevelSwitches class]];
		[ary addObject:[LevelCeilingGearIsWatchingYou class]];
		[ary addObject:[LevelDoorsOfDoom class]];
		[ary addObject:[LevelLifter class]];
		[ary addObject:[LevelStayOnTarget2 class]];
		[ary addObject:[LevelTurnTurnTurn class]];
		[ary addObject:[LevelTeeterTotter class]];
		[ary addObject:[LevelLaserBeams class]];
		[ary addObject:[LevelRotator class]];
    [ary addObject:[LevelIntoTheChute class]]; // follow by flywheel. Start of the white-walled levels.
		[ary addObject:[LevelFlywheel class]]; // follow by going up 1, directions line up.
		[ary addObject:[LevelGoingUp class]];
		[ary addObject:[LevelFlipFlops class]];
		[ary addObject:[LevelGoingUp2 class]];
		[ary addObject:[LevelFlipFlops2 class]];
    [ary addObject:[LevelSliders class]];
    [ary addObject:[LevelPassthrough class]];
    [ary addObject:[LevelCams class]];
		[ary addObject:[LevelOutside class]];
	}
	
  // Unused levels: [ary addObject:[Level3 class]];
  
	levels = ary;
	
	done = TRUE;
}

NSString *SAVED_LEVEL = @"savedLevel";

+ (NSArray *)levels {
	return levels;
}

+ (Class)level:(int)index {
	if(index){
//		NSLog(@"Saving level progress %d", index);
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setInteger:index forKey:SAVED_LEVEL];
		[defaults synchronize];
	}
	
	return [levels objectAtIndex:index];
}

+ (Class)savedLevel {
	int index = [[NSUserDefaults standardUserDefaults] integerForKey:SAVED_LEVEL];
	return (index ? [self level:index] : [LevelTutorial class]);
}

+ (Class)nextLevel:(Class)current {
	int index = [levels indexOfObject:current] + 1;
	int count = [levels count];
	
	return [self level:(index == count ? 0 : index)];
}

@end
