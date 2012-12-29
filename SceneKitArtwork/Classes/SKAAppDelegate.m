//
//  SKAAppDelegate.m
//  SceneKitArtwork
//
//  Created by Benoît on 27/12/12.
//  Copyright (c) 2012 Pragmatic Code. All rights reserved.
//

#import "SKAAppDelegate.h"
#import "SKAMainWindowController.h"

@interface SKAAppDelegate()
@property (nonatomic) SKAMainWindowController* mainWindowController;
@end

@implementation SKAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.mainWindowController = [[SKAMainWindowController alloc] init];
	[self.mainWindowController showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
