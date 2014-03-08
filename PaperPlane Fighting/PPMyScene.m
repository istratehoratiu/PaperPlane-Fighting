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



#define MAGNITUDE 100.0
// Aceasta valoate trebuie sa ia o valoare de la 0 la 1. 0 fiind cea mai peformanta
#define TURN_ANGLE_PERFORMANCE 1

@implementation PPMyScene


@synthesize arrayOfCurrentMissilesOnScreen = _arrayOfCurrentMissilesOnScreen;
@synthesize hunterAirplane = _hunterAirplane;


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        
        _mainBase = [[PPMainBase alloc] initMainBaseNode];
        _mainBase.scale = 0.2;
        _mainBase.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:_mainBase];
        
        self.arrayOfCurrentMissilesOnScreen = [NSMutableArray array];
        
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
        
        SKButtonNode *backButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"buttonNormal" selected:@"buttonSelected"];
        [backButton setPosition:CGPointMake(100, 100)];
        [backButton.title setText:@"Button"];
        [backButton.title setFontName:@"Chalkduster"];
        [backButton.title setFontSize:20.0];
        [backButton setTouchUpInsideTarget:_userAirplane action:@selector(fireBullet)];
        //[self addChild:backButton];
        
        //schedule enemies
//        SKAction *wait = [SKAction waitForDuration:1];
//        SKAction *callEnemies = [SKAction runBlock:^{
//            [self EnemiesAndClouds];
//        }];
//        
//        SKAction *updateEnimies = [SKAction sequence:@[wait,callEnemies]];
//        [self runAction:[SKAction repeatActionForever:updateEnimies]];
        
        
        PPMissile *missile = [[PPMissile alloc] initMissileNode];
        missile.position = CGPointMake(self.size.width / 2 + 200, self.size.height / 2 + 200);
        missile.targetAirplane = _userAirplane;
        missile.scale = 0.1;
        [self addChild:missile];
        [_arrayOfCurrentMissilesOnScreen addObject:missile];
        [missile updateOrientationVector];
        
        
        //adding the smokeTrail
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        _smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        _smokeTrail.position = CGPointMake(_screenWidth/2, 15);
        _smokeTrail.targetNode = self;
        [self addChild:_smokeTrail];
        
        
        _hunterAirplane = [[PPHunterAirplane alloc] initHunterAirPlane];
        _hunterAirplane.position = CGPointMake(self.size.width, 0.0);
        _hunterAirplane.scale = 0.2;
        _hunterAirplane.targetAirplane = _userAirplane;
        
        _hunterAirplane.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_hunterAirplane.size.width * 0.5]; // 1
        _hunterAirplane.physicsBody.dynamic = YES; // 2
        _hunterAirplane.physicsBody.categoryBitMask = enemyAirplaneCategory; // 3
        _hunterAirplane.physicsBody.contactTestBitMask = projectileCategory | userAirplaneFiringRangeCategory | missileCategory; // 4
        _hunterAirplane.physicsBody.collisionBitMask = 0; // 5
        
        [self addChild:_hunterAirplane];
        [_hunterAirplane updateOrientationVector];
    }
    return self;
}

- (void)fireButtonPreset {

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
    
    [_hunterAirplane updateRotation:_deltaTime];
    [_hunterAirplane updateMove:_deltaTime];
    [_hunterAirplane updateOrientationVector];
    
    
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
    
    if (((contact.bodyA.categoryBitMask == userAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask == enemyAirplaneCategory) && (contact.bodyB.categoryBitMask == userAirplaneFiringRangeCategory)))
    {
        NSLog(@" %d /// %d", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
        if (!_userAirplane.isFiringBullets) {
            [_userAirplane fireBullet];
        }
    }
    
    if (((contact.bodyA.categoryBitMask == enemyAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask == userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneFiringRangeCategory)))
    {
        NSLog(@" %d --- %d", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask == enemyAirplaneCategory);
        if (!_hunterAirplane.isFiringBullets) {
            [_hunterAirplane fireBullet];
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
    
    if (((contact.bodyA.categoryBitMask == enemyAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) ||
        ((contact.bodyA.categoryBitMask == userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneFiringRangeCategory)))
    {
        [_hunterAirplane stopFiring];
    }
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {

    [projectile removeFromParent];
    [monster removeFromParent];
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

- (void)calculateForCGPath:(CGMutablePathRef)cgPath controlPointsGivenStartingPoint:(CGPoint)startingPoint andEndPoint:(CGPoint) endPoint {
    CGPoint firstPoint1 = CGPointZero;
    CGPoint firstPoint2 = CGPointZero;
    
    CGPoint differenceVector =  skPointsSubtract(endPoint, startingPoint);
    
    if (differenceVector.x > 0 && differenceVector.y > 0) {
        firstPoint1 = CGPointMake(startingPoint.x + (differenceVector.x * 0.25) - 50, startingPoint.y + (differenceVector.y * 0.25));
        firstPoint2 = CGPointMake(startingPoint.x + (differenceVector.x * 0.75) - 50, startingPoint.y + (differenceVector.y * 0.75));
    } else if (differenceVector.x < 0 && differenceVector.y > 0) {
        firstPoint1 = CGPointMake(startingPoint.x + (differenceVector.x * 0.25) - 50, startingPoint.y + (differenceVector.y * 0.25));
        firstPoint2 = CGPointMake(startingPoint.x + (differenceVector.x * 0.75) - 50, startingPoint.y + (differenceVector.y * 0.75));
    }

    CGPathAddCurveToPoint(cgPath, NULL, firstPoint1.x, firstPoint1.y, firstPoint2.x, firstPoint2.y, endPoint.x, endPoint.y);
    
}

- (CGPoint)calculateControlPoint2GivenStartingPoint:(CGPoint)startingPoint firstControlPoint:(CGPoint)firstControlPoint andEndPoint:(CGPoint) endPoint {
    CGPoint controlPoint = CGPointZero;
    
    return controlPoint;
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


