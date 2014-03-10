//
//  PPMyScene.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMyScene.h"
#import "SKShapeNode+Additions.h"
#import "SKSpriteNode+Additions.h"
#import "PPSpriteNode.h"
#import "PPMath.h"
#import "SKButtonNode.h"
#import "PPMainAirplane.h"
#import "PPMissile.h"
#import "PPMainBase.h"  
#import "PPHunterAirplane.h"
#import "PPConstants.h"
#import "PPPositionIndicator.h"

#define MAGNITUDE 100.0
// Aceasta valoate trebuie sa ia o valoare de la 0 la 1. 0 fiind cea mai peformanta
#define TURN_ANGLE_PERFORMANCE 1

@implementation PPMyScene

@synthesize arrayOfEnemyBombers             = _arrayOfEnemyBombers;
@synthesize arrayOfEnemyHunterAirplanes     = _arrayOfEnemyHunterAirplanes;
@synthesize arrayOfCurrentMissilesOnScreen  = _arrayOfCurrentMissilesOnScreen;
@synthesize positionIndicator               = _positionIndicator;


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        
        SKButtonNode *backButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"restart.png" selected:@"restart_down.png"];
        [backButton setPosition:CGPointMake(100, 100)];
        [backButton.title setFontName:@"Chalkduster"];
        [backButton.title setFontSize:20.0];
        [backButton setTouchUpInsideTarget:self action:@selector(restartScene)];
        [self addChild:backButton];
        
        
        SKButtonNode *addEnemy = [[SKButtonNode alloc] initWithImageNamedNormal:@"plus.png" selected:@"plus.png"];
        [addEnemy setPosition:CGPointMake(200, 100)];
        [addEnemy.title setFontName:@"Chalkduster"];
        [addEnemy.title setFontSize:10.0];
        [addEnemy.title setText:@"Aircraft"];
        [addEnemy setTouchUpInsideTarget:self action:@selector(addEnemyAtRandomLocation)];
        [self addChild:addEnemy];
        
        SKButtonNode *addMissile = [[SKButtonNode alloc] initWithImageNamedNormal:@"plus.png" selected:@"plus.png"];
        [addMissile setPosition:CGPointMake(300, 100)];
        [addMissile.title setFontName:@"Chalkduster"];
        [addMissile.title setText:@"Missile"];
        [addMissile.title setFontSize:10.0];
        [addMissile setTouchUpInsideTarget:self action:@selector(addEnemyMissile)];
        [self addChild:addMissile];
        
        _mainBase = [[PPMainBase alloc] initMainBaseNode];
        _mainBase.scale = 0.2;
        _mainBase.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:_mainBase];
        
        self.arrayOfCurrentMissilesOnScreen = [NSMutableArray array];
        self.arrayOfEnemyHunterAirplanes = [NSMutableArray array];
        self.arrayOfEnemyBombers = [NSMutableArray array];
        
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //init several sizes used in all scene
        _screenRect = [[UIScreen mainScreen] bounds];
        _screenHeight = _screenRect.size.height;
        _screenWidth = _screenRect.size.width;
        
        // Main Actor
        _userAirplane = [[PPMainAirplane alloc] initMainAirplane];
        _userAirplane.scale = 0.2;
        _userAirplane.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        _userAirplane.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_userAirplane.size.width * 0.5]; // 1
        _userAirplane.physicsBody.dynamic = YES; // 2
        _userAirplane.physicsBody.categoryBitMask = userAirplaneCategory; // 3
        _userAirplane.physicsBody.contactTestBitMask = projectileCategory | missileCategory | enemyAirplaneCategory; // 4
        _userAirplane.physicsBody.collisionBitMask = 0; // 5
        
        [self addChild:_userAirplane];
        
        [_userAirplane updateOrientationVector];
        
        //schedule enemies
//        SKAction *wait = [SKAction waitForDuration:1];
//        SKAction *callEnemies = [SKAction runBlock:^{
//            [self EnemiesAndClouds];
//        }];
//        
//        SKAction *updateEnimies = [SKAction sequence:@[wait,callEnemies]];
//        [self runAction:[SKAction repeatActionForever:updateEnimies]];
        
        
        //adding the smokeTrail
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        _smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        _smokeTrail.position = CGPointMake(_screenWidth/2, 15);
        _smokeTrail.targetNode = self;
        [self addChild:_smokeTrail];
        
        _positionIndicator = [[PPPositionIndicator alloc] initPositionIndicatorForAircraft:_userAirplane];
    }
    return self;
}

- (void)restartScene {
    _userAirplane.position = CGPointMake(self.size.width / 2, self.size.height / 2);
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
        
    
    [_userAirplane updateOrientationVector];
    [_userAirplane updateMove:_deltaTime];
    [_userAirplane updateRotation:_deltaTime];
    
    [_positionIndicator updatePositionIndicatorForMainAircraft];
    
    for (PPSpriteNode *hunterAirplane in _arrayOfEnemyHunterAirplanes) {
        [hunterAirplane updateMove:_deltaTime];
        [hunterAirplane updateRotation:_deltaTime];
        [hunterAirplane updateOrientationVector];
    }
    
    for (PPSpriteNode *missile in _arrayOfCurrentMissilesOnScreen) {
        [missile updateMove:_deltaTime];
        [missile updateRotation:_deltaTime];
        [missile setTargetPoint:_userAirplane.position];
        [missile updateOrientationVector];
    }
    
    _smokeTrail.position = CGPointMake(_userAirplane.position.x ,_userAirplane.position.y-(_userAirplane.size.height/2));
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    
    NSLog(@" %d --- %d", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
    
    if (((contact.bodyA.categoryBitMask ==  enemyMissileCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask ==  userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyMissileCategory))) {
        // Remove bullet from scene.
        if (contact.bodyA.categoryBitMask ==  enemyMissileCategory) {
            [_arrayOfCurrentMissilesOnScreen removeObject:firstNode];
            [firstNode removeFromParent];
        } else {
            [_arrayOfCurrentMissilesOnScreen removeObject:secondNode];
            [secondNode removeFromParent];
        }
        
        [_userAirplane setHealth:_userAirplane.health - 50];
        
        if ([_userAirplane health] <= 0) {
            _userAirplane.health = 100;
            [self restartScene];
        }
    }
    
    if (((contact.bodyA.categoryBitMask ==  enemyProjectileCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask ==  userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyProjectileCategory))) {
        // Remove bullet from scene.
        if (contact.bodyA.categoryBitMask ==  enemyProjectileCategory) {
            [firstNode removeFromParent];
        } else {
            [secondNode removeFromParent];
        }
        
        [_userAirplane setHealth:_userAirplane.health - 10];
        
        if ([_userAirplane health] <= 0) {
            
            for (PPSpriteNode *hunterAirplane in _arrayOfEnemyHunterAirplanes) {
                if (hunterAirplane.isFiringBullets) {
                    [hunterAirplane stopFiring];
                }
            }
            
            _userAirplane.health = 100;
            [self restartScene];
        }
    }
    
    if ((contact.bodyA.categoryBitMask ==  projectileCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneCategory)) {
        // Remove bullet from scene.
        [firstNode removeFromParent];
        
        [(PPHunterAirplane *)secondNode setHealth:[(PPHunterAirplane *)secondNode health] - 10];
        
        if ([(PPHunterAirplane *)secondNode health] <= 0) {
            
            [_arrayOfEnemyHunterAirplanes removeObject:secondNode];
            
            [_userAirplane stopFiring];
            //[self addEnemyAtRandomLocation];
        }
    } else if ((contact.bodyA.categoryBitMask == enemyAirplaneCategory) && (contact.bodyB.categoryBitMask == projectileCategory)) {
       
        // Remove bullet from scene.
        [secondNode removeFromParent];
        
        [(PPHunterAirplane *)firstNode setHealth:[(PPHunterAirplane *)firstNode health] - 10];
        
        if ([(PPHunterAirplane *)firstNode health] <= 0) {
            
            [_arrayOfEnemyHunterAirplanes removeObject:firstNode];
            
            [_userAirplane stopFiring];
            //[self addEnemyAtRandomLocation];
        }
    }
    
    if (((contact.bodyA.categoryBitMask == userAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask == enemyAirplaneCategory) && (contact.bodyB.categoryBitMask == userAirplaneFiringRangeCategory)))
    {
        if (!_userAirplane.isFiringBullets) {
            [_userAirplane fireBullet];
        }
    }
    
    if ((contact.bodyA.categoryBitMask == enemyAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) {
        if (![(PPHunterAirplane *)firstNode.parent isFiringBullets]) {
            [(PPHunterAirplane *)firstNode.parent fireBullet];
        }
    }
    
    if ((contact.bodyA.categoryBitMask == userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneFiringRangeCategory)) {
        if (![(PPHunterAirplane *)secondNode.parent isFiringBullets]) {
            [(PPHunterAirplane *)secondNode.parent fireBullet];
        }
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    // 1
    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    if (((contact.bodyA.categoryBitMask == userAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask == enemyAirplaneCategory) && (contact.bodyB.categoryBitMask == userAirplaneFiringRangeCategory)))
    {
        [_userAirplane stopFiring];
    }
    
    if ((contact.bodyA.categoryBitMask == enemyAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) {
        [(PPHunterAirplane *)firstNode.parent stopFiring];
    }
    
    if ((contact.bodyA.categoryBitMask == userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneFiringRangeCategory)) {
        [(PPHunterAirplane *)secondNode.parent stopFiring];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
            
        CGPoint location = [touch locationInNode:self];
        
        if (location.x < self.size.width * 0.5) {
            _userAirplane.flightDirection = kPPTurnLeft;
        } else {
            _userAirplane.flightDirection = kPPTurnRight;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        
        _userAirplane.flightDirection = kPPFlyStraight;
    }
}

#pragma mark -
#pragma mark Position Indicator Methods



#pragma mark -
#pragma mark Helper Methods

- (void)addEnemyMissile {
    PPMissile *missile = [[PPMissile alloc] initMissileNode];
    missile.position = CGPointMake([self getRandomNumberBetween:0 to:self.size.width], [self getRandomNumberBetween:0 to:745]);
    missile.targetAirplane = _userAirplane;
    missile.scale = 0.1;
    
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.frame.size]; // 1
    missile.physicsBody.dynamic = YES; // 2
    missile.physicsBody.categoryBitMask = enemyMissileCategory; // 3
    missile.physicsBody.contactTestBitMask = userAirplaneCategory; // 4
    missile.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:missile];
    [_arrayOfCurrentMissilesOnScreen addObject:missile];
    [missile updateOrientationVector];
}

- (void)addEnemyAtRandomLocation {
    PPHunterAirplane *enemyAirplane = [[PPHunterAirplane alloc] initHunterAirPlane];
    
    enemyAirplane.position = CGPointMake([self getRandomNumberBetween:0 to:self.size.width], [self getRandomNumberBetween:0 to:745]);
    enemyAirplane.scale = 0.2;
    enemyAirplane.targetAirplane = _userAirplane;
    
    enemyAirplane.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemyAirplane.size.width * 0.5]; // 1
    enemyAirplane.physicsBody.dynamic = YES; // 2
    enemyAirplane.physicsBody.categoryBitMask = enemyAirplaneCategory; // 3
    enemyAirplane.physicsBody.contactTestBitMask = projectileCategory | userAirplaneFiringRangeCategory | missileCategory; // 4
    enemyAirplane.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:enemyAirplane];
    [enemyAirplane updateOrientationVector];
    [_arrayOfEnemyHunterAirplanes addObject:enemyAirplane];
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

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

@end


