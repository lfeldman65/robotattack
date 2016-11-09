//
//  TutorialViewController
//  Bowling
//
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface TutorialViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *tilesRemainingLabel;
@property (assign,nonatomic)  int currentLevel;


@end
