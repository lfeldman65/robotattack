//
//  GameScene.m
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//  Test 2

#import "GameScene.h"
#define maxSpeed 600
#define speedScale 150.0
#define stopSpeed 10.0

static const uint32_t ballCategory  = 0x1 << 0;
static const uint32_t skullCategory  = 0x1 << 1;
static const uint32_t diamondCategory = 0x1 << 2;
static const uint32_t obstacleCategory = 0x1 << 3;

@interface GameScene()

@end

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

@implementation GameScene


int turnNumber;
int livesRemaining;
double initBallX;
double initBallY;
bool firstTouchEnded;
int numDiamondsHit;
bool skullHit;

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        initBallX = 0.5*self.frame.size.width;
        initBallY = 0.1*self.frame.size.height;

        turnNumber = 0;
        livesRemaining = 4;
        firstTouchEnded = false;
        skullHit = false;
        numDiamondsHit = 0;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            self.obstacleString = @"blockiPad.png";
            self.ballString = @"balliPad.png";
            self.diamondString = @"diamond.png";
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
                
             //   self.paddleString = @"paddleiPadWide.png";
                
            }
        }
        else {
            
            self.obstacleString = @"blockiPhone.png";
            self.ballString = @"balliPhone.png";
            self.diamondString = @"diamondiPhone.png";
            self.skullString = @"blackHoleiPhone.png";

            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
                
              //  self.paddleString = @"paddleiPhoneWide.png";
            }
            
        }
        
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"paddleiPad.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
       // [self addChild:background];
        
        self.turnNumberLabel = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy"];
        self.turnNumberLabel.position = CGPointMake(.5*self.frame.size.width, .9*self.frame.size.height);
        self.turnNumberLabel.fontColor = [UIColor cyanColor];
        self.turnNumberLabel.fontSize = .06*self.frame.size.width;
        self.turnNumberLabel.zPosition = 1;
        [self addChild:self.turnNumberLabel];
        self.turnNumberLabel.text = [NSString stringWithFormat:@"Turns: %d", turnNumber];
        
    //    self.blockTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(dropBlock) userInfo:nil repeats:YES];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -0.0f);
        
        //Create a physics body that borders the screen
        
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        self.physicsBody.restitution = 1.0f;
        
        // Ball
        
        [self addBall];
        
        // Obstacles
        
        [self addObstacles];
        
        // Diamonds
        
        [self addDiamonds:1];
        
        // Skulls
        
        [self addSkulls];
        
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
    
    double magnitude = sqrt(tapVector.x * tapVector.x + tapVector.y * tapVector.y);
    
    NSLog(@"tapVector = %f %f", tapVector.x/magnitude, tapVector.y/magnitude);

    self.ballVelocityX = speedScale*tapVector.x/magnitude;
    self.ballVelocityY = -speedScale*tapVector.y/magnitude;

    [self.ballNode.physicsBody applyImpulse:CGVectorMake(self.ballVelocityX, self.ballVelocityY)];
    
    turnNumber++;
    self.turnNumberLabel.text = [NSString stringWithFormat:@"Turns: %d", turnNumber];
    
    firstTouchEnded = true;
    
}

-(void)initBallPosition
{
    self.ballNode.position = CGPointMake(initBallX, initBallY);
    self.ballNode.physicsBody.velocity = CGVectorMake(0, 0);
    [self.view setUserInteractionEnabled:YES];
}

-(void)addBall
{
    self.ballNode = [SKSpriteNode spriteNodeWithImageNamed: self.ballString];
    self.ballNode.name = @"ball";
    self.ballNode.position = CGPointMake(initBallX, initBallY);
    self.ballNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ballNode.frame.size.width/2];
    self.ballNode.physicsBody.friction = 0.0f;
    self.ballNode.physicsBody.linearDamping = 0.5f;
    self.ballNode.physicsBody.allowsRotation = YES;
    self.ballNode.physicsBody.affectedByGravity = NO;
    self.ballNode.physicsBody.density = 10.0;
    self.ballNode.physicsBody.dynamic = YES;                        // If no, ball can get pushed off screen!
    self.ballNode.physicsBody.categoryBitMask = ballCategory;
  //  self.ballNode.physicsBody.contactTestBitMask =  ballCategory | diamondCategory | skullCategory;
    [self addChild:self.ballNode];
}

-(void)addObstacles {
    
    self.obstacleNode = [SKSpriteNode spriteNodeWithImageNamed: self.obstacleString];
    
    int minX = self.obstacleNode.size.width / 2;
    int maxX = self.frame.size.width - self.obstacleNode.size.width / 2;
    int rangeX = maxX - minX;
    int actualXStart = (arc4random() % rangeX) + minX;
    
    self.obstacleNode.position = CGPointMake(.5*self.frame.size.width, .5*self.frame.size.height);
    self.obstacleNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.obstacleNode.frame.size];
    self.obstacleNode.physicsBody.allowsRotation = NO;
    self.obstacleNode.physicsBody.friction = 0.0f;
    self.obstacleNode.physicsBody.velocity = CGVectorMake(0, 0);
    self.obstacleNode.name = @"obstacle";
    self.obstacleNode.physicsBody.categoryBitMask = obstacleCategory;
    self.obstacleNode.physicsBody.contactTestBitMask = obstacleCategory;
    self.obstacleNode.physicsBody.affectedByGravity = NO;
    self.obstacleNode.physicsBody.density = 10000.0;
    self.obstacleNode.physicsBody.restitution = 1.0;
    [self addChild:self.obstacleNode];
    
}

-(void)addDiamonds:(int)count {
    
    for (int i = 0; i < count; i++) {
        
        int minX = self.diamondNode.size.width / 2;
        int maxX = self.frame.size.width - self.diamondNode.size.height / 2;
        int rangeX = maxX - minX;
        int actualXStart = (arc4random() % rangeX) + minX;
        
        int minY = self.diamondNode.size.width / 2;
        int maxY = self.frame.size.height - self.diamondNode.size.height / 2;
        int rangeY = maxY - minY;
        int actualYStart = (arc4random() % rangeY) + minY;
        
        self.diamondNode = [SKSpriteNode spriteNodeWithImageNamed: self.diamondString];
        self.diamondNode.position = CGPointMake(0.8*self.frame.size.width, 0.8*self.frame.size.height);
        self.diamondNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.diamondNode.frame.size.width/2];
        self.diamondNode.physicsBody.allowsRotation = NO;
        self.diamondNode.physicsBody.friction = 0.0f;
        self.diamondNode.physicsBody.velocity = CGVectorMake(0, 0);
        self.diamondNode.name = @"diamond";
        self.diamondNode.physicsBody.categoryBitMask = diamondCategory;
        self.diamondNode.physicsBody.contactTestBitMask = ballCategory;
        self.diamondNode.physicsBody.affectedByGravity = NO;
        self.diamondNode.physicsBody.density = .001;
        [self addChild:self.diamondNode];
        
        self.diamondNode = [SKSpriteNode spriteNodeWithImageNamed: self.diamondString];
        self.diamondNode.position = CGPointMake(0.2*self.frame.size.width, 0.4*self.frame.size.height);
        self.diamondNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.diamondNode.frame.size.width/2];
        self.diamondNode.physicsBody.allowsRotation = NO;
        self.diamondNode.physicsBody.friction = 0.0f;
        self.diamondNode.physicsBody.velocity = CGVectorMake(0, 0);
        self.diamondNode.name = @"diamond";
        self.diamondNode.physicsBody.categoryBitMask = diamondCategory;
        self.diamondNode.physicsBody.contactTestBitMask = ballCategory;
        self.diamondNode.physicsBody.affectedByGravity = NO;
        self.diamondNode.physicsBody.density = .001;
        [self addChild:self.diamondNode];

    }
    
}

-(void)addSkulls
{
    self.skullNode = [[SKSpriteNode alloc] initWithImageNamed: self.skullString];
    self.skullNode.name = @"skull";
    self.skullNode.position = CGPointMake(0.2*self.frame.size.width, 0.9*self.frame.size.height);
    self.skullNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.skullNode.frame.size];
    self.skullNode.physicsBody.friction = 0.0f;
    self.skullNode.physicsBody.density = 10000;
    self.skullNode.physicsBody.allowsRotation = NO;
    self.skullNode.physicsBody.categoryBitMask = skullCategory;
    self.skullNode.physicsBody.contactTestBitMask = ballCategory;
    [self addChild:self.skullNode];
    
    self.skullNode = [[SKSpriteNode alloc] initWithImageNamed: self.skullString];
    self.skullNode.name = @"skull";
    self.skullNode.position = CGPointMake(0.8*self.frame.size.width, 0.1*self.frame.size.height);
    self.skullNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.skullNode.frame.size];
    self.skullNode.physicsBody.friction = 0.0f;
    self.skullNode.physicsBody.density = 10000;
    self.skullNode.physicsBody.allowsRotation = NO;
    self.skullNode.physicsBody.categoryBitMask = skullCategory;
    self.skullNode.physicsBody.contactTestBitMask = ballCategory;
    [self addChild:self.skullNode];
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
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == skullCategory) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
            [self runAction:[SKAction playSoundFileNamed:@"pop.mp3" waitForCompletion:NO]];
        }
        for (SKNode* node in self.children) {
            if ([node.name isEqual:@"diamond"]) {
                [node removeFromParent];
            }
        }
        numDiamondsHit = 0;
        [self addDiamonds:1];
        [self initBallPosition];
    }

    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == diamondCategory) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
            [self runAction:[SKAction playSoundFileNamed:@"pop.mp3" waitForCompletion:NO]];

        }
        numDiamondsHit++;
        NSLog(@"number of diamonds hit = %d", numDiamondsHit);
        [secondBody.node removeFromParent];
        
     //   NSString *blockString = [NSString stringWithFormat:@"Turns: %d", turnNumber];
     //   self.turnNumberLabel.text = blockString;

    }
    
    
  //  if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == superBlockCategory) {
        
    /*    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
            [self runAction:[SKAction playSoundFileNamed:@"super.mp3" waitForCompletion:NO]];
            
        }
        [secondBody.node removeFromParent];
        [ball.physicsBody applyImpulse:CGVectorMake(0.0f, -5.0f)];
        turnNumber++;
        
        int numberOfBricksBefore = 0;
        for (SKNode* node in self.children) {
            if ([node.name isEqual: blockCategoryName]) {
                numberOfBricksBefore++;
            }
        }

        for (SKNode* node in self.children) {
            if ([node.name isEqual: blockCategoryName] || [node.name isEqual: obstacleCategoryName]) {
                [node removeFromParent];
            }
        }
        
        int numberOfBricksAfter = 0;
        for (SKNode* node in self.children) {
            if ([node.name isEqual: blockCategoryName] || [node.name isEqual: obstacleCategoryName]) {
                numberOfBricksAfter++;
            }
        }
        
        turnNumber = turnNumber + numberOfBricksBefore - numberOfBricksAfter;
        NSString *blockString = [NSString stringWithFormat:@"Turns: %d", turnNumber];
        self.turnNumberLabel.text = blockString; */
        
 //   }
}


-(void)gameOver {
    
    [self.blockTimer invalidate];
    [self.superBlockTimer invalidate];
    [[NSUserDefaults standardUserDefaults] setInteger:turnNumber forKey:@"lastGameScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOverNotification" object:self];
    [self.scene removeFromParent];
    [SKAction removeFromParent];
    
}

/*
-(BOOL) isGameWon {
    int numberOfBricks = 0;
    for (SKNode* node in self.children) {
        if ([node.name isEqual: blockCategoryName]) {
            numberOfBricks++;
        }
    }
    return numberOfBricks <= 0;  // if numberOfBricks <= 0, return true
}
 */

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    SKNode* ball2 = [self childNodeWithName:@"ball"];

    float speed = sqrt(ball2.physicsBody.velocity.dx*ball2.physicsBody.velocity.dx + ball2.physicsBody.velocity.dy * ball2.physicsBody.velocity.dy);
    
  //  NSLog(@"speed = %f", speed);
    
    if (firstTouchEnded == true)
    {
        if (speed < stopSpeed)
        {
            firstTouchEnded = false;
            [self initBallPosition];
            
            for (SKNode* node in self.children) {
                if ([node.name isEqual:@"diamond"]) {
                    [node removeFromParent];
                }
            }
            
            [self addDiamonds:1];
            
            if (numDiamondsHit == 2)
            {
                turnNumber = 0;
                self.turnNumberLabel.text = [NSString stringWithFormat:@"Turns: %d", turnNumber];
            }
            
            numDiamondsHit = 0;
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
