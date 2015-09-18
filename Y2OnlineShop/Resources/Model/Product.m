//
//  Product.m
//  Y2OnlineShop
//
//  Created by maverick on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Product.h"

@implementation Product
@synthesize ID,name,price,priceRetail,image, images;

- (id)initWithID:(NSNumber*)_id andName:(NSString*)productName withImage:(NSString*)productImg withPrice:(NSNumber*)productPrice{
    self = super.init;
    if(self){
        ID = _id;
        name = productName;
        price = productPrice;
        image = productImg;
    }
    return self;
}

- (id)initWithID:(NSNumber*)_id andName:(NSString*)productName withImages:(NSMutableArray*)productImgs withPrice:(NSNumber*)productPrice{
    self = super.init;
    if(self){
        ID = _id;
        name = productName;
        price = productPrice;
        if ([productImgs count]>0) {
            image = [productImgs objectAtIndex:0];
        }
        images = productImgs;
    }
    return self;
}

- (id)initWithID:(NSNumber*)_id andName:(NSString*)productName withImages:(NSMutableArray*)productImgs withPrice:(NSNumber*)productPrice andRetailPrice:(NSNumber*)retailPrice{
    self = super.init;
    if(self){
        ID = _id;
        name = productName;
        price = productPrice;
        priceRetail = retailPrice;
        if ([productImgs count]>0) {
            image = [productImgs objectAtIndex:0];
        }
        images = productImgs;
    }
    return self;
}


@end
