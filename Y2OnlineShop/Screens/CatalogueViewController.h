//
//  CatalogueViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogueItem.h"
#import "Product.h"
#import "UIViewController+AMSlideMenu.h"
#import "CartViewController.h"
#import "WishListViewController.h"
#import "Constants.h"
#import "LeftMenuTVC.h"
#import "ASINetworkQueue.h"

@interface CatalogueViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>
{
    int widthContentView;
    
    float varPrice;
    
    UITextField *textFieldSearch;
    NSMutableArray *productsExperiment;
    int numberOfItemToFetch;
    int limitToFetchNewData;
    int tappedItem;
    ASINetworkQueue *networkQueue;
    NSMutableArray *displayProducts;
    NSMutableArray *removedProductIndexes;
    
    int currentPage;
    BOOL listReachEnd;
}

@property (strong, nonatomic) LeftMenuTVC* leftMenuReference;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;
@property (strong, nonatomic) NSMutableArray *products;

@property (strong, nonatomic) NSString * pageTitle;
@property (strong, nonatomic) NSDictionary * category;
@property (strong, nonatomic) NSDictionary * store;
@property (strong, nonatomic) IBOutlet UIImageView *noProductImg;
@property (strong, nonatomic) IBOutlet UIImageView *noNetworkImg;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;

@property (strong, nonatomic) NSString * APIUrl;
//@property bool isRetail;
//@property bool isAllOwnerProduct;
//@property int type;

@end
