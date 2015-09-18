//
//  M_User.h
//  Y2OnlineShop
//
//  Created by maverick on 12/23/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface M_User : NSManagedObject

@property (nonatomic, retain) NSString * birthdate;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * id_user;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * phone_other;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * raw_data;

@end
