//
//  GameScene.h
//  Bowling
//

//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property (strong, nonatomic) NSTimer *blockTimer;
@property (strong, nonatomic) NSTimer *superBlockTimer;
@property (strong, nonatomic) SKSpriteNode *paddle;
@property (strong, nonatomic) SKSpriteNode *ball;
@property (strong, nonatomic) SKSpriteNode *block;
@property (strong, nonatomic) SKNode *bottom;
@property (nonatomic) SKLabelNode *blocksHitLabel;
@property (nonatomic) SKLabelNode *livesLabel;
@property (nonatomic) NSString *paddleString;
@property (nonatomic) NSString *blockString;
@property (nonatomic) NSString *superBlockString;
@property (nonatomic) NSString *ballString;



@end
