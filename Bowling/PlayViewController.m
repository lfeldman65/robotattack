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
#define controlHeight 150.0
#define maxMinSpeed 20
#define bfgCount 10
#define testSpeed 0
#define bottomAchieve 20000

@interface PlayViewController ()

- (IBAction)backPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) IBOutlet UIImageView *ammoImage;
@property (strong, nonatomic) IBOutlet UIImageView *ammo2Image;
@property (strong, nonatomic) IBOutlet UIImageView *ammo3Image;

@property (strong, nonatomic) IBOutlet UIImageView *character;
@property (strong, nonatomic) IBOutlet UIImageView *shield1Image;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *shieldLabel;
@property (strong, nonatomic) IBOutlet UIImageView *alien1Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien2Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien3Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien4Image;
@property (strong, nonatomic) IBOutlet UIImageView *fireball;
@property (strong, nonatomic) IBOutlet UILabel *fireballLabel;

@property (retain, nonatomic) AVAudioPlayer *ammoPlayer;

@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) NSTimer *ammoTimer;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic) float charVelocityX;
@property (nonatomic) float charVelocityY;
@property (nonatomic) float ammoVelocityX;
@property (nonatomic) float ammoVelocityY;
@property (nonatomic) float alien1VelocityX;
@property (nonatomic) float alien1VelocityY;
@property (nonatomic) float alien2VelocityX;
@property (nonatomic) float alien2VelocityY;
@property (nonatomic) float alien3VelocityX;
@property (nonatomic) float alien3VelocityY;
@property (nonatomic) float alien4VelocityX;
@property (nonatomic) float alien4VelocityY;

@property (nonatomic) float shield1VelocityX;
@property (nonatomic) float shield1VelocityY;

@property (nonatomic) float fireballVelocityX;
@property (nonatomic) float fireballVelocityY;

- (IBAction)playButtonPressed:(id)sender;

@end

@implementation PlayViewController

BOOL ammoInFlight;
BOOL fireballInFlight;

BOOL alien1InFlight;
BOOL alien2InFlight;
BOOL alien3InFlight;
BOOL soundIsOn;

double screenWidth;
double screenHeight;
double charWidth;
double charHeight;
double ufoSpeed;
double minSpeed;
double timePassed;
int score;
int shield;
int fireballCount;
int deviceScaler;

CGPoint alien1Vector, alien2Vector, alien3Vector, alien4Vector, fireballVector, shield1Vector, ammoLaunchPosition, fireballEnd;
CGPoint alien1End, alien2End, alien3End;


- (void)viewDidLoad
{
    [super viewDidLoad];
    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;
    charWidth = self.character.frame.size.width;
    charHeight = self.character.frame.size.height;
    self.character.hidden = true;
    self.playButton.hidden = false;
    self.leftView.multipleTouchEnabled = true;
    self.rightView.multipleTouchEnabled = true;
    self.view.multipleTouchEnabled = true;
    [self initGame];
    [self playButtonPressed:nil];
    NSNumber* soundOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundOn"];
    soundIsOn = [soundOn boolValue];
    
    // Ammo sound
    
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/Cosmic.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    self.ammoPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    
    if(err)
    {
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else
    {
        self.ammoPlayer.delegate = self;
        self.ammoPlayer.numberOfLoops = 0;
        self.ammoPlayer.currentTime = 0;
        self.ammoPlayer.volume = 1.0;
    }
    
    deviceScaler = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        deviceScaler = 2;
    }
}

- (IBAction)playButtonPressed:(id)sender
{
    [self initGame];
    self.playButton.hidden = true;
    self.character.hidden = false;
    self.alien1Image.hidden = false;
    self.alien2Image.hidden = false;
    self.alien3Image.hidden = false;
    self.alien4Image.hidden = false;
    self.shield1Image.hidden = false;
    self.fireball.hidden = false;
    timePassed = 0;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (fireballCount > 0)
    {
        self.alien1Image.center = CGPointMake(-50, [self randomHeight]);
        self.alien2Image.center = CGPointMake(screenWidth + 50, [self randomHeight]);
        self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight - 50);
        self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 50);
        fireballCount--;
        self.fireballLabel.text = [NSString stringWithFormat:@"%d", fireballCount];
    }
    
}

-(void)initGame
{
    score = 0;
    shield = 100;
    minSpeed = 1.0;
    fireballCount = 0;
    self.scoreLabel.text = @"Score: 0";
    self.shieldLabel.text = @"100";
    self.fireballLabel.text = @"0";
    self.character.transform = CGAffineTransformMakeRotation(0.0);
    self.character.alpha = 1.0;
    self.character.center = CGPointMake(screenWidth/2, (screenHeight - controlHeight)/2);

    self.alien1Image.center = CGPointMake(-50, [self randomHeight]);
    self.alien2Image.center = CGPointMake(1.5*screenWidth, [self randomHeight]);
    self.alien3Image.center = CGPointMake([self randomWidth], -5*screenHeight);
    self.alien4Image.center = CGPointMake(8*screenWidth, 8*[self randomHeight]);

    self.shield1Image.center = CGPointMake(4*screenWidth, [self randomHeight]);
    self.fireball.center = CGPointMake(-4*screenWidth, [self randomHeight]);

    ammoInFlight = false;
    fireballInFlight = false;
    
    alien1InFlight = false;
    alien2InFlight = false;
    alien3InFlight = false;
    
    self.charVelocityX = 0;
    self.charVelocityY = 0;
    
    [self moveAmmoAway];

    self.alien1Image.hidden = true;
    self.alien2Image.hidden = true;
    self.alien3Image.hidden = true;
    self.alien4Image.hidden = true;
    self.shield1Image.hidden = true;
    self.fireball.hidden = true;
}

-(void)gameGuts
{
    timePassed = timePassed + .05;
    
    minSpeed = minSpeed + 0.001;
    
    if(minSpeed >= maxMinSpeed)
    {
        minSpeed = maxMinSpeed;
    }
    
    if ([LeftViewController isInLeft])
    {
        [self movePlayer];
    }
    
    if ([RightViewController isInRight] || ammoInFlight)
    {
        [self shootGun];
        
    } else {
        
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.ammo2Image.center = CGPointMake(100000, 100000);
        self.ammo3Image.center = CGPointMake(100000, 100000);
    }
    
    [self moveAlien1];
    [self moveAlien2];
    [self moveAlien3];
    [self moveAlien4];
    [self moveShields];
    [self moveFireball];
    [self collisionBetweenCharAndAliens];
    [self collisionBetweenAmmoAndAliens];
    [self collisionBetweenCharAndShield];
    [self collisionBetweenCharAndFireball];
}

-(void)movePlayer
{
    self.charVelocityX = charSpeedScale*[LeftViewController findDistanceX];
    self.charVelocityY = charSpeedScale*[LeftViewController findDistanceY];
    
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
        self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, screenHeight - controlHeight);
    }
    
    if(self.character.center.y > screenHeight - controlHeight)
    {
        self.charVelocityY = 0;
        self.character.center = CGPointMake(self.character.center.x + self.charVelocityX, 0);
    }
}

-(void)shootGun
{
    if(ammoInFlight)
    {
        [self moveAmmo1];
        
    } else {
        
        [self initAmmo1];
    }
}

-(void)moveAmmo1
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
        
    } else if(self.ammoImage.center.y > screenHeight - controlHeight)
    {
        self.ammoImage.center = CGPointMake(self.ammoImage.center.x, 0);
    }
}

-(void)moveAmmo2
{
    self.ammo2Image.center = CGPointMake(self.ammo2Image.center.x - self.ammoVelocityY, self.ammo2Image.center.y + self.ammoVelocityX);
    
    if(self.ammo2Image.center.x < 0)
    {
        self.ammo2Image.center = CGPointMake(screenWidth, self.ammo2Image.center.y);
        
    } else if (self.ammo2Image.center.x > screenWidth)
        
    {
        self.ammo2Image.center = CGPointMake(0, self.ammo2Image.center.y);
    }
    
    if(self.ammo2Image.center.y < 0)
    {
        self.ammo2Image.center = CGPointMake(self.ammo2Image.center.x, screenHeight - 150.0);
        
    } else if(self.ammo2Image.center.y > screenHeight - controlHeight)
    {
        self.ammo2Image.center = CGPointMake(self.ammo2Image.center.x, 0);
    }
}

-(void)moveAmmo3
{
    self.ammo3Image.center = CGPointMake(self.ammo3Image.center.x + self.ammoVelocityY, self.ammo3Image.center.y - self.ammoVelocityX);
    
    if(self.ammo3Image.center.x < 0)
    {
        self.ammo3Image.center = CGPointMake(screenWidth, self.ammo3Image.center.y);
        
    } else if (self.ammo3Image.center.x > screenWidth)
        
    {
        self.ammo3Image.center = CGPointMake(0, self.ammo3Image.center.y);
    }
    
    if(self.ammo3Image.center.y < 0)
    {
        self.ammo3Image.center = CGPointMake(self.ammo3Image.center.x, screenHeight - 150.0);
        
    } else if(self.ammo3Image.center.y > screenHeight - controlHeight)
    {
        self.ammo3Image.center = CGPointMake(self.ammo3Image.center.x, 0);
    }
}


-(void)initAmmo1
{
    ammoLaunchPosition.x = self.character.center.x;
    ammoLaunchPosition.y = self.character.center.y;
    
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



-(void)ammoStopped
{
    ammoInFlight = false;
}


-(void)moveAlienOld
{
    alien1Vector.x = self.character.center.x -  self.alien1Image.center.x;
    alien1Vector.y = self.character.center.y - self.alien1Image.center.y;
    double alien1Mag = sqrt(alien1Vector.x*alien1Vector.x + alien1Vector.y*alien1Vector.y);
    double speed = [self randomSpeed];
    self.alien1VelocityX = speed*alien1Vector.x/alien1Mag;
    self.alien1VelocityY = speed*alien1Vector.y/alien1Mag;
    self.alien1Image.center = CGPointMake(self.alien1Image.center.x + self.alien1VelocityX, self.alien1Image.center.y + self.alien1VelocityY);
}

-(void)moveAlien1
{
    if(alien1InFlight)
    {
        alien1Vector.x = alien1End.x -  self.alien1Image.center.x;
        alien1Vector.y = alien1End.y - self.alien1Image.center.y;
        double Mag = sqrt(alien1Vector.x*alien1Vector.x + alien1Vector.y*alien1Vector.y);
        
        if (Mag < 10)
        {
            alien1InFlight = false;
            self.alien1Image.center = CGPointMake(-50, [self randomHeight]);
        }
        
        self.alien1VelocityX = [self randomSpeed]*alien1Vector.x/Mag;
        self.alien1VelocityY = [self randomSpeed]*alien1Vector.y/Mag;
        self.alien1Image.center = CGPointMake(self.alien1Image.center.x + self.alien1VelocityX, self.alien1Image.center.y + self.alien1VelocityY);
        
    } else {
        
        alien1End.x = screenWidth + 30;
        alien1End.y = [self randomHeight];
        alien1InFlight = true;
    }
}

-(void)moveAlien2Old
{
    alien2Vector.x = self.character.center.x -  self.alien2Image.center.x;
    alien2Vector.y = self.character.center.y - self.alien2Image.center.y;
    double alien2Mag = sqrt(alien2Vector.x*alien2Vector.x + alien2Vector.y*alien2Vector.y);
    double speed = [self randomSpeed];
    self.alien2VelocityX = speed*alien2Vector.x/alien2Mag;
    self.alien2VelocityY = speed*alien2Vector.y/alien2Mag;
    self.alien2Image.center = CGPointMake(self.alien2Image.center.x + self.alien2VelocityX, self.alien2Image.center.y + self.alien2VelocityY);
}

-(void)moveAlien2
{
    if(alien2InFlight)
    {
        alien2Vector.x = alien2End.x -  self.alien2Image.center.x;
        alien2Vector.y = alien2End.y - self.alien2Image.center.y;
        double Mag = sqrt(alien2Vector.x*alien2Vector.x + alien2Vector.y*alien2Vector.y);
        
        if (Mag < 10)
        {
            alien2InFlight = false;
            self.alien2Image.center = CGPointMake(screenWidth + 50, [self randomHeight]);
        }
        
        self.alien2VelocityX = [self randomSpeed]*alien2Vector.x/Mag;
        self.alien2VelocityY = [self randomSpeed]*alien2Vector.y/Mag;
        self.alien2Image.center = CGPointMake(self.alien2Image.center.x + self.alien2VelocityX, self.alien2Image.center.y + self.alien2VelocityY);
        
    } else {
        
        alien2End.x = -50;
        alien2End.y = [self randomHeight];
        alien2InFlight = true;
    }
}


-(void)moveAlien3Old
{
    alien3Vector.x = self.character.center.x -  self.alien3Image.center.x;
    alien3Vector.y = self.character.center.y - self.alien3Image.center.y;
    double alien3Mag = sqrt(alien3Vector.x*alien3Vector.x + alien3Vector.y*alien3Vector.y);
    double speed = [self randomSpeed];
    self.alien3VelocityX = speed*alien3Vector.x/alien3Mag;
    self.alien3VelocityY = speed*alien3Vector.y/alien3Mag;
    self.alien3Image.center = CGPointMake(self.alien3Image.center.x + self.alien3VelocityX, self.alien3Image.center.y + self.alien3VelocityY);
}

-(void)moveAlien3
{
    if(alien3InFlight)
    {
        alien3Vector.x = alien3End.x -  self.alien3Image.center.x;
        alien3Vector.y = alien3End.y - self.alien3Image.center.y;
        double Mag = sqrt(alien3Vector.x*alien3Vector.x + alien3Vector.y*alien3Vector.y);
        
        if (Mag < 10)
        {
            alien3InFlight = false;
            self.alien3Image.center = CGPointMake([self randomWidth], -50);
        }
        
        self.alien3VelocityX = [self randomSpeed]*alien3Vector.x/Mag;
        self.alien3VelocityY = [self randomSpeed]*alien3Vector.y/Mag;
        self.alien3Image.center = CGPointMake(self.alien3Image.center.x + self.alien3VelocityX, self.alien3Image.center.y + self.alien3VelocityY);
        
    } else {
        
        alien3End.x = [self randomWidth];
        alien3End.y = screenHeight + 50;
        alien3InFlight = true;
    }
}


-(void)moveAlien4
{
    alien4Vector.x = self.character.center.x -  self.alien4Image.center.x;
    alien4Vector.y = self.character.center.y - self.alien4Image.center.y;
    double alien4Mag = sqrt(alien4Vector.x*alien4Vector.x + alien4Vector.y*alien4Vector.y);
    double speed = [self randomSpeed];
    self.alien4VelocityX = speed*alien4Vector.x/alien4Mag;
    self.alien4VelocityY = speed*alien4Vector.y/alien4Mag;
    self.alien4Image.center = CGPointMake(self.alien4Image.center.x + self.alien4VelocityX, self.alien4Image.center.y + self.alien4VelocityY);
}


-(void)moveShields
{
    self.shield1Image.transform = CGAffineTransformMakeRotation(5*timePassed);
    shield1Vector.x = self.character.center.x -  self.shield1Image.center.x;
    shield1Vector.y = self.character.center.y - self.shield1Image.center.y;
    double shield1Mag = sqrt(shield1Vector.x*shield1Vector.x + shield1Vector.y*shield1Vector.y);
    self.shield1VelocityX = [self randomSpeed]*shield1Vector.x/shield1Mag;
    self.shield1VelocityY = [self randomSpeed]*shield1Vector.y/shield1Mag;
    self.shield1Image.center = CGPointMake(self.shield1Image.center.x + self.shield1VelocityX, self.shield1Image.center.y + self.shield1VelocityY);
}

-(void)moveFireball
{
    if(fireballInFlight)
    {
        self.fireball.transform = CGAffineTransformMakeRotation(5*timePassed);
        fireballVector.x = fireballEnd.x -  self.fireball.center.x;
        fireballVector.y = fireballEnd.y - self.fireball.center.y;
        double fireMag = sqrt(fireballVector.x*fireballVector.x + fireballVector.y*fireballVector.y);
        
        if (fireMag < 10)
        {
            fireballInFlight = false;
            self.fireball.center = CGPointMake(-4*screenWidth, [self randomHeight]);
        }
    
        self.fireballVelocityX = [self randomSpeed]*fireballVector.x/fireMag;
        self.fireballVelocityY = [self randomSpeed]*fireballVector.y/fireMag;
        self.fireball.center = CGPointMake(self.fireball.center.x + self.fireballVelocityX, self.fireball.center.y + self.fireballVelocityY);
        
    } else {
        
        fireballEnd.x = screenWidth + 30;
        fireballEnd.y = [self randomHeight];
        fireballInFlight = true;
    }
}


-(void)collisionBetweenCharAndAliens
{
    if(CGRectIntersectsRect(self.character.frame, self.alien1Image.frame))
    {
        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien1Image.center = CGPointMake(-50, [self randomHeight]);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien2Image.frame))
    {
        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien2Image.center = CGPointMake(screenWidth + 50, [self randomHeight]);
            NSLog(@"random = (%f, %f)", self.alien2Image.center.x, self.alien2Image.center.y);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien3Image.frame))
    {
        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight - 50);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien4Image.frame))
    {
        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 50);
            NSLog(@"random = (%f, %f)", self.alien2Image.center.x, self.alien2Image.center.y);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
}


-(void)collisionBetweenAmmoAndAliens
{
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien1Image.frame))
    {
        score = score + 50;
        self.alien1Image.center = CGPointMake(-50, [self randomHeight]);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien2Image.frame))
    {
        score = score + 100;
        self.alien2Image.center = CGPointMake(screenWidth + 50, [self randomHeight]);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien3Image.frame))
    {
        score = score + 150;
        self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight - 50);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien4Image.frame))
    {
        score = score + 200;
        self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 50);
        self.ammo2Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo2Image.frame, self.alien1Image.frame))
    {
        score = score + 50;
        self.alien1Image.center = CGPointMake(-[self randomValue], screenHeight+[self randomValue]);
        self.ammo2Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo2Image.frame, self.alien2Image.frame))
    {
        score = score + 100;
        self.alien2Image.center = CGPointMake(1.5*screenWidth, [self randomHeight]);
        self.ammo2Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo2Image.frame, self.alien3Image.frame))
    {
        score = score + 150;
        self.alien3Image.center = CGPointMake(-[self randomValue], -[self randomValue]);
        self.ammo2Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo2Image.frame, self.alien4Image.frame))
    {
        score = score + 200;
        self.alien4Image.center = CGPointMake(screenWidth + [self randomValue], screenHeight + [self randomValue]);
        self.ammo2Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo3Image.frame, self.alien1Image.frame))
    {
        score = score + 50;
        self.alien1Image.center = CGPointMake(-[self randomValue], screenHeight+[self randomValue]);
        self.ammo3Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo3Image.frame, self.alien2Image.frame))
    {
        score = score + 100;
        self.alien2Image.center = CGPointMake(screenWidth + [self randomValue], -[self randomValue]);
        self.ammo3Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo3Image.frame, self.alien3Image.frame))
    {
        score = score + 150;
        self.alien3Image.center = CGPointMake(-[self randomValue], -[self randomValue]);
        self.ammo3Image.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammo3Image.frame, self.alien4Image.frame))
    {
        score = score + 200;
        self.alien4Image.center = CGPointMake(screenWidth + [self randomValue], screenHeight + [self randomValue]);
        self.ammo3Image.center = CGPointMake(100000, 100000);
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

        self.shield1Image.center = CGPointMake(1.5*screenWidth, [self randomHeight]);
        self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
    }
}

-(void)collisionBetweenCharAndFireball
{
    if(CGRectIntersectsRect(self.character.frame, self.fireball.frame))
    {
        fireballCount = fireballCount + 1;
        self.fireball.center = CGPointMake(-4*screenWidth, [self randomHeight]);
        self.fireballLabel.text = [NSString stringWithFormat:@"%d", fireballCount];
        if(soundIsOn)
        {
            NSLog(@"sound");
            [self.ammoPlayer play];
        }
    }
}

-(void)moveAmmoAway
{
    self.ammoImage.center = CGPointMake(100000, 100000);
    self.ammo2Image.center = CGPointMake(100000, 100000);
    self.ammo3Image.center = CGPointMake(100000, 100000);
}

-(void)gameOver
{
    
    [self.gameTimer invalidate];
    [self highScores];
    self.shieldLabel.text = @"0";
    self.playButton.hidden = false;
    self.character.hidden = true;
    self.alien1Image.hidden = true;
    self.alien2Image.hidden = true;
    self.alien3Image.hidden = true;
    self.alien4Image.hidden = true;
    self.shield1Image.hidden = true;
    self.fireball.hidden = true;
    [self moveAmmoAway];
}

-(double)randomSpeed
{
    return arc4random()%4 + minSpeed + testSpeed;
}

-(int)randomValue  // Delta outside of screen bounds
{
    return arc4random()%100 + 50.0;
}


-(int)randomHeight
{
    int minY = -20;
    int maxY = screenHeight - controlHeight;
    int rangeY = maxY - minY;
    return (arc4random() % rangeY) + minY;
}

-(int)randomWidth
{
    int minY = -50;
    int maxY = screenWidth + 50;
    int rangeY = maxY - minY;
    return (arc4random() % rangeY) + minY;
}

-(CGPoint)chooseRegion
{
    double x = 0;
    double y = 0;
    CGPoint point;
    
    int random = arc4random()%9;   // 0 - 8 areas around screen bounds
    
   // random = 3;
    
    switch (random) {
        case 0:                         // NW
        {
            x = -[self randomValue];
            y = -[self randomValue];
            break;
        }
        case 1:                         // N
        {
            x = [self randomValue];
            y = -[self randomValue];
            break;
        }
        case 2:                         // NE
        {
            x = screenWidth + [self randomValue];
            y = -[self randomValue];
            break;
        }
        case 3:                         // W
        {
            x = -[self randomValue];
            y = [self randomValue];
            break;
        }
        case 4:                         // E
        {
            x = screenWidth + [self randomValue];
            y = screenHeight + [self randomValue];
            break;
        }
        case 5:                         // SW
        {
            x = -[self randomValue];
            y = screenHeight + [self randomValue] - controlHeight;
            break;
        }
        case 6:                         // S
        {
            x = [self randomValue];
            y = screenHeight + [self randomValue] - controlHeight;
            break;
        }
        case 7:                         // SE
        {
            x = screenHeight + [self randomValue];
            y = screenHeight + [self randomValue] - controlHeight;
            break;
        }
        default:
            break;
    }
    
    point.x = x;
    point.y = y;
    return point;
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
    [self.gameTimer invalidate];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"What do you want to do, Space Cowboy?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *home = [UIAlertAction actionWithTitle:@"Go Home" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
       [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *resume = [UIAlertAction actionWithTitle:@"Resume" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
    }];
    
    UIAlertAction *startOver = [UIAlertAction actionWithTitle:@"Start Over" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [self playButtonPressed:nil];
    }];
    
    [alert addAction:home];
    [alert addAction:resume];
    [alert addAction:startOver];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)highScores
{
    NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    int currentHSInt = [currentHighScore intValue];
    
    if(score > currentHSInt)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:score] forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[GameCenterManager sharedManager] saveAndReportScore:score leaderboard:@"com.lfeldman.ufo.score1" sortOrder:GameCenterSortOrderHighToLow];
    }
    
    if(score >= 4*bottomAchieve)
    {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.lfeldman.ufo.achievement4" percentComplete:100.00 shouldDisplayNotification:true];
    
    } else if(score >= 3*bottomAchieve)
        
    {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.lfeldman.ufo.achievement3" percentComplete:100.00 shouldDisplayNotification:true];
        
    } else if (score >= 2*bottomAchieve)
        
    {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.lfeldman.ufo.achievement2" percentComplete:100.00 shouldDisplayNotification:true];
    }
    
    else if (score >= bottomAchieve)
        
    {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.lfeldman.ufo.achievement1" percentComplete:100.00 shouldDisplayNotification:true];
    }

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
