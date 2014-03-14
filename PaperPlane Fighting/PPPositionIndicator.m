//
//  PPPositionIndicator.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/03/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPPositionIndicator.h"
#import "PPSpriteNode.h"


@implementation PPPositionIndicator

@synthesize aircraft = _aircraft;
@synthesize aircraftOrientation = _aircraftOrientation;

- (id)initPositionIndicatorForAircraft:(PPSpriteNode *)aircraft {
    self = [super initWithImageNamed:@"positionIndicator.png"];
    
    if (self) {
        
        _aircraft = aircraft;
        
        _aircraftOrientation = [[SKSpriteNode alloc] initWithTexture:_aircraft.texture];
        [_aircraftOrientation setScale:0.2];
        [self addChild:_aircraftOrientation];
    }
    return self;
}


- (void)updatePositionIndicatorForMainAircraft {
    // Check if the airplane is not on the screen, if not on screen add poisiton indicator to same parent.
    // If airplane is on screen check if poisiton indicator is on screen, if this is the case remove the postion indicator.
    if (_aircraft.position.x > 1024) {
        
        //[self setZRotation:1];
        self.position = CGPointMake(1024, _aircraft.position.y);
        self.aircraftOrientation.zRotation = _aircraft.zRotation;
        
        if (!self.parent) {
            [_aircraft.parent addChild:self];
        }
    } else if (_aircraft.position.x < 0) {
        
        //[self setZRotation:2];
        self.position = CGPointMake(0, _aircraft.position.y);
        self.aircraftOrientation.zRotation = _aircraft.zRotation;
        
        if (!self.parent) {
            [_aircraft.parent addChild:self];
        }
    } else if (_aircraft.position.y > 756) {
        

        self.position = CGPointMake(756, _aircraft.position.y);
        self.aircraftOrientation.zRotation = _aircraft.zRotation;
        
        if (!self.parent) {
            [_aircraft.parent addChild:self];
        }
    } else if (_aircraft.position.y < 0) {
        
        self.position = CGPointMake(0, _aircraft.position.y);
        self.aircraftOrientation.zRotation = _aircraft.zRotation;
        
        if (!self.parent) {
            [_aircraft.parent addChild:self];
        }
    } else if (_aircraft.parent == self.parent) {
        [self removeFromParent];
    }
}

@end
