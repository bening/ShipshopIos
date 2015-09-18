//
//  SummaryDetailListCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/30/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface SummaryDetailListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet RWLabel *item;
@property (strong, nonatomic) IBOutlet RWLabel *price;
@property (strong, nonatomic) IBOutlet RWLabel *quantity;
@property (strong, nonatomic) IBOutlet RWLabel *total;

@end
