//
//  M_Wishlist.h
//  Y2OnlineShop
//
//  Created by maverick on 12/15/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface M_Wishlist : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * id_product;
@property (nonatomic, retain) NSNumber * id_owner;
@property (nonatomic, retain) NSNumber * is_grosir;

@end
