#import "LevelStateDelegate.h"

@implementation LevelGoop

+ (NSString *)levelName {
	return @"Goop Everywhere";
}

static cpVect gooPoints[] = {
	{107,175},
	{108,83},
	{112,215},
	{129,146},
	{131,110},
	{150,185},
	{157,54},
	{157,265},
	{159,231},
	{183,77},
	{186,168},
	{189,111},
	{195,219},
	{211,56},
	{231,167},
	{233,252},
	{250,122},
	{267,66},
	{276,205},
	{278,134},
	{28,88},
	{299,264},
	{307,183},
	{307,62},
	{329,104},
	{340,185},
	{354,153},
	{354,55},
	{359,119},
	{364,269},
	{365,212},
	{385,72},
	{389,104},
	{408,211},
	{413,52},
	{423,150},
	{421,268},
	{460,139},
	{466,189},
	{469,54},
	{470,268},
	{50,206},
	{50,53},
	{52,162},
	{72,126},
	{9,162},
	{97,266},
};
static int numGoos = sizeof(gooPoints)/sizeof(*gooPoints);

- (id)init {
	if(self = [super init]){
		ambientLevel = 0.15f;
    goldPar = 20;
    silverPar = 28;
    
		int polylines[] = {
			-50,  24,
			700,  24,
			 -1,
			-50, 288,
			700, 288,
			-1,-1,
		};
		[self addPolyLines:polylines];
		[self loadBG:@"levelGravityOrbs"];
		[self nextLevelDirection:physicsBorderInsideRightLayer];

		{
			float i = 0.5f;
			float d = 350;
			[self addStaticLight:cpv(240,   0) intensity:i distance:d];
			[self addStaticLight:cpv(240, 320) intensity:i distance:d];
			[self renderStaticLightMap];
		}
		
		[self addGoalOrb:cpv(440, 240)];
		for(int i=0; i<numGoos; i++)
			[self addGooOrbUnflipped:gooPoints[i]];
		
    [self addMoss:cpv(195,  24) big:TRUE];
    
		[self addEndArrow:cpv(440, 190) angle:0];
		[self addPlayerBall:cpv(25, 50)];
	}
	
	return self;
}

//- (void)touchDownAt:(cpVect)pos {
//	NSLog(@"(%0.0f,%0.0f)", pos.y, pos.x);
//	[super touchDownAt:pos];
//}

@end
