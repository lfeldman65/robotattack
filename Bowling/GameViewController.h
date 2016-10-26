//
//  GameViewController.h
//  Bowling
//

//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "SettingsViewController.h"
#import "CollectionViewController.h"
#import "Shop.h"


@interface GameViewController : UIViewController <GameCenterManagerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UILabel *lastGameLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;


@property (nonatomic) Shop *ourNewShop;




@end
