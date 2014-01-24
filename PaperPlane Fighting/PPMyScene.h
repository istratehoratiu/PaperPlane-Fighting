//
//  PPMyScene.h
//  PaperPlane Fighting
//

//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PPSpriteNode;

@interface PPMyScene : SKScene {
    
    CGMutablePathRef pathToDraw;
    CGMutablePathRef controlPointPath1;
    CGMutablePathRef controlPointPath2;
    
    SKShapeNode* bezierPath;
    SKShapeNode *controlPoint1;
    SKShapeNode *controlPoint2;
    
    PPSpriteNode *sprite;
}

@end
