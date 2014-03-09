//
//  PPBomber.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 09/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPBomber.h"

@implementation PPBomber

- (id)initMainAirplane {
    self = [super initWithImageNamed:@".png"];
    
    if (self) {
        
        self.health = kPPBomberHealth;
        
        return self;
    }
    
    return self;
}

@end
