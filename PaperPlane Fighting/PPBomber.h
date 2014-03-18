//
//  PPBomber.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"

@interface PPBomber : PPSpriteNode {
    PPSpriteNode *_mainAirplane;
    PPSpriteNode *_mainBase;
    BOOL _shouldFire;
}

@property (nonatomic, strong) PPSpriteNode *mainAirplane;
@property (nonatomic, strong) PPSpriteNode *mainBase;

- (id)initBomber;

@end
