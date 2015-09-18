//
//  ReturDetailCell.h
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface ReturDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet RWLabel *item;
@property (strong, nonatomic) IBOutlet RWLabel *price;
@property (strong, nonatomic) IBOutlet UITextField *quantityField;
@property (strong, nonatomic) IBOutlet RWLabel *total;
@property (strong, nonatomic) IBOutlet RWLabel *status;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;

@end
