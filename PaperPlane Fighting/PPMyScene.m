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

#define MAGNITUDE 100.0
// Aceasta valoate trebuie sa ia o valoare de la 0 la 1. 0 fiind cea mai peformanta
#define TURN_ANGLE_PERFORMANCE 1

@implementation PPMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // Main Actor
        sprite = [PPSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        sprite.size = CGSizeMake(100.0, 100.0);
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
    }
    return self;
}

- (void)fireButtonPreset:(id)sender {

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
    
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
            
        CGPoint location = [touch locationInNode:self];
        
        CGPoint diff = CGPointMake(location.x - sprite.position.x, location.y - sprite.position.y);
        
        CGFloat angleRadians = atan2f(diff.y, diff.x);
        
        SKAction *rotateToTouch = [SKAction rotateByAngle:angleRadians duration:2];
        //SKAction *rotateToTouch = [SKAction rotateToAngle:angleRadians duration:2 shortestUnitArc:YES];
        
        NSLog(@">>>>>>>>> zRotation:%f --- angleRadians: %f", [sprite zRotation], angleRadians);
        
        [sprite setTargetPoint:location];
        
        //[sprite runAction:rotateToTouch];
        //-----------------------------------//
        CGPoint locationOfPlane = [sprite position];
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"B 2.png"];
        
        bullet.position = CGPointMake(locationOfPlane.x,locationOfPlane.y+sprite.size.height/2);
        //bullet.position = location;
        bullet.zPosition = 1;
        bullet.scale = 0.8;
        
        SKAction *action = [SKAction moveToY:self.frame.size.height+bullet.size.height duration:2];
        SKAction *remove = [SKAction removeFromParent];
        
        [bullet runAction:[SKAction sequence:@[action,remove]]];
        
        [self addChild:bullet];
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

@end


