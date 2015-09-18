//
//  UIIndexedPageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/21/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIIndexedPageViewController : UIPageViewController
@property(nonatomic,readwrite) NSInteger index;
@property(nonatomic,readwrite) NSInteger selectedColorIndex;
@end
