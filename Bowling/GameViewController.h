//
//  GameViewController.h
//  Bowling
//

//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "SettingsViewController.h"
#import "Shop.h"


@interface GameViewController : UIViewController <GameCenterManagerDelegate, ADBannerViewDelegate, SettingsDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) SKScene *scene;
@property (nonatomic, strong) SKView *skView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UILabel *lastGameLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *webAddress;


@property (nonatomic) Shop *ourNewShop;




@end
