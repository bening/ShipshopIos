//
//  OrderTableViewCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/7/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "OrderTableViewCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation OrderTableViewCell
@synthesize orderNumber,orderDate,orderTotal,orderStatus,detailButton;

- (void)awakeFromNib
{
    // Initialization code
    [orderNumber setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [orderDate setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [orderTotal setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [orderStatus setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
