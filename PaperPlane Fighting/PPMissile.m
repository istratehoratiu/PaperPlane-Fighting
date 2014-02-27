//
//  PPMissile.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMissile.h"
#import "SKSpriteNode+Additions.h"
#import "PPMath.h"
#import "PPConstants.h"


@implementation PPMissile

@synthesize smokeTrail      = _smokeTrail;
@synthesize targetAirplane  = _targetAirplane;

#define kPPMainAirplaneRotationSpeed 1.5
#define kPPMissileRotationSpeed .5

- (id)initMissileNode {
    
    self = [super initWithImageNamed:@"missile.png"];
    
    if (self) {
        
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        self.smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    }
    
    return self;
}

- (void)updateMove:(CFTimeInterval)dt {

    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint destinationPoint = lineEnd;//[self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = skPointsSubtract(destinationPoint, self.position);
    
    CGPoint targetVector =  normalizeVector(offset);
    // 5
    float POINTS_PER_SECOND = 150;
    CGPoint targetPerSecond = skPointsMultiply(targetVector, POINTS_PER_SECOND);
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    CGPoint actualTarget = skPointsAdd(self.position, skPointsMultiply(targetPerSecond, dt));
    
    self.position = actualTarget;
    
    if (![_smokeTrail parent]) {
        [self.parent addChild:_smokeTrail];
         _smokeTrail.targetNode = self.parent;
    }
    _smokeTrail.position = actualTarget;
    

}

- (void)updateRotation:(CFTimeInterval)dt {

    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint airplaneCenter = [self.parent convertPoint:_targetAirplane.position fromNode:self];
    CGPoint airplaneDirection = [self.parent convertPoint:CGPointMake(_targetAirplane.size.width, 0) fromNode:self];
    
    CGPoint intersectionPoint = getIntersectionOfLinesGivenByPoints(lineSource, lineEnd, airplaneCenter, airplaneDirection);
    
    if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetAirplane.position, lineSource, lineEnd)) {
        
        [self setZRotation:self.zRotation + (kPPMissileRotationSpeed * dt)];
        
        
        CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
        CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
        
        if (!checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetAirplane.position, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation - (kPPMissileRotationSpeed * dt)];
            
            _spriteFinishedOrientationRotation = YES;
        }
    } else {
        
        [self setZRotation:self.zRotation - (kPPMissileRotationSpeed * dt)];
        
        if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetAirplane.position, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation + (kPPMissileRotationSpeed * dt)];
            
            _spriteFinishedOrientationRotation = YES;
        }
    }
}

@end
