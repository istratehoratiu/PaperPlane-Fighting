//
//  PPHangar.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 22/03/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPHangar.h"

@implementation PPHangar

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"hangarBackground.jpg"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        //CGRectMake(0.0, self.size.height - (self.size.height * 0.25), self.size.width, self.size.height * 0.5)
        _airplaneScrollingStrip = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(self.size.width * 0.5, self.size.height * 0.5)];
        _airplaneScrollingStrip.position = CGPointZero;//center
        [_airplaneScrollingStrip setName:@"background"];
        //[_airplaneScrollingStrip setAnchorPoint:CGPointZero];

        [self addChild:_airplaneScrollingStrip];
        
        // 2) Loading the images
        NSArray *imageNames = @[@"PLANE 8 N.png", @"PLANE 8 N.png", @"PLANE 8 N.png", @"PLANE 8 N.png"];
        for(int i = 0; i < [imageNames count]; ++i) {
            NSString *imageName = [imageNames objectAtIndex:i];
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            //[sprite setName:kAnimalNodeName];

            float offsetFraction = ((float)(i + 1)) / ([imageNames count] + 1);
            [sprite setPosition:CGPointMake(size.width * offsetFraction, size.height / 2)];
            [_airplaneScrollingStrip addChild:sprite];
        }
        
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    for (SKSpriteNode *childSprite in _airplaneScrollingStrip.children) {
        
        CGPoint positionInMainView = [_airplaneScrollingStrip.parent convertPoint:childSprite.position fromNode:_airplaneScrollingStrip];
       
    
        CGFloat distanceFromCenter = self.size.width * 0.5 - positionInMainView.x;
        distanceFromCenter = (distanceFromCenter < 0) ? (distanceFromCenter * -1) : distanceFromCenter;
        
        childSprite.scale = ((self.size.width * 0.5) - distanceFromCenter) / (self.size.width * 0.5) ;
        
        
         NSLog(@">>>> %f %f >>>>>>> %f", positionInMainView.x, positionInMainView.y, (self.size.width * 0.5 - distanceFromCenter) / self.size.width * 0.5);
    }
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        
        touchLocation = [self convertPointFromView:touchLocation];
        
        //[self selectNodeForTouch:touchLocation];
        
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        
        CGPoint newPos = CGPointMake(_airplaneScrollingStrip.position.x + translation.x, _airplaneScrollingStrip.position.y + translation.y);
        [_airplaneScrollingStrip setPosition:CGPointMake(newPos.x, _airplaneScrollingStrip.position.y)];
        
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

            float scrollDuration = 0.2;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            CGPoint pos = [_airplaneScrollingStrip position];
            CGPoint p = mult(velocity, scrollDuration);
            
            CGPoint newPos = CGPointMake(pos.x + p.x, _airplaneScrollingStrip.position.y);
            //newPos = [self boundLayerPos:newPos];
            [_airplaneScrollingStrip removeAllActions];
            
            SKAction *moveTo = [SKAction moveTo:newPos duration:scrollDuration];
            [moveTo setTimingMode:SKActionTimingEaseOut];
            [_airplaneScrollingStrip runAction:moveTo];
    }
}

CGPoint mult(const CGPoint v, const CGFloat s) {
	return CGPointMake(v.x*s, v.y*s);
}

@end
