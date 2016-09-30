//
//  SettingsViewController.h
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import <iAd/iAd.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GameCenterManager.h"
#import <MediaPlayer/MediaPlayer.h>


@class SettingsViewController;

@protocol SettingsDelegate

- (void)settingsDidFinish:(SettingsViewController *) controller;

@end


@interface SettingsViewController : UIViewController

@property (weak, nonatomic) id <SettingsDelegate> delegate;


@end
