//
//  NSColor+SKAAdditions.m
//  SceneKitArtwork
//
//  Created by Benoît on 28/12/12.
//  Copyright (c) 2012 Pragmatic Code. All rights reserved.
//

#import "NSColor+SKAAdditions.h"

@implementation NSColor (SKAAdditions)

- (NSColor *)ska_darkerColourBy:(CGFloat)darken {
	// (c) Martin Pilkington (https://github.com/pilky/M3Appkit)
	
	if (darken < 0) {
		return 0;
	}
	
	CGFloat red = 0;
	CGFloat green = 0;
	CGFloat blue = 0;
	
	if ([self.colorSpace isEqual:[NSColorSpace genericGrayColorSpace]]) {
		red = self.whiteComponent - darken;
		green = self.whiteComponent - darken;
		blue = self.whiteComponent - darken;
	} else {
		red = self.redComponent - darken;
		green = self.greenComponent - darken;
		blue = self.blueComponent - darken;
	}
	if (red < 0) {
		green += red/2;
		blue += red/2;
	}
	if (green < 0) {
		red += green/2;
		blue += green/2;
	}
	if (blue < 0) {
		green += blue/2;
		red += blue/2;
	}
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:self.alphaComponent];
}

@end
