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

static const uint32_t projectileCategory                =  0;
static const uint32_t enemyProjectileCategory           =  6;
static const uint32_t enemyAirplaneCategory             =  1;
static const uint32_t userAirplaneFiringRangeCategory   =  2;
static const uint32_t enemyAirplaneFiringRangeCategory  =  3;
static const uint32_t userAirplaneCategory              =  4;
static const uint32_t missileCategory                   =  5;

extern CGFloat kPPSpeedOfHunterAirplane;
extern CGFloat kPPRotationSpeedOfHunterAirplane;
extern CGFloat kPPRateOfFireForMainAirplane;

typedef enum {
    kPPTurnLeft,
    kPPTurnRight,
    kPPFlyStraight
} PPFlightDirection;