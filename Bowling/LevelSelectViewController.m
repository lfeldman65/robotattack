//
//  LevelSelectViewController.m
//  Bowling
//
//  Created by Maurice on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "CreateLevelsViewController.h"
#import "SSZipArchive.h"

@interface LevelSelectViewController ()

//- (IBAction)homePressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *zipButton;
@end

@implementation LevelSelectViewController


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



- (IBAction)zipAndMail:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:documentsPath]
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'plist'"];
    
    NSMutableArray* arrayOfPList = [NSMutableArray arrayWithCapacity:10];
    
    for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
    
        [arrayOfPList addObject:fileURL.path];
    }
    
    if (arrayOfPList.count == 0)
    {
        [self showAlertWithTitle:@"No Files" message:@"There are no puzzles to zip up"];

        return;
    }
    
    NSString* zipFile = [documentsPath stringByAppendingPathComponent: @"puzzles.zip"];
    
    [[NSFileManager defaultManager] removeItemAtPath:zipFile error:nil];
    
    
    [SSZipArchive createZipFileAtPath:zipFile withFilesAtPaths:arrayOfPList];
    
    [self showEmail:zipFile];
}


- (void)showEmail:(NSString*)file {
    
    NSString *emailTitle = @"Here are your puzzles for Golden Trail";
    NSString *messageBody = @"";
    //NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    //[mc setToRecipients:toRecipents];
    
    // Determine the file name and extension
    NSArray *filepart = [file componentsSeparatedByString:@"."];
  //  NSString *filename = [filepart objectAtIndex:0];
    NSString *extension = [filepart objectAtIndex:1];
    
    // Get the resource path and read the file using NSData
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    NSData *fileData = [NSData dataWithContentsOfFile:file];
    
    // Determine the MIME type
    NSString *mimeType;
    if ([extension isEqualToString:@"zip"]) {
        mimeType = @"application/zip";
    } else if ([extension isEqualToString:@"png"]) {
        mimeType = @"image/png";
    } else if ([extension isEqualToString:@"doc"]) {
        mimeType = @"application/msword";
    } else if ([extension isEqualToString:@"ppt"]) {
        mimeType = @"application/vnd.ms-powerpoint";
    } else if ([extension isEqualToString:@"html"]) {
        mimeType = @"text/html";
    } else if ([extension isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    }
    
    // Add attachment
    [mc addAttachmentData:fileData mimeType:mimeType fileName:@"puzzles.zip"];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.zipButton.hidden = !theAppDelegate().createLevelsMode;
    int level = 1;
    
    self.levelArray = [NSMutableArray arrayWithCapacity:10];
    while (YES)
    {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", level]  ofType:@"plist"];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *localPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.plist", level]];
        
        
        if ((plistPath.length > 0) || ([[NSFileManager defaultManager] fileExistsAtPath:localPath]))
        {
            [self.levelArray addObject:[NSString stringWithFormat:@"Level %d", level]];
        }
        else
        {
            if (theAppDelegate().createLevelsMode)
            {
                [self.levelArray insertObject:@"New Level" atIndex:0];
            }
            
            break;
        }
        
        level += 1;
    }

}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.myTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* level = [self.levelArray objectAtIndex:indexPath.row];
    
    level = [level stringByReplacingOccurrencesOfString:@"Level " withString:@""];
    
    
    if (theAppDelegate().createLevelsMode)
    {
        if (indexPath.row == 0)
        {
            self.selectedLevel = (int)self.levelArray.count;
        }
        else
        {
            self.selectedLevel = level.intValue;
        }
        
        [self performSegueWithIdentifier:@"toLevelsCreation" sender:nil];
    }
    else
    {
        self.selectedLevel = level.intValue;
        
        if (self.selectedLevel >= 5) {
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"fullVersion"])
            {
                [self performSegueWithIdentifier:@"toGame" sender:nil];

            } else {
                
                [self offerPurchase];
                
            }
            
        } else {
        
            [self performSegueWithIdentifier:@"toGame" sender:nil];
        }
    
    }
}

-(void)offerPurchase
{
    NSLog(@"offer purchase");
    [self.ourNewShop validateProductIdentifiers];

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
    
    
    if (theAppDelegate().createLevelsMode == NO)
    {
        NSString *key = [NSString stringWithFormat:@"bestTime%d", (int)indexPath.row + 1];
        
        NSInteger best = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        if (best < 10000000)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;

        }
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
    else if ([[segue identifier] isEqualToString:@"toLevelsCreation"])
    {
        CreateLevelsViewController* cvc = (CreateLevelsViewController*) segue.destinationViewController;
        cvc.currentLevel = self.selectedLevel;
        
        
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", self.selectedLevel]  ofType:@"plist"];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *localPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.plist", self.selectedLevel]];
        
        NSString* puzzlePath = localPath;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPath])
        {
            puzzlePath = plistPath;
        }
        
        cvc.currentPuzzle = [[Puzzle alloc] initWithFilePath: puzzlePath];
    }
}

- (IBAction)homePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (Shop *)ourNewShop
{
    if (!_ourNewShop) {
        _ourNewShop = [[Shop alloc] init];
        _ourNewShop.delegate = self;
    }
    return _ourNewShop;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
