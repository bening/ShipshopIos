//
//  CartItemCell.h
//  Y2OnlineShop
//
//  Created by maverick on 12/24/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface CartItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *productImg;
@property (strong, nonatomic) IBOutlet RWLabel *productOwner;
@property (strong, nonatomic) IBOutlet RWLabel *productName;
@property (strong, nonatomic) IBOutlet RWLabel *productDetail;
@property (strong, nonatomic) IBOutlet RWLabel *productDisc;
@property (strong, nonatomic) IBOutlet RWLabel *productPrice;
@property (strong, nonatomic) IBOutlet RWLabel *productQty;
@property (strong, nonatomic) IBOutlet RWLabel *productTotalPrice;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;

@end
