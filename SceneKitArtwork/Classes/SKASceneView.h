//
//  SKASceneView.h
//  SceneKitArtwork
//
//  Created by Benoît on 28/12/12.
//  Copyright (c) 2012 Pragmatic Code. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@protocol SKASceneViewDelegate;

@interface SKASceneView : SCNView

@property (nonatomic, weak) IBOutlet id <SKASceneViewDelegate,NSObject> delegate;

@end


@protocol SKASceneViewDelegate
@optional
- (void)sceneView:(SKASceneView*)sceneView mouseDownOnNode:(SCNNode*)node;
@end