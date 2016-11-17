//
//  PlayViewController.m
//  Bowling
//
//  Created by Maurice on 11/16/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "PlayViewController.h"

#define charSpeedScale 0.5


@interface PlayViewController ()

- (IBAction)backPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (nonatomic) CGPoint leftActionCenter;
@property (nonatomic) CGPoint rightActionCenter;
@property (nonatomic) CGPoint currentTouchPosition;
@property (strong, nonatomic) IBOutlet UIView *character;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) NSTimer *ammoTimer;
@property (nonatomic) float charVelocityX;
@property (nonatomic) float charVelocityY;
@property (nonatomic) float ammoVelocityX;
@property (nonatomic) float ammoVelocityY;
@property (strong, nonatomic) IBOutlet UIImageView *ammoImage;

@end


@implementation PlayViewController

BOOL leftTouchActive;
BOOL rightTouchActive;
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
    actionSide = 130.0;
    self.leftActionCenter = CGPointMake(actionSide/2, screenHeight - actionSide/2);
    self.rightActionCenter = CGPointMake(screenWidth - actionSide/2,screenHeight - actionSide/2);
    self.character.center = CGPointMake(screenWidth/2, screenHeight/2);
    self.ammoImage.center = CGPointMake(screenWidth/2 + 40.0, screenHeight/2);
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
 //   self.ammoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(shootGun) userInfo:nil repeats:YES];

    leftTouchActive = false;
    rightTouchActive = false;
    self.charVelocityX = 0;
    self.charVelocityY = 0;
    self.ammoVelocityX = 2.0;
    self.ammoVelocityY = 2.0;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];

    if ([self touchInLeftBox])
    {
        leftTouchActive = true;
        NSLog(@"Touch Began = (%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
        
    } else {
        
        leftTouchActive = false;
        self.charVelocityX = 0;
        self.charVelocityY = 0;
    }
    
    if ([self touchInRightBox])
    {
        rightTouchActive = true;
        NSLog(@"Touch Began = (%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
        
    } else {
        
        rightTouchActive = false;
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];

    if ([self touchInLeftBox])
    {
        leftTouchActive = true;
        NSLog(@"Move in Left box");
        
    } else {
        
        leftTouchActive = false;
        self.charVelocityX = 0;
        self.charVelocityY = 0;
    }
    
    if ([self touchInRightBox])
    {
        rightTouchActive = true;
        NSLog(@"Move In Right box");
        
    } else {
        
        rightTouchActive = false;
        self.charVelocityX = 0;
        self.charVelocityY = 0;
    }

    NSLog(@"Touch Moved Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    leftTouchActive = false;
    rightTouchActive = false;
    self.charVelocityX = 0;
    self.charVelocityY = 0;
    self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
}


-(void)gameGuts
{
    [self movePlayer];
    [self shootGun];
}

-(void)movePlayer
{
  //  NSLog(@"touch started = %d", leftTouchActive);
    
    if (leftTouchActive)
    {
        double xDistance = self.currentTouchPosition.x - self.leftActionCenter.x;
        double yDistance = self.currentTouchPosition.y - self.leftActionCenter.y;
        
        self.charVelocityX = charSpeedScale*xDistance;
        self.charVelocityY = charSpeedScale*yDistance;
        
        NSLog(@"Velocity X = %f", self.charVelocityX);
        NSLog(@"Velocity Y = %f", self.charVelocityY);
        
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
}

-(void)shootGun
{
    if(rightTouchActive)
    {
        NSLog(@"shoot");
        self.ammoImage.hidden = NO;
        double xDistance = self.currentTouchPosition.x - self.rightActionCenter.x;
        double yDistance = self.currentTouchPosition.y - self.rightActionCenter.y;
        
        self.ammoVelocityX = 2*xDistance;
        self.ammoVelocityY = 2*yDistance;
        
        NSLog(@"Ammo Velocity X = %f", self.ammoVelocityX);
        NSLog(@"Ammo Velocity Y = %f", self.ammoVelocityY);
        
        self.ammoImage.center = CGPointMake(self.ammoImage.center.x + self.ammoVelocityX, self.ammoImage.center.y + self.ammoVelocityY);
        
        if(self.ammoImage.center.x < -500)
        {
            self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        }
        
        if(self.ammoImage.center.x > screenWidth + 250)
        {
            self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        }
        
        if(self.ammoImage.center.y < -500)
        {
            self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        }
        
        if(self.ammoImage.center.y > screenHeight + 250)
        {
            self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
        }
        
    } else {
        
        self.ammoImage.hidden = YES;
    }
}

-(BOOL)touchInLeftBox
{
    NSLog(@"Left Box touch = (%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
    
    if (self.currentTouchPosition.x > 0 && self.currentTouchPosition.x < 130.0 && self.currentTouchPosition.y > 180.0 && self.currentTouchPosition.y < screenHeight)
    {
        
        return true;
    }
    
    else {
        
        return false;
    }
}

-(BOOL)touchInRightBox
{
    NSLog(@"Right Box touch = (%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
    
    if (self.currentTouchPosition.x > screenWidth - actionSide && self.currentTouchPosition.x < screenWidth && self.currentTouchPosition.y > 180.0 && self.currentTouchPosition.y < screenHeight)
    {
        
        return true;
    }
    
    else {
        
        return false;
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
