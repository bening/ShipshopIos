//
//  SellerListCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/30/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface SellerListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet RWLabel *username;
@property (strong, nonatomic) IBOutlet RWLabel *name;
@property (strong, nonatomic) IBOutlet RWLabel *phone;
@property (strong, nonatomic) IBOutlet RWLabel *orderStatus;

@end
