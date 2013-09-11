//
//  main.m
//  GLGame
//
//  Created by Scott Lembcke on 12/6/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chipmunk.h"

int main(int argc, char *argv[]) {
	cpInitChipmunk();
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
	return retVal;
}
