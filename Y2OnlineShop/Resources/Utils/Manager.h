//
//  Manager.h
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface Manager : NSObject

@property (nonatomic, assign) bool isAgen;
@property (nonatomic, assign) bool isSubAgen;
@property (nonatomic, assign) bool isUser;
@property (nonatomic, assign) bool isLogin;

+ (id)sharedManager;
//+ (void)setProduct;
//+ (Product*)getProduct:(int)index;

@end
