//
//  PPMyScene.h
//  PaperPlane Fighting
//

//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PPSpriteNode;

@interface PPMyScene : SKScene {
    
    PPSpriteNode *_userAirplane;
    
    CFTimeInterval _lastUpdateTime;
    CFTimeInterval _deltaTime;
    
    CGRect _screenRect;
    CGFloat _screenHeight;
    CGFloat _screenWidth;
}

@property (nonatomic, retain) PPSpriteNode *userAirplane;
@property (nonatomic, assign) CGRect screenRect;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CFTimeInterval lastUpdateTime;
@property (nonatomic, assign) CFTimeInterval deltaTime;

@end
