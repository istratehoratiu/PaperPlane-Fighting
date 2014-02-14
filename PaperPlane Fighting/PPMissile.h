//
//  PPMissile.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"

@interface PPMissile : PPSpriteNode {
    SKSpriteNode *_smokeTrail;
}

@property (nonatomic, retain) SKSpriteNode *smokeTrail;

- (id)initMissileNode;

@end
