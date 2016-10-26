//
//  CollectionViewController.m
//  Golden Trail
//
//  Copyright © 2016 Larry Feldman. All rights reserved.


#import "CollectionViewController.h"
#import "CollectionViewCell.h"

@interface CollectionViewController ()

@property (nonatomic, strong) NSIndexPath *tileIndex;
@property (nonatomic, strong) NSMutableArray *level1;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (assign,nonatomic)  int secondsElapsed;

- (IBAction)resetPressed:(id)sender;
- (IBAction)backPressed:(id)sender;

@end

@implementation CollectionViewController

int tilesRemaining;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureLevel];
    self.myCollectionView.allowsMultipleSelection = true;
    tilesRemaining = 18;
    self.tilesRemaining.text = [NSString stringWithFormat:@"Tiles Remaining: %d", tilesRemaining];
    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeElapsed) userInfo:nil repeats:YES];
    self.secondsElapsed = 0;
    
    NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:@"bestTime"];
    if (best == 10000000)
    {
        self.bestTime.text = @"Best Time: Never Completed";
        
    } else {
    
        self.bestTime.text = [NSString stringWithFormat:@"Best Time: %ld sec", (long)best];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

    for(NSIndexPath *ip in self.level1)
    {
        if(indexPath.section == ip.section && indexPath.row == ip.row)
        {
            cell.textLable.text = @"👍";
            cell.selected = true;
        }
    }
    if(indexPath.section == 7 && indexPath.row == 0)
    {
        cell.textLable.text = @"Start";
    }
    
    if(indexPath.section == 0 && indexPath.row == 7)
    {
        cell.textLable.text = @"End";
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
    if(!(indexPath.section == 7 && indexPath.row == 0) && !(indexPath.section == 0 && indexPath.row == 7))
    {
        tilesRemaining--;
        self.tilesRemaining.text = [NSString stringWithFormat:@"Tiles Remaining: %d", tilesRemaining];
        if(!tilesRemaining)
        {
            if([self didWin:collectionView])
            {
                self.tilesRemaining.text = @"You won!";
            }
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    if(!(indexPath.section == 7 && indexPath.row == 0) && !(indexPath.section == 0 && indexPath.row == 7))
    {
        cell.backgroundColor = [UIColor greenColor];
        tilesRemaining++;
        self.tilesRemaining.text = [NSString stringWithFormat:@"Tiles Remaining: %d", tilesRemaining];
        if(!tilesRemaining)
        {
            if([self didWin:collectionView])
            {
                self.tilesRemaining.text = @"You won!";
            }
        }
    }
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
            
            if(row == 0 && section == 7)  // Make sure start cell has exactly 1 neighbor
            {
                ipRight = [NSIndexPath indexPathForRow:1 inSection:7];
                cellRight = [collectionView cellForItemAtIndexPath:ipRight];
                
                ipAbove = [NSIndexPath indexPathForRow:0 inSection:6];
                cellAbove = [collectionView cellForItemAtIndexPath:ipAbove];
                
                if(cellRight.selected && cellAbove.selected)    // can't have both cells highlighted
                {
                    return false;
                }
                
                if(!cellRight.selected && !cellAbove.selected) {  // can't have both cells empty
                    
                    return false;
                }
            }
            
            else if(row == 7 && section == 0)  // Make sure end cell has exactly 2 neighbors
            {
                ipLeft = [NSIndexPath indexPathForRow:1 inSection:7];
                cellLeft = [collectionView cellForItemAtIndexPath:ipLeft];
                
                ipBelow = [NSIndexPath indexPathForRow:0 inSection:6];
                cellBelow = [collectionView cellForItemAtIndexPath:ipBelow];
                
                if(cellLeft.selected && cellBelow.selected)     // can't have both cells highlighted
                {
                    return false;
                }
                
                if(!cellLeft.selected && !cellBelow.selected)   // can't have both cells empty

                {
                    return false;
                }
            }
            
            else if(cell.selected)
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
                if (neighbors != 2)
                {
                    return false;
                }
            }
        }
    }
  //  [self.view setUserInteractionEnabled:NO];
    [self.levelTimer invalidate];
    
    NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:@"bestTime"];
    
    if (self.secondsElapsed < best)
    {
        self.bestTime.text = [NSString stringWithFormat:@"Best Time: %ld sec", (long)self.secondsElapsed];
        [[NSUserDefaults standardUserDefaults] setInteger:self.secondsElapsed forKey:@"bestTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    //    [[GameCenterManager sharedManager] saveAndReportScore:(int)lastGame leaderboard:@"assaultHighScore" sortOrder:GameCenterSortOrderHighToLow];
        
    }
    return true;
}

-(void)configureLevel  // visible tiles only
{
    self.tileIndex = [NSIndexPath indexPathForRow:7 inSection:0];    // start
    self.level1 = [NSMutableArray arrayWithObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:5 inSection:3];
    [self.level1 addObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:0 inSection:3];
    [self.level1 addObject:self.tileIndex];

    self.tileIndex = [NSIndexPath indexPathForRow:2 inSection:2];
    [self.level1 addObject:self.tileIndex];

    self.tileIndex = [NSIndexPath indexPathForRow:4 inSection:4];
    [self.level1 addObject:self.tileIndex];
    
 //   self.tileIndex = [NSIndexPath indexPathForRow:6 inSection:4];
 //   [self.level1 addObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:2 inSection:5];
    [self.level1 addObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:0 inSection:7];    // end
    [self.level1 addObject:self.tileIndex];
}

- (IBAction)resetPressed:(id)sender
{
    [self.myCollectionView reloadData];
    [self configureLevel];
    tilesRemaining = 11;
    self.tilesRemaining.text = [NSString stringWithFormat:@"Tiles Remaining: %d", tilesRemaining];
}

- (IBAction)backPressed:(id)sender
{    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) timeElapsed
{
    self.secondsElapsed++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %d sec", self.secondsElapsed];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
