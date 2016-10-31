//
//  Shop.h
//  SpriteKitSimpleGame
//
//  Created by Larry Feldman on 4/13/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@import StoreKit;

@interface Shop : NSObject <SKProductsRequestDelegate>

@property (nonatomic) NSArray *allProducts;
@property (nonatomic) SKProduct *thisProduct;
@property (weak) id delegate;

- (void)validateProductIdentifiers;
- (void)makeThePurchase;
- (void)restoreThePurchase;

@end
