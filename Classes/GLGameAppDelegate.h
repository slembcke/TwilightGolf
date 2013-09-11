#import <UIKit/UIKit.h>

extern bool LITE_VERSION;

@class EAGLView;

@interface GLGameAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	
	IBOutlet EAGLView *glView;
	IBOutlet UIView *splashView;
	IBOutlet UIView *morePane;
	IBOutlet UIView *playHavenPane;
}

+ (GLGameAppDelegate *)appDelegate;

- (void)setView:(UIView *)view;
- (void)runGame:(int)index;
- (void)showPrefs;
- (void)showPlayHaven;

@end

