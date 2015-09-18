//
//  SalesOrderCell.m
//  Y2OnlineShop
//
//  Created by maverick on 1/28/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "SalesOrderCell.h"
#import "UILabel+VerticalAlignment.h"

@implementation SalesOrderCell
@synthesize orderNumber,customer,totalItems,total,dateAdded,status;

- (void)awakeFromNib
{
    // Initialization code
    [orderNumber setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [customer setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [totalItems setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [total setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [dateAdded setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [status setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
