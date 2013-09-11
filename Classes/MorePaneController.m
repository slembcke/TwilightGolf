#import "MorePaneController.h"
#import "GLGameAppDelegate.h"

#import "Sound.h"
#import "Levels.h"


@interface ResetScoreAlertDelegate : NSObject {
	LevelListController *listController;
}
@end

@implementation ResetScoreAlertDelegate
- initWithListController:(LevelListController *)controller {
	if(self = [super init]){
		listController = controller;
	}
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex != [alertView cancelButtonIndex]){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[[NSDictionary alloc] init] forKey:@"medals"];
		[defaults synchronize];
		
		[listController resetList];
		[(UITableView *)listController.view reloadData];
	}
}
@end

@implementation MorePaneController

- (void)dealloc {
	NSLog(@"dealloc morePane");
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	musicEnable.on = music_is_enabled;
	soundEnable.on = sound_is_enabled;
	
	UITableView *table = (UITableView *)listController.view;
	NSIndexPath *path = [table indexPathForSelectedRow];
	if(path){
		[table deselectRowAtIndexPath:path animated:FALSE];
	}
	
	// User may have won new levels since the last time we saw this.
	[listController resetList];
	[(UITableView *)listController.view reloadData];
}

#pragma mark IBActions

- (IBAction)done {
	[[GLGameAppDelegate appDelegate] runGame:0];
}

- (IBAction)setMusic {
	set_music(musicEnable.on);
}

- (IBAction)setSound {
	set_sound(soundEnable.on);
}

- (IBAction)resetScores {
	ResetScoreAlertDelegate *del = [[ResetScoreAlertDelegate alloc] initWithListController:listController];
	UIAlertView *alert = [[UIAlertView alloc]
		initWithTitle:@"Reset Scores?"
		message:@"Are you sure you want to reset all your scores?"
		delegate:del cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[alert show];
}

@end


@implementation LevelListController

static UITableViewCell *
make_cell(NSInteger i)
{
	LevelCellViewController *controller = [[LevelCellViewController alloc] initForIndex:i];
	UIView *view = controller.view;
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
	[cell.contentView addSubview:view];
	
	return [cell autorelease];
}

//- (void)viewDidLoad {
//	[super viewDidLoad];
//	[self resetList];
//}

#define SKIP_MENU_AND_TUTORIAL 2

- (void)resetList {
	[tableCells release];
	
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	int lastLevel = [[Levels levels] count];
	
	if(LITE_VERSION){
		lastLevel--; // don't show buy level
	}
	
	for(int i=SKIP_MENU_AND_TUTORIAL; i<lastLevel; i++)
		[cells addObject:make_cell(i)];
	
	tableCells = cells;
}

- (void) dealloc
{
	[tableCells release];
	[super dealloc];
}

enum TableSections {
	SOUND_SETTINGS,
	EXTRAS,
	LEVEL_SELECT,
	SECTION_COUNT,
};

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section){
		case SOUND_SETTINGS:
			return 2;
		case EXTRAS:
			return 1;
		case LEVEL_SELECT:
			return [tableCells count];
		default: return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"%@", indexPath);

	switch([indexPath indexAtPosition:0]){
		case SOUND_SETTINGS:
			switch([indexPath indexAtPosition:1]){
				case 0: return musicView;
				case 1: return soundView;
				default: abort();
			}
		case EXTRAS: return facebookView;
		case LEVEL_SELECT: return [tableCells objectAtIndex:[indexPath indexAtPosition:1]];
		default: abort();
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	static NSString *names[] = {@"Sound Settings:", @"Extras:", @"Play a level:"};
	return names[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch([indexPath indexAtPosition:0]){
		case EXTRAS:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://m.facebook.com/profile.php?id=153925381284"]];
			return;
		case LEVEL_SELECT:
			[[GLGameAppDelegate appDelegate] runGame:[indexPath indexAtPosition:1] + SKIP_MENU_AND_TUTORIAL];
			return;
		default:
			return;
	}
//	UIViewController *controller = [[LevelDetailViewController alloc] initForIndex:[indexPath indexAtPosition:0]];
//	
//	GLGameAppDelegate *delegate = [UIApplication sharedApplication].delegate;
//	[delegate.navigationController pushViewController:controller animated:TRUE];
//	[controller release];
}

@end


@implementation LevelCellViewController

static UIImage *
imageForMedal(medalType medal){
	switch(medal){
		case medalGold:   return [UIImage imageNamed:@"gold-small.png"];
		case medalSilver: return [UIImage imageNamed:@"silver-small.png"];
		case medalBronze: return [UIImage imageNamed:@"bronze-small.png"];
		case medalNone:   return [UIImage imageNamed:@"none-small.png"];
		default: return nil;
	}
}

- (id)initForIndex:(NSInteger)index {
	if(self = [super initWithNibName:@"LevelCellView" bundle:nil]){
		[self loadView]; // force it to load now so that it sets the damn IBOutlets
		
		Class level = [[Levels levels] objectAtIndex:index];
		label.text = [NSString stringWithFormat:@"%@", [level levelName]];
		medal.image = imageForMedal([level medal]);
	}
	
	return self;
}

@end

