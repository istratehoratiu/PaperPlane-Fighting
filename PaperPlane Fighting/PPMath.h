//
//  PPMath.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <Foundation/Foundation.h>

CGPoint skPointsAdd(CGPoint startingPosition, CGPoint endPoint);
CGPoint skPointsSubtract(CGPoint startingPosition, CGPoint endPoint);
CGPoint skPointsMultiply(CGPoint startingPosition, CGFloat value);
CGPoint skPointsDivide (CGPoint startingPosition, CGFloat value);
CGPoint normalizeVector (CGPoint vector);
CGPoint getSpriteOrientationForRadians(CGFloat radians);
CGFloat degreesToRadians(CGFloat degrees);
CGFloat radiansToDegrees(CGFloat radians);
BOOL checkIfPointIsToTheLeftOfLineGivenByTwoPoints (CGPoint pointToCheck, CGPoint firstLinePoint, CGPoint secondLinePoint);
CGPoint getIntersectionOfLinesGivenByPoints(CGPoint firstPointOnLine1, CGPoint secondPointOnLine1, CGPoint firstPointOnLine2, CGPoint secondPointOnLine2);