//
//  OrderDetailListCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/29/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "OrderDetailListCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation OrderDetailListCell
@synthesize destinationBank,bankName,bankAccount,accountName,transDate,transAmount;

- (void)awakeFromNib
{
    // Initialization code
    [destinationBank setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [bankName setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [bankAccount setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [accountName setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [transDate setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [transAmount setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
