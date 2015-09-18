//
//  SalesOrderCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/28/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface SalesOrderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet RWLabel *orderNumber;
@property (strong, nonatomic) IBOutlet RWLabel *customer;
@property (strong, nonatomic) IBOutlet RWLabel *totalItems;
@property (strong, nonatomic) IBOutlet RWLabel *total;
@property (strong, nonatomic) IBOutlet RWLabel *dateAdded;
@property (strong, nonatomic) IBOutlet RWLabel *status;

@end
