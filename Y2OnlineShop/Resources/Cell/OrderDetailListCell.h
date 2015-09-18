//
//  OrderDetailListCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/29/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface OrderDetailListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet RWLabel *destinationBank;
@property (strong, nonatomic) IBOutlet RWLabel *bankName;
@property (strong, nonatomic) IBOutlet RWLabel *bankAccount;
@property (strong, nonatomic) IBOutlet RWLabel *accountName;
@property (strong, nonatomic) IBOutlet RWLabel *transDate;
@property (strong, nonatomic) IBOutlet RWLabel *transAmount;
@property (strong, nonatomic) IBOutlet UIButton *buttonToHandleImageTap;

@end
