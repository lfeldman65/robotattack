//
//  GameViewController.m
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

- (IBAction)gameCenterPressed:(id)sender;
- (IBAction)soundSwitchChanged:(id)sender;
- (IBAction)fullVersionPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (retain, nonatomic) AVAudioPlayer *ambientPlayer;
@property (strong, nonatomic) IBOutlet UILabel *highScoreLabel;

@property (strong, nonatomic) IBOutlet UIImageView *shield1Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien1Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien2Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien3Image;
@property (strong, nonatomic) IBOutlet UIImageView *alien4Image;
@property (strong, nonatomic) IBOutlet UIImageView *fireball;

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


@property (strong, nonatomic) NSTimer *gameTimer;

@end

@implementation GameViewController

BOOL fireballInFlight2;
BOOL alien1InFlight2;
BOOL alien2InFlight2;
BOOL alien3InFlight2;
BOOL alien4InFlight2;
BOOL shieldInFlight;
int deviceScaler1;

double timePassed2;


CGPoint alien1Vector2, alien2Vector2, alien3Vector2, alien4Vector2, fireballVector2, shield1Vector2, fireballEnd2, shieldEnd;
CGPoint alien1End2, alien2End2, alien3End2, alien4End2;

double screenWidth2;
double screenHeight2;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    screenWidth2 = self.view.frame.size.width;
    screenHeight2 = self.view.frame.size.height;
    
    // Background sound

    NSNumber* soundOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundOn"];
    BOOL soundIsOn = [soundOn boolValue];
    
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/alienBG.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    self.ambientPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    
    if(err)
    {
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else
    {
        self.ambientPlayer.delegate = self;
        
        if(soundIsOn)
        {
            [self.ambientPlayer play];
        }
        self.ambientPlayer.numberOfLoops = -1;
        self.ambientPlayer.currentTime = 0;
        self.ambientPlayer.volume = 0.3;
    }
    
    // Game Center
    
    [[GameCenterManager sharedManager] setDelegate:self];
    BOOL available = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    if (available) {
        NSLog(@"available");
    } else {
        NSLog(@"not available");
    }
    
    [[GKLocalPlayer localPlayer] authenticateHandler];
    
    deviceScaler1 = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        deviceScaler1 = 2;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    timePassed2 = 0;

    self.alien1Image.center = CGPointMake([self randomWidth], [self randomHeight]);
    self.alien2Image.center = CGPointMake([self randomWidth], [self randomHeight]);
    self.alien3Image.center = CGPointMake([self randomWidth], [self randomHeight]);
    self.alien4Image.center = CGPointMake([self randomWidth], [self randomHeight]);
    
    self.fireball.center = CGPointMake(-50, [self randomHeight]);

    self.shield1Image.center = CGPointMake(screenWidth2 + 50, [self randomHeight]);
    self.fireball.center = CGPointMake(-screenWidth2, [self randomHeight]);
    
    alien1InFlight2 = false;
    alien2InFlight2 = false;
    alien3InFlight2 = false;
    alien4InFlight2 = false;
    fireballInFlight2 = false;
    shieldInFlight = false;

    NSNumber* sound = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundOn"];
    BOOL soundOn = [sound boolValue];
    if(soundOn)
    {
        self.soundSwitch.on = true;
        
    } else {
        
        self.soundSwitch.on = false;
    }
    
    NSNumber* launched = [[NSUserDefaults standardUserDefaults] objectForKey:@"wasGameLaunched"];
    BOOL wasLaunched = [launched boolValue];
    
    if (!wasLaunched)
    {
     //   NSString *infoString = @"blah blah";
     //   [self showAlertWithTitle:@"Prepare for Lift Off" message:infoString];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"wasGameLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    int currentHSInt = [currentHighScore intValue];
    self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %d", currentHSInt];
    
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameGuts) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.gameTimer invalidate];
}


-(void)gameGuts
{
    timePassed2 = timePassed2 + .05;
    
    if(alien1InFlight2)
    {
        alien1Vector2.x = alien1End2.x -  self.alien1Image.center.x;
        alien1Vector2.y = alien1End2.y - self.alien1Image.center.y;
        double Mag = sqrt(alien1Vector2.x*alien1Vector2.x + alien1Vector2.y*alien1Vector2.y);
        
        if (Mag < 10)
        {
            alien1InFlight2 = false;
            self.alien1Image.center = CGPointMake(-50, [self randomHeight]);
        }
        
        self.alien1VelocityX = 4*deviceScaler1*alien1Vector2.x/Mag;
        self.alien1VelocityY = 4*deviceScaler1*alien1Vector2.y/Mag;
        self.alien1Image.center = CGPointMake(self.alien1Image.center.x + self.alien1VelocityX, self.alien1Image.center.y + self.alien1VelocityY);
        
    } else {
        
        alien1End2.x = screenWidth2 + 50;
        alien1End2.y = [self randomHeight];
        alien1InFlight2 = true;
    }
    
    if(alien2InFlight2)
    {
        alien2Vector2.x = alien2End2.x -  self.alien2Image.center.x;
        alien2Vector2.y = alien2End2.y - self.alien2Image.center.y;
        double Mag = sqrt(alien2Vector2.x*alien2Vector2.x + alien2Vector2.y*alien2Vector2.y);
        
        if (Mag < 10)
        {
            alien2InFlight2 = false;
            self.alien2Image.center = CGPointMake(screenWidth2 + 50, [self randomHeight]);
        }
        
        self.alien2VelocityX = 4*deviceScaler1*alien2Vector2.x/Mag;
        self.alien2VelocityY = 4*deviceScaler1*alien2Vector2.y/Mag;
        self.alien2Image.center = CGPointMake(self.alien2Image.center.x + self.alien2VelocityX, self.alien2Image.center.y + self.alien2VelocityY);
        
    } else {
        
        alien2End2.x = -50;
        alien2End2.y = [self randomHeight];
        alien2InFlight2 = true;
    }
    
    if(alien3InFlight2)
    {
        alien3Vector2.x = alien3End2.x -  self.alien3Image.center.x;
        alien3Vector2.y = alien3End2.y - self.alien3Image.center.y;
        double Mag = sqrt(alien3Vector2.x*alien3Vector2.x + alien3Vector2.y*alien3Vector2.y);
        
        if (Mag < 10)
        {
            alien3InFlight2 = false;
            self.alien3Image.center = CGPointMake([self randomWidth], -screenHeight2 - 50);
        }
        
        self.alien3VelocityX = 4*deviceScaler1*alien3Vector2.x/Mag;
        self.alien3VelocityY = 4*deviceScaler1*alien3Vector2.y/Mag;
        self.alien3Image.center = CGPointMake(self.alien3Image.center.x + self.alien3VelocityX, self.alien3Image.center.y + self.alien3VelocityY);
        
    } else {
        
        alien3End2.x = [self randomWidth];
        alien3End2.y = screenHeight2 + 50;
        alien3InFlight2 = true;
    }
    
    if(alien4InFlight2)
    {
        alien4Vector2.x = alien4End2.x -  self.alien4Image.center.x;
        alien4Vector2.y = alien4End2.y - self.alien4Image.center.y;
        double Mag = sqrt(alien4Vector2.x*alien4Vector2.x + alien4Vector2.y*alien4Vector2.y);
        
        if (Mag < 10)
        {
            alien4InFlight2 = false;
            self.alien4Image.center = CGPointMake([self randomWidth], screenHeight2 + 50);
        }
        
        self.alien4VelocityX = 4*deviceScaler1*alien4Vector2.x/Mag;
        self.alien4VelocityY = 4*deviceScaler1*alien4Vector2.y/Mag;
        self.alien4Image.center = CGPointMake(self.alien4Image.center.x + self.alien4VelocityX, self.alien4Image.center.y + self.alien4VelocityY);
        
    } else {
        
        alien4End2.x = [self randomWidth];
        alien4End2.y = -50;
        alien4InFlight2 = true;
    }
    
    if(fireballInFlight2)
    {
        fireballVector2.x = fireballEnd2.x -  self.fireball.center.x;
        fireballVector2.y = fireballEnd2.y - self.fireball.center.y;
        double Mag = sqrt(fireballVector2.x*fireballVector2.x + fireballVector2.y*fireballVector2.y);
        self.fireball.transform = CGAffineTransformMakeRotation(5*timePassed2);
        
        if (Mag < 10)
        {
            fireballInFlight2 = false;
            self.fireball.center = CGPointMake(-50, [self randomHeight]);
        }
        
        self.fireballVelocityX = 4*deviceScaler1*fireballVector2.x/Mag;
        self.fireballVelocityY = 4*deviceScaler1*fireballVector2.y/Mag;
        self.fireball.center = CGPointMake(self.fireball.center.x + self.fireballVelocityX, self.fireball.center.y + self.fireballVelocityY);
        
    } else {
        
        fireballEnd2.x = screenWidth2 + 50;
        fireballEnd2.y = [self randomHeight];
        fireballInFlight2 = true;
    }
    
    if(shieldInFlight)
    {
        shield1Vector2.x = shieldEnd.x -  self.shield1Image.center.x;
        shield1Vector2.y = shieldEnd.y - self.shield1Image.center.y;
        double Mag = sqrt(shield1Vector2.x*shield1Vector2.x + shield1Vector2.y*shield1Vector2.y);
        self.shield1Image.transform = CGAffineTransformMakeRotation(5*timePassed2);
        
        if (Mag < 10)
        {
            shieldInFlight = false;
            self.shield1Image.center = CGPointMake(screenWidth2 + 50, [self randomHeight]);
        }
        
        self.shield1VelocityX = 4*deviceScaler1*shield1Vector2.x/Mag;
        self.shield1VelocityY = 4*deviceScaler1*shield1Vector2.y/Mag;
        self.shield1Image.center = CGPointMake(self.shield1Image.center.x + self.shield1VelocityX, self.shield1Image.center.y + self.shield1VelocityY);
        
    } else {
        
        shieldEnd.x = -50;
        shieldEnd.y = [self randomHeight];
        shieldInFlight = true;
    }

}


-(int)randomHeight
{
    int minY = 0;
    int maxY = screenHeight2 - 50;
    int rangeY = maxY - minY;
    return (arc4random() % rangeY) + minY;
}

-(int)randomWidth
{
    int minY = 0;
    int maxY = screenWidth2;
    int rangeY = maxY - minY;
    return (arc4random() % rangeY) + minY;
}


- (void)shoppingDone:(NSNotification *)notification
{
    NSLog(@"shopping done");
}

- (Shop *)ourNewShop {
    
    if (!_ourNewShop) {
        _ourNewShop = [[Shop alloc] init];
        _ourNewShop.delegate = self;
    }
    return _ourNewShop;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: {
            [self.ourNewShop makeThePurchase];
            break;
            
        }
            
        case 1: {
            [self.ourNewShop restoreThePurchase];
            break;
            
        }
            
        default: {
            break;
        }
    }
}


# pragma mark - Game Center


- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availabilty: %@", availabilityInformation);
    if ([[availabilityInformation objectForKey:@"status"] isEqualToString:@"GameCenter Available"]) {
        
        NSLog(@"Game Center is online, the current player is logged in, and this app is setup.");
        
    } else {
        
     //   NSLog(@"error here1");
    }
    
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GCM Error: %@", error);
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (gameCenterViewController.viewState == GKGameCenterViewControllerStateAchievements) {
        NSLog(@"Displayed GameCenter achievements.");
    } else if (gameCenterViewController.viewState == GKGameCenterViewControllerStateLeaderboards) {
        NSLog(@"Displayed GameCenter leaderboard.");
    } else {
        NSLog(@"Displayed GameCenter controller.");
    }
}

-(void) showLeaderboard {
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self];
}

- (void) loadChallenges {
    // This feature is only supported in iOS 6 and higher (don't worry - GC Manager will check for you and return NIL if it isn't available)
    [[GameCenterManager sharedManager] getChallengesWithCompletion:^(NSArray *challenges, NSError *error) {
        NSLog(@"GC Challenges: %@ | Error: %@", challenges, error);
    }];
}

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    [self presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)gameCenterPressed:(id)sender
{
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self];
}

- (IBAction)soundSwitchChanged:(id)sender {
    
    if(self.soundSwitch.on)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"soundOn"];
        [self.ambientPlayer play];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"soundOn"];
        [self.ambientPlayer pause];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)fullVersionPressed:(id)sender {
    
    NSLog(@"offer purchase");
    [self.ourNewShop validateProductIdentifiers];

}

-(void) showAlertWithTitle:(NSString*) title message:(NSString*) msg
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
