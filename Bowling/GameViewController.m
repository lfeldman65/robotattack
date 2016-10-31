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

@property (weak, nonatomic) IBOutlet UISwitch* createLevelsSwitch;

@end


@implementation GameViewController

- (IBAction)createGameModeChanged:(id)sender {
    
    theAppDelegate().createLevelsMode = self.createLevelsSwitch.on;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasGameLaunched"])
    {
        NSString *infoString = @"Create a Golden Trail that connects the start tile to the end tile. Play level 1 to learn the rules.  As the saying goes, it's easy to learn and hard to master!";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:infoString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"wasGameLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Game Center
    
 //   [[GameCenterManager sharedManager] setDelegate:self];
    BOOL available = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    if (available) {
        NSLog(@"available");
    } else {
        NSLog(@"not available");
    }
    
    [[GKLocalPlayer localPlayer] authenticateHandler];
    
}


- (void)shoppingDone:(NSNotification *)notification {
    

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


- (IBAction)startPressed:(id)sender {
        
  
    
    
}


- (void)checkGameOver:(NSNotification *)notification {
    
    if ([[notification name] isEqualToString:@"gameOverNotification"]) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        NSLog(@"game over");
        
        self.startButton.hidden = NO;
        self.settingsButton.hidden = NO;
            
        self.highScoreLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.lastGameLabel.hidden = NO;
        self.bgImage.hidden = NO;
                
        NSInteger lastGame = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastGameScore"];
        
        //   NSLog(@"last game = %ld", (long)lastGame);
        
        NSString *lastGameString = [NSString stringWithFormat:@"Last Game: %ld", (long)lastGame];
        self.lastGameLabel.text = lastGameString;
        
        NSInteger numGames = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelNumber"];
        numGames++;
        
        [[NSUserDefaults standardUserDefaults] setInteger:numGames forKey:@"levelNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
        
        if (lastGame > best) {
            
            NSString *highScoreString = [NSString stringWithFormat:@"High Score: %ld", (long)lastGame];
            self.highScoreLabel.text = highScoreString;
            
            [[NSUserDefaults standardUserDefaults] setInteger:lastGame forKey:@"highScore"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[GameCenterManager sharedManager] saveAndReportScore:(int)lastGame leaderboard:@"assaultHighScore" sortOrder:GameCenterSortOrderHighToLow];
            
        }
        
        if (lastGame >=50 && lastGame < 100) {
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"50blocks" percentComplete:100 shouldDisplayNotification:YES];
        }
        
        if (lastGame >= 100 && lastGame < 250) {
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"100blocks" percentComplete:100 shouldDisplayNotification:YES];
        }
        
        if (lastGame >= 250) {
            [[GameCenterManager sharedManager] saveAndReportAchievement:@"250blocks" percentComplete:100 shouldDisplayNotification:YES];
        }
        

     /*   [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(soundChanged:)
                                                     name:@"soundDidChange"
                                                   object:nil];*/
        
        // every 10 games, offer full version if they don't already have it.

        if (![[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"levelNumber"]%10 == 0) {
            [self.ourNewShop validateProductIdentifiers];
            
        }
    }
}

/*
- (void)soundChanged:(NSNotification *)notification {
    
    if ([[notification name] isEqualToString:@"soundDidChange"]) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundOn"]) {
            
          //  [self.backgroundMusicPlayer prepareToPlay];
          //  [self.backgroundMusicPlayer play];
            
        } else {
            
        //    [self.backgroundMusicPlayer stop];
        }
    }
}*/


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toSettings"]){
        SettingsViewController *svc = (SettingsViewController *)[segue destinationViewController];
      //  svc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"toLevelSelector"]){
        CollectionViewController *cvc = (CollectionViewController *)[segue destinationViewController];
      //  svc.delegate = self;
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

@end
