//
//  SummaryDetailListCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/30/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "SummaryDetailListCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation SummaryDetailListCell
@synthesize item,price,quantity,total;

- (void)awakeFromNib
{
    // Initialization code
    [item setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [price setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [quantity setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [total setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
