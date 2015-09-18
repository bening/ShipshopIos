//
//  OrderItemCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/7/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface OrderItemCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet RWLabel *productOwner;
@property (strong, nonatomic) IBOutlet RWLabel *productName;
@property (strong, nonatomic) IBOutlet RWLabel *productSKU;
@property (strong, nonatomic) IBOutlet RWLabel *productPrice;
//@property (strong, nonatomic) IBOutlet UILabel *productSpec;
@property (strong, nonatomic) IBOutlet RWLabel *productAmount;
@property (strong, nonatomic) IBOutlet UIButton *returBtn;

@end
