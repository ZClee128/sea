//
//  LifeDataConnector.h
//  lolo
//
//  Created on 2026/2/11.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LifeDataConnectorDelegate <NSObject>
@optional
- (void)connectorDidLoadProducts:(NSArray<SKProduct *> *)products;
- (void)connectorProductsLoadFailed:(NSError *)error;
- (void)connectorPurchaseSucceeded:(SKProduct *)product stars:(NSInteger)stars;
- (void)connectorPurchaseFailed:(NSError *)error;
- (void)connectorPurchaseCancelled;
- (void)connectorRestoreCompleted:(NSInteger)count;
- (void)connectorRestoreFailed:(NSError *)error;
@end

@interface LifeDataConnector : NSObject

@property (nonatomic, weak) id<LifeDataConnectorDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<SKProduct *> *products;
@property (nonatomic, assign, readonly) BOOL isLoading;

+ (LifeDataConnector *)defaultConnector;

/// Register as payment transaction observer
- (void)startObserving;

/// Request product information from App Store
- (void)loadProducts;

/// Initiate a purchase for a product
- (void)purchaseProduct:(SKProduct *)product;

/// Restore previous purchases
- (void)restorePurchases;

/// Get star value for a product identifier
- (NSInteger)starsForProductIdentifier:(NSString *)productIdentifier;

/// Get all registered product identifiers
- (NSArray<NSString *> *)allProductIdentifiers;

@end

NS_ASSUME_NONNULL_END
