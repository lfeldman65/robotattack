//
//  CollectionViewController.m
//  Golden Trail
//
//  Copyright © 2016 Larry Feldman. All rights reserved.


#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "Puzzle.h"


@interface CollectionViewController ()

@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, strong) Puzzle* currentPuzzle;
@property (assign,nonatomic)  int secondsElapsed;
@property (assign,nonatomic)  int tilesRemaining;
@property (assign,nonatomic)  int currentLevel;
@property (strong,nonatomic)  IBOutlet UIButton* nextLevelButton;

- (IBAction)resetPressed:(id)sender;
- (IBAction)backPressed:(id)sender;

@end

@implementation CollectionViewController


static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nextLevelButton.hidden = true;
    
    if (_currentLevel == 0)
    {
        NSNumber* num = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberGames"];
        
        _currentLevel = [num intValue] + 1;
    }
    
    
    [self configureLevel:_currentLevel];
    
    self.myCollectionView.allowsMultipleSelection = true;
    
    [self resetTimer];
    
    NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:@"bestTime"];
    if (best == 10000000)
    {
        self.bestTime.text = @"Best Time: Never Completed";
        
    } else {
    
        self.bestTime.text = [NSString stringWithFormat:@"Best Time: %ld sec", (long)best];
    }
}




#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 8;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selected = NO;
    cell.textLable.text = @"";
    
    int rowNumber = 0;
    for (NSArray* row in self.currentPuzzle.puzzleArray)
    {
        for (NSDictionary* dict in row)
        {
            NSNumber* column = dict[@"Column"];
            
            if ((rowNumber == indexPath.section) && ([column intValue] == indexPath.row))
            {
                cell.textLable.text = dict[@"Text"];
                cell.selected = true;
            }
        }
        
        rowNumber++;
    }
    
    
    if(cell.selected)
    {
        cell.backgroundColor = [UIColor yellowColor];
        
    } else {
        
        cell.backgroundColor = [UIColor greenColor];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    
    self.tilesRemaining--;
    [self updateTilesRemaining];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    cell.backgroundColor = [UIColor greenColor];
    self.tilesRemaining++;
    [self updateTilesRemaining];
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(30.0, 30.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1; // This is the minimum inter item spacing, can be more
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

-(BOOL)didWin:(UICollectionView *)collectionView
{
    UICollectionViewCell *cell;
    UICollectionViewCell *cellLeft;
    UICollectionViewCell *cellRight;
    UICollectionViewCell *cellAbove;
    UICollectionViewCell *cellBelow;

    NSIndexPath *ip;
    NSIndexPath *ipLeft;
    NSIndexPath *ipRight;
    NSIndexPath *ipAbove;
    NSIndexPath *ipBelow;
    
    for(int section = 0; section < 8; section++)
    {
        for (int row = 0; row < 8; row++)
        {
            int neighbors = 0;
            ip = [NSIndexPath indexPathForRow:row inSection:section];
            ipLeft = [NSIndexPath indexPathForRow:row-1 inSection:section];
            ipRight = [NSIndexPath indexPathForRow:row+1 inSection:section];
            ipAbove = [NSIndexPath indexPathForRow:row inSection:section+1];
            ipBelow = [NSIndexPath indexPathForRow:row inSection:section-1];

            cell = [collectionView cellForItemAtIndexPath:ip];
            cellLeft = [collectionView cellForItemAtIndexPath:ipLeft];
            cellRight = [collectionView cellForItemAtIndexPath:ipRight];
            cellAbove = [collectionView cellForItemAtIndexPath:ipAbove];
            cellBelow = [collectionView cellForItemAtIndexPath:ipBelow];
            
            if(cell.selected)
            {
                if(cellLeft.selected)
                {
                    neighbors++;
                }
                
                if(cellRight.selected)
                {
                    neighbors++;
                }
                
                if(cellAbove.selected)
                {
                    neighbors++;
                }
                
                if(cellBelow.selected)
                {
                    neighbors++;
                }
                
                
                if(row == self.currentPuzzle.startIndexPath.row && section == self.currentPuzzle.startIndexPath.section)
                {
                    if (neighbors > 1)
                        return false;
                }
                else
                if(row == self.currentPuzzle.endIndexPath.row && section == self.currentPuzzle.endIndexPath.section)
                {
                    if (neighbors > 1)
                        return false;
                }
                else
                if (neighbors != 2)
                {
                    return false;
                }
            }
        }
    }
  //  [self.view setUserInteractionEnabled:NO];
        return true;
}


-(void) updateTilesRemaining
{
    self.tilesRemainingLabel.text = [NSString stringWithFormat:@"Tiles Remaining: %d", self.tilesRemaining];
    if(!self.tilesRemaining)
    {
        
        //__weak typeof (self) ws = self;
        if([self didWin:self.myCollectionView])
        {
            [self.levelTimer invalidate];
            
            NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:@"bestTime"];
            
            if (self.secondsElapsed < best)
            {
                self.bestTime.text = [NSString stringWithFormat:@"Best Time: %ld sec", (long)self.secondsElapsed];
                [[NSUserDefaults standardUserDefaults] setInteger:self.secondsElapsed forKey:@"bestTime"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //    [[GameCenterManager sharedManager] saveAndReportScore:(int)lastGame leaderboard:@"assaultHighScore" sortOrder:GameCenterSortOrderHighToLow];
                
            }

            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_currentLevel] forKey:@"numberGames"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
            
            //_currentLevel += 1;
            
            self.tilesRemainingLabel.text = @"You won!";
            
            self.nextLevelButton.hidden = false;
            /*
            NSString* message = [NSString stringWithFormat:@"You completed this in %d secs", self.secondsElapsed];
            
            if (self.secondsElapsed < best)
            {
                message = [NSString stringWithFormat:@"You broke your record. You completed this in %d secs", self.secondsElapsed];
            }
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Good Job"
                                                                           message: message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                  
                                                                      ///[ws resetPressed:nil];
                                                                      //[ws resetTimer];
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            */
            
            
        }
    }
}

-(void)configureLevel:(int) level
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", level]  ofType:@"plist"];
    
    self.currentPuzzle = [[Puzzle alloc] initWithFilePath:plistPath];
    
    self.tilesRemaining = self.currentPuzzle.numberOfTiles;
    [self updateTilesRemaining];
    
}

-(void) resetTimer
{
    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeElapsed) userInfo:nil repeats:YES];
    self.secondsElapsed = 0;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %d sec", self.secondsElapsed];

}

- (IBAction)resetPressed:(id)sender
{
    [self configureLevel:_currentLevel];
    [self.myCollectionView reloadData];
}

- (IBAction)backPressed:(id)sender
{    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextLevelPressed:(id)sender
{
    _currentLevel +=1;
    
    [self resetPressed:nil];
    [self resetTimer];
    self.nextLevelButton.hidden = true;
}


-(void) timeElapsed
{
    self.secondsElapsed++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %d sec", self.secondsElapsed];
}


@end
