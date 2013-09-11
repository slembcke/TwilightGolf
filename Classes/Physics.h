#import <Foundation/Foundation.h>

enum physicsLayers {
	physicsOutsideBorderLayer = 1,
	physicsTerrainLayer = 2,
	physicsBorderInsideTopLayer = 4,
	physicsBorderInsideBottomLayer = 8,
	physicsBorderInsideRightLayer = 16,
	physicsBorderInsideLeftLayer = 32,
	physicsBorderLayers = 
		physicsOutsideBorderLayer | 
		physicsBorderInsideTopLayer | physicsBorderInsideBottomLayer | 
		physicsBorderInsideRightLayer | physicsBorderInsideLeftLayer,
};

extern NSString *physicsBallGroup;
extern NSString *physicsMechanicalGroup;

extern NSString *physicsBallType;
extern NSString *physicsGoalType;
extern NSString *physicsPusherType;
extern NSString *physicsOutsideBorderType;

extern NSString *physicsBlueOrbType;
extern NSString *physicsBlueCrystalType;

extern NSString *physicsWhiteOrbType;
extern NSString *physicsRedOrbType;
extern NSString *physicsGooOrbType;

extern NSString *physicsOneWayPlatformType;

