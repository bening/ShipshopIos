//
//  OrderTableViewCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/7/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface OrderTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet RWLabel *orderNumber;
@property (strong, nonatomic) IBOutlet RWLabel *orderDate;
@property (strong, nonatomic) IBOutlet RWLabel *orderTotal;
@property (strong, nonatomic) IBOutlet RWLabel *orderStatus;
@property (strong, nonatomic) IBOutlet UIButton *detailButton;

@end
