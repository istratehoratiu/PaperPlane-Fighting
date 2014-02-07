//
//  PPSpriteNode.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"
#import "SKSpriteNode+Additions.h"

#define SPEED 10
#define ROTATION_SPEED 0.9

@implementation PPSpriteNode

@dynamic targetPoint;
@synthesize spriteFinishedOrientationRotation = _spriteFinishedOrientationRotation;

- (void)setTargetPoint:(CGPoint)targetPoint {
    _targetPoint = targetPoint;
    _spriteFinishedOrientationRotation = NO;
}

- (CGPoint)targetPoint {
    return _targetPoint;
}

- (void)updateMove:(CFTimeInterval)dt {

    CGPoint destinationPoint = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = [self skPointsSubtract:destinationPoint andVector:self.position];
 
    CGPoint targetVector =     [self normalizeVector:offset];
    // 5
    float POINTS_PER_SECOND = 100;
    CGPoint targetPerSecond = [self skPointsMultiply:targetVector andValue:POINTS_PER_SECOND];
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    CGPoint actualTarget = [self skPointsAdd:self.position andVector:[self skPointsMultiply:targetPerSecond andValue:dt]];

    self.position = actualTarget;
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
    if (_spriteFinishedOrientationRotation) {
        return;
    }
    
    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    if ([self checkIfPoint:_targetPoint isToTheLeftOfLineGivenByThePoint:lineSource andPoint:lineEnd]) {
        
        [self setZRotation:self.zRotation + (ROTATION_SPEED * dt)];
        
        
        CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
        CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
        
        if (![self checkIfPoint:_targetPoint isToTheLeftOfLineGivenByThePoint:lineSource andPoint:lineEnd]) {
            
            [self setZRotation:self.zRotation - (ROTATION_SPEED * dt)];
            
            _spriteFinishedOrientationRotation = YES;
        }
        
        
    } else {
        
        [self setZRotation:self.zRotation - (ROTATION_SPEED * dt)];
        
        if ([self checkIfPoint:_targetPoint isToTheLeftOfLineGivenByThePoint:lineSource andPoint:lineEnd]) {
            
            [self setZRotation:self.zRotation + (ROTATION_SPEED * dt)];
            
            _spriteFinishedOrientationRotation = YES;
        }
    }
}

- (void)updateOrientationVector {
    
    if (!orientationNode) {
        orientationNode = [SKShapeNode node];
        orientationNode.strokeColor = [SKColor yellowColor];
        orientationNode.zPosition = 1;
        [self addChild:orientationNode];
    }
    
    if (!northLineNode) {
        northLineNode = [SKShapeNode node];
        northLineNode.strokeColor = [SKColor blueColor];
        northLineNode.zPosition = 1;
        
        CGPoint startingPosition = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             0.0,
                             self.size.height);
        northLineNode.path = thePath;
        
        [self addChild:northLineNode];
    }
    
    if (!spriteOrientationLine) {
        spriteOrientationLine = [SKShapeNode node];
        spriteOrientationLine.strokeColor = [SKColor redColor];
        spriteOrientationLine.zPosition = 1;
        
        CGPoint startingPosition = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             self.size.width,
                             0.0);
        spriteOrientationLine.path = thePath;
        
        [self addChild:spriteOrientationLine];
    }
    
    orientationNode.path = [self getPathForSpriteOrientation];
    

}

- (CGPoint)calculateControlPoint2GivenStartingPoint:(CGPoint)startingPoint firstControlPoint:(CGPoint)firstControlPoint andEndPoint:(CGPoint) endPoint {
    CGPoint controlPoint = CGPointZero;
    
    return controlPoint;
}

- (BOOL)checkIfPoint:(CGPoint)pointToCheck isToTheLeftOfLineGivenByThePoint:(CGPoint)firstLinePoint andPoint:(CGPoint)secondLinePoint {
    return ((secondLinePoint.x - firstLinePoint.x)*(pointToCheck.y - firstLinePoint.y) - (secondLinePoint.y - firstLinePoint.y)*(pointToCheck.x - firstLinePoint.x)) > 0;
}


- (CGPoint)skPointsAdd:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x + endPoint.x, startingPosition.y + endPoint.y);
}

- (CGPoint)skPointsSubtract:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x - endPoint.x, startingPosition.y - endPoint.y);
}

- (CGPoint)skPointsMultiply:(CGPoint)startingPosition andValue:(CGFloat)value {
    return CGPointMake(startingPosition.x * value, startingPosition.y * value);
}

- (CGPoint)skPointsDivide:(CGPoint)startingPosition andValue:(CGFloat)value {
    return CGPointMake(startingPosition.x / value, startingPosition.y / value);
}

// 1. Calculate the cosine of the angle and multiply this by the distance.
// 2. Calculate the sine of the angle and multiply this by the distance.
- (CGVector)getSpriteOrientationForRadians:(CGFloat)radians {
    return CGVectorMake(cosf(radians), sinf(radians));
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * (M_PI * 180.0f);
}

- (CGFloat)radiansToDegrees:(CGFloat)radians {
    return radians * (180.0f / M_PI);
}

- (CGPoint)normalizeVector:(CGPoint)vector {
    CGFloat magnitude = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    return CGPointMake(vector.x / magnitude, vector.y / magnitude);
}

@end
