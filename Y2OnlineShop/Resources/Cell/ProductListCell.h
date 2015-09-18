//
//  ProductListCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/22/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface ProductListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet RWLabel *sku;
@property (strong, nonatomic) IBOutlet RWLabel *name;
@property (strong, nonatomic) IBOutlet RWLabel *category;
@property (strong, nonatomic) IBOutlet RWLabel *brand;
@property (strong, nonatomic) IBOutlet RWLabel *price;
@property (strong, nonatomic) IBOutlet RWLabel *stock;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) IBOutlet UIView *col2;
@property (strong, nonatomic) IBOutlet UIView *col3;
@property (strong, nonatomic) IBOutlet UILabel *stockLabel;
@property (strong, nonatomic) IBOutlet UILabel *stockLabelDoublePeriod;

@end
