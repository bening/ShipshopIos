//
//  SearchResultPageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 2/4/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"

@interface SearchResultPageViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate, UISearchBarDelegate, UIScrollViewDelegate>{
    int currentPage;
    int widthContentView;
    NSMutableArray *searchResultList;
    BOOL refreshList;
    BOOL listReachEnd;
    int tappedItem;
    ASINetworkQueue *networkQueue;
    NSMutableArray *displayProducts;
    NSMutableArray *removedProductIndexes;
}

@property BOOL isRetail;
@property (strong, nonatomic) NSString* searchKey;
@property (strong, nonatomic) IBOutlet UILabel *searchKeyLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *searchResultCollection;
@property (strong, nonatomic) IBOutlet UIImageView *noProductImg;
@property (strong, nonatomic) IBOutlet UIImageView *noNetworkImg;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;
@property (strong, nonatomic) IBOutlet UILabel *loadingMsgLabel;

@end
