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
#import "PPBomber.h"


#define MAGNITUDE 100.0
// Aceasta valoate trebuie sa ia o valoare de la 0 la 1. 0 fiind cea mai peformanta
#define TURN_ANGLE_PERFORMANCE 1

@implementation PPMyScene

@synthesize arrayOfEnemyBombers             = _arrayOfEnemyBombers;
@synthesize arrayOfEnemyHunterAirplanes     = _arrayOfEnemyHunterAirplanes;
@synthesize arrayOfCurrentMissilesOnScreen  = _arrayOfCurrentMissilesOnScreen;
@synthesize positionIndicator               = _positionIndicator;
@synthesize gameIsPaused                    = _gameIsPaused;
@synthesize pauseButton                     = _pauseButton;


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        

        
        _mainBase = [[PPMainBase alloc] initMainBaseNode];
        _mainBase.scale = 0.2;
        _mainBase.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        
        _mainBase.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_mainBase.size.width]; // 1
        _mainBase.physicsBody.dynamic = YES; // 2
        _mainBase.physicsBody.categoryBitMask = mainBaseCategory; // 3
        _mainBase.physicsBody.contactTestBitMask = enemyBomberCategory; // 4
        _mainBase.physicsBody.collisionBitMask = 0; // 5
        
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
        _userAirplane.scale = 0.15;
        _userAirplane.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        _userAirplane.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_userAirplane.size.width * 0.5]; // 1
        _userAirplane.physicsBody.dynamic = YES; // 2
        _userAirplane.physicsBody.categoryBitMask = userAirplaneCategory; // 3
        _userAirplane.physicsBody.contactTestBitMask = projectileCategory | missileCategory | enemyAirplaneCategory; // 4
        _userAirplane.physicsBody.collisionBitMask = 0; // 5
        
        [self addChild:_userAirplane];
        
        [_userAirplane updateOrientationVector];
        
        _positionIndicator = [[PPPositionIndicator alloc] initPositionIndicatorForAircraft:_userAirplane];
        
        
        SKTextureAtlas *cloudsAtlas = [SKTextureAtlas atlasNamed:@"Clouds"];
        NSArray *textureNamesClouds = [cloudsAtlas textureNames];
        _cloudsTextures = [NSMutableArray new];
        for (NSString *name in textureNamesClouds) {
            SKTexture *texture = [cloudsAtlas textureNamed:name];
            [_cloudsTextures addObject:texture];
        }
        
        
        //schedule enemies
        SKAction *wait = [SKAction waitForDuration:2];
        SKAction *callClouds = [SKAction runBlock:^{
            [self addClouds];
        }];
        
        SKAction *updateClouds = [SKAction sequence:@[wait,callClouds]];
        [self runAction:[SKAction repeatActionForever:updateClouds]];
        
        //load explosions
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
        NSArray *textureNames = [explosionAtlas textureNames];
        _explosionTextures = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [_explosionTextures addObject:texture];
        }

        SKButtonNode *backButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"restart.png" selected:@"restart_down.png"];
        [backButton setPosition:CGPointMake(100, 100)];
        [backButton.title setFontName:@"Chalkduster"];
        [backButton.title setFontSize:20.0];
        [backButton setTouchUpInsideTarget:self action:@selector(restartScene)];
        backButton.zPosition = 1000;
        [self addChild:backButton];
        
        
        SKButtonNode *addEnemy = [[SKButtonNode alloc] initWithImageNamedNormal:@"plus.png" selected:@"plus.png"];
        [addEnemy setPosition:CGPointMake(200, 100)];
        [addEnemy.title setFontName:@"Chalkduster"];
        [addEnemy.title setFontSize:10.0];
        [addEnemy.title setText:@"Aircraft"];
        [addEnemy setTouchUpInsideTarget:self action:@selector(addEnemyAtRandomLocation)];
        addEnemy.zPosition = 1000;
        [self addChild:addEnemy];
        
        SKButtonNode *addMissile = [[SKButtonNode alloc] initWithImageNamedNormal:@"plus.png" selected:@"plus.png"];
        [addMissile setPosition:CGPointMake(300, 100)];
        [addMissile.title setFontName:@"Chalkduster"];
        [addMissile.title setText:@"Missile"];
        [addMissile.title setFontSize:10.0];
        [addMissile setTouchUpInsideTarget:self action:@selector(addEnemyMissile)];
        addMissile.zPosition = 1000;
        [self addChild:addMissile];
        
        SKButtonNode *addBomber = [[SKButtonNode alloc] initWithImageNamedNormal:@"plus.png" selected:@"plus.png"];
        [addBomber setPosition:CGPointMake(400, 100)];
        [addBomber.title setFontName:@"Chalkduster"];
        [addBomber.title setFontSize:10.0];
        [addBomber.title setText:@"Bomber"];
        [addBomber setTouchUpInsideTarget:self action:@selector(addEnemyBomberAtRandomLocation)];
        addBomber.zPosition = 1000;
        [self addChild:addBomber];
        
        SKButtonNode *launchMissile = [[SKButtonNode alloc] initWithImageNamedNormal:@"glossy_red_button.png" selected:@"glossy_red_button.png"];
        [launchMissile setPosition:CGPointMake(100, 500)];
        [launchMissile.title setFontName:@"Chalkduster"];
        [launchMissile.title setFontSize:10.0];
        [launchMissile.title setText:@""];
        [launchMissile setTouchUpInsideTarget:self action:@selector(launchMissileFromMainAicraft)];
        launchMissile.zPosition = 1000;
        [self addChild:launchMissile];
        
        _pauseButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"play.png" selected:@"play.png"];
        [_pauseButton setPosition:CGPointMake(self.size.width - 100, self.size.height - 100)];
        [_pauseButton.title setFontName:@"Chalkduster"];
        [_pauseButton.title setFontSize:10.0];
        [_pauseButton.title setText:@""];
        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseGame)];
        _pauseButton.zPosition = 1000;
        [self addChild:_pauseButton];
        
        _gameIsPaused = YES;
    }
    return self;
}

- (void)restartScene {
    
    _gameIsPaused = YES;
    
    [_userAirplane stopFiring];
    _userAirplane.health = kPPUserAirplaneHealth;
    _userAirplane.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    for (PPSpriteNode *item in _arrayOfCurrentMissilesOnScreen) {
        [item removeFromParent];
    }
    for (PPSpriteNode *item in _arrayOfEnemyBombers) {
        [item removeFromParent];
    }
    for (PPSpriteNode *item in _arrayOfEnemyHunterAirplanes) {
        [item removeFromParent];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    if (_gameIsPaused) {
        return;
    }
        
    
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
    
    for (PPSpriteNode *bomber in _arrayOfEnemyBombers) {
        [bomber updateMove:_deltaTime];
        [bomber updateRotation:_deltaTime];
        [bomber setTargetPoint:_userAirplane.position];
        [bomber updateOrientationVector];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    
    NSLog(@" %d --- %d", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
    
    if (((contact.bodyA.categoryBitMask ==  missileCategory) && ((contact.bodyB.categoryBitMask == enemyAirplaneCategory) || (contact.bodyB.categoryBitMask == enemyBomberCategory))) ||
        (((contact.bodyA.categoryBitMask ==  enemyAirplaneCategory) || (contact.bodyA.categoryBitMask ==  enemyBomberCategory)) && (contact.bodyB.categoryBitMask == missileCategory))) {
        // Remove bullet from scene.
        if (contact.bodyA.categoryBitMask ==  missileCategory) {
            [_arrayOfCurrentMissilesOnScreen removeObject:firstNode];
            [firstNode removeFromParent];
            
            [(PPHunterAirplane *)secondNode setHealth:[(PPHunterAirplane *)secondNode health] - 2000];
        } else {
            [_arrayOfCurrentMissilesOnScreen removeObject:secondNode];
            [secondNode removeFromParent];
            
            [(PPHunterAirplane *)firstNode setHealth:[(PPHunterAirplane *)secondNode health] - 2000];
        }
    }
    
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
    
    if ((contact.bodyA.categoryBitMask ==  projectileCategory) && ((contact.bodyB.categoryBitMask == enemyAirplaneCategory) || (contact.bodyB.categoryBitMask == enemyBomberCategory))) {
        // Remove bullet from scene.
        [firstNode removeFromParent];
        
        [(PPHunterAirplane *)secondNode setHealth:[(PPHunterAirplane *)secondNode health] - 10];
        
        if ([(PPHunterAirplane *)secondNode health] <= 0) {
            
            [_arrayOfEnemyHunterAirplanes removeObject:secondNode];
            
            [_userAirplane stopFiring];
            //[self addEnemyAtRandomLocation];
        }
    } else if (((contact.bodyA.categoryBitMask == enemyAirplaneCategory) || (contact.bodyA.categoryBitMask == enemyBomberCategory)) && (contact.bodyB.categoryBitMask == projectileCategory)) {
       
        // Remove bullet from scene.
        [secondNode removeFromParent];
        
        [(PPHunterAirplane *)firstNode setHealth:[(PPHunterAirplane *)firstNode health] - 10];
        
        if ([(PPHunterAirplane *)firstNode health] <= 0) {
            
            [_arrayOfEnemyHunterAirplanes removeObject:firstNode];
            
            [_userAirplane stopFiring];
            //[self addEnemyAtRandomLocation];
        }
    }
    
    if (((contact.bodyA.categoryBitMask == userAirplaneFiringRangeCategory) && ((contact.bodyB.categoryBitMask == enemyAirplaneCategory) || (contact.bodyB.categoryBitMask == enemyBomberCategory))) ||
        (((contact.bodyA.categoryBitMask == enemyBomberCategory) || (contact.bodyA.categoryBitMask == enemyAirplaneCategory)) && (contact.bodyB.categoryBitMask == userAirplaneFiringRangeCategory)))
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
    
    if (((contact.bodyA.categoryBitMask == userMissileRangeCategory) || (contact.bodyB.categoryBitMask == userMissileRangeCategory)))
    {
        
        if (_userAirplane.targetAirplane) {
            // Lock nearest target
            CGFloat distanceToNewTarget = 0;
            CGFloat distanceToCurrentTarget = distanceBetweenPoint(_userAirplane.position, _userAirplane.targetAirplane.position);
            
            if (contact.bodyA.categoryBitMask == userMissileRangeCategory) {
                distanceToNewTarget = distanceBetweenPoint(_userAirplane.position, secondNode.position);
            } else {
                distanceToNewTarget = distanceBetweenPoint(_userAirplane.position, firstNode.position);
            }
            
            if (distanceToCurrentTarget < distanceToNewTarget) {
                return;
            }
        }
        
        if (contact.bodyA.categoryBitMask == userMissileRangeCategory && [secondNode isKindOfClass:[PPSpriteNode class]]) {
            [(PPSpriteNode *)secondNode startLockOnAnimation];
            [_userAirplane setTargetAirplane:(PPSpriteNode *)secondNode];
        } else if ([firstNode isKindOfClass:[PPSpriteNode class]]){
            [(PPSpriteNode *)firstNode startLockOnAnimation];
            [_userAirplane setTargetAirplane:(PPSpriteNode *)firstNode];
        }
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    // 1
    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    if (((contact.bodyA.categoryBitMask == userAirplaneFiringRangeCategory) && ((contact.bodyB.categoryBitMask == enemyAirplaneCategory) || (contact.bodyB.categoryBitMask == enemyBomberCategory))) ||
        (((contact.bodyA.categoryBitMask == enemyAirplaneCategory) || (contact.bodyA.categoryBitMask == enemyBomberCategory)) && (contact.bodyB.categoryBitMask == userAirplaneFiringRangeCategory)))
    {
        [_userAirplane stopFiring];
    }
    
    if ((contact.bodyA.categoryBitMask == enemyAirplaneFiringRangeCategory) && (contact.bodyB.categoryBitMask == userAirplaneCategory)) {
        [(PPHunterAirplane *)firstNode.parent stopFiring];
    }
    
    if ((contact.bodyA.categoryBitMask == userAirplaneCategory) && (contact.bodyB.categoryBitMask == enemyAirplaneFiringRangeCategory)) {
        [(PPHunterAirplane *)secondNode.parent stopFiring];
    }
    
    if (((contact.bodyA.categoryBitMask == mainBaseCategory) && (contact.bodyB.categoryBitMask == mainBaseCategory)) ||
        ((contact.bodyA.categoryBitMask == enemyBomberCategory) && (contact.bodyB.categoryBitMask == mainBaseCategory)))
    {
        //add explosion
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
        explosion.zPosition = 1;
        explosion.scale = 0.3;
        explosion.position = contact.bodyA.node.position;
        
        [self addChild:explosion];
        
        SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.3];
        SKAction *remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
    }
    
    
    if (((contact.bodyA.categoryBitMask == userMissileRangeCategory) || (contact.bodyB.categoryBitMask == userMissileRangeCategory)))
    {
        if (contact.bodyA.categoryBitMask == userMissileRangeCategory && [secondNode isKindOfClass:[PPSpriteNode class]]) {
            [(PPSpriteNode *)secondNode removeLockOn];
            [_userAirplane setTargetAirplane:nil];
        } else if ([firstNode isKindOfClass:[PPSpriteNode class]]) {
            [(PPSpriteNode *)firstNode removeLockOn];
            [_userAirplane setTargetAirplane:nil];
        }
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

- (void)addClouds {

    CGFloat whichCloud = getRandomNumberBetween(0, 3);
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[_cloudsTextures objectAtIndex:whichCloud]];
    CGFloat randomYAxix = getRandomNumberBetween(0, self.size.height);
    cloud.position = CGPointMake(_screenRect.size.height+cloud.size.height/2, randomYAxix);
    cloud.zPosition = 1;
    CGFloat randomTimeCloud = getRandomNumberBetween(9, 19);
    
    SKAction *move =[SKAction moveTo:CGPointMake(0-cloud.size.height, randomYAxix) duration:randomTimeCloud];
    SKAction *remove = [SKAction removeFromParent];
    [cloud runAction:[SKAction sequence:@[move,remove]]];
    [self addChild:cloud];
}

- (void)addEnemyMissile {
    PPMissile *missile = [[PPMissile alloc] initMissileNode];
    missile.position = CGPointMake(getRandomNumberBetween(0, self.size.width), getRandomNumberBetween(0, self.size.height));
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
    
    enemyAirplane.position = CGPointMake(getRandomNumberBetween(0, self.size.width), getRandomNumberBetween(0, self.size.height));
    enemyAirplane.scale = 0.15;
    enemyAirplane.targetAirplane = _userAirplane;
    
    enemyAirplane.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemyAirplane.size.width * 0.5]; // 1
    enemyAirplane.physicsBody.dynamic = YES; // 2
    enemyAirplane.physicsBody.categoryBitMask = enemyAirplaneCategory; // 3
    enemyAirplane.physicsBody.contactTestBitMask = projectileCategory | userAirplaneFiringRangeCategory | missileCategory; // 4
    enemyAirplane.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:enemyAirplane];
    
    //[enemyAirplane startLockOnAnimation];
    
    [enemyAirplane updateOrientationVector];
    [_arrayOfEnemyHunterAirplanes addObject:enemyAirplane];
}

- (void)addEnemyBomberAtRandomLocation {
    PPBomber *enemyBomberAirplane = [[PPBomber alloc] initBomber];
    
    enemyBomberAirplane.position = CGPointMake(getRandomNumberBetween(0, self.size.width), getRandomNumberBetween(0, self.size.height));
    enemyBomberAirplane.scale = 0.25;
    enemyBomberAirplane.mainAirplane = _userAirplane;
    enemyBomberAirplane.mainBase = _mainBase;
    
    enemyBomberAirplane.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemyBomberAirplane.size.width * 0.5]; // 1
    enemyBomberAirplane.physicsBody.dynamic = YES; // 2
    enemyBomberAirplane.physicsBody.categoryBitMask = enemyBomberCategory; // 3
    enemyBomberAirplane.physicsBody.contactTestBitMask = mainBaseCategory | projectileCategory | userAirplaneFiringRangeCategory | missileCategory; // 4
    enemyBomberAirplane.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:enemyBomberAirplane];
    
    //[enemyBomberAirplane startLockOnAnimation];
    
    [enemyBomberAirplane updateOrientationVector];
    [_arrayOfEnemyBombers addObject:enemyBomberAirplane];
}

- (void)pauseGame {
    _gameIsPaused = !_gameIsPaused;
    
    if (!_gameIsPaused) {
        _pauseButton.normalTexture = [SKTexture textureWithImageNamed:@"pause.png"];
        _pauseButton.selectedTexture = [SKTexture textureWithImageNamed:@"pause.png"];
    } else {
        _pauseButton.normalTexture = [SKTexture textureWithImageNamed:@"play.png"];
        _pauseButton.selectedTexture = [SKTexture textureWithImageNamed:@"play.png"];
    }
}

- (void)launchMissileFromMainAicraft {
    NSLog(@"??????");
    if (_userAirplane.targetAirplane) {
        if (_userAirplane.targetAirplane.isLockedOnByEnemy) {
            NSLog(@"!!!!!!");
            [_userAirplane launchMissileTowardAircraft:_userAirplane.targetAirplane];
        }
    }
//    for (PPSpriteNode *enemyAicraft in _arrayOfEnemyBombers) {
//        if (enemyAicraft.isLockedOnByEnemy) {
//            [_userAirplane launchMissileTowardAircraft:enemyAicraft];
//            return;
//        }
//    }
//    
//    for (PPSpriteNode *enemyAicraft in _arrayOfEnemyHunterAirplanes) {
//        if (enemyAicraft.isLockedOnByEnemy) {
//            [_userAirplane launchMissileTowardAircraft:enemyAicraft];
//            return;
//        }
//    }
}

@end


