//
//  GameViewController.m
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "GameViewController.h"
#import "AppDelegate.h"

@interface GameViewController ()
- (IBAction)gameCenterPressed:(id)sender;
- (IBAction)soundSwitchChanged:(id)sender;
- (IBAction)fullVersionPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch* createLevelsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (strong, nonatomic) UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UILabel *levelCreationLabel;

@end


@implementation GameViewController

int numLeftSwipes = 0;

- (IBAction)createGameModeChanged:(id)sender
{
    theAppDelegate().createLevelsMode = self.createLevelsSwitch.on;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
   // self.levelCreationLabel.hidden = true;
   // self.createLevelsSwitch.hidden = true;
    
    // Game Center
    
    [[GameCenterManager sharedManager] setDelegate:self];
    BOOL available = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    if (available) {
        NSLog(@"available");
    } else {
        NSLog(@"not available");
    }
    
    [[GKLocalPlayer localPlayer] authenticateHandler];
    
    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeDetected)];
    self.leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:self.leftSwipe];
    
}

-(void)leftSwipeDetected
{
    NSLog(@"here");
    numLeftSwipes++;
    if(numLeftSwipes >= 3)
    {
        self.levelCreationLabel.hidden = false;
        self.createLevelsSwitch.hidden = false;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    
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
        NSString *infoString = @"Create a Golden Trail that connects tiles horizontally and vertically. Tap on the Tutorial to learn how to play. As with all good puzzles, it's easy to learn and hard to master!";
        [self showAlertWithTitle:@"Welcome!" message:infoString];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"wasGameLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

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
    
    if(self.soundSwitch.on) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"soundOn"];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"soundOn"];
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
