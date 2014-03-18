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
@synthesize speed = _speed;
@synthesize manevrability = _manevrability;
@synthesize rateOfFire = _rateOfFire;
@synthesize damage = _damage;
@synthesize isLockedOnByEnemy = _isLockedOnByEnemy;
@synthesize hasLockOnByEnemy = _hasLockOnByEnemy;
@synthesize lockOnCrosshair = _lockOnCrosshair;
@synthesize lockOnAnimation = _lockOnAnimation;
@synthesize numberOfRockets = _numberOfRockects;
@synthesize smokeTrail = _smokeTrail;
@synthesize shadow = _shadow;
@synthesize missileRange = _missileRange;
@synthesize isInProcessOfLockingIn = _isInProcessOfLockingIn;


- (id)initWithImageNamed:(NSString *)name {
    
    self = [super initWithImageNamed:name];
    
    if (self) {
        _flightDirection = kPPFlyStraight;
        
        _lockOnCrosshair = [[SKSpriteNode alloc] initWithImageNamed:@"crosshair.png"];
        
        SKAction *zoom = [SKAction scaleTo:.5 duration:1];
        SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration:1];
        
        [self setUserInteractionEnabled:YES];
        
        _lockOnAnimation = [SKAction group:@[zoom, oneRevolution]];
    }
    
    return self;
}


#pragma mark -
#pragma mark Getter Setter methods

- (void)setHealth:(CGFloat)health {
    _health = health;
    
    if (_health <= 0) {
        [self addExplosionEmitter];
    } else {
        [self addBulletHitEmitter];
    }
}

- (void)setTargetPoint:(CGPoint)targetPoint {
    _targetPoint = targetPoint;
    _spriteFinishedOrientationRotation = NO;
}

- (CGPoint)targetPoint {
    return _targetPoint;
}


#pragma mark -
#pragma mark Overriden

- (void)fireBullet {

}

- (void)stopFiring {

}

- (void)updateMove:(CFTimeInterval)dt {
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
}

- (void)startLockOnAnimation {
    
    if (_lockOnCrosshair.parent) {
        [_lockOnCrosshair removeFromParent];
    }
    
    _isLockedOnByEnemy = YES;
    
    _lockOnCrosshair.position = self.centerRect.origin;
    [self addChild:_lockOnCrosshair];
    [_lockOnCrosshair runAction:_lockOnAnimation completion:^{

        
    }];
}

- (void)removeLockOn {
    _isLockedOnByEnemy = NO;

    [_lockOnCrosshair removeAllActions];
    
    if (_lockOnCrosshair.parent) {
        [_lockOnCrosshair removeFromParent];
    }
}



#pragma mark - 
#pragma mark Help Methods

- (void)addExplosionEmitter {
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"];
    SKEmitterNode *explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    //explosionPath.position = CGPointMake(_screenWidth/2, 15);
    explosionEmitter.targetNode = self.parent;
    explosionEmitter.numParticlesToEmit = 100;
    explosionEmitter.position = self.position;
    [self.parent addChild:explosionEmitter];
}

- (void)addBulletHitEmitter {
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"bulletHit" ofType:@"sks"];
    SKEmitterNode *explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    //explosionPath.position = CGPointMake(_screenWidth/2, 15);
    explosionEmitter.targetNode = self.parent;
    explosionEmitter.numParticlesToEmit = 1;
    explosionEmitter.position = self.position;
    [self.parent addChild:explosionEmitter];
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
