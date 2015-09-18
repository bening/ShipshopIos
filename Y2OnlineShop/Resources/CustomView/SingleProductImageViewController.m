//
//  SingleProductImageViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/21/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "SingleProductImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZoomImageViewController.h"
#import "Constants.h"
#import "DataSingleton.h"

@interface SingleProductImageViewController ()

@end

@implementation SingleProductImageViewController
@synthesize index, images;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //images = [[NSMutableArray alloc] initWithObjects:@"mukenah0.jpg",@"mukenah1.jpg",@"mukenah2.jpg", @"mukenah3.jpg",@"mukenah4.jpg",@"mukenah5.jpg", nil];
        imageEmpty = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.imageView.image = [UIImage imageNamed:[images objectAtIndex:self.index]];
    if (!imageEmpty) {
        if (images.count >0) {
            
            NSString* imageUrl = [images objectAtIndex:self.index];
            __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [activityIndicator setColor:COLOR_PINK_Y2];
            activityIndicator.center = self.imageView.center;
            activityIndicator.hidesWhenStopped = YES;
            __weak UIImageView* tempImage = self.imageView;
            __weak SingleProductImageViewController* weakVC = self;
            [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
             {
                 if (!image) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         tempImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                     });
                     
                     NSLog(@"failed load image for description");
                 }else{
                     UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:weakVC action:@selector(handleTapFrom:)];
                     tapGesture.numberOfTapsRequired = 1;
                     [tempImage setUserInteractionEnabled:YES];
                     [tempImage addGestureRecognizer:tapGesture];
                     
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [activityIndicator removeFromSuperview];
                 });
                 
             }];
            [self.imageView addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
        }
    }
    
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:self.imageView.image];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)makeAsEmptyImage{
    images = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"icon_no_img.png"], nil];
    imageEmpty = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
