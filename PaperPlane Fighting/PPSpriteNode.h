//
//  PPSpriteNode.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PPSpriteNode : SKSpriteNode {
    SKShapeNode *orientationNode;
    SKShapeNode *northLineNode;
    SKShapeNode *spriteOrientationLine;
    // point to which the sprite point to. the target of the movement(touch) in case of the main airplane
    CGPoint _targetPoint;
    BOOL _spriteFinishedOrientationRotation;
    
    BOOL _shouldFireBullets;
    
    CGFloat _health;
}

@property (nonatomic, assign) BOOL shouldFireBullets;
@property (nonatomic, assign) CGPoint targetPoint;
@property (nonatomic, assign) BOOL spriteFinishedOrientationRotation;
@property (nonatomic, assign) CGFloat health;

- (void)updateOrientationVector;
- (void)updateMove:(CFTimeInterval)dt;
- (void)updateRotation:(CFTimeInterval)dt;
- (CGPoint)returnFireRange;

@end
