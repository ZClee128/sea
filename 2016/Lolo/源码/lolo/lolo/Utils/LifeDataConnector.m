//
//  LifeDataConnector.m
//  lolo
//
//  Created on 2026/2/11.
//

#import "LifeDataConnector.h"
#import "DataService.h"

@interface LifeDataConnector () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSArray<SKProduct *> *products;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *starValueMap;
@end

@implementation LifeDataConnector

#pragma mark - Singleton

+ (LifeDataConnector *)defaultConnector {
    static LifeDataConnector *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _products = @[];
        _isLoading = NO;
        [self setupStarValueMap];
    }
    return self;
}

#pragma mark - Product Configuration

- (void)setupStarValueMap {
    // Map product identifiers to star amounts
    NSString *base = @"Lolo";
    
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[base] = @32;
    map[[base stringByAppendingString:@"1"]] = @60;
    map[[base stringByAppendingString:@"2"]] = @96;
    map[[base stringByAppendingString:@"4"]] = @155;
    map[[base stringByAppendingString:@"5"]] = @189;
    map[[base stringByAppendingString:@"9"]] = @359;
    map[[base stringByAppendingString:@"19"]] = @729;
    map[[base stringByAppendingString:@"49"]] = @1869;
    map[[base stringByAppendingString:@"99"]] = @3799;
    
    _starValueMap = [map copy];
}

- (NSInteger)starsForProductIdentifier:(NSString *)productIdentifier {
    NSNumber *value = self.starValueMap[productIdentifier];
    return value ? [value integerValue] : 0;
}

- (NSArray<NSString *> *)allProductIdentifiers {
    return [self.starValueMap allKeys];
}

#pragma mark - Transaction Observer

- (void)startObserving {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Load Products

- (void)loadProducts {
    if (self.isLoading) return;
    
    if (![SKPaymentQueue canMakePayments]) {
        NSError *error = [NSError errorWithDomain:@"LoloIAPError"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"In-app purchases are not allowed on this device."}];
        if ([self.delegate respondsToSelector:@selector(connectorProductsLoadFailed:)]) {
            [self.delegate connectorProductsLoadFailed:error];
        }
        return;
    }
    
    self.isLoading = YES;
    
    NSSet *productIdentifiers = [NSSet setWithArray:[self allProductIdentifiers]];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.isLoading = NO;
    self.productsRequest = nil;
    
    // Sort products by price (ascending)
    self.products = [response.products sortedArrayUsingComparator:^NSComparisonResult(SKProduct *p1, SKProduct *p2) {
        return [p1.price compare:p2.price];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorDidLoadProducts:)]) {
            [self.delegate connectorDidLoadProducts:self.products];
        }
    });
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    self.isLoading = NO;
    self.productsRequest = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorProductsLoadFailed:)]) {
            [self.delegate connectorProductsLoadFailed:error];
        }
    });
}

#pragma mark - Purchase

- (void)purchaseProduct:(SKProduct *)product {
    if (![SKPaymentQueue canMakePayments]) return;
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self handlePurchasedTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self handleFailedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self handleRestoredTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
            case SKPaymentTransactionStateDeferred:
                // No action needed
                break;
        }
    }
}

#pragma mark - Transaction Handling

- (void)handlePurchasedTransaction:(SKPaymentTransaction *)transaction {
    // Validate the receipt before granting stars
    if ([self validateReceiptForTransaction:transaction]) {
        NSString *productIdentifier = transaction.payment.productIdentifier;
        NSInteger stars = [self starsForProductIdentifier:productIdentifier];
        
        if (stars > 0) {
            [[DataService shared] addStars:stars];
            
            SKProduct *product = [self productForIdentifier:productIdentifier];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(connectorPurchaseSucceeded:stars:)]) {
                    [self.delegate connectorPurchaseSucceeded:product stars:stars];
                }
            });
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)handleFailedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code == SKErrorPaymentCancelled) {
        // User cancelled - notify delegate silently
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(connectorPurchaseCancelled)]) {
                [self.delegate connectorPurchaseCancelled];
            }
        });
    } else {
        // Actual error - report to delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(connectorPurchaseFailed:)]) {
                [self.delegate connectorPurchaseFailed:transaction.error];
            }
        });
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)handleRestoredTransaction:(SKPaymentTransaction *)transaction {
    // For consumable products, restore typically doesn't apply
    // but we handle it correctly regardless
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - Receipt Validation

- (BOOL)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    // Get the app receipt from the bundle
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if (!receiptURL) {
        NSLog(@"[LifeDataConnector] No receipt URL found");
        return NO;
    }
    
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    if (!receiptData || receiptData.length == 0) {
        NSLog(@"[LifeDataConnector] No receipt data found");
        return NO;
    }
    
    // Local receipt validation: verify the receipt exists and has data
    // For production, you should implement server-side receipt validation
    // by sending the receipt to your server which then validates with Apple
    
    // Verify the transaction has valid identifiers
    if (!transaction.payment.productIdentifier || transaction.payment.productIdentifier.length == 0) {
        NSLog(@"[LifeDataConnector] Invalid product identifier in transaction");
        return NO;
    }
    
    // Verify the transaction identifier exists
    if (!transaction.transactionIdentifier || transaction.transactionIdentifier.length == 0) {
        NSLog(@"[LifeDataConnector] Invalid transaction identifier");
        return NO;
    }
    
    return YES;
}

#pragma mark - Restore Delegates

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorRestoreCompleted:)]) {
            [self.delegate connectorRestoreCompleted:queue.transactions.count];
        }
    });
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorRestoreFailed:)]) {
            [self.delegate connectorRestoreFailed:error];
        }
    });
}

#pragma mark - Helpers

- (nullable SKProduct *)productForIdentifier:(NSString *)identifier {
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:identifier]) {
            return product;
        }
    }
    return nil;
}

@end
