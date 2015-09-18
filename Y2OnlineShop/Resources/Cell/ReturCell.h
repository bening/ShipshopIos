//
//  ReturCell.h
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface ReturCell : UITableViewCell

@property (strong, nonatomic) IBOutlet RWLabel *orderNumber;
@property (strong, nonatomic) IBOutlet RWLabel *customer;
@property (strong, nonatomic) IBOutlet RWLabel *dateAdded;
@property (strong, nonatomic) IBOutlet RWLabel *status;

@end
