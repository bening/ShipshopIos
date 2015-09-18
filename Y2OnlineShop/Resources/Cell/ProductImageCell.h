//
//  ProductImageCell.h
//  Y2OnlineShop
//
//  Created by maverick on 1/26/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductImageCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) IBOutlet UITextField *color;

@end
