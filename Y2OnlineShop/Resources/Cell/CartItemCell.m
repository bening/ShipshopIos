//
//  CartItemCell.m
//  Y2OnlineShop
//
//  Created by maverick on 12/24/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "CartItemCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation CartItemCell
@synthesize backgroundView,productOwner,productName,productDetail,productDisc,productPrice,productQty,productTotalPrice;

- (void)awakeFromNib
{
    // Initialization code
    //backgroundView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0].CGColor;
    //backgroundView.layer.borderWidth = 2.0f;
    //backgroundView.layer.cornerRadius = 4.0f;
    [productOwner setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productName setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productDetail setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productDisc setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productPrice setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productQty setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productTotalPrice setTextVerticalAlignment:UITextVerticalAlignmentTop];
    productDisc.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
