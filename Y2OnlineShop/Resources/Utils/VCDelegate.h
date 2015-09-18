//
//  VCDelegate.h
//  Y2OnlineShop
//
//  Created by maverick on 1/13/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VCDelegate <NSObject>

@optional
- (void)shippingArrivalConfirmed:(BOOL)confirmed;
- (void)submitEditedProduct:(BOOL)didSubmit;
- (void)addNewProduct:(BOOL)didAddSuccessfully;
- (void)updateOrderStatus:(BOOL)didUpdate;
- (void)itemAddedToCart:(BOOL)didAdd;
- (void)confirmRetur:(BOOL)didConfirm;

@end
