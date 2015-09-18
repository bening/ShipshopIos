//
//  M_Category.h
//  Y2OnlineShop
//
//  Created by maverick on 11/28/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface M_Category : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) NSString * image;

@end
