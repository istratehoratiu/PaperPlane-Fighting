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


#define MAGNITUDE 100.0
// Aceasta valoate trebuie sa ia o valoare de la 0 la 1. 0 fiind cea mai peformanta
#define TURN_ANGLE_PERFORMANCE 1

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

@implementation PPMyScene


@synthesize arrayOfCurrentMissilesOnScreen = _arrayOfCurrentMissilesOnScreen;

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
        _userAirplane = [[PPMainAirplane alloc] initWithImageNamed:@"PLANE 8 N"];
        _userAirplane.scale = 0.2;
        _userAirplane.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        
        [self addChild:_userAirplane];
        
        [_userAirplane updateOrientationVector];
        
        SKButtonNode *backButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"buttonNormal" selected:@"buttonSelected"];
        [backButton setPosition:CGPointMake(100, 100)];
        [backButton.title setText:@"Button"];
        [backButton.title setFontName:@"Chalkduster"];
        [backButton.title setFontSize:20.0];
        [backButton setTouchUpInsideTarget:_userAirplane action:@selector(fireBullet)];
        [self addChild:backButton];
        
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
        
        //adding the smokeTrail
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        _smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        _smokeTrail.position = CGPointMake(_screenWidth/2, 15);
        _smokeTrail.targetNode = self;
        [self addChild:_smokeTrail];
        
        

        
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
    
    
    for (PPSpriteNode *missile in _arrayOfCurrentMissilesOnScreen) {
        [missile updateMove:_deltaTime];
        [missile updateRotation:_deltaTime];
    }
    
    _smokeTrail.position = CGPointMake(_userAirplane.position.x ,_userAirplane.position.y-(_userAirplane.size.height/2));
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {

    [projectile removeFromParent];
    [monster removeFromParent];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
            
        CGPoint location = [touch locationInNode:self];
        
        [_userAirplane setTargetPoint:location];
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

-(void)EnemiesAndClouds{
    //not always come
    int GoOrNot = [self getRandomNumberBetween:0 to:1];
    
    if(GoOrNot == 1){
        
        SKSpriteNode *enemy;
        
        int randomEnemy = [self getRandomNumberBetween:0 to:1];
        if(randomEnemy == 0)
            enemy = [[PPMissile alloc] initMissileNode];
        else
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 2 N.png"];
        
        
        enemy.scale = 0.2;
        
        enemy.position = CGPointMake(_screenRect.size.width/2, _screenRect.size.height/2);
        enemy.zPosition = 1;
        
        
        CGMutablePathRef cgpath = CGPathCreateMutable();
        
        //random values
        float xStart = [self getRandomNumberBetween:0+enemy.size.width to:_screenRect.size.width-enemy.size.width ];
        float xEnd = [self getRandomNumberBetween:0+enemy.size.width to:_screenRect.size.width-enemy.size.width ];
        
        //ControlPoint1
        float cp1X = [self getRandomNumberBetween:0+enemy.size.width to:_screenRect.size.width-enemy.size.width ];
        float cp1Y = [self getRandomNumberBetween:0+enemy.size.width to:_screenRect.size.width-enemy.size.height ];
        
        //ControlPoint2
        float cp2X = [self getRandomNumberBetween:0+enemy.size.width to:_screenRect.size.width-enemy.size.width ];
        float cp2Y = [self getRandomNumberBetween:0 to:cp1Y];
        
        CGPoint s = CGPointMake(xStart, 1024.0);
        CGPoint e = CGPointMake(xEnd, -100.0);
        CGPoint cp1 = CGPointMake(cp1X, cp1Y);
        CGPoint cp2 = CGPointMake(cp2X, cp2Y);
        CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:26];
        
        
        enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemy.size.width * 0.5]; // 1
        enemy.physicsBody.dynamic = YES; // 2
        enemy.physicsBody.categoryBitMask = monsterCategory; // 3
        enemy.physicsBody.contactTestBitMask = projectileCategory; // 4
        enemy.physicsBody.collisionBitMask = 0; // 5
        
        [self addChild:enemy];
        
        SKAction *remove = [SKAction removeFromParent];
        [enemy runAction:[SKAction sequence:@[planeDestroy,remove]]];
        
        CGPathRelease(cgpath);
        
    }
    
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

@end


