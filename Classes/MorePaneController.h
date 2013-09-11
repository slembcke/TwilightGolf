#import <UIKit/UIKit.h>


@class LevelListController;

@interface MorePaneController : UIViewController {
	IBOutlet UISwitch *musicEnable;
	IBOutlet UISwitch *soundEnable;
	IBOutlet LevelListController *listController;
}

- (IBAction)done;
- (IBAction)setMusic;
- (IBAction)setSound;
- (IBAction)resetScores;

@end


@interface LevelListController : UITableViewController {
	NSArray *tableCells;
	IBOutlet UITableViewCell *musicView;
	IBOutlet UITableViewCell *soundView;
	IBOutlet UITableViewCell *facebookView;
}

- (void)resetList;

@end


@interface LevelCellViewController : UIViewController {
	IBOutlet UILabel *label;
	IBOutlet UIImageView *medal;
}

- (id)initForIndex:(NSInteger)index;

@end
