//
//  M_Shop.h
//  Y2OnlineShop
//
//  Created by maverick on 11/25/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface M_Shop : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * name;

@end
