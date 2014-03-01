//
//  PPHunterAirplane.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"

@interface PPHunterAirplane : PPSpriteNode {
    // A pointer to the airplane that the missile is targeting.
    PPSpriteNode *_targetAirplane;
    BOOL _shouldFire;
}

@property (nonatomic, assign) BOOL shouldFire;
@property (nonatomic, strong) PPSpriteNode *targetAirplane;

- (id)initHunterAirPlane;

@end
