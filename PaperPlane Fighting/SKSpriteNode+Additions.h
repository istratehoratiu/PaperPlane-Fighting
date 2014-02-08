//
//  SKSpriteNode+Additions.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 23/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (Additions)

- (CGVector)getSpriteOrientation;
- (CGMutablePathRef)getPathForSpriteOrientation;
- (CGPoint)getVectorRepresentingTheDirectionOfTheSprite;

@end
