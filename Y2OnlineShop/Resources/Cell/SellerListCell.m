//
//  SellerListCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/30/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "SellerListCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation SellerListCell
@synthesize username,name,phone,orderStatus;

- (void)awakeFromNib
{
    // Initialization code
    [username setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [name setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [phone setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [orderStatus setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
