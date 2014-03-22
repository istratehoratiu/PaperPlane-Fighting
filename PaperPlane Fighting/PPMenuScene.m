//
//  PPMenuScene.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 21/03/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMenuScene.h"
#import "SKButtonNode.h"
#import "PPMyScene.h"
#import "PPHangar.h"


@implementation PPMenuScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        
//        SKButtonNode *missionsButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"" selected:@""];
//        [missionsButton setPosition:CGPointMake(self.size.width * 0.5, self.size.height - 100)];
//        [missionsButton.title setFontName:@"Chalkduster"];
//        [missionsButton.title setFontSize:10.0];
//        [missionsButton.title setText:@"Missions"];
//        [missionsButton setTouchUpInsideTarget:self action:@selector(selectMission)];
//        missionsButton.zPosition = 1000;
//        [self addChild:missionsButton];
        
        SKButtonNode *surviverButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"" selected:@""];
        [surviverButton setPosition:CGPointMake(self.size.width * 0.5, self.size.height - 200)];
        [surviverButton.title setFontName:@"Chalkduster"];
        [surviverButton.title setFontSize:30.0];
        [surviverButton.title setText:@"Survivel"];
        [surviverButton setTouchUpInsideTarget:self action:@selector(startSurviverGame)];
        surviverButton.zPosition = 1000;
        [self addChild:surviverButton];
        
        SKButtonNode *hangerButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"" selected:@""];
        [hangerButton setPosition:CGPointMake(self.size.width * 0.5, self.size.height - 300)];
        [hangerButton.title setFontName:@"Chalkduster"];
        [hangerButton.title setFontSize:30.0];
        [hangerButton.title setText:@"Hangar"];
        [hangerButton setTouchUpInsideTarget:self action:@selector(hangarButton)];
        hangerButton.zPosition = 1000;
        [self addChild:hangerButton];
        
        SKButtonNode *getMedalsButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"" selected:@""];
        [getMedalsButton setPosition:CGPointMake(self.size.width * 0.5, self.size.height - 400)];
        [getMedalsButton.title setFontName:@"Chalkduster"];
        [getMedalsButton.title setFontSize:30.0];
        [getMedalsButton.title setText:@"Get Medals"];
        [getMedalsButton setTouchUpInsideTarget:self action:@selector(getMedalsButton)];
        getMedalsButton.zPosition = 1000;
        [self addChild:getMedalsButton];
        
        SKButtonNode *soundOrMuteButton = [[SKButtonNode alloc] initWithImageNamedNormal:@"soundOn.png" selected:@"soundOn.png"];
        [soundOrMuteButton setPosition:CGPointMake(self.size.width * 0.5, self.size.height - 500)];
        [soundOrMuteButton.title setFontName:@"Chalkduster"];
        [soundOrMuteButton.title setFontSize:10.0];
        [soundOrMuteButton.title setText:@""];
        [soundOrMuteButton setTouchUpInsideTarget:self action:@selector(soundButton)];
        soundOrMuteButton.zPosition = 1000;
        [self addChild:soundOrMuteButton];
    }
    
    return self;
}


#pragma mark - 
#pragma mark Button methods

- (void)startSurviverGame {
    SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0]; //[SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    PPMyScene *newScene = [[PPMyScene alloc] initWithSize:self.size];
    //  Optionally, insert code to configure the new scene.
    [self.scene.view presentScene: newScene transition: reveal];
}

- (void)getMedalsButton {

}

- (void)soundButton {

}

- (void)hangarButton {
    SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0]; //[SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    PPHangar *newScene = [[PPHangar alloc] initWithSize:self.size];
    //  Optionally, insert code to configure the new scene.
    [self.scene.view presentScene: newScene transition: reveal];
}

//SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
//GameConfigScene *newScene = [[GameConfigScene alloc] initWithSize: CGSizeMake(1024,768)]];
////  Optionally, insert code to configure the new scene.
//[self.scene.view presentScene: newScene transition: reveal];
@end
