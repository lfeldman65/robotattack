//
//  LevelSelectViewController.h
//  Bowling
//
//  Created by Maurice on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray *levelArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (assign,nonatomic) int selectedLevel;

@end
