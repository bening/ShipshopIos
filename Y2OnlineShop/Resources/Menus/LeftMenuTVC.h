//
//  LeftMenuTVC.h
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/4/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "AMSlideMenuLeftTableViewController.h"
#import "Constants.h"
#import "M_Shop.h"
#import "M_Category.h"
#import "ASINetworkQueue.h"
#define menu_main 0
#define menu_shop 1
#define menu_category 2
#define menu_agent 3
#define menu_footer1 4
#define menu_footer2 5
#define menu_footer3 6
#define menu_footer4 7
#define menu_product 8
#define menu_sales 9
#define menu_account 10
#define menu_login 11
#define menu_api 12
#define header_back 0
#define header_segment 1

@interface LeftMenuTVC : AMSlideMenuLeftTableViewController<ASIHTTPRequestDelegate, ASIProgressDelegate>{
    NSMutableArray *maleMenuList;
    NSMutableArray *femaleMenuList;
    int currentMenu;
    int header;
    NSDictionary *selectedStore;
    NSDictionary *selectedAgent;
    NSDictionary *selectedCategory;
    NSDictionary *prevSelectedCategory;
    NSMutableDictionary *currentParent;
    NSMutableArray *listOfParent;
    NSMutableArray *currentCategory;
    ASINetworkQueue *networkQueue;
    bool isAll;
    bool isAllOwnerProduct;
    bool isLogoutProcess;
    NSString* userIDTemp;
    NSString* deviceTokenTemp;
    int currentSession;
    BOOL firstTime;
}


@property (nonatomic) NSString *agenName;
@property (nonatomic) NSString *subAgenName;
@property (nonatomic) NSString *catType;

#pragma mark - Outlets
@property (strong, nonatomic) IBOutlet UITableView *tableView;

#pragma mark - Properties
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *prevTableData;
@property (strong, nonatomic) NSMutableArray *rootTableData;
@property (nonatomic, strong) UIActivityIndicatorView *loader;

- (void) goToHome;
- (void) backPressed:(id)sender;
- (void) goToCategoryPageProduct:(NSString*)APIUrl withTitle:(NSString*)title;
- (void) showNetworkErrorPage;
- (void) showNoProductPage;
- (void) setAllOwnerProductStatus:(BOOL)allOwnerProduct;
- (BOOL) getAllOwnerProductStatus;
- (void) fetchData:(BOOL)isLogout;

@end
