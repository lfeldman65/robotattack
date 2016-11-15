//
//  AppDelegate.h
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Shop.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GameCenterManager.h"
#import <MediaPlayer/MediaPlayer.h>

#define numFullLevels 100
#define numFreeLevels 20
#define infinity 10000000

@import StoreKit;


@interface AppDelegate : UIResponder <UIApplicationDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL createLevelsMode;


@end

AppDelegate* theAppDelegate();
