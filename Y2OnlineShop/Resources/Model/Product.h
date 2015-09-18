//
//  Product.h
//  Y2OnlineShop
//
//  Created by maverick on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject
@property (strong,readwrite) NSNumber* ID;
@property (strong,readwrite) NSNumber* groupID;
@property (strong,readwrite) NSString* image;
@property (strong,readwrite) NSString* name;
@property (strong,readwrite) NSNumber* price;
@property (strong,readwrite) NSNumber* priceRetail;
@property (strong,readwrite) NSMutableArray* images;
@property (strong,readwrite) NSMutableDictionary* completeData;
@property BOOL isGrosirProduct;


- (id)initWithID:(NSNumber*)_id andName:(NSString*)productName withImage:(NSString*)productImg withPrice:(NSNumber*)productPrice;
- (id)initWithID:(NSNumber*)_id andName:(NSString*)productName withImages:(NSMutableArray*)productImgs withPrice:(NSNumber*)productPrice;
- (id)initWithID:(NSNumber*)_id andName:(NSString*)productName withImages:(NSMutableArray*)productImgs withPrice:(NSNumber*)productPrice andRetailPrice:(NSNumber*)retailPrice;

@end
