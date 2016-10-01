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

@property (nonatomic) CGPoint touchPoint;
//@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGPoint shotVectorUnit;

@property (nonatomic) float ballVelocityX;
@property (nonatomic) float ballVelocityY;

@property (nonatomic) int tiltSpeed;

@property (strong, nonatomic) NSTimer *swipeTimer;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) NSTimer *placeBallTimer;

@property (strong, nonatomic) IBOutlet UIImageView *bgImage;

@property (strong, nonatomic) IBOutlet UIImageView *leftTilt;
@property (strong, nonatomic) IBOutlet UIImageView *rightTilt;
@property (strong, nonatomic) IBOutlet UIImageView *image3;


@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *shotLabel;
@property (strong, nonatomic) IBOutlet UILabel *ngLabel;
@property (strong, nonatomic) IBOutlet UILabel *tiltLabel;


@property (strong, nonatomic) NSMutableArray *overlapArray;





@end
