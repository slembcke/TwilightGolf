#import "GameState.h"

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import "EAGLView.h"

#import "time.h"

@interface GameStateBreak : NSObject {
	id value;
}

@property(readonly, nonatomic) id value;

- initWithValue:(id)value;

@end

@implementation GameStateBreak

@synthesize value;

- (void) dealloc
{
	[value release];
	[super dealloc];
}

- (id) initWithValue:(id)val {
	if(self = [super init]){
		value = val;
		[value retain];
	}
	
	return self;
}

@end

static bool breakLock;
static id breakCache;
static NSString *breakSentinel = @"breakSentinel";

@implementation GameState

static float runLoopDelay = 0.003f;
//+ (void)initialize {
//	static bool done = FALSE;
//	if(done) return;
//	
//	NSString *vers = [[UIDevice currentDevice] systemVersion];
//	NSLog(@"System version %@", vers);
//	if([vers hasPrefix:@"2."]){
//		NSLog(@"2.x device detected. Adjusting run loop.");
//		runLoopDelay = 0.01f;
//	}
//	
//	done = TRUE;
//}

@synthesize delegate;

- (void) dealloc {
	[delegate release];
	[super dealloc];
}


- (id)initWithDelegate:(id)del {
	if(self = [super init]) {
		delegate = del;
		[delegate retain];
	}
	
	return self;
}

- (id)init {
	return [self initWithDelegate:nil];
}

- (void)loopStep {
	[self sync];
	
	// pump events
	breakCache = breakSentinel;
	breakLock = true;
	for(; CFRunLoopRunInMode(kCFRunLoopDefaultMode, runLoopDelay, TRUE) == kCFRunLoopRunHandledSource;){}
	breakLock = false;
	if(breakCache != breakSentinel){
		[GameState stopWithValue:breakCache];
	}
	
	while(self.needsUpdate)
		[self update];
	
	if(self.needsRedraw){
		[self draw];
		[EAGLView swapCurrentContext];
	}
}

- (GameState *)run {
	[self enterState];
	
	GameState *nextState = nil;
	@try {
		while(TRUE) [self loopStep];
	} @catch(GameStateBreak *stateBreak){
		nextState = stateBreak.value;
		[stateBreak release];
	}
		
	[self exitState];
	return nextState;
}

+ (void)stop {
	[self stopWithValue:nil];
}

+ (void)stopWithValue:(id)value {
	if(breakLock){
		breakCache = value;
	} else {
		@throw [[GameStateBreak alloc] initWithValue:value];
	}
}

GameState *currentState = nil;
+ (GameState *)currentState {
	return currentState;
}

+ (void)stateMachine:(GameState *)state {
	GameState *oldState = currentState;
	
	currentState = state;
	for(GameState *nextState; (nextState = [state run]); state = nextState){
		currentState = nextState;
		[state release];
	}
	
	[state release];
	currentState = oldState;
}

static inline void
delegateCall(id delegate, SEL selector)
{
	if([delegate respondsToSelector:selector])
		[delegate performSelector:selector];
}

- (void)sync {
	delegateCall(delegate, @selector(sync));
}

- (bool)needsUpdate {
	if([delegate respondsToSelector:@selector(needsUpdate)]){
		return [delegate needsUpdate];
	} else {
		return FALSE;
	}
}

- (void)update {
	delegateCall(delegate, @selector(update));
}

- (bool)needsRedraw {
	if([delegate respondsToSelector:@selector(needsRedraw)]){
		return [delegate needsRedraw];
	} else {
		return TRUE;
	}
}

- (void)draw {
	delegateCall(delegate, @selector(draw));
}

- (void)enterState {
	delegateCall(delegate, @selector(enterState));
}

- (void)exitState {
	delegateCall(delegate, @selector(exitState));
}

@end

@implementation TickLimitedGameState

- (id)initWithStep:(double)step delegate:(id)del{
	if(self = [super initWithDelegate:del]){
		timeStep = step;
	}
	
	return self;
}

- (id)init {
	return [self initWithStep:1.0f/60.0f delegate:nil];
}

- (void)enterState {
	refTime = getDoubleTime();
	refTicks = 0;
	[super enterState];
}

- (void)sync {
	curTime = getDoubleTime();
	
	double overtime = (curTime - refTime) - (refTicks + 10)*timeStep;
	if(overtime > 0.0f)
		refTime += overtime;
	
	[super sync];
}

- (bool)needsUpdate {
	return (curTime - refTime) > refTicks*timeStep;
}

- (void)update {
	refTicks += 1;
	[super update];
}

@end
