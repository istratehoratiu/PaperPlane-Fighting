//
//  PPMainAirplane.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMainAirplane.h"
#import "SKSpriteNode+Additions.h"
#import "PPMath.h"
#import "PPConstants.h"

#define kPPMainAirplaneRotationSpeed 1.5
#define kPPMissileRotationSpeed 1.5

@implementation PPMainAirplane


- (id)initMainAirplane {
    self = [super initWithImageNamed:@"PLANE 8 N.png"];
    
    if (self) {
        
        self.health = kPPUserAirplaneHealth;
        
        SKSpriteNode *_propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1.png"];
        _propeller.scale = 0.2;
        _propeller.position = CGPointMake(self.position.x + 105, self.position.y );
        
        SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1.png"];
        SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2.png"];
        
        SKAction *spin = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:spin];
        [_propeller runAction:spinForever];
        
        _isFiringBullets = NO;
        
        [self addChild:_propeller];
        
        _fireRange = [[SKSpriteNode alloc] init];
        _fireRange.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0.0, 0.0) toPoint:CGPointMake(300, 0.0)]; // 1
        //spriteOrientationLine.physicsBody.n
        _fireRange.physicsBody.dynamic = YES; // 2
        _fireRange.physicsBody.categoryBitMask = userAirplaneFiringRangeCategory; // 3
        _fireRange.physicsBody.usesPreciseCollisionDetection = YES;
        _fireRange.physicsBody.contactTestBitMask = enemyAirplaneCategory; // 4
        _fireRange.physicsBody.collisionBitMask = 0; // 5

        [self addChild:_fireRange];
    }
    
    return self;
}

- (void)setHealth:(CGFloat)health {
    [super setHealth:health];
    
    _health = health;
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
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = enemyAirplaneCategory;
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

- (void)updateMove:(CFTimeInterval)dt {
    
    CGPoint destinationPoint = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = skPointsSubtract(destinationPoint, self.position);
    
    CGPoint targetVector =  normalizeVector(offset);
    // 5
    float POINTS_PER_SECOND = 100;
    CGPoint targetPerSecond = skPointsMultiply(targetVector, POINTS_PER_SECOND);
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    CGPoint actualTarget = skPointsAdd(self.position, skPointsMultiply(targetPerSecond, dt));
    
    self.position = actualTarget;
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
    if (_flightDirection == kPPFlyStraight) {
        self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
        return;
    }
    
    if (_flightDirection == kPPTurnLeft) {
        
        [self setZRotation:self.zRotation + (kPPMainAirplaneRotationSpeed * dt)];
        self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L.png"];
        
    } else {
        
        [self setZRotation:self.zRotation - (kPPMainAirplaneRotationSpeed * dt)];
        self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R.png"];
    }
}

- (CGPoint)currentDirection {
    return [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
}

@end
