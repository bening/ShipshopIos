//
//  ReturDetailCell.m
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "ReturDetailCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation ReturDetailCell
@synthesize item,price, total, status,quantityField;

- (void)awakeFromNib
{
    // Initialization code
    [item setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [price setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [total setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [status setTextVerticalAlignment:UITextVerticalAlignmentTop];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, quantityField.frame.size.height)];
    quantityField.leftView = paddingView;
    quantityField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
