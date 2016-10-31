//
//  AppDelegate.h
//  Bowling
//
//  Created by Larry Feldman on 5/27/15.
//  Copyright (c) 2015 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
@import StoreKit;


@interface AppDelegate : UIResponder <UIApplicationDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL createLevelsMode;

@end

AppDelegate* theAppDelegate();
