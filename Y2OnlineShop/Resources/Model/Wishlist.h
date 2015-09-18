//
//  Wishlist.h
//  Y2OnlineShop
//
//  Created by maverick on 11/26/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface Wishlist : NSObject
@property (strong,readwrite) NSNumber* ID;
@property (strong,readwrite) NSMutableArray *items;

-(id)initWithID:(NSNumber*)cartID andProducts:(NSArray*)products;
-(void)addNewProduct:(Product*)newProduct;

@end
