//
//  CreateLevelsViewController.m
//  Bowling
//
//  Created by Kennedy Kok on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "CreateLevelsViewController.h"
#import "CollectionViewCell.h"
#import "Puzzle.h"


@interface CreateLevelsViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *tilesToCompleteLabel;

@property (assign, nonatomic) BOOL alreadyHasStart;
@property (assign, nonatomic) BOOL alreadyHasEnd;
@property (assign, nonatomic) int tilesToComplete;

@end

@implementation CreateLevelsViewController


-(void) setTilesToComplete:(int)tilesToComplete
{
    _tilesToComplete = tilesToComplete;
    self.tilesToCompleteLabel.text = [NSString stringWithFormat:@"Tiles to Complete = %d", _tilesToComplete];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myCollectionView.allowsMultipleSelection = true;
    
    if (self.currentPuzzle == nil)
    {
        self.currentPuzzle = [Puzzle new];
    }
    
    self.levelLabel.text = [NSString stringWithFormat:@"Level %d", self.currentLevel];
    
    self.tilesToComplete = 0;
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.myCollectionView reloadData];
    
    __weak typeof(self) ws = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [ws countTilesToComplete];
    });
    
}


-(void) countTilesToComplete
{
    int tempTilesCount = 0;
    for (int row = 0; row < 8; row++)
    {
        for (int col = 0; col < 8; col++)
        {
            CollectionViewCell *cell = (CollectionViewCell*) [_myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:col inSection:row]];
            
            if (cell.selected)
            {
                if (cell.textLable.text.length == 0)
                    tempTilesCount++;
                
                if ([cell.textLable.text isEqualToString:@"Start"])
                    _alreadyHasStart = YES;
                else if ([cell.textLable.text isEqualToString:@"End"])
                    _alreadyHasEnd = YES;
                
            }
        }
    }

    self.tilesToComplete = tempTilesCount;
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
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    //cell.selected = NO;
    //cell.textLable.text = @"";
    cell.selected = NO;
    cell.textLable.text = @"";
    
    int rowNumber = 0;
    for (NSArray* r in self.currentPuzzle.puzzleArray)
    {
        for (NSDictionary* dict in r)
        {
            NSNumber* column = dict[@"Column"];
            
            if ((rowNumber == indexPath.section) && ([column intValue] == indexPath.row))
            {
                cell.textLable.text = dict[@"Text"];
                cell.selected = true;
                [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                
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
    CollectionViewCell *cell = (CollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    
    cell.textLable.text = [_mySegmentedControl titleForSegmentAtIndex: _mySegmentedControl.selectedSegmentIndex];
    
    if ([cell.textLable.text isEqualToString:@"Start"])
    {
        if (self.alreadyHasStart)
        {
            [theAppDelegate() showAlertWithTitle:@"Duplicate" message:@"There is already a Start tile"];
            cell.textLable.text = @"";
            cell.selected = NO;
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            cell.backgroundColor = [UIColor greenColor];
            //[self collectionView:_myCollectionView didDeselectItemAtIndexPath:indexPath];
        }
        else
        {
            self.alreadyHasStart = true;
        }
    }
    else if ([cell.textLable.text isEqualToString:@"End"])
    {
        if (self.alreadyHasEnd)
        {
            [theAppDelegate() showAlertWithTitle:@"Duplicate" message:@"There is already an End tile"];
            cell.textLable.text = @"";
            cell.selected = NO;
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            cell.backgroundColor = [UIColor greenColor];
            //[self collectionView:_myCollectionView didDeselectItemAtIndexPath:indexPath];
        }
        else
        {
            self.alreadyHasEnd = true;
        }
    }
    
    
    [self countTilesToComplete];
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect index path = %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    CollectionViewCell *cell = (CollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];

    cell.backgroundColor = [UIColor greenColor];

    if ([cell.textLable.text isEqualToString:@"Start"])
    {
        self.alreadyHasStart = false;
    }
    else if ([cell.textLable.text isEqualToString:@"End"])
    {
        self.alreadyHasEnd = false;
    }
    
    cell.textLable.text = @"";
    
    [self countTilesToComplete];
   
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float f = (_myCollectionView.frame.size.width-16) / 8;
    
    return CGSizeMake(f, f);
    
    //return CGSizeMake(30.0, 30.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1; // This is the minimum inter item spacing, can be more
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}




- (IBAction)savePressed:(id)sender {
    
    int tilesCount = 0;
    
    for (int row = 0; row < 8; row++)
    {
        for (int col = 0; col < 8; col++)
        {
            CollectionViewCell *cell = (CollectionViewCell*) [_myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:col inSection:row]];
            
            if (cell.selected)
            {
                NSMutableArray* mut =  self.currentPuzzle.puzzleArray[row];
                
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:10];
                
                dict[@"Column"] = [NSNumber numberWithInt:col];
                dict[@"Text"] = cell.textLable.text;
                
                [mut addObject:dict];
                
                if (cell.textLable.text.length > 0)
                {
                    
                }
                else
                {
                    tilesCount++;
                    
                }
            }
        }
    }
    
    self.currentPuzzle.numberOfTiles = tilesCount;
    
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.plist", self.currentLevel]];
    
    NSLog(@"file saved %@", filePath);
    
    BOOL ret = [self.currentPuzzle saveToFile:filePath];
    
    if (!ret)
    {
        [self showAlertWithTitle:@"Error" message:@"Failed to write"];
    }
    
}

-(void) showAlertWithTitle:(NSString*) title message:(NSString*) msg
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clearPressed:(id)sender {
    
    [_myCollectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
