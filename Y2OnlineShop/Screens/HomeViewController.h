//
//  HomeViewController.h
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/3/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LeftMenuTVC.h"
#import "UIViewController+AMSlideMenu.h"
#import "iCarousel.h"
#import "CatalogueViewController.h"
#import "WishListViewController.h"
#import "CartViewController.h"
#import "ASINetworkQueue.h"

//#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
//
//#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface HomeViewController : UIViewController<UISearchBarDelegate>
{
    NSArray *carouselItemsTop;
    NSArray *carouselItemsBot;
    MPMoviePlayerController *moviePlayerController;
    
    int heightContentView;
    int widthContentView;
    int heightScreenVideo;
    bool isPortrait;
    
    int varIpad;
    int varIpadImage;
    
    int indexOfSelectedTopProduct;
    int indexOfSelectedTopBrand;
    int indexOfSelectedTopSeller;
    ASINetworkQueue *networkQueue;
    NSMutableArray *displayProducts;
    NSMutableArray *removedProductIndexes;
    
    NSTimer *sliderTimer;
    BOOL touchBlocked;
}

@property (strong, nonatomic) IBOutlet UIView *mainWrapper;
@property (strong, nonatomic) IBOutlet UIView *videoWrapper;
@property (strong, nonatomic) IBOutlet UIView *iCarouselWrapper;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollerTop;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollerBot;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScroller;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong,nonatomic) LeftMenuTVC * leftMenuReference;
+(HomeViewController*)getCurrentInstance;

@end
