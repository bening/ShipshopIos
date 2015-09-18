//
//  DescriptionViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Product.h"
#import "UIViewController+AMSlideMenu.h"
#import "ZoomImageViewController.h"
#import "ImageColorItem.h"
#import "CartViewController.h"
#import "WishListViewController.h"
#import "AppDelegate.h"
#import "M_Cart.h"
#import "M_Wishlist.h"
#import "DXPopover.h"
#import "ASINetworkQueue.h"

@interface DescriptionViewController : UIViewController < UICollectionViewDelegate,UICollectionViewDataSource,UIPageViewControllerDataSource,UIPageViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    int varIpadWidth;
    int varIpadHeight;
    int marginWidth;
    int marginHeight;
    int widthContentView;
    
    NSMutableArray *images;
    int mainPagerIndex;
    int subPagerIndex;

    int currentIndex;
    int currentSubIndex;
    int currentColorIndex;
    
    bool viewColorIsHidden;
    bool deviceIsInLandscape;
    
    bool variantOptShown;
    bool quantityBoxShown;
    DXPopover *optionPopover;
    DXPopover *variantPopover;
    DXPopover *quantityBoxPopover;
    
    NSMutableArray *variantCollection;
    NSMutableArray *variantOptions;
    int selectedOption;
    UITextField* activeTextField;
    BOOL variantTableShown;
    NSMutableArray *needDetailProducts;
    NSMutableArray *removedProductIndexes;
    ASINetworkQueue *networkQueue;
    NSMutableArray *colorOfProduct;
    CGFloat textFieldWidth;
    CGFloat textFieldHeight;
    CGFloat wrapperWidth;
    CGFloat fontSize;
    CGFloat variantTableOptionWidth;
    int currentQty;
}

@property (strong, nonatomic) NSMutableArray *selectedOptionProduct;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSDictionary* productToDisplay;
@property (strong, nonatomic) NSDictionary* productToShare;
@property NSInteger indexProduct;

@property (strong, nonatomic) UIImageView *imageProduct;
@property (strong, nonatomic) IBOutlet UIScrollView *variantView;
@property (strong, nonatomic) IBOutlet UITableView *variantTableOption;
@property (strong, nonatomic) IBOutlet UIView *imageWrapper;

@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *detailBtn;
@property (strong, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *chooseSizeBtn;
@property (strong, nonatomic) IBOutlet UIButton *addToBagBtn;
@property (strong, nonatomic) IBOutlet UIButton *addToBagBtnSingle;
@property (strong, nonatomic) IBOutlet UIButton *colorBtn;

@property (strong, nonatomic) IBOutlet UIView *viewColor;
@property (strong, nonatomic) IBOutlet UICollectionView *collColor;
@property (strong, nonatomic) IBOutlet UIView *buttonWrapper;
@property (strong, nonatomic) IBOutlet UIView *buttonWrapperSingle;
@property (strong, nonatomic) IBOutlet UIView *buttonWrapperPilihan;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) UIPageViewController *pageController;
@property bool isRetail;
@property int type;
@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *quantityBox;
@property (strong, nonatomic) IBOutlet TextFieldValidator *quantityTextField;

-(void) setMainPagerIndex: (NSInteger) index;
-(IBAction)toggleColorLayout:(id)sender;
- (IBAction)goToDetailProduct:(id)sender;
- (IBAction)selectVariant:(id)sender;
- (IBAction)submitQuantity:(id)sender;
- (IBAction)increaseQty:(id)sender;
- (IBAction)decreaseQty:(id)sender;

@end
