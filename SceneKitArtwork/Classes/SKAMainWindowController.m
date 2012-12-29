//
//  SKAMainWindowController.m
//  SceneKitArtwork
//
//  Created by Benoît on 27/12/12.
//  Copyright (c) 2012 Pragmatic Code. All rights reserved.
//

#import "SKAMainWindowController.h"
#import "SKASceneView.h"
#import "NSImage+SKAAdditions.h"
#import "NSColor+SKAAdditions.h"
#import <SceneKit/SceneKit.h>
#import <QuartzCore/QuartzCore.h>

static inline double DEG2RAD(double degrees) {
    return degrees * M_PI / 180;
}

static inline double RAD2DEG(double radians) {
    return radians * 180 / M_PI;
}

static inline CGFloat LINEAR_EQUATION(CGFloat x, CGPoint p1, CGPoint p2) {
    return (p2.y - p1.y) / (p2.x - p1.x) * (x - p1.x) + p1.y;
}

typedef NS_ENUM(NSUInteger, SKACameraSliderPosition) {
    SKACameraSliderPositionFront,
    SKACameraSliderPositionBack
};

@interface SKAMainWindowController () <SKASceneViewDelegate>

@property (nonatomic, weak) IBOutlet SKASceneView* sceneView;
@property (nonatomic) NSArray* boxNodes;
@property (nonatomic) SCNNode *ambientLightNode;
@property (nonatomic) SCNNode *diffuseLightFrontNode;
@property (nonatomic) SCNNode *diffuseLightBackNode;
@property (nonatomic) SCNNode *spotLightNode;
@property (nonatomic) SCNNode *cameraNode;
@property (nonatomic) SCNNode *modelNode;
@property (nonatomic) BOOL lightingEnabled;
@property (nonatomic) BOOL titlesHidden;
@property (nonatomic) CGFloat cameraSliderValue;
@property (nonatomic) SKACameraSliderPosition cameraSliderPosition;
@end

@implementation SKAMainWindowController {}

#pragma mark - Setup and Teardown

- (NSString *)windowNibName {
    return NSStringFromClass([self class]);
}

- (void)windowDidLoad {
    [super windowDidLoad];
	
	[self configureScene];
	
	
	self.lightingEnabled = YES;
	
	const CGFloat animationDuration = 0.8;
	CABasicAnimation* positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	positionAnimation.duration = animationDuration;
	SCNVector3 finalPos = self.cameraNode.position;
	positionAnimation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(finalPos.x, finalPos.y + 340., finalPos.z)];
	positionAnimation.toValue = [NSValue valueWithSCNVector3:finalPos];
	positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.cameraNode addAnimation:positionAnimation forKey:@"positionAnimation"];
	
	CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
	rotationAnimation.duration = animationDuration;
	rotationAnimation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, -M_PI / 4.)];
	rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, 0)];
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.cameraNode addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


#pragma mark - Scene

#pragma mark Configuration

- (void)configureScene {
	
	self.sceneView.scene = [SCNScene scene];
	
	SCNFloor *floorGeometry = [SCNFloor floor];
	floorGeometry.reflectionFalloffEnd = 50.0;
	floorGeometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"woodTile"];
	floorGeometry.firstMaterial.diffuse.mipFilter = SCNLinearFiltering;
	
	SCNNode *floorNode = [SCNNode node];
	floorNode.geometry = floorGeometry;
	floorNode.name = @"floor";
	[self.sceneView.scene.rootNode addChildNode:floorNode];

	SCNNode* boxNode1 = [self createBoxWithImage:[NSImage imageNamed:@"sampleIcon1"] title:@"GarageBand"];
	boxNode1.position = SCNVector3Make(-100., 80., 60.);
	boxNode1.transform = CATransform3DRotate(boxNode1.transform, 0.6, 0, 0, 1);
	[self.sceneView.scene.rootNode addChildNode:boxNode1];
	
	SCNNode* boxNode2 = [self createBoxWithImage:[NSImage imageNamed:@"sampleIcon2"] title:@"Tiny Wings"];
	boxNode2.position = SCNVector3Make(100., 80., 0.);
	[self.sceneView.scene.rootNode addChildNode:boxNode2];
	
	SCNNode* boxNode3 = [self createBoxWithImage:[NSImage imageNamed:@"sampleIcon3"] title:@"iMovie"];
	boxNode3.position = SCNVector3Make(304., 80., 40.);
	boxNode3.transform = CATransform3DRotate(boxNode3.transform, 0.6, 0, 0, -1);
	[self.sceneView.scene.rootNode addChildNode:boxNode3];
	
	self.boxNodes = @[boxNode1, boxNode2, boxNode3];
	
	SCNCamera* camera = [SCNCamera camera];
	camera.xFov = 80.;
	camera.yFov = 80.;
	camera.zNear = 20.;
	camera.zFar = 4000.;
	
	self.cameraNode = [SCNNode node];
	self.cameraNode.camera = camera;
	SCNNode* middleBox = (SCNNode*)[self.boxNodes objectAtIndex:1];
	self.cameraNode.position = SCNVector3Make(middleBox.position.x,middleBox.position.y, 400.);
    [self.sceneView.scene.rootNode addChildNode:self.cameraNode];
}

- (SCNNode*)createBoxWithImage:(NSImage*)image title:(NSString*)title {
    NSURL* sceneURL   = [[NSBundle mainBundle] URLForResource:@"box" withExtension:@"dae"];
    SCNScene* scene = [SCNScene sceneWithURL:sceneURL options:nil error:nil];
	
	SCNNode* materialNode;
	SCNMaterial* material;
	
	NSColor* baseColor = [image ska_averageColor];
	
	materialNode = [scene.rootNode childNodeWithName:@"front" recursively:YES];
	material = [materialNode.geometry materialWithName:@"frontMaterial"];
	material.diffuse.contents = image;
	material.diffuse.mipFilter = SCNLinearFiltering;
	
	materialNode = [scene.rootNode childNodeWithName:@"back" recursively:YES];
	material = [materialNode.geometry materialWithName:@"backMaterial"];
	material.diffuse.contents = [baseColor ska_darkerColourBy:0.1];
	
	materialNode = [scene.rootNode childNodeWithName:@"border" recursively:YES];
	material = [materialNode.geometry materialWithName:@"borderMaterial"];
	material.diffuse.contents = baseColor;

	materialNode = [scene.rootNode childNodeWithName:@"logo-top" recursively:YES];
	material = [materialNode.geometry materialWithName:@"logoMaterial"];
	material.diffuse.contents = [baseColor ska_darkerColourBy:0.25];
	
	SCNNode* boxNode;
	boxNode = [scene.rootNode childNodeWithName:@"box" recursively:NO];
	boxNode.rotation = SCNVector4Make(1, 0, 0, -M_PI / 2.);
	
	SCNText* textGeometry = [SCNText textWithString:title extrusionDepth:10.];
	textGeometry.font = [NSFont fontWithName:@"Futura" size:24.];
	
	material = [SCNMaterial material];
	material.diffuse.contents = baseColor;
	textGeometry.materials = @[material];
	
	SCNNode* textNode = [SCNNode nodeWithGeometry:textGeometry];
	textNode.name = @"title";
	textNode.rotation = SCNVector4Make(0,1,1,M_PI);
	textNode.position = SCNVector3Make(textGeometry.textSize.width / 2.0, 12., -50.);

	[boxNode addChildNode:textNode];
	
	return boxNode;
}

#pragma mark Helper Methods

- (SCNNode*)boxNodeForNode:(SCNNode*)node {
	__block SCNNode* retNode = nil;
	for (SCNNode* boxNode in self.boxNodes) {
		[boxNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
			if (child==node) {
				retNode = boxNode;
				*stop = YES;
			}
			return NO;
		}];
	}
	return retNode;
}

- (CATransform3D)transformationToRotateAroundPosition:(SCNVector3)center radius:(CGFloat)radius horizontalAngle:(CGFloat)horizontalAngle verticalAngle:(CGFloat)verticalAngle {
	SCNVector3 pos;
	pos.x = center.x + radius * cos(verticalAngle) * sin(horizontalAngle);
	pos.y = center.y - radius * sin(verticalAngle);
	pos.z = center.z + radius * cos(verticalAngle) * cos(horizontalAngle);
	
	CATransform3D rotX = CATransform3DMakeRotation(verticalAngle, 1, 0, 0);
	CATransform3D rotY = CATransform3DMakeRotation(horizontalAngle, 0, 1, 0);
	CATransform3D rotation = CATransform3DConcat(rotX, rotY);
	
	CATransform3D translate = CATransform3DMakeTranslation(pos.x, pos.y, pos.z);
	CATransform3D transform = CATransform3DConcat(rotation,translate);
	
	return transform;
}

#pragma mark - Accessors

- (void)setCameraSliderValue:(CGFloat)cameraSliderValue {
	_cameraSliderValue = cameraSliderValue;
	[self updateCameraSliderPosition];
}

- (void)setCameraSliderPosition:(SKACameraSliderPosition)cameraSliderPosition {
	if (cameraSliderPosition != _cameraSliderPosition) {
		_cameraSliderPosition = cameraSliderPosition;
		[self updateCameraSliderPosition];
	}
}

- (void)updateCameraSliderPosition {
	
	CGFloat angle = LINEAR_EQUATION(self.cameraSliderValue, CGPointMake(0, M_PI_2), CGPointMake(25., 0)) ;// -M_PI/50. * self.cameraSliderValue + M_PI_2;
	
	CGFloat deltaX = cos(angle);
	CGFloat deltaY = sin(angle);
	
	
	CGFloat minXAngle = 0., maxXAngle = 0.;
	if (self.cameraSliderPosition == SKACameraSliderPositionFront) {
		minXAngle = -50.;
		maxXAngle = 50.;
	}
	else if (self.cameraSliderPosition == SKACameraSliderPositionBack) {
		minXAngle = 90.;
		maxXAngle = 270.;
	}
	else {
		NSAssert(NO, @"Missing Case");
	}
	CGFloat horizontalAngle = LINEAR_EQUATION(deltaX, CGPointMake(-1., minXAngle), CGPointMake(1., maxXAngle));
	
	
	CGFloat minYAngle = 0;
	CGFloat maxYAngle = - 30;
	CGFloat verticalAngle = LINEAR_EQUATION(deltaY, CGPointMake(-1., minYAngle), CGPointMake(1., maxYAngle));
	
	SCNNode* middleBoxNode = (SCNNode*)[self.boxNodes objectAtIndex:1];
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:1.0];
	[self.cameraNode removeAllAnimations];
	self.sceneView.pointOfView = self.cameraNode;
	self.cameraNode.transform = [self transformationToRotateAroundPosition:middleBoxNode.position radius:400. horizontalAngle:DEG2RAD(horizontalAngle) verticalAngle:DEG2RAD(verticalAngle)];
	[SCNTransaction commit];
}

- (void)setTitlesHidden:(BOOL)titlesHidden {
	if (titlesHidden != _titlesHidden) {
		_titlesHidden = titlesHidden;
		
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:0.4];
		for (SCNNode* boxNode in self.boxNodes) {
			SCNNode* titleNode = [boxNode childNodeWithName:@"title" recursively:NO];
			
			titleNode.opacity = (_titlesHidden) ? 0. : 1.;
			
			CGFloat transY = 6. * ((_titlesHidden) ? -1. : 1.);
			titleNode.transform = CATransform3DConcat(titleNode.transform, CATransform3DMakeTranslation(0,transY, 0));
		}
		[SCNTransaction commit];
	}
}

- (void)setLightingEnabled:(BOOL)lightingEnabled {
	if (lightingEnabled!=_lightingEnabled) {
		_lightingEnabled = lightingEnabled;
		
		if (_lightingEnabled) {
			if (!self.diffuseLightFrontNode) {
				self.diffuseLightFrontNode = [SCNNode node];
				self.diffuseLightFrontNode.light = [SCNLight light];
				self.diffuseLightFrontNode.light.type = SCNLightTypeOmni;
				self.diffuseLightFrontNode.position = SCNVector3Make(60., 220., 200.);
				[self.sceneView.scene.rootNode addChildNode:self.diffuseLightFrontNode];
			}
			
			if (!self.diffuseLightBackNode) {
				self.diffuseLightBackNode = [SCNNode node];
				self.diffuseLightBackNode.light = [SCNLight light];
				self.diffuseLightBackNode.light.type = SCNLightTypeOmni;
				self.diffuseLightBackNode.position = SCNVector3Make(60., 220., -300.);
				[self.sceneView.scene.rootNode addChildNode:self.diffuseLightBackNode];
			}
			
			if (!self.ambientLightNode) {
				self.ambientLightNode = [SCNNode node];
				self.ambientLightNode.light = [SCNLight light];
				self.ambientLightNode.light.type = SCNLightTypeAmbient;
				[self.sceneView.scene.rootNode addChildNode:self.ambientLightNode];
			}
		}
		
		[SCNTransaction begin];
		[SCNTransaction setDisableActions:YES];
		self.diffuseLightFrontNode.light.color = (_lightingEnabled)?[NSColor colorWithDeviceWhite:0.8 alpha:1.0]:[NSColor colorWithDeviceWhite:0.0 alpha:1.0];
		self.diffuseLightBackNode.light.color = self.diffuseLightFrontNode.light.color;
		self.ambientLightNode.light.color = (_lightingEnabled)?[NSColor colorWithDeviceWhite:0.1 alpha:1.0]:[NSColor colorWithDeviceWhite:0.0 alpha:1.0];
		if (!_lightingEnabled) {
			self.spotLightNode.light.color = [NSColor colorWithDeviceWhite:0 alpha:1.0];
		}
		[SCNTransaction commit];
	}
}

#pragma mark - Actions

- (IBAction)resetAction:(id)sender {
	SCNNode* middleBoxNode = (SCNNode*)[self.boxNodes objectAtIndex:1];
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:0.44];
	[self.cameraNode removeAllAnimations];
	self.sceneView.pointOfView = self.cameraNode;
	self.cameraNode.transform = [self transformationToRotateAroundPosition:middleBoxNode.position radius:400. horizontalAngle:0. verticalAngle:0.];
	[SCNTransaction commit];
}

- (IBAction)turnCameraAroundAction:(id)sender {
	SCNNode* middleBoxNode = (SCNNode*)[self.boxNodes objectAtIndex:1];
	
	self.sceneView.pointOfView = self.cameraNode;
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	animation.duration = 10.;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	
	NSMutableArray* animationValues = [NSMutableArray array];
	for (NSInteger i = 0 ; i<= 360 ; i++) {
		[animationValues addObject:[NSValue valueWithCATransform3D:[self transformationToRotateAroundPosition:middleBoxNode.position radius:400. horizontalAngle:DEG2RAD((CGFloat)i) verticalAngle:DEG2RAD(-20.)]]];
	}
	
	animation.values = [animationValues copy];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.cameraNode addAnimation:animation forKey:@"animation"];
}


#pragma mark - SKASceneView Delegate

- (void)sceneView:(SKASceneView*)sceneView mouseDownOnNode:(SCNNode*)node {
	
	SCNNode* boxNode = [self boxNodeForNode:node];
	
	[SCNTransaction begin];
	[SCNTransaction setAnimationDuration:0.44];
	
	if (self.lightingEnabled && boxNode) {
		
		if (!self.spotLightNode) {
			self.spotLightNode  = [SCNNode node];
			self.spotLightNode.rotation = SCNVector4Make(1, 0, 0, -M_PI / 2.);
			self.spotLightNode.light = [SCNLight light];
			self.spotLightNode.light.type = SCNLightTypeSpot;
			[self.sceneView.scene.rootNode addChildNode:self.spotLightNode];
		}
		
		SCNVector3 pos = boxNode.position;
		self.spotLightNode.position = SCNVector3Make(pos.x, pos.y + 300., pos.z - 20.);
		self.spotLightNode.light.color = [NSColor colorWithDeviceWhite:0.5 alpha:1.0];
	}
	else {
		self.spotLightNode.light.color = [NSColor colorWithDeviceWhite:0. alpha:1.0];
	}
	
	[SCNTransaction commit];
}

@end



