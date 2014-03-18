//
//  PPConstants.h
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 08/02/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define kPPUserAirplaneHealth 100
#define kPPHunterAirplaneHealth 50
#define kPPBomberHealth 300

static const NSUInteger projectileCategory                =  0;
static const NSUInteger enemyAirplaneCategory             =  1;
static const NSUInteger userAirplaneFiringRangeCategory   =  2;
static const NSUInteger enemyAirplaneFiringRangeCategory  =  3;
static const NSUInteger userAirplaneCategory              =  4;
static const NSUInteger missileCategory                   =  5;
static const NSUInteger enemyProjectileCategory           =  6;
static const NSUInteger enemyMissileCategory              =  7;
static const NSUInteger userMissileRangeCategory          =  8;
static const NSUInteger enemyMissileRangeCategory         =  9;
static const NSUInteger mainBaseCategory                  =  10;
static const NSUInteger enemyBomberCategory               =  11;

extern CGFloat kPPSpeedOfHunterAirplane;
extern CGFloat kPPRotationSpeedOfHunterAirplane;
extern CGFloat kPPRateOfFireForMainAirplane;
extern CGFloat kPPRotationSpeedOfBomber;

typedef enum {
    kPPTurnLeft,
    kPPTurnRight,
    kPPFlyStraight
} PPFlightDirection;