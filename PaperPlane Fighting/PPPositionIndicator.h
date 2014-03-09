//
//  PPPositionIndicator.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/03/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"

@class PPSpriteNode;

@interface PPPositionIndicator : SKSpriteNode {
    PPSpriteNode *_aircraft;
    SKSpriteNode *_aircraftOrientation;
}

@property (nonatomic, strong) PPSpriteNode *aircraft;
@property (nonatomic, retain) SKSpriteNode *aircraftOrientation;

- (id)initPositionIndicatorForAircraft:(PPSpriteNode *)aircraft;
- (void)updatePositionIndicatorForMainAircraft;

@end
