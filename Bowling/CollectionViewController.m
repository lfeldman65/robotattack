//
//  CollectionViewController.m
//  Bowling
//
//  Created by Maurice on 10/24/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"

@interface CollectionViewController ()

@property (nonatomic, strong) NSIndexPath *tileIndex;
@property (nonatomic, strong) NSMutableArray *level1;
@property (nonatomic, strong) NSMutableArray *level2;
@property (nonatomic, strong) NSMutableArray *levels1To2;

@end

@implementation CollectionViewController

int tilesRemaining;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureLevel];
    self.myCollectionView.allowsMultipleSelection = true;
    tilesRemaining = 13;
    self.tilesRemaining.text = [NSString stringWithFormat:@"Tiles Remaining: %d", tilesRemaining];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.backgroundColor = [UIColor greenColor]; // default
    
    if(indexPath.section == 7 && indexPath.row == 0)
    {
        cell.backgroundColor = [UIColor yellowColor];  // start
        cell.textLable.text = @"Start";
    }
    
    if(indexPath.section == 0 && indexPath.row == 7)
    {
        cell.backgroundColor = [UIColor yellowColor];  // end
        cell.textLable.text = @"End";
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
            if([self didWin])
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

-(BOOL)didWin
{
    return true;
}

-(void)configureLevel  // visible tiles only
{
    self.tileIndex = [NSIndexPath indexPathForRow:7 inSection:0];    // start
    self.level1 = [NSMutableArray arrayWithObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:5 inSection:3];
    [self.level1 addObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:2 inSection:5];
    [self.level1 addObject:self.tileIndex];
    
    self.tileIndex = [NSIndexPath indexPathForRow:0 inSection:7];    // end
    [self.level1 addObject:self.tileIndex];
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

@end
