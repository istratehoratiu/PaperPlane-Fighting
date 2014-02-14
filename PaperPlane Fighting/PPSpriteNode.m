//
//  PPSpriteNode.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"
#import "SKSpriteNode+Additions.h"
#import "PPMath.h"

#define SPEED 2
#define ROTATION_SPEED 1.5

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;


@implementation PPSpriteNode

@dynamic targetPoint;
@synthesize spriteFinishedOrientationRotation = _spriteFinishedOrientationRotation;

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    
    if (self) {
        
        SKSpriteNode *_propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1.png"];
        _propeller.scale = 0.2;
        _propeller.position = CGPointMake(self.position.x + 45, self.position.y );
        
        SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1.png"];
        SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2.png"];
        
        SKAction *spin = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:spin];
        [_propeller runAction:spinForever];
        
        [self addChild:_propeller];
    }
    
    return self;
}

- (void)setTargetPoint:(CGPoint)targetPoint {
    _targetPoint = targetPoint;
    _spriteFinishedOrientationRotation = NO;
}

- (CGPoint)targetPoint {
    return _targetPoint;
}

- (void)fireBullet {
    
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"B 2.png"];
    
    projectile.zRotation = self.zRotation;
    projectile.position = self.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width * 0.5];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    // 5 - OK to add now - we've double checked position
    [self.parent addChild:projectile];
    
    CGPoint endPoint;
    CGPoint startingPosition = CGPointMake(0.0, 0.0);
    endPoint.y = sinf(self.zRotation) * (self.size.width * 0.5);
    endPoint.x = cosf(self.zRotation) * (self.size.width * 0.5);
    endPoint = skPointsAdd(startingPosition, endPoint);
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = normalizeVector(endPoint);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = skPointsMultiply(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    //CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    CGVector vectorDir = CGVectorMake(shootAmount.x, shootAmount.y);
    
    // 9 - Create the actions
    float velocity = 30.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveBy:vectorDir duration:realMoveDuration];
    //SKAction * actionMove = [SKAction moveTo:shootAmount duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)updateMove:(CFTimeInterval)dt {

    CGPoint destinationPoint = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = skPointsSubtract(destinationPoint, self.position);
 
    CGPoint targetVector =  normalizeVector(offset);
    // 5
    float POINTS_PER_SECOND = 100;
    CGPoint targetPerSecond = skPointsMultiply(targetVector, POINTS_PER_SECOND);
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    CGPoint actualTarget = skPointsAdd(self.position, skPointsMultiply(targetPerSecond, dt));

    self.position = actualTarget;
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
    if (_spriteFinishedOrientationRotation) {
        return;
    }
    
    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetPoint, lineSource, lineEnd)) {
        
        [self setZRotation:self.zRotation + (ROTATION_SPEED * dt)];
        
        
        CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
        CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
        
        if (!checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetPoint, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation - (ROTATION_SPEED * dt)];
            
            _spriteFinishedOrientationRotation = YES;
            
            self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
            
        } else {
            self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L.png"];
        }
        
        
    } else {
        
        [self setZRotation:self.zRotation - (ROTATION_SPEED * dt)];
        
        if (checkIfPointIsToTheLeftOfLineGivenByTwoPoints(_targetPoint, lineSource, lineEnd)) {
            
            [self setZRotation:self.zRotation + (ROTATION_SPEED * dt)];
            
            _spriteFinishedOrientationRotation = YES;
            
            self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
            
        } else {
            self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R.png"];
        }
    }
}

- (void)updateOrientationVector {
    
    if (!orientationNode) {
        orientationNode = [SKShapeNode node];
        orientationNode.strokeColor = [SKColor yellowColor];
        orientationNode.zPosition = 1;
        // Uncommnet if orientation vectors are needed.
        //[self addChild:orientationNode];
    }
    
    if (!northLineNode) {
        northLineNode = [SKShapeNode node];
        northLineNode.strokeColor = [SKColor blueColor];
        northLineNode.zPosition = 1;
        
        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             0.0,
                             self.size.height);
        northLineNode.path = thePath;
        // Uncommnet if orientation vectors are needed.
        //[self addChild:northLineNode];
    }
    
    if (!spriteOrientationLine) {
        spriteOrientationLine = [SKShapeNode node];
        spriteOrientationLine.strokeColor = [SKColor redColor];
        spriteOrientationLine.zPosition = 1;

        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             self.size.width,
                             0.0);
        spriteOrientationLine.path = thePath;
        // Uncommnet if orientation vectors are needed.
        //[self addChild:spriteOrientationLine];
    }
    
    orientationNode.path = [self getPathForSpriteOrientation];
    

}


// 1. Calculate the cosine of the angle and multiply this by the distance.
// 2. Calculate the sine of the angle and multiply this by the distance.
- (CGVector)getSpriteOrientationForRadians:(CGFloat)radians {
    return CGVectorMake(cosf(radians), sinf(radians));
}


@end
