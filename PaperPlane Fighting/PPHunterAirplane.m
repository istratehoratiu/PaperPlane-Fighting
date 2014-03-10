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
    
    if (self) {
        self.health = kPPHunterAirplaneHealth;
        
        
        _fireRange = [[SKSpriteNode alloc] init];
        _fireRange.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0.0, 0.0) toPoint:CGPointMake(300, 0.0)]; // 1
        //spriteOrientationLine.physicsBody.n
        _fireRange.physicsBody.dynamic = YES; // 2
        _fireRange.physicsBody.categoryBitMask = enemyAirplaneFiringRangeCategory; // 3
        _fireRange.physicsBody.usesPreciseCollisionDetection = YES;
        _fireRange.physicsBody.contactTestBitMask = userAirplaneCategory; // 4
        _fireRange.physicsBody.collisionBitMask = 0; // 5
        
        [self addChild:_fireRange];
    }
    
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

- (void)setHealth:(CGFloat)health {
    
    [super setHealth:health];
    
    if (_health <= 0) {
        [self removeFromParent];
    }
}

- (void)stopFiring {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fireBullet) object:nil];
    _isFiringBullets = NO;
}

- (void)fireBullet {
    
    _isFiringBullets = YES;
    
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"B 2.png"];
    
    projectile.zRotation = self.zRotation;
    projectile.position = self.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width * 0.5];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = enemyProjectileCategory;
    projectile.physicsBody.contactTestBitMask = userAirplaneCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    // 5 - OK to add now - we've double checked position
    [self.parent addChild:projectile];
    
    CGPoint endPoint;
    CGPoint startingPosition = CGPointMake(0.0, 0.0);
    endPoint.y = sinf(self.zRotation) * (self.size.width * 0.5);
    endPoint.x = cosf(self.zRotation) * (self.size.width * 0.5);
    endPoint = skPointsAdd(startingPosition, endPoint);
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = normalizeVector(endPoint);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = skPointsMultiply(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    //CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    CGVector vectorDir = CGVectorMake(shootAmount.x, shootAmount.y);
    
    // 9 - Create the actions
    float velocity = 30.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveBy:vectorDir duration:realMoveDuration];
    //SKAction * actionMove = [SKAction moveTo:shootAmount duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    [self performSelector:@selector(fireBullet) withObject:nil afterDelay:.2];
}

@end
