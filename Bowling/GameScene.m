//
//  GameScene.m
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "GameScene.h"
#define blockSpeed -40.0
#define maxSpeed 600
#define speedScale 1.0
#define stopSpeed 10.0

static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";
static NSString* superBlockCategoryName = @"superBlockNode";

static const uint32_t ballCategory  = 0x1 << 0;
static const uint32_t bottomCategory = 0x1 << 1;
static const uint32_t blockCategory = 0x1 << 2;
static const uint32_t paddleCategory = 0x1 << 3;
static const uint32_t superBlockCategory = 0x1 << 4;


@interface GameScene()

@property (nonatomic) BOOL isFingerOnPaddle;

@end

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}


@implementation GameScene

@synthesize paddle;
@synthesize ball;
@synthesize block;
@synthesize bottom;

int blocksHit;
int livesRemaining;
double initBallX;
double initBallY;
bool gameStarted;
bool targetHit;

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        initBallX = 0.5*self.frame.size.width;
        initBallY = 0.1*self.frame.size.height;

        blocksHit = 0;
        livesRemaining = 4;
        gameStarted = false;
        targetHit = false;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            self.paddleString = @"paddleiPad.png";
            self.blockString = @"blockiPad.png";
            self.superBlockString = @"superBlockiPad.png";
            self.ballString = @"balliPad.png";
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
                
                self.paddleString = @"paddleiPadWide.png";
                
            }
            
        }
        else {
            
            self.paddleString = @"paddleiPhone.png";
            self.blockString = @"blockiPhone.png";
            self.superBlockString = @"superBlockiPhone.png";
            self.ballString = @"balliPhone.png";

            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
                
                self.paddleString = @"paddleiPhoneWide.png";

            }
            
        }
        
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"paddleiPad.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
       // [self addChild:background];
        
        self.blocksHitLabel = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy"];
        self.blocksHitLabel.position = CGPointMake(.5*self.frame.size.width, .9*self.frame.size.height);
        self.blocksHitLabel.fontColor = [UIColor cyanColor];
        self.blocksHitLabel.fontSize = .06*self.frame.size.width;
        self.blocksHitLabel.zPosition = 1;
        [self addChild:self.blocksHitLabel];
        self.blocksHitLabel.text = [NSString stringWithFormat:@"Turns: %d", blocksHit];
        
    //    self.blockTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(dropBlock) userInfo:nil repeats:YES];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -0.0f);
        
        //Create a physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        self.physicsBody.restitution = 1.0f;
        
        // Ball
        ball = [SKSpriteNode spriteNodeWithImageNamed: self.ballString];
        ball.name = ballCategoryName;
        ball.position = CGPointMake(initBallX, initBallY);
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        ball.physicsBody.friction = 0.0f;
        //  ball.physicsBody.restitution = 1.2f;
        ball.physicsBody.linearDamping = 0.5f;
        ball.physicsBody.allowsRotation = YES;
        ball.physicsBody.affectedByGravity = NO;
        ball.physicsBody.density = 10.0;

        [self addChild:ball];
        
        // Obstacles
        
        [self addObstacle];
        
        // Targets
        
        [self addTarget];
        
     //   [ball.physicsBody applyImpulse:CGVectorMake(5.0f, (arc4random() % 15) + 3.0)];
        
        paddle = [[SKSpriteNode alloc] initWithImageNamed: self.paddleString];
        paddle.name = paddleCategoryName;
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), .5*paddle.frame.size.height);
      //  [self addChild:paddle];
        paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.frame.size];
        paddle.physicsBody.restitution = 1.0f;
        paddle.physicsBody.friction = 0.4f;
        paddle.physicsBody.density = 100000.0;
        paddle.physicsBody.allowsRotation = NO;

        paddle.physicsBody.dynamic = YES;  // If no, ball can get pushed off screen!
        
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        bottom = [SKNode node];
        bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
     //   [self addChild:bottom];
        
        bottom.physicsBody.categoryBitMask = bottomCategory;
        ball.physicsBody.categoryBitMask = ballCategory;
        paddle.physicsBody.categoryBitMask = paddleCategory;
        
        ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory | superBlockCategory | paddleCategory;
        
        self.physicsWorld.contactDelegate = self;

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self.view setUserInteractionEnabled:YES];
    self.touchPoint = [touch locationInView:self.view];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view setUserInteractionEnabled:NO];
    CGPoint initPoint = CGPointMake(0.5*self.frame.size.width, 0.9*self.frame.size.height);
    
    CGPoint tapVector = rwSub(self.touchPoint, initPoint);
    
  //  NSLog(@"tap down = %f %f", self.firstPoint.x, self.firstPoint.y);
   // NSLog(@"origin = %f %f", self.lastPoint.x, self.lastPoint.y);
    NSLog(@"tapVector = %f %f", tapVector.x, tapVector.y);
    
    self.ballVelocityX = speedScale*tapVector.x;
    self.ballVelocityY = -speedScale*tapVector.y;
    
    [ball.physicsBody applyImpulse:CGVectorMake(self.ballVelocityX, self.ballVelocityY)];
    
    blocksHit++;
    self.blocksHitLabel.text = [NSString stringWithFormat:@"Turns: %d", blocksHit];;
    
    gameStarted = true;
    
}

-(void)initBallPosition
{
    ball.position = CGPointMake(initBallX, initBallY);
    ball.physicsBody.velocity = CGVectorMake(0, 0);
    [self.view setUserInteractionEnabled:YES];
}


-(void)addObstacle {
    
    SKSpriteNode *superBlock = [SKSpriteNode spriteNodeWithImageNamed: self.superBlockString];
    
    int minX = superBlock.size.width / 2;
    int maxX = self.frame.size.width - superBlock.size.width / 2;
    int rangeX = maxX - minX;
    int actualXStart = (arc4random() % rangeX) + minX;
    
    superBlock.position = CGPointMake(.5*self.frame.size.width, .5*self.frame.size.height);
    superBlock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:superBlock.frame.size];
    superBlock.physicsBody.allowsRotation = NO;
    superBlock.physicsBody.friction = 0.0f;
    superBlock.physicsBody.velocity = CGVectorMake(0, 0);
    superBlock.name = superBlockCategoryName;
    superBlock.physicsBody.categoryBitMask = superBlockCategory;
    superBlock.physicsBody.contactTestBitMask = bottomCategory | paddleCategory;
    superBlock.physicsBody.affectedByGravity = NO;
    superBlock.physicsBody.density = 10000.0;
    superBlock.physicsBody.restitution = 1.0;
    [self addChild:superBlock];
    
}

-(void)addTarget {
    
    SKSpriteNode *regBlock = [SKSpriteNode spriteNodeWithImageNamed: self.ballString];
    
    int minX = regBlock.size.width / 2;
    int maxX = self.frame.size.width - regBlock.size.width / 2;
    int rangeX = maxX - minX;
    int actualXStart = (arc4random() % rangeX) + minX;
    
    regBlock.position = CGPointMake(0.8*self.frame.size.width, 0.8*self.frame.size.height);
    regBlock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:regBlock.frame.size];
    regBlock.physicsBody.allowsRotation = NO;
    regBlock.physicsBody.friction = 0.0f;
    regBlock.physicsBody.velocity = CGVectorMake(0, 0);
    regBlock.name = blockCategoryName;
    regBlock.physicsBody.categoryBitMask = blockCategory;
    regBlock.physicsBody.contactTestBitMask = ballCategory;
    regBlock.physicsBody.affectedByGravity = NO;
    regBlock.physicsBody.density = .01;
    [self addChild:regBlock];
    
}


/*
-(void)addRowOfBlocks {
    
    int numberOfBlocks = 3;
    int blockWidth = [SKSpriteNode spriteNodeWithImageNamed: self.blockString].size.width;
    float padding = 20.0f;
    // 2 Calculate the xOffset
    float xOffset = (self.frame.size.width - (blockWidth * numberOfBlocks + padding * (numberOfBlocks-1))) / 2;
    // 3 Create the blocks and add them to the scene
    for (int i = 1; i <= numberOfBlocks; i++) {
        SKSpriteNode* block2 = [SKSpriteNode spriteNodeWithImageNamed:self.blockString];
        block2.position = CGPointMake((i-0.5f)*block2.frame.size.width + (i-1)*padding + xOffset, self.frame.size.height*0.95f);
        block2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block2.frame.size];
        block2.physicsBody.allowsRotation = NO;
        block2.physicsBody.friction = 0.0f;
        block2.physicsBody.velocity = CGVectorMake(0, blockSpeed);
        block2.name = blockCategoryName;
        block2.physicsBody.categoryBitMask = blockCategory;
        block2.physicsBody.contactTestBitMask = bottomCategory | paddleCategory;
        block2.physicsBody.affectedByGravity = YES;
        block2.physicsBody.density = 1000.0;
        [self addChild:block2];
    }

}*/


- (void)didBeginContact:(SKPhysicsContact*)contact {
    
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory) {

        livesRemaining--;
        
        if(livesRemaining <= 0) {

         //   [self gameOver];
        
        }
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
            [self runAction:[SKAction playSoundFileNamed:@"pop.mp3" waitForCompletion:NO]];
            
        }

        if (ball.position.x > paddle.position.x + .3*paddle.size.width) {
            
            NSLog(@"right");
            [ball.physicsBody applyImpulse:CGVectorMake(30.0f, 0.0f)];

        }
        
        if (ball.position.x < paddle.position.x - .3*paddle.size.width) {
            
            NSLog(@"left");
            [ball.physicsBody applyImpulse:CGVectorMake(-30.0f, 0.0f)];
            
        }
        
    }

    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blockCategory) {
        
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
            [self runAction:[SKAction playSoundFileNamed:@"pop.mp3" waitForCompletion:NO]];

        }
        targetHit = true;
        [secondBody.node removeFromParent];
        
     //   blocksHit++;
     //   NSString *blockString = [NSString stringWithFormat:@"Turns: %d", blocksHit];
     //   self.blocksHitLabel.text = blockString;

    }
    
    if (firstBody.categoryBitMask == bottomCategory && secondBody.categoryBitMask == blockCategory) {

    //    [self gameOver];
        
    }
    
    if (firstBody.categoryBitMask == blockCategory && secondBody.categoryBitMask == paddleCategory) {
        
    //    [self gameOver];
        
    }
    
    if (firstBody.categoryBitMask == bottomCategory && secondBody.categoryBitMask == superBlockCategory) {
        
    //    [self gameOver];
        
    }
    
    if (firstBody.categoryBitMask == paddleCategory && secondBody.categoryBitMask == superBlockCategory) {
        
    //    [self gameOver];
        
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == superBlockCategory) {
        
    /*    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
            [self runAction:[SKAction playSoundFileNamed:@"super.mp3" waitForCompletion:NO]];
            
        }
        [secondBody.node removeFromParent];
        [ball.physicsBody applyImpulse:CGVectorMake(0.0f, -5.0f)];
        blocksHit++;
        
        int numberOfBricksBefore = 0;
        for (SKNode* node in self.children) {
            if ([node.name isEqual: blockCategoryName]) {
                numberOfBricksBefore++;
            }
        }

        for (SKNode* node in self.children) {
            if ([node.name isEqual: blockCategoryName] || [node.name isEqual: superBlockCategoryName]) {
                [node removeFromParent];
            }
        }
        
        int numberOfBricksAfter = 0;
        for (SKNode* node in self.children) {
            if ([node.name isEqual: blockCategoryName] || [node.name isEqual: superBlockCategoryName]) {
                numberOfBricksAfter++;
            }
        }
        
        blocksHit = blocksHit + numberOfBricksBefore - numberOfBricksAfter;
        NSString *blockString = [NSString stringWithFormat:@"Turns: %d", blocksHit];
        self.blocksHitLabel.text = blockString; */
        
    }
}


-(void)gameOver {
    
    [self.blockTimer invalidate];
    [self.superBlockTimer invalidate];
    [[NSUserDefaults standardUserDefaults] setInteger:blocksHit forKey:@"lastGameScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOverNotification" object:self];
    [self.scene removeFromParent];
    [SKAction removeFromParent];
    
}


-(BOOL) isGameWon {
    int numberOfBricks = 0;
    for (SKNode* node in self.children) {
        if ([node.name isEqual: blockCategoryName]) {
            numberOfBricks++;
        }
    }
    return numberOfBricks <= 0;  // if numberOfBricks <= 0, return true
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    SKNode* ball2 = [self childNodeWithName: ballCategoryName];

    float speed = sqrt(ball2.physicsBody.velocity.dx*ball2.physicsBody.velocity.dx + ball2.physicsBody.velocity.dy * ball2.physicsBody.velocity.dy);
    
  //  NSLog(@"speed = %f", speed);
    
    if (gameStarted == true)
    {
        if (speed < stopSpeed)
        {
            gameStarted = false;
            [self initBallPosition];
            
            if (targetHit)
            {
                [self addTarget];
                targetHit = false;
                blocksHit = 0;
                self.blocksHitLabel.text = @"Turns: 0";
            }
        }
    }
    
    if (speed > maxSpeed) {
    //    ball2.physicsBody.linearDamping = 10.0f;
    } else {
    //    ball2.physicsBody.linearDamping = 0.0f;
    }
    
    if (ball2.position.x > self.size.width) {
        
     //   ball2.position = CGPointMake(self.size.width, ball2.position.y);
    }
    
    if (ball2.position.x <= ball2.frame.size.width/2) {
        
     //   ball2.position = CGPointMake(ball2.frame.size.width/2, ball2.position.y);
    }

    
    // Nudge ball to left if necessary...

    if (ball2.physicsBody.velocity.dx < 20.0 && ball2.physicsBody.velocity.dx >= 0) {
        
    //    [ball2.physicsBody applyImpulse:CGVectorMake(-5.0f, 0.0f)];
        
    }
    
    // Nudge ball to right if necessary...
    
    if (ball2.physicsBody.velocity.dx > -20.0 && ball2.physicsBody.velocity.dx < 0) {
        
   //     [ball2.physicsBody applyImpulse:CGVectorMake(5.0f, 0.0f)];
        
    }
    
    // Nudge ball down if necessary
    
    if (ball2.physicsBody.velocity.dy > -80.0 && ball2.physicsBody.velocity.dy < 0) {
        
   //     [ball2.physicsBody applyImpulse:CGVectorMake(0.0f, -10.0f)];
        
    }
    
    // Nudge ball up if necessary
    
    if (ball2.physicsBody.velocity.dy < 80.0 && ball2.physicsBody.velocity.dy >= 0) {
        
    //    [ball2.physicsBody applyImpulse:CGVectorMake(0.0f, 10.0f)];
        
    }
}

@end
