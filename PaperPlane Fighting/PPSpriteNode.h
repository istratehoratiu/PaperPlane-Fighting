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
    SKSpriteNode *_missileRange;
    SKShapeNode *orientationNode;
    SKShapeNode *northLineNode;
    SKShapeNode *spriteOrientationLine;
    // point to which the sprite point to. the target of the movement(touch) in case of the main airplane
    CGPoint _targetPoint;
    BOOL _spriteFinishedOrientationRotation;
    
    BOOL _isFiringBullets;
    
    PPFlightDirection _flightDirection;
    
    CGFloat _health;
    CGFloat _speed;
    CGFloat _manevrability;
    CGFloat _rateOfFire;
    CGFloat _damage;
    NSUInteger _numberOfRockects;
    
    SKSpriteNode *_lockOnCrosshair;
    BOOL _isInProcessOfLockingIn;
    BOOL _isLockedOnByEnemy;
    BOOL _hasLockOnByEnemy;
    
    SKAction *_lockOnAnimation;
    SKEmitterNode *_smokeTrail;
    SKSpriteNode *_shadow;
}

@property (nonatomic, retain) SKAction *lockOnAnimation;
@property (nonatomic, assign) PPFlightDirection flightDirection;
@property (nonatomic, retain) SKSpriteNode *fireRange;
@property (nonatomic, retain) SKSpriteNode *missileRange;
@property (nonatomic, retain) SKSpriteNode *shadow;
@property (nonatomic, assign) BOOL isFiringBullets;
@property (nonatomic, assign) CGPoint targetPoint;
@property (nonatomic, assign) BOOL spriteFinishedOrientationRotation;
@property (nonatomic, assign) CGFloat health;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CGFloat manevrability;
@property (nonatomic, assign) CGFloat rateOfFire;
@property (nonatomic, assign) CGFloat damage;
@property (nonatomic, retain) SKSpriteNode *lockOnCrosshair;
@property (nonatomic, assign) BOOL isLockedOnByEnemy;
@property (nonatomic, assign) BOOL isInProcessOfLockingIn;;
@property (nonatomic, assign) BOOL hasLockOnByEnemy;
@property (nonatomic, assign) NSUInteger numberOfRockets;
@property SKEmitterNode *smokeTrail;

- (void)updateOrientationVector;
- (void)updateMove:(CFTimeInterval)dt;
- (void)updateRotation:(CFTimeInterval)dt;
- (CGPoint)returnFireRange;
- (void)fireBullet;
- (void)stopFiring;
- (void)addExplosionEmitter;
- (void)addBulletHitEmitter;
- (void)startLockOnAnimation;
- (void)removeLockOn;

@end
