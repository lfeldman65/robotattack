//
//  CollectionViewController.m
//  Golden Trail
//
//  Copyright © 2016 Larry Feldman. All rights reserved. Test


#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "Puzzle.h"
#import "Shop.h"


@interface CollectionViewController ()

@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, strong) Puzzle* currentPuzzle;
@property (assign,nonatomic)  int secondsElapsed;
@property (assign,nonatomic)  int tilesRemaining;
@property (strong,nonatomic)  IBOutlet UIButton* nextLevelButton;
@property (strong, nonatomic) IBOutlet UIButton *previousLevelButton;
@property (assign, nonatomic) SystemSoundID selectSound;
@property (retain, nonatomic) AVAudioPlayer *ambientPlayer;
@property (retain, nonatomic) AVAudioPlayer *selectPlayer;
@property (strong, nonnull) UIColor *greenishColor;
@property (strong, nonnull) UIColor *yellowishColor;



- (IBAction)resetPressed:(id)sender;
- (IBAction)backPressed:(id)sender;

@end

@implementation CollectionViewController


static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.greenishColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
  //  self.yellowishColor = [UIColor colorWithRed:0.99 green:0.84 blue:0.0 alpha:1.0];
    self.yellowishColor = [UIColor yellowColor];

    // Select Sound
    
    NSString *selectSoundPath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: selectSoundPath], &_selectSound);
    
    NSError* err;
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/pop.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    
    self.selectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    
    if(err)
    {
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else
    {
        self.selectPlayer.delegate = self;
        self.selectPlayer.currentTime = 0;
        self.selectPlayer.volume = 0.5;
    }

    self.nextLevelButton.hidden = false;
    
    self.previousLevelButton.hidden = false;
    
    if(self.currentLevel == 1)
    {
        self.previousLevelButton.hidden = true;
    }
    
    if(self.currentLevel == numFullLevels)
    {
        self.nextLevelButton.hidden = true;
    }

    self.levelLabel.text = [NSString stringWithFormat:@"Level: %d", self.currentLevel];

    [self configureLevel:self.currentLevel];
    
    self.myCollectionView.allowsMultipleSelection = true;
    
    [self resetTimer];

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
                NSString*str = dict[@"Text"];
                
                if (str.length > 0)
                {
                    cell.textLable.text = dict[@"Text"];
                    cell.selected = true;
                }
            }
        }
        
        rowNumber++;
    }
    
    
    if(cell.selected)
    {
        cell.backgroundColor = self.yellowishColor;
        
    } else {
        
        cell.backgroundColor = self.greenishColor;
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"soundOn"])
    {
       // AudioServicesPlayAlertSound(self.selectSound);
        [self.selectPlayer play];

    }
    
    NSLog(@"select index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = self.yellowishColor;
    
    self.tilesRemaining--;
    [self updateTilesRemaining];
    BOOL flag = [self testForGroupsOfFour:collectionView];
    NSLog(@"flag = %d", flag);
}


-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = self.greenishColor;
    self.tilesRemaining++;
    [self updateTilesRemaining];
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float f = (self.myCollectionView.frame.size.width-16) / 8;
    return CGSizeMake(f, f);
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
    
    BOOL anyGroupsOfFour = [self testForGroupsOfFour:collectionView];
    
    if(anyGroupsOfFour)
    {
        return false;
    }
    
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
                else if(row == self.currentPuzzle.endIndexPath.row && section == self.currentPuzzle.endIndexPath.section)
                {
                    if (neighbors > 1)
                        return false;
                }
                else if (neighbors != 2)
                {
                    return false;
                }
            }
        }
    }

    return true;
}

-(BOOL)testForGroupsOfFour:(UICollectionView *)collectionView {
    
    UICollectionViewCell *cell;
    UICollectionViewCell *cellRight;
    UICollectionViewCell *cellSE;
    UICollectionViewCell *cellBelow;
    
    NSIndexPath *ip;
    NSIndexPath *ipRight;
    NSIndexPath *ipSE;
    NSIndexPath *ipBelow;
    
    for(int section = 0; section < 8; section++)
    {
        for (int row = 0; row < 8; row++)
        {
            ip = [NSIndexPath indexPathForRow:row inSection:section];
            ipRight = [NSIndexPath indexPathForRow:row+1 inSection:section];
            ipSE = [NSIndexPath indexPathForRow:row+1 inSection:section+1];
            ipBelow = [NSIndexPath indexPathForRow:row inSection:section+1];
            
            cell = [collectionView cellForItemAtIndexPath:ip];
            cellRight = [collectionView cellForItemAtIndexPath:ipRight];
            cellSE = [collectionView cellForItemAtIndexPath:ipSE];
            cellBelow = [collectionView cellForItemAtIndexPath:ipBelow];
            
            if(cell.selected && cellRight.selected && cellSE.selected && cellBelow.selected)
            {
                return true;
            }
        }
    }
    return false;
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
            
            NSString *key = [NSString stringWithFormat:@"bestTime%d", self.currentLevel];
            NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:key];
            
            if (best == infinity)
            {
                self.bestTime.text = [NSString stringWithFormat:@"Completion Time: %ld sec", (long)self.secondsElapsed];
            
                [[NSUserDefaults standardUserDefaults] setInteger:self.secondsElapsed forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self checkFreeLevelsComplete];
                [self checkFullLevelsComplete];
                
               // [[GameCenterManager sharedManager] saveAndReportScore:self.secondsElapsed leaderboard:key sortOrder:GameCenterSortOrderLowToHigh];
            }
            self.tilesRemainingLabel.text = @"You won!";
        }
    }
}

-(void)checkFreeLevelsComplete
{
    BOOL freeLevelsAreComplete = true;
    
    for (int i = 1; i <= numFreeLevels; i++)
    {
        NSString *bestTimeKey = [NSString stringWithFormat:@"bestTime%d", i];
        NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:bestTimeKey];
        if(best == infinity)
        {
            freeLevelsAreComplete = false;
        }
    }
    
    if(freeLevelsAreComplete)
    {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.lfeldman.golden.lp1" percentComplete:100.00 shouldDisplayNotification:true];
    }
}

-(void)checkFullLevelsComplete
{
    BOOL fullLevelsAreComplete = true;
    
    for (int i = 1; i <= numFullLevels; i++)
    {
        NSString *bestTimeKey = [NSString stringWithFormat:@"bestTime%d", i];
        NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:bestTimeKey];
        if(best == infinity)
        {
            fullLevelsAreComplete = false;
        }
    }
    
    if(fullLevelsAreComplete)
    {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.lfeldman.golden.lp2" percentComplete:100.00 shouldDisplayNotification:true];
    }
}


-(void)configureLevel:(int) level
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", level]  ofType:@"plist"];
    
    self.currentPuzzle = [[Puzzle alloc] initWithFilePath:plistPath];
    
    NSString *key = [NSString stringWithFormat:@"bestTime%d", self.currentLevel];
    
    NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    
    if (best == infinity)
    {
        self.bestTime.text = @"Completion Time: N/A";
        
    } else {
        
        self.bestTime.text = [NSString stringWithFormat:@"Completion Time: %ld sec", (long)best];
    }
    
    self.tilesRemaining = self.currentPuzzle.numberOfTiles;
    [self updateTilesRemaining];
}

-(void) resetTimer
{
    [self.levelTimer invalidate];
    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeElapsed) userInfo:nil repeats:YES];
    self.secondsElapsed = 0;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %d sec", self.secondsElapsed];
}

- (IBAction)resetPressed:(id)sender
{
    [self configureLevel:self.currentLevel];
    [self resetTimer];
    [self.myCollectionView reloadData];
}

- (IBAction)backPressed:(id)sender
{    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)previousLevelPressed:(id)sender
{
    self.currentLevel--;
    [self changeLevels];
}

- (IBAction)nextLevelPressed:(id)sender
{
    if(self.currentLevel >= numFreeLevels)
    {
        NSNumber* fullVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"fullVersion"];
        BOOL full = [fullVersion boolValue];
        
        if (full)
        {
            self.currentLevel++;
            [self changeLevels];
            
        } else {
            
            [self offerPurchase];
        }
        
    } else {
        
        self.currentLevel++;
        [self changeLevels];
    }
}


-(void)changeLevels
{
    self.levelLabel.text = [NSString stringWithFormat:@"Level: %d", self.currentLevel];
    NSString *key = [NSString stringWithFormat:@"bestTime%d", self.currentLevel];
    NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    if (best == infinity)
    {
        self.bestTime.text = @"Completion Time: N/A";
        
    } else {
        
        self.bestTime.text = [NSString stringWithFormat:@"Completion Time: %ld sec", (long)best];
    }
    [self resetPressed:nil];
    [self resetTimer];
    self.nextLevelButton.hidden = false;
    self.previousLevelButton.hidden = false;
    
    if(self.currentLevel == numFullLevels)
    {
        self.nextLevelButton.hidden = true;
    }
    
    if(self.currentLevel == 1)
    {
        self.previousLevelButton.hidden = true;
    }
    
}

-(void)offerPurchase
{
    NSLog(@"offer purchase");
    [self.ourNewShop validateProductIdentifiers];
}


- (Shop *)ourNewShop
{
    if (!_ourNewShop) {
        _ourNewShop = [[Shop alloc] init];
        _ourNewShop.delegate = self;
    }
    return _ourNewShop;
}



-(void) timeElapsed
{
    self.secondsElapsed++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %d sec", self.secondsElapsed];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: {
            [self.ourNewShop makeThePurchase];
            break;
            
        }
            
        case 1: {
            [self.ourNewShop restoreThePurchase];
            break;
            
        }
            
        default: {
            break;
        }
    }
}



@end
