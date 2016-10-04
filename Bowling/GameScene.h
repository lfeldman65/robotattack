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
@property (strong, nonatomic) SKSpriteNode *skullNode;
@property (strong, nonatomic) SKSpriteNode *ballNode;
@property (strong, nonatomic) SKSpriteNode *diamondNode;
@property (strong, nonatomic) SKSpriteNode *obstacleNode;

@property (nonatomic) SKLabelNode *turnNumberLabel;
@property (nonatomic) SKLabelNode *livesLabel;
@property (nonatomic) NSString *skullString;
@property (nonatomic) NSString *obstacleString;
@property (nonatomic) NSString *ballString;
@property (nonatomic) NSString *diamondString;


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
