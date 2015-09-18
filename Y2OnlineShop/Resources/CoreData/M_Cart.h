//
//  M_Cart.h
//  Y2OnlineShop
//
//  Created by maverick on 2/2/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface M_Cart : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * id_owner;
@property (nonatomic, retain) NSNumber * id_product;
@property (nonatomic, retain) NSNumber * is_grosir;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * option;
@property (nonatomic, retain) NSNumber * var_id;

@end
