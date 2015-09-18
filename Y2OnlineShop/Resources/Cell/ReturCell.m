//
//  ReturCell.m
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "ReturCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation ReturCell
@synthesize orderNumber,customer,dateAdded,status;

- (void)awakeFromNib
{
    // Initialization code
    [orderNumber setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [customer setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [dateAdded setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [status setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
