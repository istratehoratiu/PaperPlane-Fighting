//
//  SKShapeNode+SKShapeNode_Additions.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 23/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "SKShapeNode+Additions.h"

@implementation SKShapeNode (SKShapeNode_Additions)

- (void)drawCircleAtPoint:(CGPoint)circleCenter withRadius:(CGFloat)radius {
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathAddArc(thePath, NULL, circleCenter.x, circleCenter.y, radius, 0.f, (360* M_PI)/180, NO);
    CGPathCloseSubpath(thePath);
    self.path = thePath;
    CGPathRelease(thePath);
}

@end
