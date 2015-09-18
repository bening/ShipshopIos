//
//  Cart.m
//  Y2OnlineShop
//
//  Created by maverick on 11/26/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Cart.h"
#import "Product.h"
#import "Constants.h"
#import "DataSingleton.h"

@implementation Cart
@synthesize ID,items,totalPrice,totalItem;

-(id)initWithID:(NSNumber*)cartID andProducts:(NSArray*)products{
    self = super.init;
    if(self){
        items = [NSMutableArray array];
        ID = cartID;
        totalItem = 0;
        totalPrice = 0;
        for (id product in products) {
            if ([product isKindOfClass:[Product class]]) {
                NSNumber* ownerID = [((Product*)product).completeData valueForKey:@"owner_id"];
                NSMutableDictionary* oneProduct = [[NSMutableDictionary alloc]initWithObjectsAndKeys:(Product*)product,productKey,[NSNumber numberWithInt:1],quantityKey,ownerID,ownerIDKey, nil];
                BOOL newProduct = true;
                for (NSMutableDictionary *singleProduct in items) {
                    Product* _product = (Product*)[singleProduct valueForKey:productKey];
                    if ([_product.ID intValue] == [((Product*)product).ID intValue]) {
                        NSNumber *_quantity = [singleProduct valueForKey:quantityKey];
                        _quantity = [NSNumber numberWithInt:[_quantity intValue]+1];
                        [singleProduct setValue:_quantity forKey:quantityKey];
                        newProduct = false;
                        break;
                    }
                }
                if (newProduct) {
                    [items addObject:oneProduct];
                }
                totalItem = [NSNumber numberWithInt:[totalItem intValue]+1];
                totalPrice = [NSNumber numberWithInt:[totalPrice intValue]+[((Product*)product).price intValue]];
            }
        }
    }
    return self;
}

-(void)addNewProduct:(Product*)newProduct asManyAs:(int)quantity{
    if (items==NULL) {
        items = [NSMutableArray array];
    }
    if (newProduct!=NULL) {
        NSNumber* ownerID;
        NSString* ownerName;
        NSString* sellerRole;
        BOOL isRetailProduct = ![(NSNumber*)[newProduct.completeData valueForKey:@"is_grosir"]boolValue];
        if (isRetailProduct) {
            ownerID = [NSNumber numberWithInt:cartOwnerIDRetail];
            ownerName = @"Retail";
            sellerRole = @"";
        }else{
            sellerRole = [newProduct.completeData valueForKey:@"seller_role"];
            if ([sellerRole isEqualToString:@"admin_toko"]) {
                ownerID = [NSNumber numberWithInt:cartOwnerIDToko];
                ownerName = @"Grosir";
            }else{
                ownerID = [newProduct.completeData valueForKey:@"owner_id"];
                ownerName = [newProduct.completeData valueForKey:@"nama_toko"];
            }
        }
        NSMutableDictionary* oneProduct = [[NSMutableDictionary alloc]initWithObjectsAndKeys:newProduct,productKey,[NSNumber numberWithInt:quantity],quantityKey,ownerID,ownerIDKey,ownerName,ownerNameKey,sellerRole,cartSellerRoleKey, nil];
        BOOL isNewProduct = true;
        for (NSMutableDictionary *singleProduct in items) {
            Product* _product = (Product*)[singleProduct valueForKey:productKey];
            if (isRetailProduct) {
                //check product ID
                if ([_product.ID intValue] == [newProduct.ID intValue]) {
                    //if product ID happens to be same, check its option value
                    NSMutableArray* selectedOptionValSorted = [NSMutableArray arrayWithArray:(NSArray*)[newProduct.completeData valueForKey:product_option_key]];
                    NSMutableArray* oldOptionValSorted = [NSMutableArray arrayWithArray:(NSArray*)[_product.completeData valueForKey:product_option_key]];
                    
                    if ([DataSingleton isThisOptionValue:selectedOptionValSorted equalTo:oldOptionValSorted]) {
                        //product exactly same
                        NSNumber *_quantity = [singleProduct valueForKey:quantityKey];
                        _quantity = [NSNumber numberWithInt:[_quantity intValue]+quantity];
                        [singleProduct setValue:_quantity forKey:quantityKey];
                        isNewProduct = false;
                        break;
                    }
                }
                
            }else{
                if ([_product.ID intValue] == [newProduct.ID intValue]) {
                    NSNumber *_quantity = [singleProduct valueForKey:quantityKey];
                    _quantity = [NSNumber numberWithInt:[_quantity intValue]+quantity];
                    [singleProduct setValue:_quantity forKey:quantityKey];
                    isNewProduct = false;
                    break;
                }
            }
        }
        if (isNewProduct) {
            [items addObject:oneProduct];
        }
        totalItem = [NSNumber numberWithInt:[totalItem intValue]+quantity];
        totalPrice = [NSNumber numberWithInt:[totalPrice intValue]+([newProduct.price intValue]*quantity)];
    }
}

-(void)removeItemAtIndex:(int)index{
    if (index > -1 && index < items.count) {
        NSMutableDictionary* oneProduct = [items objectAtIndex:index];
        Product* _product = [oneProduct valueForKey:productKey];
        NSNumber* quantity = [oneProduct valueForKey:quantityKey];
        NSNumber* wholePrice = [NSNumber numberWithInt:[_product.price intValue]*[quantity intValue]];
        totalItem = [NSNumber numberWithInt:[totalItem intValue]-[quantity intValue]];
        totalPrice = [NSNumber numberWithInt:[totalPrice intValue]-[wholePrice intValue]];
        [items removeObjectAtIndex:index];
    }
}

-(void)removeAllItems{
    [items removeAllObjects];
    totalItem = [NSNumber numberWithInt:0];
    totalPrice = [NSNumber numberWithInt:0];
}


-(void)updateItemAtIndex:(int)index with:(NSMutableDictionary*)newData{
    if (index > -1 && index < items.count) {
        NSMutableDictionary* oneProduct = [items objectAtIndex:index];
        NSNumber* oldQty = [oneProduct valueForKey:quantityKey];
        Product* _product = [oneProduct valueForKey:productKey];
        NSNumber* newQty = [newData valueForKey:quantityKey];
        if ([newQty intValue]>0) {
            [oneProduct setValue:newQty forKey:quantityKey];
            NSNumber* oldPrice = [NSNumber numberWithInt:[_product.price intValue]*[oldQty intValue]];
            NSNumber* newPrice = [NSNumber numberWithInt:[_product.price intValue]*[newQty intValue]];
            int difference =[newPrice intValue]-[oldPrice intValue];
            totalPrice = [NSNumber numberWithInt:[totalPrice intValue]+difference];
            totalItem = [NSNumber numberWithInt:[totalItem intValue]+([newQty intValue]-[oldQty intValue])];
        }else{
            //if quantity becomes 0
            [self removeItemAtIndex:index];
        }
        
        
        //[items removeObjectAtIndex:index];
        //[items insertObject:oneProduct atIndex:index];
    }
}

@end
