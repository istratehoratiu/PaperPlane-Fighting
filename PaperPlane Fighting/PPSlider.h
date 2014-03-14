//
//  PPSlider.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 11/03/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PPMainAirplane;
@interface PPSlider : SKSpriteNode {
    SKSpriteNode *_speedScaleIndicator;
    SKSpriteNode *_currentSpeedIndicator;
    SKSpriteNode *_desiredSpeedIndicator;

    PPMainAirplane *_mainAriplane;
}

@property (nonatomic, retain) SKSpriteNode *speedScaleIndicator;
@property (nonatomic, retain) SKSpriteNode *currentSpeedIndicator;
@property (nonatomic, retain) SKSpriteNode *desiredSpeedIndicator;

@property (nonatomic, strong) PPMainAirplane *mainAriplane;

@end
