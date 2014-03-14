//
//  PPSlider.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 11/03/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSlider.h"
#import "PPMainAirplane.h"

@implementation PPSlider

@synthesize mainAriplane = _mainAriplane;
@synthesize desiredSpeedIndicator = _desiredSpeedIndicator;
@synthesize currentSpeedIndicator = _currentSpeedIndicator;
@synthesize speedScaleIndicator = _speedScaleIndicator;

- (id)initSpeedSliderWithFrame:(CGRect)frame {
    
    self = [super initWithColor:[UIColor clearColor] size:frame.size];
    
    if (self) {
        self.position = frame.origin;
        
        //Create sliders
    }
    
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];
        

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];
    
}

@end
