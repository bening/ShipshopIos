//
//  ProductListViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 1/22/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListCell.h"
#import "ASIHTTPRequest.h"
#import "VCDelegate.h"
#import "DXPopover.h"
#import "DropDownTextField.h"

@interface ProductListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,ASIHTTPRequestDelegate, VCDelegate>{
    NSMutableArray *productList;
    int widthContentView;
    int indexOfSelectedProduct;
    
    NSString *selectedSKU;
    NSString *selectedGender;
    NSString *selectedProductName;
    NSString *selectedCategory;
    NSString *selectedGenderName;
    
    DXPopover *dropdownPopover;
    NSMutableArray* genderValues;
    NSMutableArray* categoryValues;
    NSMutableArray* dropdownValues;
    NSMutableDictionary* categoryDict;
    
    UITextField *activeTextField;
    
    int selectedGenderIndex;
    int selectedCategoryIndex;
    BOOL popoverShown;
    UIGestureRecognizer *tapper;
    
    int currentPage;
    BOOL refreshProductList;
    BOOL productListReachEnd;
}
@property BOOL isRetailProduct;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet UIButton *addProductBtn;
@property (strong, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UILabel *tableTitle;
@property (strong, nonatomic) IBOutlet UITableView *productTable;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UITextField *sku;
@property (strong, nonatomic) IBOutlet UITextField *productName;
@property (strong, nonatomic) IBOutlet DropDownTextField *gender;
@property (strong, nonatomic) IBOutlet DropDownTextField *category;
@property (strong, nonatomic) IBOutlet UITableView *dropdownTableView;
@property (strong, nonatomic) IBOutlet UIView *wraper;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroller;



- (IBAction)addProduct:(id)sender;

@end
