//
//  SKASceneView.m
//  SceneKitArtwork
//
//  Created by Benoît on 28/12/12.
//  Copyright (c) 2012 Pragmatic Code. All rights reserved.
//

#import "SKASceneView.h"

@interface SKASceneView()
@property(nonatomic) BOOL tapDetected;
@end

@implementation SKASceneView

- (void)mouseDragged:(NSEvent *)event {
	[super mouseDragged:event];
	self.tapDetected = NO;
}

- (void)mouseDown:(NSEvent *)event {
	[super mouseDown:event];
	self.tapDetected = YES;
}

- (void)mouseUp:(NSEvent *)event {
	[super mouseUp:event];
	if (self.tapDetected) {
		NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
		NSArray *hits = [self hitTest:mouseLocation options:nil];
		
		SCNNode* clickedNode = nil;
		if ([hits count] > 0) {
			SCNHitTestResult *hit = hits[0];
			clickedNode = hit.node;
		}
		
		BOOL respondsToSelector = (self.delegate && [self.delegate respondsToSelector:@selector(sceneView:mouseDownOnNode:)]);
		if (respondsToSelector) [self.delegate sceneView:self mouseDownOnNode:clickedNode];
		
		self.tapDetected = NO;
	}
}

@end
