//
//  SKSpriteNode+Additions.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 23/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "SKSpriteNode+Additions.h"
#define DISTANCE_FROM_CENTER_OF_SPRITE 50


@implementation SKSpriteNode (Additions)

CGPoint skPointsAdd(CGPoint startingPosition, CGPoint endPoint) {
    return CGPointMake(startingPosition.x + endPoint.x, startingPosition.y + endPoint.y);
}

CGPoint skPointsSubtract(CGPoint startingPosition, CGPoint endPoint) {
    return CGPointMake(startingPosition.x - endPoint.x, startingPosition.y - endPoint.y);
}

CGPoint skPointsMultiply(CGPoint startingPosition, CGPoint endPoint) {
    return CGPointMake(startingPosition.x * endPoint.x, startingPosition.y * endPoint.y);
}

CGPoint skPointsDivide(CGPoint startingPosition, CGPoint endPoint) {
    return CGPointMake(startingPosition.x / endPoint.x, startingPosition.y / endPoint.y);
}

// 1. Calculate the cosine of the angle and multiply this by the distance.
// 2. Calculate the sine of the angle and multiply this by the distance.
- (CGVector)getSpriteOrientation {
    return CGVectorMake(cosf(self.zRotation), sinf(self.zRotation));
}


// 3. Add the cosine result to the x-coordinate from the starting point and add the sine result
//to the y-coordinate to get the coordinates for the second point.
- (CGMutablePathRef)getPathForSpriteOrientation {
    // Get Orientation of sprite in Radians
    CGVector orientation = [self getSpriteOrientation];
    // Calculate center of sprite.
    CGPoint startingPosition = CGPointMake(0.0, 0.0);
    // Create new path that will contain the final coordinates.
    CGMutablePathRef thePath = CGPathCreateMutable();
    // Set the starting position of the direction vector to be the center of the sprite.
    CGPathMoveToPoint(thePath, NULL, startingPosition.x, startingPosition.y);
    // Calutate point in the direction of orientation at a distance of DISTANCE_FROM_CENTER_OF_SPRITE
   
    CGPoint endPoint;
    endPoint.x = sinf(self.zRotation) * DISTANCE_FROM_CENTER_OF_SPRITE;
    endPoint.y = cosf(self.zRotation) * DISTANCE_FROM_CENTER_OF_SPRITE;
    endPoint = skPointsAdd(startingPosition, endPoint);
    

    CGPathAddLineToPoint(thePath,
                         NULL,
                         endPoint.x,
                         endPoint.y);
    
    NSLog(@"START X:%f --- Y:%f END X:%f --- Y:%f",
          startingPosition.x,
          startingPosition.y,
          endPoint.x,
          endPoint.y);
    
    return thePath;
}

@end
