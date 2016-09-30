//
//  GameViewController.m
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "GameViewController.h"


@implementation GameViewController

int iAdHeight;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
        self.iAdOutlet.hidden = YES;
    } else {
        self.iAdOutlet.hidden = NO;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        iAdHeight = 66;
    }
    else {
        
        iAdHeight = 50;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkGameOver:)
                                                 name:@"gameOverNotification"
                                               object:nil];
    
  /*  [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(soundChanged:)
                                                 name:@"soundDidChange"
                                               object:nil];*/
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasGameLaunched"]) {
        
        NSString *infoString = @"Block Assault is the love child of Space Invaders and Breakout. Please go to the Settings screen to read the full instructions.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:infoString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"wasGameLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    NSString *lGS = [NSString stringWithFormat:@"Last Game: %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"lastGameScore"]];
    self.lastGameLabel.text = lGS;
    
    NSString *hSS = [NSString stringWithFormat:@"High Score: %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]];
    self.highScoreLabel.text = hSS;
    
    // Game Center
    
    [[GameCenterManager sharedManager] setDelegate:self];
    BOOL available = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    if (available) {
        NSLog(@"available");
    } else {
        NSLog(@"not available");
    }
    
    [[GKLocalPlayer localPlayer] authenticateHandler];
    
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    float sWidth = [UIScreen mainScreen].bounds.size.width;    // 4S: width = 320
    float sHeight = [UIScreen mainScreen].bounds.size.height;  // 4S: height = 480
    
    [self.bgImage setFrame:CGRectMake(0, 0, sWidth, sHeight)];
    self.bgImage.center = CGPointMake(sWidth/2, sHeight/2);
    
    [self.settingsButton setFrame:CGRectMake(0, 0, .1*sWidth, .1*sWidth)];
    self.settingsButton.center = CGPointMake(.9*sWidth, 0.12*sHeight);
    
    [self.titleLabel setFrame:CGRectMake(0, 0, sWidth, .09*sHeight)];
    [[self titleLabel] setFont:[UIFont fontWithName:@"Noteworthy" size:.11*sWidth]];
    self.titleLabel.center = CGPointMake(.5*sWidth, .23*sHeight);

    [self.lastGameLabel setFrame:CGRectMake(0, 0, .5*sWidth, .11*sHeight)];
    self.lastGameLabel.font = [UIFont fontWithName: @"Noteworthy" size: .07*sWidth];
    self.lastGameLabel.center = CGPointMake(.5*sWidth, .4*sHeight);
    
    [self.highScoreLabel setFrame:CGRectMake(0, 0, .5*sWidth, .11*sHeight)];
    self.highScoreLabel.font = [UIFont fontWithName: @"Noteworthy" size: .07*sWidth];
    self.highScoreLabel.center = CGPointMake(.5*sWidth, .6*sHeight);
    
    [self.startButton setFrame:CGRectMake(0, 0, sWidth, .1*sWidth)];
    self.startButton.titleLabel.font = [UIFont fontWithName: @"Noteworthy" size: .09*sWidth];
    self.startButton.center = CGPointMake(.5*sWidth, .8*sHeight);
    
    [self.bgImage setFrame:CGRectMake(0, 0, sWidth, sHeight)];
    self.bgImage.center = CGPointMake(.5*sWidth, .5*sHeight);
    
    [self.webAddress setFrame:CGRectMake(0, 0, sWidth, .1*sWidth)];
    self.webAddress.font = [UIFont fontWithName: @"Noteworthy" size: .06*sWidth];
    self.webAddress.center = CGPointMake(sWidth/2, .96*sHeight);
    
    [self.iAdOutlet setFrame:CGRectMake(0, sHeight - iAdHeight, sWidth, iAdHeight)];
    

}

- (void)shoppingDone:(NSNotification *)notification {
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
        self.iAdOutlet.hidden = YES;
    } else {
        self.iAdOutlet.hidden = NO;
    }
    
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
        
    // Configure the view.
    
    self.skView = (SKView *)self.view;
    if (!self.skView.scene) {
        self.skView.showsFPS = NO;
        self.skView.showsNodeCount = NO;
    }
    
    self.startButton.hidden = YES;
    self.settingsButton.hidden = YES;
    self.highScoreLabel.hidden = YES;
    self.titleLabel.hidden = YES;
    self.lastGameLabel.hidden = YES;
    self.bgImage.hidden = YES;
    self.iAdOutlet.hidden = YES;
    self.webAddress.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkGameOver:)
                                                 name:@"gameOverNotification"
                                               object:nil];
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(soundChanged:)
                                                 name:@"soundDidChange"
                                               object:nil];*/
    
    self.scene = [[GameScene alloc] initWithSize:self.skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    [self.skView presentScene:self.scene];
    
}


- (void)checkGameOver:(NSNotification *)notification {
    
    if ([[notification name] isEqualToString:@"gameOverNotification"]) {
        
        [self.scene removeFromParent];
        [self.skView presentScene:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        NSLog(@"game over");
        
        self.startButton.hidden = NO;
        self.settingsButton.hidden = NO;
        
        [self.scene removeFromParent];
        [self.skView presentScene:nil];
        
        self.highScoreLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.lastGameLabel.hidden = NO;
        self.bgImage.hidden = NO;
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
            self.iAdOutlet.hidden = YES;
        } else {
            self.iAdOutlet.hidden = NO;
        }
        
        self.webAddress.hidden = NO;
        
        NSInteger lastGame = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastGameScore"];
        
        //   NSLog(@"last game = %ld", (long)lastGame);
        
        NSString *lastGameString = [NSString stringWithFormat:@"Last Game: %ld", (long)lastGame];
        self.lastGameLabel.text = lastGameString;
        
        NSInteger numGames = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberGames"];
        numGames++;
        
        [[NSUserDefaults standardUserDefaults] setInteger:numGames forKey:@"numberGames"];
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

        if (![[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"numberGames"]%10 == 0) {
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

-(void)settingsDidFinish:(SettingsViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
        self.iAdOutlet.hidden = YES;
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toSettings"]){
        SettingsViewController *svc = (SettingsViewController *)[segue destinationViewController];
        svc.delegate = self;
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


#pragma mark - iAd

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"fullVersion"]) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        [banner setAlpha:1];
        [UIView commitAnimations];
      //  NSLog(@"here");
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [banner setAlpha:0];
    [UIView commitAnimations];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
