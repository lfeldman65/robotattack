//
//  LevelSelectViewController.m
//  Bowling
//
//  Created by Maurice on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "CollectionViewController.h"



@interface LevelSelectViewController ()
- (IBAction)homePressed:(id)sender;

@end

@implementation LevelSelectViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.levelArray = [NSArray arrayWithObjects: @"Level 1", @"Level 2", @"Level 3", @"Level 4", @"Level 5", nil];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.myTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLevel = (int)indexPath.row + 1;
    [self performSegueWithIdentifier:@"toGame" sender:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.levelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [self.levelArray objectAtIndex:indexPath.row];
    
    NSString *key = [NSString stringWithFormat:@"bestTime%d", (int)indexPath.row + 1];
    
    NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    if (best < 10000000)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }
    return cell;
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue identifier] isEqualToString:@"toGame"])
    {
        CollectionViewController* cvc = (CollectionViewController*) segue.destinationViewController;
        cvc.currentLevel = self.selectedLevel;
    }
}

- (IBAction)homePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
