//
//  PPMissile.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"

@interface PPMissile : PPSpriteNode {
    SKEmitterNode *_smokeTrail;
    // A pointer to the airplane that the missile is targeting.
    PPSpriteNode *_targetAirplane;
}

@property (nonatomic, retain) SKEmitterNode *smokeTrail;
@property (nonatomic, strong) PPSpriteNode *targetAirplane;

- (id)initMissileNode;

@end
