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
    }
    return self;
}

- (void)fireButtonPreset:(id)sender {

}

-(void)update:(CFTimeInterval)currentTime {
    [sprite updateOrientationVector];
    NSLog(@">>>>>>>>> %f", [sprite zRotation]);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    CGPathRelease(pathToDraw);
    
    pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, sprite.position.x, sprite.position.y);
    
    CGPoint e = CGPointMake(self.view.center.x, self.view.center.y);
    CGPoint cp1 = CGPointMake(self.size.width * 0.5 + MAGNITUDE, 0.0);
    CGPoint cp2 = CGPointMake(e.x + MAGNITUDE, e.y);
    
    [controlPoint2 drawCircleAtPoint:cp2 withRadius:10];
    [controlPoint1 drawCircleAtPoint:cp1 withRadius:10];
    
    CGPathAddCurveToPoint(pathToDraw, NULL, cp1.x, cp1.y, cp2.x, cp2.y, positionInScene.x, positionInScene.y);
    bezierPath.path = pathToDraw;

    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
    
    [sprite runAction:action completion:^(){
        [bezierPath removeFromParent];
        CGPathRelease(pathToDraw);
    }];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {

    CGPathRelease(pathToDraw);
    
    pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, sprite.position.x, sprite.position.y);
    
    UITouch* touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    CGPoint e = CGPointMake(self.view.center.x, self.view.center.y);
    CGPoint cp1 = CGPointMake(self.size.width * 0.5 + MAGNITUDE, 0.0);
    CGPoint cp2 = CGPointMake(e.x + MAGNITUDE, e.y);
    

    [controlPoint2 drawCircleAtPoint:cp2 withRadius:10];
    [controlPoint1 drawCircleAtPoint:cp1 withRadius:10];
    
    CGPathAddCurveToPoint(pathToDraw, NULL, cp1.x, cp1.y, cp2.x, cp2.y, positionInScene.x, positionInScene.y);
    bezierPath.path = pathToDraw;
    
    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
    
    
    [sprite removeAllActions];
    
    [sprite runAction:action completion:^(){
        [bezierPath removeFromParent];
        CGPathRelease(pathToDraw);
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

//    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
//    
//    [sprite runAction:action completion:^(){
//        [lineNode removeFromParent];
//        CGPathRelease(pathToDraw);
//    }];
}
@end
