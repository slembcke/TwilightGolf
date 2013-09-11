#import <Foundation/Foundation.h>

#import "LevelStateDelegate.h"

@interface Levels : NSObject
+ (NSArray *)levels;
+ (Class)level:(int)index;
+ (Class)nextLevel:(Class)current;
+ (Class)savedLevel;
@end

@interface LevelLitePreview : LevelStateDelegate {
	LevelStateDelegate *delegate;
	GLuint frostTexture;
	NSArray *levels;
}
@end

@interface LevelMenu : LevelStateDelegate
@end

@interface LevelIntro : LevelStateDelegate
@end

@interface LevelTutorial : LevelIntro {
	int lastTouchIndex;
	ChipmunkBody *handBody;
	ChipmunkBody *text1Body;
	ChipmunkBody *text2Body;
	ChipmunkBody *text3Body;
	ChipmunkBody *text4Body;
	ChipmunkBody *text5Body;
}
@end

@interface Level2 : LevelStateDelegate
@end

@interface LevelTeeter : LevelStateDelegate
@end

@interface LevelTheWay : LevelStateDelegate

@end

@interface LevelTheWay2 : LevelStateDelegate
@end

@interface LevelRaiseTheBridge : LevelStateDelegate {
	ALuint squeakLoop;
	ChipmunkBody *drawBridge;
}
@end

@interface LevelStayOnTarget : LevelStateDelegate{
  NSMutableArray* leftGroup;
  NSMutableArray* rightGroup;
  ChipmunkBody* floater;
}
@end

@interface LevelBlowback : LevelStateDelegate {
	float fade;
}
  - (void) triggerWhiteOrb:(cpShape*) orb;
@end

@interface LevelCrumble : LevelStateDelegate {
	NSMutableArray *blocks;
}
@end

@interface LevelCrumble2 : LevelStateDelegate {
	NSMutableArray *blocks;
}
@end

@interface LevelDoorsOfDoom : LevelStateDelegate{
  ALuint slideLoop;
  ChipmunkBody* bigBox;
  
  ChipmunkBody* door1;
  ChipmunkBody* door2;
  ChipmunkBody* door3;
  ChipmunkBody* door4;
  
  ChipmunkPivotJoint *pivot1;
  ChipmunkPivotJoint *pivot2;
  ChipmunkPivotJoint *pivot3;
  ChipmunkPivotJoint *pivot4;
}
@end

@interface LevelGravity : LevelStateDelegate
@end

@interface LevelIntoTheChute : LevelStateDelegate
@end

@interface LevelDilithiumCrystal : LevelStateDelegate{
  NSMutableArray* blowupable;
  Light *light;
  cpShape *orb1, *orb2, *orb3, *orb4;
  
  int lastSwitch;
}  
- (void) triggerBlueOrb:(cpShape*) orb;
- (void) triggerRedOrb:(cpShape*) orb;
@end

@interface LevelTimmysGravityWell : LevelStateDelegate
@end

@interface LevelRotator : LevelStateDelegate
@end

@interface LevelGoop : LevelStateDelegate
@end

@interface LevelCeilingGearIsWatchingYou : LevelStateDelegate {
  float fade;
  ALuint squeakLoop;
}

@end

@interface LevelLifter : LevelStateDelegate{
	ALuint ratchetLoop;
  ChipmunkBody *shaft;
}
@end

@interface LevelTurnTurnTurn : LevelStateDelegate {
	ChipmunkSimpleMotor* motor1;
	ChipmunkSimpleMotor* motor2;
	ChipmunkBody *leverShaft;
}

@end

@interface LevelFlywheel : LevelStateDelegate {
	ChipmunkPivotJoint *doorMotor;
	ChipmunkBody *gear2;
}
@end

@interface LevelSwitches : LevelStateDelegate {
  int stage;
  int lastRed;
  
  ChipmunkBody* crystal1;
  ChipmunkBody* crystal2;
  ChipmunkBody* crystal3;
  ChipmunkBody* crystal4;
  ChipmunkBody* crystal5;
  
  ChipmunkGearJoint* joint;
  
  Light* crystalLight1;
  Light* crystalLight2;
  Light* crystalLight3;
  Light* crystalLight4;
  Light* crystalLight5;
  
  Light* answerLight1;
  Light* answerLight2;
  Light* answerLight3;
  Light* answerLight4;
  Light* answerLight5;
  
}

- (void) triggerBlueCrystal:(cpShape*) orb;
@end


@interface LevelSwitchesEasy : LevelStateDelegate {
  int stage;
  int lastRed;
  
  ChipmunkBody* crystal1;
  ChipmunkBody* crystal2;
  ChipmunkBody* crystal3;
  ChipmunkBody* crystal4;
  
  Light* crystalLight1;
  Light* crystalLight2;
  Light* crystalLight3;
  Light* crystalLight4;
  
  ChipmunkBody* door1;
  ChipmunkBody* door2;
  
  ChipmunkPivotJoint *pivot1;
  ChipmunkPivotJoint *pivot2;
  
}
- (void) triggerBlueCrystal:(cpShape*) orb;
@end

@interface LevelTeeterTotter : LevelStateDelegate {
  float fade;
}
@end

@interface LevelStayOnTarget2 : LevelStateDelegate {
  ChipmunkBody* left;
  ChipmunkBody* mid;
  ChipmunkBody* right;	
	ChipmunkPivotJoint* pivotLeft;
	ChipmunkPivotJoint* pivotMid;
	ChipmunkPivotJoint* pivotRight;
}
@end

@interface LevelGoingUp : LevelStateDelegate
@end

@interface LevelGoingUp2 : LevelStateDelegate
@end

@interface LevelFlipFlops : LevelStateDelegate
@end

@interface LevelFlipFlops2 : LevelStateDelegate
@end

@interface LevelOutside : LevelStateDelegate
@end

@interface LevelLidBox : LevelStateDelegate
@end

@interface LevelEscalator : LevelStateDelegate{
  ChipmunkBody* stairs;
  ChipmunkPivotJoint * pivot1;
  ChipmunkBody *lever;
}
@end

@interface LevelCams : LevelStateDelegate
@end

@interface LevelSliders : LevelStateDelegate
@end

@interface LevelLauncher : LevelStateDelegate {
  ChipmunkBody* door1;
  ChipmunkPivotJoint *pivot1;

  ChipmunkBody* launcher;
  ChipmunkPivotJoint *launcherJoint;

}
@end

@interface LevelPassthrough : LevelStateDelegate
@end


@interface LevelLaserBeams : LevelStateDelegate {
	ChipmunkBody *laserEnd, *laserEmitter, *door1, *door2;
	ChipmunkPivotJoint *pivot1, *pivot2;
}
@end


