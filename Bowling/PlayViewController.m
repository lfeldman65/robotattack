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
#define maxMinSpeed 10
#define bfgCount 10
#define testSpeed 0
#define bottomAchieve 20000
#define ufo1Score 100
#define ufo2Score 200
#define ufo3Score 300
#define ufo4Score 400

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
@property (strong, nonatomic) IBOutlet UIImageView *alien5Image;

@property (strong, nonatomic) IBOutlet UIImageView *fireball;
@property (strong, nonatomic) IBOutlet UILabel *fireballLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bigShield;

@property (retain, nonatomic) AVAudioPlayer *ammoPlayer;
@property (retain, nonatomic) AVAudioPlayer *overPlayer;
@property (retain, nonatomic) AVAudioPlayer *whooshPlayer;

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
@property (nonatomic) float alien5VelocityX;
@property (nonatomic) float alien5VelocityY;

@property (nonatomic) float shield1VelocityX;
@property (nonatomic) float shield1VelocityY;

@property (nonatomic) float bigShieldVelocityX;
@property (nonatomic) float bigShieldVelocityY;

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
BOOL alien4InFlight;
BOOL alien5InFlight;

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

CGPoint alien1Vector, alien2Vector, alien3Vector, alien4Vector, alien5Vector;
CGPoint fireballVector, shield1Vector, bigShieldVector, ammoLaunchPosition, fireballEnd;
CGPoint alien1End, alien2End, alien3End, alien4End, alien5End;


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
    
    // Game Over sound
    
    resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/gameOver.mp3"];
    
    self.overPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    
    if(err)
    {
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else
    {
        self.overPlayer.delegate = self;
        self.overPlayer.numberOfLoops = 0;
        self.overPlayer.currentTime = 0;
        self.overPlayer.volume = 1.0;
    }
    
    // Whoosh sound
    
    resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/whoosh.mp3"];
    
    self.whooshPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    
    if(err)
    {
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else
    {
        self.whooshPlayer.delegate = self;
        self.whooshPlayer.numberOfLoops = 0;
        self.whooshPlayer.currentTime = 0;
        self.whooshPlayer.volume = 1.0;
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
    self.alien5Image.hidden = false;
    self.shield1Image.hidden = false;
    self.fireball.hidden = false;
    timePassed = 0;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (fireballCount > 0)
    {
        self.alien1Image.center = CGPointMake(-200, [self randomHeight]);
        self.alien2Image.center = CGPointMake(screenWidth + 200, [self randomHeight]);
        self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight - 200);
        self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 200);
        self.alien5Image.center = CGPointMake(200, [self randomHeight]);
        fireballCount--;
        self.fireballLabel.text = [NSString stringWithFormat:@"%d", fireballCount];
     //   score = score + ufo1Score + ufo2Score + ufo3Score + ufo4Score + ufo1Score;
        if(soundIsOn)
        {
            [self.ammoPlayer play];
        }
    }
}

-(void)initGame
{
    score = 0;
    shield = 100;
    minSpeed = 2.0;     // starting min speed
    fireballCount = 0;
    self.scoreLabel.text = @"Score: 0";
    self.shieldLabel.text = @"100";
    self.fireballLabel.text = @"0";
    self.character.transform = CGAffineTransformMakeRotation(0.0);
    self.character.alpha = 1.0;
    self.character.center = CGPointMake(screenWidth/2, (screenHeight - controlHeight)/2);

    self.alien1Image.center = CGPointMake(-100, [self randomHeight]);
    self.alien2Image.center = CGPointMake(2*screenWidth, [self randomHeight]);
    self.alien3Image.center = CGPointMake([self randomWidth], -3*screenHeight);
    self.alien4Image.center = CGPointMake([self randomWidth], 5*screenHeight);
    self.alien5Image.center = CGPointMake(10*screenWidth, [self randomHeight]);

    self.shield1Image.center = CGPointMake(7*screenWidth, [self randomHeight]);
    self.bigShield.center = CGPointMake(-18*screenWidth, [self randomHeight]);
    self.fireball.center = CGPointMake(-4*screenWidth, [self randomHeight]);

    ammoInFlight = false;
    fireballInFlight = false;
    
    alien1InFlight = false;
    alien2InFlight = false;
    alien3InFlight = false;
    alien4InFlight = false;
    alien5InFlight = false;
    
    self.charVelocityX = 0;
    self.charVelocityY = 0;
    
    [self moveAmmoAway];

    self.alien1Image.hidden = true;
    self.alien2Image.hidden = true;
    self.alien3Image.hidden = true;
    self.alien4Image.hidden = true;
    self.alien5Image.hidden = true;
    self.shield1Image.hidden = true;
    self.fireball.hidden = true;
}

-(void)gameGuts
{
    timePassed = timePassed + .05;
    minSpeed = minSpeed + 0.001;
    
    if(minSpeed >= deviceScaler*maxMinSpeed)
    {
        minSpeed = deviceScaler*maxMinSpeed;
    }
    
    self.character.image = [UIImage imageNamed:@"spaceShipStill.png"];
    
    if ([LeftViewController isInLeft])
    {
        self.character.image = [UIImage imageNamed:@"spaceShip.png"];
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
    [self moveAlien5];
    [self moveShields];
    [self moveBigShields];
    [self moveFireball];
    [self collisionBetweenCharAndAliens];
    [self collisionBetweenAmmoAndAliens];
    [self collisionBetweenCharAndShield];
    [self collisionBetweenCharAndBigShield];
    [self collisionBetweenCharAndFireball];
}

-(void)movePlayer
{
    self.charVelocityX = deviceScaler*charSpeedScale*[LeftViewController findDistanceX];
    self.charVelocityY = deviceScaler*charSpeedScale*[LeftViewController findDistanceY];
    
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
    
    self.ammoVelocityX = deviceScaler*ammoSpeedScale*distX;
    self.ammoVelocityY = deviceScaler*ammoSpeedScale*distY;
    
    self.ammoImage.center = CGPointMake(self.character.center.x, self.character.center.y);
    
    [self.ammoTimer invalidate];
    self.ammoTimer = [NSTimer scheduledTimerWithTimeInterval:0.30 target:self selector:@selector(ammoStopped) userInfo:nil repeats:NO];

}


-(void)ammoStopped
{
    ammoInFlight = false;
}


-(void)moveAlien1
{
    if(alien1InFlight)
    {
        alien1Vector.x = alien1End.x -  self.alien1Image.center.x;
        alien1Vector.y = alien1End.y - self.alien1Image.center.y;
        double mag = [self magnitude:alien1Vector];
        
        if (mag < 10)
        {
            alien1InFlight = false;
            self.alien1Image.center = CGPointMake(-100, [self randomHeight]);
        }
        
        self.alien1VelocityX = deviceScaler*[self randomSpeed]*alien1Vector.x/mag;
        self.alien1VelocityY = deviceScaler*[self randomSpeed]*alien1Vector.y/mag;
        self.alien1Image.center = CGPointMake(self.alien1Image.center.x + self.alien1VelocityX, self.alien1Image.center.y + self.alien1VelocityY);
        
    } else {
        
        alien1End.x = screenWidth + 100;
        alien1End.y = [self randomHeight];
        alien1InFlight = true;
    }
}

-(void)moveAlien2
{
    if(alien2InFlight)
    {
        alien2Vector.x = alien2End.x -  self.alien2Image.center.x;
        alien2Vector.y = alien2End.y - self.alien2Image.center.y;
        double mag = [self magnitude:alien2Vector];
        
        if (mag < 10)
        {
            alien2InFlight = false;
            self.alien2Image.center = CGPointMake(screenWidth + 100, [self randomHeight]);
        }
        
        self.alien2VelocityX = deviceScaler*[self randomSpeed]*alien2Vector.x/mag;
        self.alien2VelocityY = deviceScaler*[self randomSpeed]*alien2Vector.y/mag;
        self.alien2Image.center = CGPointMake(self.alien2Image.center.x + self.alien2VelocityX, self.alien2Image.center.y + self.alien2VelocityY);
        
    } else {
        
        alien2End.x = -100;
        alien2End.y = [self randomHeight];
        alien2InFlight = true;
    }
}


-(void)moveAlien3
{
    if(alien3InFlight)
    {
        alien3Vector.x = alien3End.x -  self.alien3Image.center.x;
        alien3Vector.y = alien3End.y - self.alien3Image.center.y;
        double mag = [self magnitude:alien3Vector];
        
        if (mag < 10)
        {
            alien3InFlight = false;
            self.alien3Image.center = CGPointMake([self randomWidth], -100);
        }
        
        self.alien3VelocityX = deviceScaler*[self randomSpeed]*alien3Vector.x/mag;
        self.alien3VelocityY = deviceScaler*[self randomSpeed]*alien3Vector.y/mag;
        self.alien3Image.center = CGPointMake(self.alien3Image.center.x + self.alien3VelocityX, self.alien3Image.center.y + self.alien3VelocityY);
        
    } else {
        
        alien3End.x = [self randomWidth];
        alien3End.y = screenHeight + 100;
        alien3InFlight = true;
    }
}


-(void)moveAlien4
{
    if(alien4InFlight)
    {
        alien4Vector.x = alien4End.x -  self.alien4Image.center.x;
        alien4Vector.y = alien4End.y - self.alien4Image.center.y;
        double mag = [self magnitude:alien4Vector];
        
        if (mag < 10)
        {
            alien4InFlight = false;
            self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 100);
        }
        
        self.alien4VelocityX = deviceScaler*[self randomSpeed]*alien4Vector.x/mag;
        self.alien4VelocityY = deviceScaler*[self randomSpeed]*alien4Vector.y/mag;
        self.alien4Image.center = CGPointMake(self.alien4Image.center.x + self.alien4VelocityX, self.alien4Image.center.y + self.alien4VelocityY);
        
    } else {
        
        alien4End.x = [self randomWidth];
        alien4End.y = -100;
        alien4InFlight = true;
    }
}


-(void)moveAlien5
{
    if(alien5InFlight)
    {
        alien5Vector.x = alien5End.x -  self.alien5Image.center.x;
        alien5Vector.y = alien5End.y - self.alien5Image.center.y;
        double mag = [self magnitude:alien5Vector];
        
        if (mag < 10)
        {
            alien5InFlight = false;
            self.alien5Image.center = CGPointMake(screenWidth + 100, [self randomHeight]);
        }
        
        self.alien5VelocityX = deviceScaler*[self randomSpeed]*alien5Vector.x/mag;
        self.alien5VelocityY = deviceScaler*[self randomSpeed]*alien5Vector.y/mag;
        self.alien5Image.center = CGPointMake(self.alien5Image.center.x + self.alien5VelocityX, self.alien5Image.center.y + self.alien5VelocityY);
        
    } else {
        
        alien5End.x = -100;
        alien5End.y = [self randomHeight];
        alien5InFlight = true;
    }
}



-(void)moveShields
{
    self.shield1Image.transform = CGAffineTransformMakeRotation(5*timePassed);
    shield1Vector.x = self.character.center.x -  self.shield1Image.center.x;
    shield1Vector.y = self.character.center.y - self.shield1Image.center.y;
    double Mag = [self magnitude:shield1Vector];
    self.shield1VelocityX = deviceScaler*[self randomSpeed]*shield1Vector.x/Mag;
    self.shield1VelocityY = deviceScaler*[self randomSpeed]*shield1Vector.y/Mag;
    self.shield1Image.center = CGPointMake(self.shield1Image.center.x + self.shield1VelocityX, self.shield1Image.center.y + self.shield1VelocityY);
}


-(void)moveBigShields
{
    bigShieldVector.x = self.character.center.x -  self.bigShield.center.x;
    bigShieldVector.y = self.character.center.y - self.bigShield.center.y;
    double Mag = [self magnitude:bigShieldVector];
    self.bigShieldVelocityX = deviceScaler*[self randomSpeed]*bigShieldVector.x/Mag;
    self.bigShieldVelocityY = deviceScaler*[self randomSpeed]*bigShieldVector.y/Mag;
    self.bigShield.center = CGPointMake(self.bigShield.center.x + self.bigShieldVelocityX, self.bigShield.center.y + self.bigShieldVelocityY);
}

-(void)moveFireball
{
    if(fireballInFlight)
    {
        self.fireball.transform = CGAffineTransformMakeRotation(5*timePassed);
        fireballVector.x = fireballEnd.x -  self.fireball.center.x;
        fireballVector.y = fireballEnd.y - self.fireball.center.y;
        double mag = [self magnitude:fireballVector];
        
        if (mag < 10)
        {
            fireballInFlight = false;
            self.fireball.center = CGPointMake(-4*screenWidth, [self randomHeight]);
        }
    
        self.fireballVelocityX = deviceScaler*[self randomSpeed]*fireballVector.x/mag;
        self.fireballVelocityY = deviceScaler*[self randomSpeed]*fireballVector.y/mag;
        self.fireball.center = CGPointMake(self.fireball.center.x + self.fireballVelocityX, self.fireball.center.y + self.fireballVelocityY);
        
    } else {
        
        fireballEnd.x = screenWidth + 100;
        fireballEnd.y = [self randomHeight];
        fireballInFlight = true;
    }
}


-(void)collisionBetweenCharAndAliens
{
    if(CGRectIntersectsRect(self.character.frame, self.alien1Image.frame))
    {
        score = score + ufo1Score;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
        
        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien1Image.center = CGPointMake(-100, [self randomHeight]);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien2Image.frame))
    {
        score = score + ufo2Score;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];

        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien2Image.center = CGPointMake(screenWidth + 100, [self randomHeight]);
            NSLog(@"random = (%f, %f)", self.alien2Image.center.x, self.alien2Image.center.y);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien3Image.frame))
    {
        score = score + ufo3Score;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];

        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight - 100);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien4Image.frame))
    {
        score = score + ufo4Score;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];

        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
        
            self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 100);
            shield = shield - 10.0;
            self.character.alpha = .007*shield + 0.30;
            self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        }
    }
    
    if(CGRectIntersectsRect(self.character.frame, self.alien5Image.frame))
    {
        score = score + ufo1Score;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
        
        if (shield <= 0)
        {
            [self gameOver];
            
        } else {
            
            self.alien5Image.center = CGPointMake(screenWidth + 100, [self randomHeight]);
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
        score = score + ufo1Score;
        self.alien1Image.center = CGPointMake(-100, [self randomHeight]);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien2Image.frame))
    {
        score = score + ufo2Score;
        self.alien2Image.center = CGPointMake(screenWidth + 100, [self randomHeight]);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien3Image.frame))
    {
        score = score + ufo3Score;
        self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight - 100);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien4Image.frame))
    {
        score = score + ufo4Score;
        self.alien4Image.center = CGPointMake([self randomWidth], screenHeight + 100);
        self.ammoImage.center = CGPointMake(100000, 100000);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    }
    
    if(CGRectIntersectsRect(self.ammoImage.frame, self.alien5Image.frame))
    {
        score = score + ufo1Score;
        self.alien5Image.center = CGPointMake(screenWidth + 100, [self randomHeight]);
        self.ammoImage.center = CGPointMake(100000, 100000);
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

        self.shield1Image.center = CGPointMake(7*screenWidth, [self randomHeight]);
        self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        self.character.alpha = .007*shield + 0.30;
    }
}


-(void)collisionBetweenCharAndBigShield
{
    if(CGRectIntersectsRect(self.character.frame, self.bigShield.frame))
    {
        shield = shield + 100;
        
        if (shield > 100)
        {
            shield = 100;
        }
        
        self.bigShield.center = CGPointMake(-18*screenWidth, [self randomHeight]);
        self.shieldLabel.text = [NSString stringWithFormat:@"%d", shield];
        self.character.alpha = .007*shield + 0.30;
    }
}


-(void)collisionBetweenCharAndFireball
{
    if(CGRectIntersectsRect(self.character.frame, self.fireball.frame))
    {
        fireballCount = fireballCount + 1;
        self.fireball.center = CGPointMake(-4*screenWidth, [self randomHeight]);
        self.fireballLabel.text = [NSString stringWithFormat:@"%d", fireballCount];
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
    if(soundIsOn)
    {
        [self.overPlayer play];
    }
    self.shieldLabel.text = @"0";
    self.playButton.hidden = false;
    self.character.hidden = true;
    self.alien1Image.hidden = true;
    self.alien2Image.hidden = true;
    self.alien3Image.hidden = true;
    self.alien4Image.hidden = true;
    self.alien5Image.hidden = true;
    self.shield1Image.hidden = true;
    self.fireball.hidden = true;
    
    [self moveAmmoAway];
}

-(double)randomSpeed
{
    NSLog(@"speed = %f", minSpeed);
    return arc4random()%4 + minSpeed + testSpeed;
}

-(int)randomValue  // Delta outside of screen bounds
{
    return arc4random()%100 + 50.0;
}


-(int)randomHeight
{
    int minY = 0;
    int maxY = screenHeight - controlHeight;
    int range = maxY - minY;
    return (arc4random() % range) + minY;
}

-(int)randomWidth
{
    int minX = 0;
    int maxX = screenWidth;
    int range = maxX - minX;
    return (arc4random() % range) + minX;
}

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
    
    if(score >= 3*bottomAchieve)
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

-(double)magnitude:(CGPoint)point
{
    return sqrt(point.x*point.x + point.y*point.y);
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
