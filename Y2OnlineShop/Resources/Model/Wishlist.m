//
//  Wishlist.m
//  Y2OnlineShop
//
//  Created by maverick on 11/26/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Wishlist.h"
#import "Product.h"

@implementation Wishlist
@synthesize ID,items;

-(id)initWithID:(NSNumber*)cartID andProducts:(NSArray*)products{
    self = super.init;
    if(self){
        items = [NSMutableArray array];
        ID = cartID;
        for (id product in products) {
            if ([product isKindOfClass:[Product class]]) {
                [items addObject:product];
            }
        }
    }
    return self;
}

-(void)addNewProduct:(Product*)newProduct{
    if (items==NULL) {
        items = [NSMutableArray array];
    }
    if (newProduct!=NULL) {
        [items addObject:newProduct];
    }
}

@end
