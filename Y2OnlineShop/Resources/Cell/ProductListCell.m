//
//  ProductListCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/22/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "ProductListCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation ProductListCell
@synthesize sku,name,category,brand,price,stock,image,stockLabel,stockLabelDoublePeriod;

- (void)awakeFromNib
{
    // Initialization code
//    [sku setTextVerticalAlignment:UITextVerticalAlignmentTop];
//    [name setTextVerticalAlignment:UITextVerticalAlignmentTop];
//    [category setTextVerticalAlignment:UITextVerticalAlignmentTop];
//    [brand setTextVerticalAlignment:UITextVerticalAlignmentTop];
//    [price setTextVerticalAlignment:UITextVerticalAlignmentTop];
//    [stock setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
