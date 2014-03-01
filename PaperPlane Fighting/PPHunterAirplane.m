//
//  PPHunterAirplane.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPHunterAirplane.h"
#import "PPMath.h"
#import "PPConstants.h"

@implementation PPHunterAirplane

@synthesize targetAirplane  = _targetAirplane;
@synthesize shouldFire = _shouldFire;

- (id)initHunterAirPlane {
    
    self = [super initWithImageNamed:@"PLANE 1 N.png"];
    return self;
}

- (void)updateMove:(CFTimeInterval)dt {
    
    CGPoint destinationPoint = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = skPointsSubtract(destinationPoint, self.position);
    
    CGPoint targetVector =  normalizeVector(offset);
    // 5
    float POINTS_PER_SECOND = 60;
    CGPoint targetPerSecond = skPointsMultiply(targetVector, POINTS_PER_SECOND);
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    CGPoint actualTarget = skPointsAdd(self.position, skPointsMultiply(targetPerSecond, dt));
    
    self.position = actualTarget;
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
//    if (_spriteFinishedOrientationRotation) {
//        return;
//    }
    
    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetAirplane.position, lineSource, lineEnd)) {
        
        [self setZRotation:self.zRotation + (kPPRotationSpeedOfHunterAirplane * dt)];
        
        
        CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
        CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
        
        if (!checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetAirplane.position, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation - (kPPRotationSpeedOfHunterAirplane * dt)];
        }
        
    } else {
        
        [self setZRotation:self.zRotation - (kPPRotationSpeedOfHunterAirplane * dt)];
        
        if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetAirplane.position, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation + (kPPRotationSpeedOfHunterAirplane * dt)];
            
        }
    }
}

@end
