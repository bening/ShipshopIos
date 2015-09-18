//
//  M_Product.h
//  Y2OnlineShop
//
//  Created by maverick on 11/25/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface M_Product : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * id_category;
@property (nonatomic, retain) NSNumber * id_shop;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price_agen;
@property (nonatomic, retain) NSNumber * price_retail;
@property (nonatomic, retain) NSNumber * group_product;

@end
