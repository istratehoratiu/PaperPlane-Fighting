//
//  PPMyScene.h
//  PaperPlane Fighting
//

//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PPSpriteNode;
@class PPMainAirplane;
@class PPMainBase;
@class PPHunterAirplane;


@interface PPMyScene : SKScene {
    
    PPMainAirplane *_userAirplane;
    PPMainBase *_mainBase;
    PPHunterAirplane *_hunterAirplane;
    
    CFTimeInterval _lastUpdateTime;
    CFTimeInterval _deltaTime;
    
    CGRect _screenRect;
    CGFloat _screenHeight;
    CGFloat _screenWidth;
    
    NSMutableArray *_arrayOfCurrentMissilesOnScreen;
}

@property (nonatomic, retain) PPHunterAirplane *hunterAirplane;
@property (nonatomic, retain) PPMainAirplane *userAirplane;
@property (nonatomic, retain) PPMainBase *mainBase;
@property (nonatomic, assign) CGRect screenRect;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CFTimeInterval lastUpdateTime;
@property (nonatomic, assign) CFTimeInterval deltaTime;
@property (nonatomic, retain) NSMutableArray *arrayOfCurrentMissilesOnScreen;
@property SKEmitterNode *smokeTrail;

@end
