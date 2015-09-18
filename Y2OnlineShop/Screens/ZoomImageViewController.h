//
//  ZoomImageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/17/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZoomImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *imageProduct;

@property (nonatomic) IBOutlet UIScrollView* scrollView;
@property (nonatomic) IBOutlet UIImageView* imageView;

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;

@end
