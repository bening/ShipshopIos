//
//  Cart.h
//  Y2OnlineShop
//
//  Created by maverick on 11/26/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface Cart : NSObject
@property (strong,readwrite) NSNumber* ID;
@property (strong,readwrite) NSMutableArray *items;
@property (strong,readwrite) NSNumber* totalPrice;
@property (strong,readwrite) NSNumber* totalItem;

-(id)initWithID:(NSNumber*)cartID andProducts:(NSArray*)products;
-(void)addNewProduct:(Product*)newProduct asManyAs:(int)quantity;
-(void)removeItemAtIndex:(int)index;
-(void)removeAllItems;
-(void)updateItemAtIndex:(int)index with:(NSMutableDictionary*)newData;

@end
