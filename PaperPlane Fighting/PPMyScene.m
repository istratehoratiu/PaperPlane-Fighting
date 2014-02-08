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


#define MAGNITUDE 100.0
// Aceasta valoate trebuie sa ia o valoare de la 0 la 1. 0 fiind cea mai peformanta
#define TURN_ANGLE_PERFORMANCE 1

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

@implementation PPMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        // Main Actor
        sprite = [[PPSpriteNode alloc] initWithImageNamed:@"PLANE 8 N"];
        sprite.scale = 0.2;
        sprite.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        
        [self addChild:sprite];

        // Path To Follow
        pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, sprite.position.x, sprite.position.y);
        
        bezierPath = [SKShapeNode node];
        bezierPath.path = pathToDraw;
        bezierPath.strokeColor = [SKColor redColor];
        bezierPath.zPosition = -1;
        [self addChild:bezierPath];
        
        // Control Point 1.
        controlPointPath1 = CGPathCreateMutable();
        CGPathMoveToPoint(controlPointPath1, NULL, sprite.position.x, sprite.position.y);
        
        controlPoint1 = [SKShapeNode node];
        controlPoint1.path = pathToDraw;
        controlPoint1.strokeColor = [SKColor greenColor];
        controlPoint1.zPosition = -1;
        [self addChild:controlPoint1];
        
        // Control Point 2.
        controlPointPath2 = CGPathCreateMutable();
        CGPathMoveToPoint(controlPointPath2, NULL, sprite.position.x, sprite.position.y);
        
        controlPoint2 = [SKShapeNode node];
        controlPoint2.path = pathToDraw;
        controlPoint2.strokeColor = [SKColor blueColor];
        controlPoint2.zPosition = -1;
        [self addChild:controlPoint2];
        
        [sprite updateOrientationVector];
        
        SKButtonNode *backButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"buttonNormal" selected:@"buttonSelected"];
        [backButton setPosition:CGPointMake(100, 100)];
        [backButton.title setText:@"Button"];
        [backButton.title setFontName:@"Chalkduster"];
        [backButton.title setFontSize:20.0];
        [backButton setTouchUpInsideTarget:sprite action:@selector(fireBullet)];
        [self addChild:backButton];
        
        //schedule enemies
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *callEnemies = [SKAction runBlock:^{
            [self EnemiesAndClouds];
        }];
        
        SKAction *updateEnimies = [SKAction sequence:@[wait,callEnemies]];
        [self runAction:[SKAction repeatActionForever:updateEnimies]];

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
        
    
    [sprite updateOrientationVector];
    
    [sprite updateMove:_deltaTime];
    
    [sprite updateRotation:_deltaTime];
    
    //NSLog(@">>>>>>>>> %f", [sprite zRotation]);
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    UITouch* touch = [touches anyObject];
//    CGPoint positionInScene = [touch locationInNode:self];
//    
//    CGPathRelease(pathToDraw);
//    
//    pathToDraw = CGPathCreateMutable();
//    CGPathMoveToPoint(pathToDraw, NULL, sprite.position.x, sprite.position.y);
//    
//    [self calculateForCGPath:pathToDraw controlPointsGivenStartingPoint:sprite.position andEndPoint:positionInScene];
//
//    bezierPath.path = pathToDraw;
//
//    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
//    
//    [sprite runAction:action completion:^(){
//        [bezierPath removeFromParent];
//        CGPathRelease(pathToDraw);
//    }];
//}

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
        
        CGPoint diff = CGPointMake(location.x - sprite.position.x, location.y - sprite.position.y);
        
        CGFloat angleRadians = atan2f(diff.y, diff.x);
        
        SKAction *rotateToTouch = [SKAction rotateByAngle:angleRadians duration:2];
        //SKAction *rotateToTouch = [SKAction rotateToAngle:angleRadians duration:2 shortestUnitArc:YES];
        
        [sprite setTargetPoint:location];
        
        //[sprite runAction:rotateToTouch];
        //-----------------------------------//
//        CGPoint locationOfPlane = [sprite position];
//        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"B 2.png"];
//        
//        bullet.position = CGPointMake(locationOfPlane.x,locationOfPlane.y+sprite.size.height/2);
//        //bullet.position = location;
//        bullet.zPosition = 1;
//        bullet.scale = 0.8;
//        
//        SKAction *action = [SKAction moveToY:self.frame.size.height+bullet.size.height duration:2];
//        SKAction *remove = [SKAction removeFromParent];
//        
//        [bullet runAction:[SKAction sequence:@[action,remove]]];
//        
//        [self addChild:bullet];
        // 3- Determine offset of location to projectile
    }
}

//- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
//
//    CGPathRelease(pathToDraw);
//    
//    pathToDraw = CGPathCreateMutable();
//    CGPathMoveToPoint(pathToDraw, NULL, sprite.position.x, sprite.position.y);
//    
//    UITouch* touch = [touches anyObject];
//    CGPoint positionInScene = [touch locationInNode:self];
//    
//    [self calculateForCGPath:pathToDraw controlPointsGivenStartingPoint:sprite.position andEndPoint:positionInScene];
//
//    bezierPath.path = pathToDraw;
//    
//    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
//    
//    
//    [sprite removeAllActions];
//    
//    [sprite runAction:action completion:^(){
//        [bezierPath removeFromParent];
//        CGPathRelease(pathToDraw);
//    }];
//}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
//    
//    [sprite runAction:action completion:^(){
//        [lineNode removeFromParent];
//        CGPathRelease(pathToDraw);
//    }];
//}

// In order to detect where the touch is in regard to the airpane.
// Subsract the touch vector from the airplane vector.
// the following vector will have the following +- sign.
/* Aiplane is in the middle.
     |
  -+ | ++
------------
  -- | +-
     |
 */

- (void)calculateForCGPath:(CGMutablePathRef)cgPath controlPointsGivenStartingPoint:(CGPoint)startingPoint andEndPoint:(CGPoint) endPoint {
    CGPoint firstPoint1 = CGPointZero;
    CGPoint firstPoint2 = CGPointZero;
    
    CGPoint differenceVector = [self skPointsSubtract:endPoint andVector:startingPoint];
    
    if (differenceVector.x > 0 && differenceVector.y > 0) {
        firstPoint1 = CGPointMake(startingPoint.x + (differenceVector.x * 0.25) - 50, startingPoint.y + (differenceVector.y * 0.25));
        firstPoint2 = CGPointMake(startingPoint.x + (differenceVector.x * 0.75) - 50, startingPoint.y + (differenceVector.y * 0.75));
    } else if (differenceVector.x < 0 && differenceVector.y > 0) {
        firstPoint1 = CGPointMake(startingPoint.x + (differenceVector.x * 0.25) - 50, startingPoint.y + (differenceVector.y * 0.25));
        firstPoint2 = CGPointMake(startingPoint.x + (differenceVector.x * 0.75) - 50, startingPoint.y + (differenceVector.y * 0.75));
    }
    
    [controlPoint2 drawCircleAtPoint:firstPoint1 withRadius:10];
    [controlPoint1 drawCircleAtPoint:firstPoint2 withRadius:10];
    
    CGPathAddCurveToPoint(cgPath, NULL, firstPoint1.x, firstPoint1.y, firstPoint2.x, firstPoint2.y, endPoint.x, endPoint.y);
    
}

- (CGPoint)calculateControlPoint2GivenStartingPoint:(CGPoint)startingPoint firstControlPoint:(CGPoint)firstControlPoint andEndPoint:(CGPoint) endPoint {
    CGPoint controlPoint = CGPointZero;
    
    return controlPoint;
}

- (CGPoint)skPointsAdd:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x + endPoint.x, startingPosition.y + endPoint.y);
}

- (CGPoint)skPointsSubtract:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x - endPoint.x, startingPosition.y - endPoint.y);
}

- (CGPoint)skPointsMultiply:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x * endPoint.x, startingPosition.y * endPoint.y);
}

- (CGPoint)skPointsDivide:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x / endPoint.x, startingPosition.y / endPoint.y);
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
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 1 N.png"];
        else
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 2 N.png"];
        
        
        enemy.scale = 0.2;
        
        enemy.position = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
        enemy.zPosition = 1;
        
        
        CGMutablePathRef cgpath = CGPathCreateMutable();
        
        //random values
        float xStart = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float xEnd = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        
        //ControlPoint1
        float cp1X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float cp1Y = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.height ];
        
        //ControlPoint2
        float cp2X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float cp2Y = [self getRandomNumberBetween:0 to:cp1Y];
        
        CGPoint s = CGPointMake(xStart, 1024.0);
        CGPoint e = CGPointMake(xEnd, -100.0);
        CGPoint cp1 = CGPointMake(cp1X, cp1Y);
        CGPoint cp2 = CGPointMake(cp2X, cp2Y);
        CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:5];
        
        
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


