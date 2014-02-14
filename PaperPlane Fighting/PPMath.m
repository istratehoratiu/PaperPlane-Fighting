//
//  PPMath.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMath.h"

CGPoint skPointsAdd(CGPoint startingPosition, CGPoint endPoint) {
    return CGPointMake(startingPosition.x + endPoint.x, startingPosition.y + endPoint.y);
}

CGPoint skPointsSubtract(CGPoint startingPosition, CGPoint endPoint) {
    return CGPointMake(startingPosition.x - endPoint.x, startingPosition.y - endPoint.y);
}

CGPoint skPointsMultiply(CGPoint startingPosition, CGFloat value) {
    return CGPointMake(startingPosition.x * value, startingPosition.y * value);
}

CGPoint skPointsDivide(CGPoint startingPosition, CGFloat value) {
    return CGPointMake(startingPosition.x / value, startingPosition.y / value);
}

CGPoint normalizeVector(CGPoint vector) {
    // Magnitude == Length of Vector.
    CGFloat magnitudine = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    return CGPointMake(vector.x / magnitudine, vector.y / magnitudine);
}
// 1. Calculate the cosine of the angle and multiply this by the distance.
// 2. Calculate the sine of the angle and multiply this by the distance.
// Get the orietntation of a sprite in vector format, knowing the radians.
CGPoint getSpriteOrientationForRadians(CGFloat radians) {
    return CGPointMake(cosf(radians), sinf(radians));
}

CGFloat degreesToRadians(CGFloat degrees) {
    return degrees * (M_PI * 180.0f);
}

CGFloat radiansToDegrees(CGFloat radians) {
    return radians * (180.0f / M_PI);
}

BOOL checkIfPointIsToTheLeftOfLineGivenByTwoPoints (CGPoint pointToCheck, CGPoint firstLinePoint, CGPoint secondLinePoint) {
    return ((secondLinePoint.x - firstLinePoint.x)*(pointToCheck.y - firstLinePoint.y) - (secondLinePoint.y - firstLinePoint.y)*(pointToCheck.x - firstLinePoint.x)) > 0;
}
