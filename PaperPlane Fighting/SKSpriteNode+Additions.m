//
//  SKSpriteNode+Additions.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 23/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "SKSpriteNode+Additions.h"
#import "PPMath.h"

#define DISTANCE_FROM_CENTER_OF_SPRITE 50


@implementation SKSpriteNode (Additions)

- (CGVector)getSpriteOrientation {
    return CGVectorMake(cosf(self.zRotation), sinf(self.zRotation));
}

// 3. Add the cosine result to the x-coordinate from the starting point and add the sine result
//to the y-coordinate to get the coordinates for the second point.
- (CGMutablePathRef)getPathForSpriteOrientation {
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
    
    return thePath;
}

- (CGPoint)getVectorRepresentingTheDirectionOfTheSprite {
    
    CGPoint endPoint;
    CGPoint startingPosition = CGPointMake(0.0, 0.0);
    endPoint.x = sinf(self.zRotation) * DISTANCE_FROM_CENTER_OF_SPRITE;
    endPoint.y = cosf(self.zRotation) * DISTANCE_FROM_CENTER_OF_SPRITE;
    endPoint = skPointsAdd(startingPosition, endPoint);
    
    return endPoint;
}

@end
