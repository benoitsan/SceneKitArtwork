//
//  NSImage+SKAAdditions.m
//  SceneKitArtwork
//
//  Created by Benoît on 28/12/12.
//  Copyright (c) 2012 Pragmatic Code. All rights reserved.
//

#import "NSImage+SKAAdditions.h"

@implementation NSImage (SKAAdditions)

- (CGImageRef)ska_createCGImage CF_RETURNS_RETAINED {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)[self TIFFRepresentation], NULL);
	CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    return cgImage;
}

- (NSColor *)ska_averageColor {
	// (c) Nikolai Ruhe. (http://stackoverflow.com/questions/12147779/how-do-i-release-a-cgimageref-in-ios/12148136#12148136)
	
    CGImageRef rawImageRef = [self ska_createCGImage];
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
    const UInt8 *rawPixelData = CFDataGetBytePtr(data);
	
    NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
    NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
	NSUInteger stride = CGImageGetBitsPerPixel(rawImageRef) / 8;
	
    unsigned int red   = 0;
    unsigned int green = 0;
    unsigned int blue  = 0;
	
	for (int row = 0; row < imageHeight; row++) {
		const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
		for (int column = 0; column < imageWidth; column++) {
            red    += rowPtr[0];
            green  += rowPtr[1];
            blue   += rowPtr[2];
			rowPtr += stride;
			
        }
    }
	CFRelease(data);
	CFRelease(rawImageRef);
	CGFloat f = 1.0f / (255.0f * imageWidth * imageHeight);
	return [NSColor colorWithCalibratedRed:f * red  green:f * green blue:f * blue alpha:1];
}

@end
