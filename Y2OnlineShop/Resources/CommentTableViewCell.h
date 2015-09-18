//
//  CommentTableViewCell.h
//  Y2OnlineShop
//
//  Created by maverick on 12/11/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASStarRatingView.h"

@interface CommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *comment;
@property (strong, nonatomic) IBOutlet ASStarRatingView *rating;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end
