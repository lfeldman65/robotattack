//
//  PlayViewController.m
//  Bowling
//
//  Created by Maurice on 11/16/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "PlayViewController.h"

#define charSpeedScale 0.3
#define ammoSpeedScale 50.0
#define alien1SpeedScale 2.0
#define shield1SpeedScale 1.0


@interface PlayViewController ()

- (IBAction)backPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) IBOutlet UIImageView *ammoImage;
@property (strong, nonatomic) IBOutlet UIImageView *character;
@property (strong, nonatomic) IBOutlet UIImageView *alien1Image;
@property (strong, nonatomic) IBOutlet UIImageView *shield1Image;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *shieldLabel;

@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) NSTimer *ammoTimer;

@property (nonatomic) float charVelocityX;
@property (nonatomic) float charVelocityY;
@property (nonatomic) float ammoVelocityX;
@property (nonatomic) float ammoVelocityY;
@property (nonatomic) float alien1VelocityX;
@property (nonatomic) float alien1VelocityY;
@property (nonatomic) float shield1VelocityX;
@property (nonatomic) float shield1VelocityY;

@end

@implementation PlayViewController

BOOL ammoInFlight;
double screenWidth;
double screenHeight;
double charWidth;
double charHeight;
int score;
float shield;

CGPoint ammoLaunchPosition;
CGPoint alien1Vector;
CGPoint shield1Vector;

- (void)viewDidLoad
{
    [super viewDidLoad];
    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;
    charWidth = self.character.frame.size.width;
    charHeight = self.character.frame.size.height;
    self.leftView.multipleTouchEnabled = true;
    self.rightView.multipleTouchEnabled = true;
    self.view.multipleTouchEnabled = true;
    self.character.center = CGPointMake(screenWidth/2, screenHeight/2);
    self.ammoImage.center = CGPointMake(screenWidth/2 + 40.0, screenHeight/2);
    self.alien1Image.center = CGPointMake(screenWidth + 40.0, 10.0);
    self.shield1Image.center = CGPointMake(screenWidth - 40.0, screenHeight + 20);

    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
 
    ammoInFlight = false;
    
    self.charVelocityX = 0;
    self.charVelocityY = 0;
    score = 0;
    shield = 100;
    self.scoreLabel.text = @"Score: 0";
    self.shieldLabel.text = @"Shield: 100";
    self.ammoImage.hidden = true;
}

-(void)gameGuts
{
    if ([LeftViewController isInLeft])
    {
        [self movePlayer];
    }
    
    if ([RightViewController isInRight])
    {
        self.ammoImage.hidden = false;
        [self shootGun];
        
    } else {
        
        self.ammoImage.hidden = true;
    }
    
  //  [self moveAlien1];
  //  [self moveShield1];
    [self collisionBetweenCharAndAliens];
    [self collisionBetweenAmmoAndAliens];
    [self collisionBetweenCharAndShield];

}

-(void)movePlayer
{
    self.charVelocityX = charSpeedScale*[LeftViewController findDistanceX];
    self.charVelocityY = charSpeedScale*[LeftViewController findDistanceY];
    
  //  NSLog(@"Velocity X = %f", self.charVelocityX);
  //  NSLog(@"Velocity Y = %f", self.charVelocityY);
    
    self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, self.character.center.y + self.charVelocityY);
    self.character.transform = CGAffineTransformMakeRotation([LeftViewController findRotationAngle]);
    
    if(self.character.center.x < 0)
    {
        self.charVelocityX = 0;
        self.character.center = CGPointMake(screenWidth, self.character.center.y + self.charVelocityY);
    }
    
    if(self.character.center.x > screenWidth)
    {
        self.charVelocityX = 0;
        self.character.center = CGPointMake(0, self.character.center.y + self.charVelocityY);
    }
    
    if(self.character.center.y < 0)
    {
        self.charVelocityY = 0;
        self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, screenHeight - 150.0);
    }
    
    if(self.character.center.y > screenHeight - 150.0)
    {
        self.charVelocityY = 0;
        self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, 0);
    }
}

-(void)shootGun
{
    if(ammoInFlight)
    {
        self.ammoImage.center = CGPointMake(self.ammoImage.center.x + self.ammoVelocityX, self.ammoImage.center.y + self.ammoVelocityY);
        
        if(self.ammoImage.center.x < 0)
        {
            self.ammoImage.center = CGPointMake(screenWidth, self.ammoImage.center.y);

        } else if (self.ammoImage.center.x > screenWidth)
            
        {
            self.ammoImage.center = CGPointMake(0, self.ammoImage.center.y);
        }
        
        if(self.ammoImage.center.y < 0)
        {
            self.ammoImage.center = CGPointMake(self.ammoImage.center.x, screenHeight - 150.0);
            
        } else if(self.ammoImage.center.y > screenHeight - 150.0)
        {
            self.ammoImage.center = CGPointMake(self.ammoImage.center.x, 0);
        }
        
    } else {
        
        ammoLaunchPosition.x = self.character.center.x;
        ammoLaunchPosition.y = self.character.center.y;
        
        NSLog(@"2 ammo launch x = %f", ammoLaunchPosition.x);
        NSLog(@"2 ammo launch y = %f", ammoLaunchPosition.y);
        
        ammoInFlight = true;
        
        double distX = [RightViewController findDistanceX];
        double distY = [RightViewController findDistanceY];
        double mag = sqrt(distX*distX + distY*distY);
        distX = distX/mag;
        distY = distY/mag;
        
        self.ammoVelocityX = ammoSpeedScale*distX;
        self.ammoVelocityY = ammoSpeedScale*distY;
        
      //  NSLog(@"Ammo Velocity X = %f", self.ammoVelocityX);
      //  NSLog(@"Ammo Velocity Y = %f", self.ammoVelocityY);
        
        self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        
        [self.ammoTimer invalidate];
        self.ammoTimer = [NSTimer scheduledTimerWithTimeInterval:0.30 target:self selector:@selector(ammoStopped) userInfo:nil repeats:NO];
    }
}

-(void)ammoStopped
{
    ammoInFlight = false;
}

-(void)moveAlien1
{
    alien1Vector.x = self.character.center.x -  self.alien1Image.center.x;
    alien1Vector.y = self.character.center.y - self.alien1Image.center.y;
    double alien1Mag = sqrt(alien1Vector.x*alien1Vector.x + alien1Vector.y*alien1Vector.y);
    
    self.alien1VelocityX = alien1SpeedScale*alien1Vector.x/alien1Mag;
    self.alien1VelocityY = alien1SpeedScale*alien1Vector.y/alien1Mag;
    
    self.alien1Image.center = CGPointMake(self.alien1Image.center.x + self.alien1VelocityX, self.alien1Image.center.y + self.alien1VelocityY);
}

-(void)moveShield1
{
    shield1Vector.x = self.character.center.x -  self.shield1Image.center.x;
    shield1Vector.y = self.character.center.y - self.shield1Image.center.y;
    double shield1Mag = sqrt(shield1Vector.x*shield1Vector.x + shield1Vector.y*shield1Vector.y);
    
    self.shield1VelocityX = shield1SpeedScale*shield1Vector.x/shield1Mag;
    self.shield1VelocityY = shield1SpeedScale*shield1Vector.y/shield1Mag;
    
    self.shield1Image.center = CGPointMake(self.shield1Image.center.x + self.shield1VelocityX, self.shield1Image.center.y + self.shield1VelocityY);
}


-(void)collisionBetweenCharAndAliens
{
    if(CGRectIntersectsRect(self.character.frame, self.alien1Image.frame))
    {
        self.character.alpha = shield/100.0;
        NSLog(@"char alpha = %.0f", shield/100);
        self.alien1Image.center = CGPointMake(-40.0, 10.0);
        shield = shield - 10.0;
        self.shieldLabel.text = [NSString stringWithFormat:@"Shield: %.0f", shield];
        
        if (shield <= 0)
        {
            [self gameOver];
        }
    }
}


-(void)collisionBetweenAmmoAndAliens
{
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien1Image.frame))
    {
        score = score + 100;
        self.alien1Image.center = CGPointMake(-40.0, 10.0);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
}

-(void)collisionBetweenCharAndShield
{
    if(CGRectIntersectsRect(self.character.frame, self.shield1Image.frame))
    {
        shield = shield + 10;
        if (shield > 100)
        {
            shield = 100;
        }
        self.shield1Image.center = CGPointMake(-40.0, screenHeight + 10.0);
        self.shieldLabel.text = [NSString stringWithFormat:@"Shield: %.0f", shield];
    }
}


-(void)gameOver
{
    [self.gameTimer invalidate];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
