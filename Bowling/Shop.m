//
//  Shop.m
//  SpriteKitSimpleGame
//
//  Created by Larry Feldman on 4/13/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "Shop.h"

@implementation Shop

- (NSArray *)allProducts {
    
    if (!_allProducts) {
        _allProducts = @[@"com.lfeldman.golden.extra1"];
    }
    return _allProducts;
}

- (void)validateProductIdentifiers {
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:self.allProducts]];
    request.delegate = self;
    [request start];
    
}

- (void)makeThePurchase {
    
    // ask the app store to take a payment
    
    SKPayment *payment = [SKPayment paymentWithProduct:self.thisProduct];
    [[SKPaymentQueue defaultQueue]addPayment:payment];
    
}

- (void)restoreThePurchase {
    
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];

}

#pragma mark - SKProductsRequest Delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    // grab ref to product
    
    self.thisProduct = response.products.firstObject;
    if ([SKPaymentQueue canMakePayments]) {
        
        [self displayStoreUI];
        NSLog(@"We can buy");
        
    } else {
        
        [self cantBuyAnything];
        NSLog(@"We cannot buy");
    }
    
}

- (void)displayStoreUI {
    
    // create number formatter
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = self.thisProduct.priceLocale;
    NSString *price = [NSString stringWithFormat:@"Buy this for %@", [formatter stringFromNumber:self.thisProduct.price]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.thisProduct.localizedTitle message:self.thisProduct.localizedDescription delegate:self.delegate cancelButtonTitle:price otherButtonTitles:@"Restore Purchase", @"Maybe Later", nil];
    alertView.tag = 1;
    [alertView show];
    
    
}

- (void)cantBuyAnything
{
    [theAppDelegate() showAlertWithTitle:@"Cannot Buy" message:@"In-App purchases are disabled"];
}

@end
