//
//  OrderItemCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/7/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "OrderItemCell.h"
#import "Constants.h"
#import "UILabel+VerticalAlignment.h"

@implementation OrderItemCell
@synthesize productName,productOwner,productAmount,productImage,productPrice,productSKU,returBtn;

- (void)awakeFromNib
{
    // Initialization code
    if (IS_IPAD) {
        productOwner.font = FONT_ARSENAL_BOLD(22);
        productName.font = FONT_ARSENAL_BOLD(17);
        productSKU.font = FONT_ARSENAL(16);
        productPrice.font = FONT_ARSENAL(16);
        productAmount.font = FONT_ARSENAL(16);
        returBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
        returBtn.layer.cornerRadius = 8.0f;
    }else{
        productOwner.font = FONT_ARSENAL_BOLD(18);
        productName.font = FONT_ARSENAL_BOLD(13);
        productSKU.font = FONT_ARSENAL(12);
        productPrice.font = FONT_ARSENAL(12);
        productAmount.font = FONT_ARSENAL(12);
        returBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
        returBtn.layer.cornerRadius = 5.0f;
    }
    
    
    
    [productOwner setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productName setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productSKU setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productPrice setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [productAmount setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
