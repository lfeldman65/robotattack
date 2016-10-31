//
//  LevelSelectViewController.h
//  Bowling
//
//  Created by Maurice on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//
/* I added the ability to create/edit a puzzle with user interface and saves it to a plist. After creating puzzles, you can zip them up and mail the plist to yourself.
 
 The work flow goes like this - Toggle the Levels Creation Mode to On. Then go into Levels, you can create new level or edit one of the existing levels. Once you are done, click Save. The Save does not check if your puzzle is valid, so for now, it’s up to the creator to make sure it’s valid. After you have created all the levels. You can zip them up and mail them to yourself to be added into the project.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Shop.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GameCenterManager.h"
#import <MediaPlayer/MediaPlayer.h>


@interface LevelSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property(nonatomic, strong) NSMutableArray *levelArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (assign,nonatomic) int selectedLevel;
@property (nonatomic) Shop *ourNewShop;


@end
