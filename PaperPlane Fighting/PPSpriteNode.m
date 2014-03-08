//
//  PPSpriteNode.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"
#import "SKSpriteNode+Additions.h"
#import "PPMath.h"
#import "PPConstants.h"

#define kPPMainAirplaneRotationSpeed 1.5
#define kPPMissileRotationSpeed 1.5

#define SPEED 2

@implementation PPSpriteNode

@dynamic targetPoint;
@synthesize flightDirection = _flightDirection;
@synthesize spriteFinishedOrientationRotation = _spriteFinishedOrientationRotation;
@synthesize health = _health;
@synthesize isFiringBullets = _isFiringBullets;
@synthesize fireRange = _fireRange;

- (id)initWithImageNamed:(NSString *)name {
    
    self = [super initWithImageNamed:name];
    
    if (self) {
        _flightDirection = kPPFlyStraight;
    }
    
    return self;
}

- (void)setTargetPoint:(CGPoint)targetPoint {
    _targetPoint = targetPoint;
    _spriteFinishedOrientationRotation = NO;
}

- (CGPoint)targetPoint {
    return _targetPoint;
}


- (void)updateMove:(CFTimeInterval)dt {

}

- (void)updateRotation:(CFTimeInterval)dt {

}

- (void)updateOrientationVector {
    
    if (!orientationNode) {
        orientationNode = [SKShapeNode node];
        orientationNode.strokeColor = [SKColor yellowColor];
        orientationNode.zPosition = 1;
        // Uncommnet if orientation vectors are needed.
        //[self addChild:orientationNode];
    }
    
    if (!northLineNode) {
        northLineNode = [SKShapeNode node];
        northLineNode.strokeColor = [SKColor blueColor];
        northLineNode.zPosition = 1;
        
        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             0.0,
                             self.size.height);
        northLineNode.path = thePath;
        // Uncommnet if orientation vectors are needed.
        //[self addChild:northLineNode];
    }
    
    if (!spriteOrientationLine) {
        spriteOrientationLine = [SKShapeNode node];
        spriteOrientationLine.strokeColor = [SKColor redColor];
        spriteOrientationLine.zPosition = 1;

        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             self.size.width * 30,
                             0.0);
        spriteOrientationLine.path = thePath;
        // Uncommnet if orientation vectors are needed.
        //[self addChild:spriteOrientationLine];
    }
    
    orientationNode.path = [self getPathForSpriteOrientation];
    

}

- (CGPoint)returnFireRange {
    return [self.parent convertPoint:CGPointMake(0.0, self.size.width *30) fromNode:self];
}

// 1. Calculate the cosine of the angle and multiply this by the distance.
// 2. Calculate the sine of the angle and multiply this by the distance.
- (CGVector)getSpriteOrientationForRadians:(CGFloat)radians {
    return CGVectorMake(cosf(radians), sinf(radians));
}


@end
