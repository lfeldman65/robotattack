//
//  GameViewController.h
//  Bowling
//

//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import "AppDelegate.h"


@interface GameViewController : UIViewController <GameCenterManagerDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic) Shop *ourNewShop;

@end
