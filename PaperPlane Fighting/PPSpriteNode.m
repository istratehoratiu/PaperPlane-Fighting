//
//  PPSpriteNode.m
//  PaperPlane Fighting
//
//  Created by Horatiu Istrate on 24/01/14.
//  Copyright (c) 2014 Horatiu Istrate. All rights reserved.
//

#import "PPSpriteNode.h"
#import "SKSpriteNode+Additions.h"

#define SPEED 10
#define ROTATION_SPEED 0.9

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

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
    
    //CGPoint location = [self.parent convertPoint:CGPointMake(self.size.width * 0.5, self.size.height * 0.5) fromNode:self];
    CGPoint offset = rwSub([self.parent convertPoint:CGPointMake(self.size.width * 0.5, self.size.height * 0.5) fromNode:self], projectile.position);
    
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
    endPoint = [self skPointsAdd:startingPosition andVector:endPoint];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(endPoint);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    //CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    CGVector vectorDir = CGVectorMake(shootAmount.x, shootAmount.y);
    
    // 9 - Create the actions
    float velocity = 80.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveBy:vectorDir duration:realMoveDuration];
    //SKAction * actionMove = [SKAction moveTo:shootAmount duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)updateMove:(CFTimeInterval)dt {

    CGPoint destinationPoint = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    CGPoint offset = [self skPointsSubtract:destinationPoint andVector:self.position];
 
    CGPoint targetVector =     [self normalizeVector:offset];
    // 5
    float POINTS_PER_SECOND = 100;
    CGPoint targetPerSecond = [self skPointsMultiply:targetVector andValue:POINTS_PER_SECOND];
    // 6
    //CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    CGPoint actualTarget = [self skPointsAdd:self.position andVector:[self skPointsMultiply:targetPerSecond andValue:dt]];

    self.position = actualTarget;
    
}

- (void)updateRotation:(CFTimeInterval)dt {
    
    if (_spriteFinishedOrientationRotation) {
        return;
    }
    
    CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
    CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
    
    if ([self checkIfPoint:_targetPoint isToTheLeftOfLineGivenByThePoint:lineSource andPoint:lineEnd]) {
        
        [self setZRotation:self.zRotation + (ROTATION_SPEED * dt)];
        
        
        CGPoint lineSource = [self.parent convertPoint:CGPointMake(0, 0) fromNode:self];
        CGPoint lineEnd = [self.parent convertPoint:CGPointMake(self.size.width, 0) fromNode:self];
        
        if (![self checkIfPoint:_targetPoint isToTheLeftOfLineGivenByThePoint:lineSource andPoint:lineEnd]) {
            
            [self setZRotation:self.zRotation - (ROTATION_SPEED * dt)];
            
            _spriteFinishedOrientationRotation = YES;
            
            self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
            
        } else {
            self.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L.png"];
        }
        
        
    } else {
        
        [self setZRotation:self.zRotation - (ROTATION_SPEED * dt)];
        
        if ([self checkIfPoint:_targetPoint isToTheLeftOfLineGivenByThePoint:lineSource andPoint:lineEnd]) {
            
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
        //[self addChild:orientationNode];
    }
    
    if (!northLineNode) {
        northLineNode = [SKShapeNode node];
        northLineNode.strokeColor = [SKColor blueColor];
        northLineNode.zPosition = 1;
        
        CGPoint startingPosition = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             0.0,
                             self.size.height);
        northLineNode.path = thePath;
        
        //[self addChild:northLineNode];
    }
    
    if (!spriteOrientationLine) {
        spriteOrientationLine = [SKShapeNode node];
        spriteOrientationLine.strokeColor = [SKColor redColor];
        spriteOrientationLine.zPosition = 1;
        
        CGPoint startingPosition = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        // Create new path that will contain the final coordinates.
        CGMutablePathRef thePath = CGPathCreateMutable();
        // Set the starting position of the direction vector to be the center of the sprite.
        CGPathMoveToPoint(thePath, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(thePath,
                             NULL,
                             self.size.width,
                             0.0);
        spriteOrientationLine.path = thePath;
        
        //[self addChild:spriteOrientationLine];
    }
    
    orientationNode.path = [self getPathForSpriteOrientation];
    

}

- (CGPoint)calculateControlPoint2GivenStartingPoint:(CGPoint)startingPoint firstControlPoint:(CGPoint)firstControlPoint andEndPoint:(CGPoint) endPoint {
    CGPoint controlPoint = CGPointZero;
    
    return controlPoint;
}

- (BOOL)checkIfPoint:(CGPoint)pointToCheck isToTheLeftOfLineGivenByThePoint:(CGPoint)firstLinePoint andPoint:(CGPoint)secondLinePoint {
    return ((secondLinePoint.x - firstLinePoint.x)*(pointToCheck.y - firstLinePoint.y) - (secondLinePoint.y - firstLinePoint.y)*(pointToCheck.x - firstLinePoint.x)) > 0;
}

- (CGPoint)skPointsAdd:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x + endPoint.x, startingPosition.y + endPoint.y);
}

- (CGPoint)skPointsSubtract:(CGPoint)startingPosition andVector:(CGPoint)endPoint {
    return CGPointMake(startingPosition.x - endPoint.x, startingPosition.y - endPoint.y);
}

- (CGPoint)skPointsMultiply:(CGPoint)startingPosition andValue:(CGFloat)value {
    return CGPointMake(startingPosition.x * value, startingPosition.y * value);
}

- (CGPoint)skPointsDivide:(CGPoint)startingPosition andValue:(CGFloat)value {
    return CGPointMake(startingPosition.x / value, startingPosition.y / value);
}

// 1. Calculate the cosine of the angle and multiply this by the distance.
// 2. Calculate the sine of the angle and multiply this by the distance.
- (CGVector)getSpriteOrientationForRadians:(CGFloat)radians {
    return CGVectorMake(cosf(radians), sinf(radians));
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * (M_PI * 180.0f);
}

- (CGFloat)radiansToDegrees:(CGFloat)radians {
    return radians * (180.0f / M_PI);
}

- (CGPoint)normalizeVector:(CGPoint)vector {
    CGFloat magnitude = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    return CGPointMake(vector.x / magnitude, vector.y / magnitude);
}

@end
