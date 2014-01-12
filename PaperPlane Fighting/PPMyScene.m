//
//  PPMyScene.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMyScene.h"

@implementation PPMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
//        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//        
//        myLabel.text = @"Hello, World!";
//        myLabel.fontSize = 30;
//        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                       CGRectGetMidY(self.frame));
//        
//        [self addChild:myLabel];
        
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        sprite.size = CGSizeMake(100.0, 100.0);
        sprite.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        
        [self addChild:sprite];
        
        fireBulletsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fireBulletsButton.frame = CGRectMake(500.0, 500.0, 200.0, 100);
        fireBulletsButton.backgroundColor = [UIColor redColor];
        [fireBulletsButton setTitle:@"Fire!!!!" forState:UIControlStateNormal | UIControlStateHighlighted];
        [fireBulletsButton addTarget:self action:@selector(fireButtonPreset:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:fireBulletsButton];
    }
    return self;
}
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    /* Called when a touch begins */
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
//}
//
//
- (void)fireButtonPreset:(id)sender {
    NSLog(@">>>>>>>>>> FIRE <<<<<<<<");
}

-(void)update:(CFTimeInterval)currentTime {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, positionInScene.x, positionInScene.y);
    
    lineNode = [SKShapeNode node];
    lineNode.path = pathToDraw;
    lineNode.strokeColor = [SKColor redColor];
    lineNode.zPosition = -1;
    [self addChild:lineNode];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    CGPathAddLineToPoint(pathToDraw, NULL, positionInScene.x, positionInScene.y);
    lineNode.path = pathToDraw;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // delete the following line if you want the line to remain on screen.
    SKAction *action = [SKAction followPath:pathToDraw asOffset:NO orientToPath:YES duration:3];
    
    
    [sprite runAction:action completion:^(){
        [lineNode removeFromParent];
        CGPathRelease(pathToDraw);
    }];
}
@end
