//
//  CommentTableViewCell.m
//  Y2OnlineShop
//
//  Created by maverick on 12/11/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell
@synthesize comment,username, contentView, rating;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    //comment.preferredMaxLayoutWidth = CGRectGetWidth(self.contentView.bounds);
    //[comment sizeToFit];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
