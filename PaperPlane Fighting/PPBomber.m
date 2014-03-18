//
//  PPBomber.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPBomber.h"
#import "PPMath.h"
#import "PPMainAirplane.h"
#import "PPConstants.h"

@implementation PPBomber

@synthesize mainAirplane = _mainAirplane;
@synthesize mainBase = _mainBase;

- (id)initBomber {
    self = [super initWithImageNamed:@"B-25J-Bomber-1.png"];
    
    if (self) {
        
        self.health = 150;
        self.speed = 50;
        self.manevrability = kPPRotationSpeedOfBomber;
        self.damage = 10;
        self.rateOfFire = .5;
        return self;
    }
    
    return self;
}

- (void)updateMove:(CFTimeInterval)dt {
    
    CGPoint destinationPoint = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = skPointsSubtract(destinationPoint, self.position);
    
    CGPoint targetVector =  normalizeVector(offset);
    
    CGPoint targetPerSecond = skPointsMultiply(targetVector, _speed);

    CGPoint actualTarget = skPointsAdd(self.position, skPointsMultiply(targetPerSecond, dt));
    
    self.position = actualTarget;
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_mainBase.position, lineSource, lineEnd)) {
        
        [self setZRotation:self.zRotation + (_manevrability * dt)];
        
        
        CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
        CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
        
        if (!checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_mainBase.position, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation - (_manevrability * dt)];
        }
        
    } else {
        
        [self setZRotation:self.zRotation - (_manevrability * dt)];
        
        if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_mainBase.position, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation + (_manevrability * dt)];
            
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
    
    projectile.scale = 0.5;
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
    float velocity = 15.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveBy:vectorDir duration:realMoveDuration];
    //SKAction * actionMove = [SKAction moveTo:shootAmount duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    [self performSelector:@selector(fireBullet) withObject:nil afterDelay:.2];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isLockedOnByEnemy) {
        [(PPMainAirplane *)_mainAirplane launchMissileTowardAircraft:self];
    }
}


@end
