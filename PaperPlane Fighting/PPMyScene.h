//
//  PPMyScene.h
//  PaperPlane Fighting
//

//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PPMyScene : SKScene {
    CGMutablePathRef pathToDraw;
    SKShapeNode *lineNode;
    SKSpriteNode *sprite;
}

@end
