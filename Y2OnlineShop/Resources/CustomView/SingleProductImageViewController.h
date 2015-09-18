//
//  SingleProductImageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/21/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface SingleProductImageViewController : UIViewController
{
//    NSMutableArray *images;
    BOOL imageEmpty;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger parentIndex;
@property (nonatomic, retain) NSMutableArray *images;

-(void)makeAsEmptyImage;

@end
