//
//  PlayViewController.m
//  Bowling
//
//  Created by Maurice on 11/16/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "PlayViewController.h"

#define charSpeedScale 0.5
#define ammoSpeedScale 100.0


@interface PlayViewController ()

- (IBAction)backPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) IBOutlet UIView *character;
@property (strong, nonatomic) IBOutlet UIImageView *ammoImage;

@property (strong, nonatomic) NSTimer *gameTimer;

@property (nonatomic) float charVelocityX;
@property (nonatomic) float charVelocityY;
@property (nonatomic) float ammoVelocityX;
@property (nonatomic) float ammoVelocityY;

@end


@implementation PlayViewController


BOOL ammoInFlight;
double screenWidth;
double screenHeight;
double actionSide;
double charWidth;
double charHeight;


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
    actionSide = 130.0;
    self.character.center = CGPointMake(screenWidth/2, screenHeight/2);
    self.ammoImage.center = CGPointMake(screenWidth/2 + 40.0, screenHeight/2);
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
 
    ammoInFlight = false;
    
    self.charVelocityX = 0;
    self.charVelocityY = 0;
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
        
        if (ammoInFlight)
        {
            self.ammoImage.hidden = true;
            
        } else {
            
            self.ammoImage.hidden = true;
        }
    }
}

-(void)movePlayer
{
    self.charVelocityX = charSpeedScale*[LeftViewController findDistanceX];
    self.charVelocityY = charSpeedScale*[LeftViewController findDistanceY];
    
  //  NSLog(@"Velocity X = %f", self.charVelocityX);
  //  NSLog(@"Velocity Y = %f", self.charVelocityY);
    
    self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, self.character.center.y + self.charVelocityY);
    
    if(self.character.center.x < charWidth/2)
    {
        self.charVelocityX = 0;
        self.character.center = CGPointMake(charWidth/2, self.character.center.y + self.charVelocityY);
    }
    
    if(self.character.center.x > screenWidth - charWidth/2)
    {
        self.charVelocityX = 0;
        self.character.center = CGPointMake(screenWidth - charWidth/2, self.character.center.y + self.charVelocityY);
    }
    
    if(self.character.center.y < charHeight/2)
    {
        self.charVelocityY = 0;
        self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, charHeight/2);
    }
    
    if(self.character.center.y > screenHeight - charHeight/2)
    {
        self.charVelocityY = 0;
        self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, self.view.frame.size.height - self.character.frame.size.height/2);
    }
}

-(void)shootGun
{
    if(ammoInFlight)
    {
        self.ammoImage.center = CGPointMake(self.ammoImage.center.x + self.ammoVelocityX, self.ammoImage.center.y + self.ammoVelocityY);
        
    } else {
        
        ammoInFlight = true;
        
        double distX = [RightViewController findDistanceX];
        double distY = [RightViewController findDistanceY];
        double mag = sqrt(distX*distX + distY*distY);
        distX = distX/mag;
        distY = distY/mag;
        
        self.ammoVelocityX = ammoSpeedScale*distX;
        self.ammoVelocityY = ammoSpeedScale*distY;
        
        NSLog(@"Ammo Velocity X = %f", self.ammoVelocityX);
        NSLog(@"Ammo Velocity Y = %f", self.ammoVelocityY);
        
        self.ammoImage.center = CGPointMake(self.ammoImage.center.x + self.ammoVelocityX, self.ammoImage.center.y + self.ammoVelocityY);
    }
    
    if(self.ammoImage.center.x < -250)
    {
        self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        ammoInFlight = false;
    }
    
    if(self.ammoImage.center.x > screenWidth + 250)
    {
        self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        ammoInFlight = false;
    }
    
    if(self.ammoImage.center.y < -250)
    {
        self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        ammoInFlight = false;
    }
    
    if(self.ammoImage.center.y > screenHeight + 250)
    {
        self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        ammoInFlight = false;
    }
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
