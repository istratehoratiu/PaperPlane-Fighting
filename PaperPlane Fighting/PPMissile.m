//
//  PPMissile.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMissile.h"
#import "SKSpriteNode+Additions.h"
#import "PPMath.h"

@implementation PPMissile

@synthesize smokeTrail = _smokeTrail;

- (id)initMissileNode {
    
    self = [super initWithImageNamed:@"missile.png"];
    
    if (self) {
        
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        _smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        _smokeTrail.position = CGPointMake(0.0, -(self.size.height * 0.5));
        [self addChild:_smokeTrail];
        
    }
    
    return self;
}

@end
