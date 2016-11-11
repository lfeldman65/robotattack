//
//  AppDelegate.m
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved. Test.
//

#import "AppDelegate.h"


AppDelegate* theAppDelegate()
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption

{
    [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    
    NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:false], @"wasGameLaunched",
                                  [NSNumber numberWithInt:1], @"levelNumber",
                                  [NSNumber numberWithBool:false], @"fullVersion",
                                  [NSNumber numberWithBool:true], @"soundOn",
                                  nil];
    
    for (int i = 1; i <= numFullLevels; i++)
    {
        NSString *bestTimeKey = [NSString stringWithFormat:@"bestTime%d", i];
        [defaultsDict setObject:[NSNumber numberWithInt:infinity] forKey:bestTimeKey];
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                [self unlockFullVersion];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
            }
                
            case SKPaymentTransactionStatePurchasing: {
                
                break;
                
            }
                
            case SKPaymentTransactionStateRestored: {
                
                [self unlockFullVersion];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Full Version successfully restored" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                
                NSLog(@"failure");
                break;
            }
                
            default:
                break;
                
        }
    }
}

- (void)unlockFullVersion
{    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"fullVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
