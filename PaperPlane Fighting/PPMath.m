//
//  PPMath.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPMath.h"

//CGPoint skPointsAdd(CGPoint startingPosition, CGPoint endPoint) {
//    return CGPointMake(startingPosition.x + endPoint.x, startingPosition.y + endPoint.y);
//}
//
//CGPoint skPointsSubtract(CGPoint startingPosition, CGPoint endPoint) {
//    return CGPointMake(startingPosition.x - endPoint.x, startingPosition.y - endPoint.y);
//}
//
//- (CGPoint)skPointsMultiply:(CGPoint)startingPosition andValue:(CGFloat)value {
//    return CGPointMake(startingPosition.x * value, startingPosition.y * value);
//}
//
//- (CGPoint)skPointsDivide:(CGPoint)startingPosition andValue:(CGFloat)value {
//    return CGPointMake(startingPosition.x / value, startingPosition.y / value);
//}
//
//- (CGVector)normalizeVector:(CGVector)vector {
//    CGFLoat magnitudine = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
//    return CGVectorMake(vector.x / magnitude, vector.y / magnitude);
//}
//// 1. Calculate the cosine of the angle and multiply this by the distance.
//// 2. Calculate the sine of the angle and multiply this by the distance.
//CGVector getSpriteOrientationForRadians(CGFloat radians) {
//    return CGVectorMake(cosf(radians), sinf(radians));
//}
//
//CGFloat degreesToRadians(CGFloat degrees) {
//    return degrees * (M_PI * 180.0f);
//}
//
//CGFloat radiansToDegrees(CGFloat radians) {
//    return radians * (180.0f / M_PI);
//}