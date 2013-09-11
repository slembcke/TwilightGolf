#import <UIKit/UIKit.h>

@interface GameState : NSObject {
	id delegate;
}

@property (readonly, nonatomic, retain) id delegate;

@property (readonly, nonatomic) bool needsUpdate;
@property (readonly, nonatomic) bool needsRedraw;

- (id)initWithDelegate:(id)delegate;
- (GameState *)run;

+ (GameState *)currentState;
+ (void)stop;
+ (void)stopWithValue:(id)value;
+ (void)stateMachine:(GameState *)state;

- (void)sync;

- (bool)needsUpdate;
- (void)update;

- (bool)needsRedraw;
- (void)draw;

- (void)enterState;
- (void)exitState;

@end

@interface TickLimitedGameState : GameState {
	double timeStep;
	double refTicks;
	double refTime;
	double curTime;
}

- initWithStep:(double)step delegate:(id)delegate;

@end