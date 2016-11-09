//
//  CollectionViewController.m
//  Golden Trail
//
//  Copyright © 2016 Larry Feldman. All rights reserved.


#import "TutorialViewController.h"
#import "CollectionViewCell.h"
#import "Puzzle.h"
#import "Shop.h"


@interface TutorialViewController ()

@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, strong) Puzzle* currentPuzzle;
@property (assign,nonatomic)  int secondsElapsed;
@property (assign,nonatomic)  int tilesRemaining;
@property (assign, nonatomic) SystemSoundID selectSound;

@property (strong, nonatomic) IBOutlet UITextView *instructionText;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)nextPressed:(id)sender;

@end

@implementation TutorialViewController

static NSString * const reuseIdentifier = @"Cell";
int step;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    step = 0;
    self.myCollectionView.userInteractionEnabled = false;

    [self configureLevel:self.currentLevel];
    
    self.myCollectionView.allowsMultipleSelection = true;
    
    self.instructionText.text = @"Welcome! Create a Golden Trail from the start tile to the end tile that passes through all of the 👍 tiles. Tap the Next button to continue.";
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &_selectSound);
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
    
    if(step == 3)
    {
        if (indexPath.section == 3 && indexPath.row == 3)
        {
            cell.selected = true;
        }
        if (indexPath.section == 3 && indexPath.row == 4)
        {
            cell.selected = true;
        }
        if (indexPath.section == 4 && indexPath.row == 4)
        {
            cell.selected = true;
        }
        if (indexPath.section == 4 && indexPath.row == 5)
        {
            cell.selected = true;
        }
        if (indexPath.section == 5 && indexPath.row == 3)
        {
            cell.selected = true;
        }
        if (indexPath.section == 6 && indexPath.row == 2)
        {
            cell.selected = true;
        }
    }
    
    if(step == 5)
    {
        if (indexPath.section == 2 && indexPath.row == 3)
        {
            cell.selected = true;
        }
        if (indexPath.section == 2 && indexPath.row == 4)
        {
            cell.selected = true;
        }
        if (indexPath.section == 2 && indexPath.row == 5)
        {
            cell.selected = true;
        }
        if (indexPath.section == 3 && indexPath.row == 3)
        {
            cell.selected = true;
        }
        if (indexPath.section == 5 && indexPath.row == 3)
        {
            cell.selected = true;
        }
        if (indexPath.section == 6 && indexPath.row == 2)
        {
            cell.selected = true;
        }
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
    NSLog(@"step = %d", step);
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"soundOn"])
    {
        AudioServicesPlayAlertSound(self.selectSound);
    }
    
    NSLog(@"select index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    
    self.tilesRemaining--;
    [self updateTilesRemaining];
    BOOL flag = [self testForGroupsOfFour:collectionView];
    NSLog(@"flag = %d", flag);

}


-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"step = %d", step);

    NSLog(@"deselect index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    cell.backgroundColor = [UIColor greenColor];
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
            self.tilesRemainingLabel.text = @"You won!";
        }
    }
}

-(void)configureLevel:(int) level
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"tutorial"]  ofType:@"plist"];
    self.currentPuzzle = [[Puzzle alloc] initWithFilePath:plistPath];
    self.tilesRemaining = self.currentPuzzle.numberOfTiles;
    [self updateTilesRemaining];
}



- (IBAction)backPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)nextPressed:(id)sender {
    
    if (step == 0)
    {
        self.myCollectionView.userInteractionEnabled = true;
        self.instructionText.text = @"Tap on green tiles to turn them yellow. Every time you add a yellow tile, the number of tiles remaining drops by one. Try it!";
    }
    else if (step == 1)
    {
        self.instructionText.text = @"Now tap on the yellow tiles you just added to turn them back to green. Give it a shot!";
    }

    else if (step == 2)
    {
        self.myCollectionView.userInteractionEnabled = false;
        [self.myCollectionView reloadData];
        self.tilesRemainingLabel.text = @"Tiles Remaining: 0";
        self.instructionText.text = @"The Golden Trail never changes width, so the path above is not valid! Tap Next to continue.";
    }
    else if (step == 3)
    {
        self.myCollectionView.userInteractionEnabled = true;
        [self.myCollectionView reloadData];
        self.tilesRemainingLabel.text = @"Tiles Remaining: 3";
        self.instructionText.text = @"Connect tiles horizontally and vertically, not diagonally. Add yellow tiles until the number of tiles remaining is exactly 0! If you're stuck, tap Next to see the solution.";
    }
    else if (step == 4)
    {
        self.myCollectionView.userInteractionEnabled = false;
        [self.myCollectionView reloadData];
        self.instructionText.text = @"Easy, right?";
        self.tilesRemainingLabel.text = @"You won!";
        self.nextButton.hidden = true;
    }
    step++;
}
@end
