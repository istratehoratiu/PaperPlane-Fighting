//
//  PPSpriteNode.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PPConstants.h"

@interface PPSpriteNode : SKSpriteNode {
    SKSpriteNode *_fireRange;
    SKShapeNode *orientationNode;
    SKShapeNode *northLineNode;
    SKShapeNode *spriteOrientationLine;
    // point to which the sprite point to. the target of the movement(touch) in case of the main airplane
    CGPoint _targetPoint;
    BOOL _spriteFinishedOrientationRotation;
    
    BOOL _isFiringBullets;
    
    PPFlightDirection _flightDirection;
    
    CGFloat _health;
}

@property (nonatomic, assign) PPFlightDirection flightDirection;
@property (nonatomic, retain) SKSpriteNode *fireRange;
@property (nonatomic, assign) BOOL isFiringBullets;
@property (nonatomic, assign) CGPoint targetPoint;
@property (nonatomic, assign) BOOL spriteFinishedOrientationRotation;
@property (nonatomic, assign) CGFloat health;

- (void)updateOrientationVector;
- (void)updateMove:(CFTimeInterval)dt;
- (void)updateRotation:(CFTimeInterval)dt;
- (CGPoint)returnFireRange;

@end
