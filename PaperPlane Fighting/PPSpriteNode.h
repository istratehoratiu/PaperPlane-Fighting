//
//  PPSpriteNode.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PPSpriteNode : SKSpriteNode {
    SKShapeNode *orientationNode;
    SKShapeNode *northLineNode;
}
- (void)updateOrientationVector;

@end
