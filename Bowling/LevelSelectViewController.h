//
//  LevelSelectViewController.h
//  Bowling
//
//  Created by Maurice on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface LevelSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property(nonatomic, strong) NSMutableArray *levelArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (assign,nonatomic) int selectedLevel;

@end
