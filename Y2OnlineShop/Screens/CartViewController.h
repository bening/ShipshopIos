//
//  CartViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/25/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemCollection.h"
#import "CartItemCell.h"
#import "WishListViewController.h"
#import "DXPopover.h"
#import "TextFieldValidator.h"
#import "ASINetworkQueue.h"

@interface CartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    int widthContentView;
    bool isEmpty;
    NSMutableArray *itemCart;
    int _total;
    int currentQty;
    NSIndexPath *editedIndex;
    ASINetworkQueue *networkQueue;
    NSMutableArray* checkedProduct;
    NSMutableArray* unavailableProducts;
    NSMutableArray* failedToCheckProducts;
    NSMutableArray* groupOfProducts;
    
    int rowToDelete;
    int sectionToDelete;
}

@property BOOL isRetail;
@property (strong, nonatomic) IBOutlet UIView *popoverView;
@property (strong, nonatomic) IBOutlet TextFieldValidator *quantityBox;
@property (strong, nonatomic) IBOutlet UIButton *quantityInc;
@property (strong, nonatomic) IBOutlet UIButton *quantityDec;
@property (strong, nonatomic) IBOutlet UIButton *quantityDone;

@property (nonatomic, strong) DXPopover *popover;

@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;
@property (nonatomic) IBOutlet UIView *viewEmpty;
@property (nonatomic) IBOutlet UIView *viewColl;
@property (nonatomic) IBOutlet UICollectionView *collItem;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutlet UITableView *cartTable;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet UIView *cartInfoWrapper;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;

- (IBAction)goToCheckout:(id)sender;
- (IBAction)increaseQty:(id)sender;
- (IBAction)decreaseQty:(id)sender;
- (IBAction)saveQuantity:(id)sender;

@end
