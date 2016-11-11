//
//  CollectionViewController.h
//  Bowling
//
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface CollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *tilesRemainingLabel;
@property (strong, nonatomic) IBOutlet UILabel *bestTime;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (assign,nonatomic)  int currentLevel;
@property (nonatomic) Shop *ourNewShop;


@end
