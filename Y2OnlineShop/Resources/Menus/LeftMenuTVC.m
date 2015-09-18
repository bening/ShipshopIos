//
//  LeftMenuTVC.m
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/4/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "LeftMenuTVC.h"
#import "HomeViewController.h"
#import "OtherViewController.h"
#import "CatalogueViewController.h"
#import "CustomerServiceViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AddNewProductViewController.h"
#import "ProductListViewController.h"
#import "SalesOrderViewController.h"
#import "ReturPageViewController.h"
#import "ProfilePageViewController.h"
#import "OrderViewController.h"
#import "WebViewViewController.h"
#import "UIImage+ColorImage.h"
#import "DataSingleton.h"
#import "BlankPageViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"
#import "Constants.h"
#define logoutAlert 1
#define queueNone 100
#define queueFetch 101
#define queueFetchInitial 102


@interface LeftMenuTVC ()

@end

@implementation LeftMenuTVC

@synthesize agenName, subAgenName,prevTableData,loader,tableData,catType, rootTableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeData];
    }
    return self;
}

-(void)initializeData{
    currentSession = queueNone;
    isAll = false;
    isAllOwnerProduct = false;
    
    currentMenu = menu_main;
    header = header_segment;
    tableData = [NSMutableArray array];
    prevTableData = [NSMutableArray array];
    [self constructMaleMenu];
    [self constructFemaleMenu];
    //default gender is Male
    catType = Male;
    tableData = [maleMenuList mutableCopy];
    currentParent = [DataSingleton instance].maleData;
    listOfParent = [NSMutableArray arrayWithObjects:currentParent, nil];
}

-(void)constructMaleMenu{
    maleMenuList = [NSMutableArray array];
    [maleMenuList addObject:homeMenu];
    [self createMaleMenuList];
    [self constructMenu:maleMenuList];
}

-(void)constructFemaleMenu{
    femaleMenuList = [NSMutableArray array];
    [femaleMenuList addObject:homeMenu];
    [self createFemaleMenuList];
    [self constructMenu:femaleMenuList];
}

/**
 * construct menu which is not from API, device menu
 */
- (void)constructMenu:(NSMutableArray*)menuList{
    
    //toggle for my account menu visibility
    if ([DataSingleton instance].isLogin) {
        [menuList addObject:myAccountMenu];
    }
    
    //toggle for add new product menu visibility
    if ([DataSingleton instance].menuCMSProduct || [DataSingleton instance].menuCMSProductGrosir) {
        [menuList addObject:productMenu];
    }
    
    //toggle for add sales menu visibility
    if ([DataSingleton instance].showSalesOrder || [DataSingleton instance].showSalesRetur) {
        [menuList addObject:salesMenu];
    }
    
    if ([DataSingleton instance].isLogin) {
        [menuList addObject:logoutMenu];
    }else{
        [menuList addObject:loginMenu];
    }
    
    [menuList addObject:footer1Menu];
    [menuList addObject:footer2Menu];
}

- (void)createMaleMenuList{
    for (NSMutableDictionary* genderChild in [[DataSingleton instance].maleData valueForKey:@"child"]) {
        [maleMenuList addObject:[genderChild valueForKey:@"name"]];
    }
}

- (void)createFemaleMenuList{
    for (NSMutableDictionary* genderChild in [[DataSingleton instance].femaleData valueForKey:@"child"]) {
        [femaleMenuList addObject:[genderChild valueForKey:@"name"]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loader.color = [UIColor colorWithRed:(236/255.0) green:(0/255.0) blue:(140/255.0) alpha:1.0];
    loader.hidesWhenStopped = YES;
    firstTime = true;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    CGFloat tableBorderLeft = 120;
    CGFloat tableBorderRight = 120;
    
    CGRect tableRect = self.view.frame;
    tableRect.origin.x += tableBorderLeft; // make the table begin a few pixels right from its origin
    tableRect.size.width -= tableBorderLeft + tableBorderRight; // reduce the width of the table
    self.tableView.frame = tableRect;
    
}

- (void)populateMenuWithMaleMenu{
    [tableData removeAllObjects];
    tableData = [maleMenuList mutableCopy];
    [self.tableView reloadData];
    currentParent = [DataSingleton instance].maleData;
}

- (void)populateMenuWithFemaleMenu{
    [tableData removeAllObjects];
    tableData = [femaleMenuList mutableCopy];
    [self.tableView reloadData];
    currentParent = [DataSingleton instance].femaleData;
}

-(void)genderPicked:(id)sender{
    catType = ((UISegmentedControl*)sender).selectedSegmentIndex==0?Female:Male;
    [tableData removeAllObjects];
    if ([catType isEqualToString:Male]) {
        tableData = [maleMenuList mutableCopy];
        currentParent = [DataSingleton instance].maleData;
    }else{
        tableData = [femaleMenuList mutableCopy];
        currentParent = [DataSingleton instance].femaleData;
    }
    listOfParent = [NSMutableArray arrayWithObjects:currentParent, nil];
    [self.tableView reloadData];
}

#pragma mark - TableView Datasource

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor * y2PinkColor = [UIColor colorWithRed:235/255.0f green:0/255.0f blue:134/255.0f alpha:1.0f];
    
    UIImage * pinkImage = [UIImage imageWithColor:y2PinkColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    if(header==header_segment){
       
        NSArray *itemArray = [NSArray arrayWithObjects: @"Wanita", @"Pria", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        segmentedControl.frame = CGRectMake(0, 0, 250, 44);
//        segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
        [segmentedControl addTarget:self
                             action:@selector(genderPicked:)
                   forControlEvents:UIControlEventValueChanged];
        if (catType==nil) {
            catType=Male;
        }
        if ([catType isEqualToString:Female]) {
            segmentedControl.selectedSegmentIndex = 0;
        }else{
            segmentedControl.selectedSegmentIndex = 1;
        }
        [headerView addSubview:segmentedControl];
        
        
        UIImage * whiteImage  = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
        [segmentedControl setBackgroundImage:pinkImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [segmentedControl setBackgroundImage:whiteImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [segmentedControl setDividerImage:pinkImage forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [segmentedControl setDividerImage:pinkImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
               NSDictionary *whiteTextAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                       [UIFont boldSystemFontOfSize:14], NSForegroundColorAttributeName,
                                       nil];
        [segmentedControl setTitleTextAttributes:whiteTextAttr forState:UIControlStateSelected];
        [segmentedControl setTitleTextAttributes:whiteTextAttr forState:UIControlStateNormal];
        return headerView;
    }else{
        UIImageView * backIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-back.png"]];
        backIcon.frame = CGRectMake(5, 13, 17, 17);
        [headerView addSubview:backIcon];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0 , 0, 110, 44);
        [button setTitle:@"Kembali" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setTitleColor:y2PinkColor forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
        
        UIImageView * separator = [[UIImageView alloc] initWithImage:pinkImage];
        separator.frame = CGRectMake(125 , 0, 2, 44);
        [headerView addSubview:separator];
        
        UIImageView *homeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-home.png"]];
        homeIcon.frame = CGRectMake(135, 13, 17, 17);
        [headerView addSubview:homeIcon];
        
        UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        homeButton.frame = CGRectMake(130 , 0, 110, 44);
        [homeButton setTitle:@"Home" forState:UIControlStateNormal];
        homeButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [homeButton setTitleColor:y2PinkColor forState:UIControlStateNormal];
        homeButton.backgroundColor = [UIColor clearColor];
        [homeButton addTarget:self action:@selector(homePressed:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:homeButton];
        
        UIImageView * bottomBar = [[UIImageView alloc] initWithImage:pinkImage];
        bottomBar.frame = CGRectMake(0 , 40, 250, 4);
        [headerView addSubview:bottomBar];
        return headerView;
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    int _row = (int)indexPath.row;
    cell.textLabel.text = tableData[_row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if(!IS_IPAD){
        cell.textLabel.font =[UIFont systemFontOfSize:13];
    }
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    
    return cell;
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    int _row = (int)indexPath.row;
//    NSString *cellText = tableData[_row];
//    UIFont *cellFont = FONT_ARSENAL(IS_IPAD ? 15 : 11);
//    
//    NSAttributedString *attributedText =
//    [[NSAttributedString alloc]
//     initWithString:cellText
//     attributes:@
//     {
//     NSFontAttributeName: cellFont
//     }];
//    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                               context:nil];
//    return rect.size.height + 20;
//}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self setCellColor:[UIColor whiteColor] ForCell:cell];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self setCellColor:[UIColor colorWithWhite:0.961 alpha:1.000] ForCell:cell];
    
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = [UIColor colorWithRed:(236/255.0) green:(0/255.0) blue:(140/255.0) alpha:1] ;;
    cell.backgroundColor = color;
}

#pragma mark - TableView Delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![DataSingleton instance].disableTouchOnLeftMenu) {
        switch (currentMenu) {
            case menu_main:
            {
                int _row = (int)indexPath.row;
                NSString *menuString = [tableData objectAtIndex:_row];
                if ([menuString isEqualToString:homeMenu]) {
                    if ([DataSingleton instance].networkError) {
                        if (firstTime) {
                            firstTime = false;
                            [self showNetworkErrorPage];
                        }else{
                            Reachability *reachability = [Reachability reachabilityForInternetConnection];
                            NetworkStatus internetStatus = [reachability currentReachabilityStatus];
                            if(internetStatus != NotReachable){
                                [self fetchInitialData];
                            }else{
                                [self showNetworkErrorPage];
                            }
                        }
                    }else{
                        [self goToHome];
                    }
                }
                else if ([menuString isEqualToString:myAccountMenu]){
                    NSArray *accountMenuList = [NSArray arrayWithObjects:detailAccountMenu,orderAccountMenu, nil];
                    [self updateMenuWithCustomList:accountMenuList];
                    currentMenu = menu_account;
                    header = header_back;
                }else if ([menuString isEqualToString:productMenu]){
                    NSMutableArray *productMenuList = [NSMutableArray array];
                    if ([DataSingleton instance].menuCMSProductGrosir) {
                        [productMenuList addObject:productGrosirMenu];
                    }
                    if ([DataSingleton instance].menuCMSProduct) {
                        [productMenuList addObject:productRetailMenu];
                    }
                    [self updateMenuWithCustomList:productMenuList];
                    currentMenu = menu_product;
                    header = header_back;
                }else if ([menuString isEqualToString:salesMenu]){
                    NSMutableArray *salesMenuList = [NSMutableArray array];
                    if ([DataSingleton instance].showSalesOrder) {
                        [salesMenuList addObject:orderMenu];
                    }
                    if ([DataSingleton instance].showSalesRetur) {
                        [salesMenuList addObject:returMenu];
                    }
                    [self updateMenuWithCustomList:salesMenuList];
                    currentMenu = menu_sales;
                    header = header_back;
                }else if ([menuString isEqualToString:logoutMenu]){
                    [self logoutAccount];
                }else if ([menuString isEqualToString:loginMenu]){
                    NSArray *loginMenuList = [NSArray arrayWithObjects:loginMenu,registerMenu, nil];
                    [self updateMenuWithCustomList:loginMenuList];
                    currentMenu = menu_login;
                    header = header_back;
                }else if ([menuString isEqualToString:footer1Menu]){
                    NSMutableArray *footer1MenuList = [NSMutableArray array];
                    for (NSDictionary* footerInfo in [DataSingleton instance].footer1MenuList) {
                        [footer1MenuList addObject:[footerInfo valueForKey:@"cat_title"]];
                    }
                    [self updateMenuWithCustomList:footer1MenuList];
                    currentMenu = menu_footer1;
                    header = header_back;
                }else if ([menuString isEqualToString:footer2Menu]){
                    NSMutableArray *footer1MenuList = [NSMutableArray array];
                    for (NSDictionary* footerInfo in [DataSingleton instance].footer2MenuList) {
                        [footer1MenuList addObject:[footerInfo valueForKey:@"cat_title"]];
                    }
                    [self updateMenuWithCustomList:footer1MenuList];
                    currentMenu = menu_footer2;
                    header = header_back;
                }else{
                    [self handleMenuAPI:menuString];
                }
            }
                
                break;
            case menu_api:
            {
                int _row = (int)indexPath.row;
                NSString *menuString = [tableData objectAtIndex:_row];
                [self handleMenuAPI:menuString];
            }
                break;
            case menu_login:
            {
                int _row = (int)indexPath.row;
                NSString *menuString = [tableData objectAtIndex:_row];
                if ([menuString isEqualToString:loginMenu]){
                    [self goToLoginPage];
                }else if ([menuString isEqualToString:registerMenu]){
                    [self goToRegisterPage];
                }
            }
                break;
            case menu_account:
            {
                int _row = (int)indexPath.row;
                NSString *menuString = [tableData objectAtIndex:_row];
                if ([menuString isEqualToString:detailAccountMenu]){
                    [self goToAccountProfile];
                }else if ([menuString isEqualToString:orderAccountMenu]){
                    [self goToAccountOrder];
                }
            }
                break;
            case menu_product:
            {
                int _row = (int)indexPath.row;
                NSString *menuString = [tableData objectAtIndex:_row];
                if ([menuString isEqualToString:productRetailMenu]){
                    [self goToListProductPage:true];
                }else if ([menuString isEqualToString:productGrosirMenu]){
                    [self goToListProductPage:false];
                }
            }
                break;
            case menu_sales:
            {
                int _row = (int)indexPath.row;
                NSString *menuString = [tableData objectAtIndex:_row];
                if ([menuString isEqualToString:orderMenu]){
                    [self goToSalesOrderPage];
                }else if ([menuString isEqualToString:returMenu]){
                    [self goToSalesReturPage];
                }
            }
                break;
            case menu_footer1:
            {
                int _row = (int)indexPath.row;
                NSDictionary *footerMenu1 = [[DataSingleton instance].footer1MenuList objectAtIndex:_row];
                [self goToFooterMenuPage:[footerMenu1 valueForKey:@"cat_title"] withContent:[footerMenu1 valueForKey:@"cat_tautan"]];
            }
                break;
            case menu_footer2:
            {
                int _row = (int)indexPath.row;
                NSDictionary *footerMenu2 = [[DataSingleton instance].footer2MenuList objectAtIndex:_row];
                [self goToFooterMenuPage:[footerMenu2 valueForKey:@"cat_title"] withContent:[footerMenu2 valueForKey:@"cat_tautan"]];
            }
                break;
            case menu_footer3:
                break;
            case menu_footer4:
                break;
            default:
                break;
        }
    }
    
    //[self updateTableWidth];
    
}

#pragma mark - AlertView Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==logoutAlert){
        if (buttonIndex==0) {
            NSLog(@"logout: tidak");
        }else{
            NSLog(@"logout: ya");
            [self logoutProcess];
        }
        [self.mainSlideMenu closeLeftMenuAnimated:YES];
    }
    
}

#pragma mark - Action
- (void)handleMenuAPI:(NSString*)menuString{
    //find out what menu user tap on
    BOOL hasChild = false;
    NSMutableDictionary *tempMenuRef;
    for (NSMutableDictionary* menuList in [currentParent valueForKey:@"child"]) {
        if ([[menuList valueForKey:@"name"]isEqualToString:menuString]) {
            if ([[menuList valueForKey:@"child" ] count]) {
                //has child, move parent
                hasChild = true;
                currentParent = menuList;
            }
            tempMenuRef = menuList;
            break;
        }
    }
    if (hasChild) {
        //has child, expand, change menu
        NSMutableDictionary * lastParent = [NSMutableDictionary dictionaryWithDictionary:currentParent];
        [listOfParent addObject:lastParent];
        [self updateMenuWithChild:[currentParent valueForKey:@"child"]];
    }else{
        //show product
        [self goToCategoryPageProduct:[tempMenuRef valueForKey:@"url"] withTitle:[tempMenuRef valueForKey:@"name"]];
    }
}

- (void) goToHome
{
    HomeViewController *rootVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    rootVC.leftMenuReference = self;
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self openContentNavigationController:nvc];
    [self fetchHomeMenuFromAPI];
}

- (void) goToAccountProfile{
    UINavigationController *nvc;
    ProfilePageViewController * profileVC = [[ProfilePageViewController alloc] initWithNibName:@"ProfilePageViewController" bundle:nil];
    profileVC.leftMenuReference = self;
    [DataSingleton retrieveUser];
    profileVC.myProfile = [DataSingleton instance].loggedInUser;
    
    nvc = [[UINavigationController alloc] initWithRootViewController:profileVC];
    [self openContentNavigationController:nvc];
}

- (void) goToAccountOrder{
    [DataSingleton instance].disableTouchOnLeftMenu = YES;
    UINavigationController *nvc;
    OrderViewController * orderVC = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
    nvc = [[UINavigationController alloc] initWithRootViewController:orderVC];
    [self openContentNavigationController:nvc];
    
}

- (void)goToAddProductPage{
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[AddNewProductViewController alloc] initWithNibName:@"AddNewProductViewController" bundle:nil];
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self openContentNavigationController:nvc];
}

- (void)goToListProductPage:(BOOL)retailProduct{
    [DataSingleton instance].disableTouchOnLeftMenu = YES;
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[ProductListViewController alloc] initWithNibName:@"ProductListViewController" bundle:nil];
    ((ProductListViewController*)rootVC).isRetailProduct = retailProduct;
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self openContentNavigationController:nvc];
}

- (void)goToSalesOrderPage{
    [DataSingleton instance].disableTouchOnLeftMenu = YES;
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[SalesOrderViewController alloc] initWithNibName:@"SalesOrderViewController" bundle:nil];
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self openContentNavigationController:nvc];
}

- (void)goToSalesReturPage{
    [DataSingleton instance].disableTouchOnLeftMenu = YES;
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[ReturPageViewController alloc] initWithNibName:@"ReturPageViewController" bundle:nil];
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self openContentNavigationController:nvc];
}

- (void)goToLoginPage{
    UINavigationController *nvc;
    LoginViewController * loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginVC.leftMenuReference = self;
    
    nvc = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self openContentNavigationController:nvc];
}

- (void)goToRegisterPage{
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self openContentNavigationController:nvc];
}

- (void)goToFooterMenuPage:(NSString*)title withContent:(NSString*)tautan{
    UINavigationController *nvc;
    WebViewViewController * footerVC = [[WebViewViewController alloc] initWithNibName:@"WebViewViewController" bundle:nil];
    footerVC.idTautan = tautan;
    footerVC.titleMenu = title;
    
    nvc = [[UINavigationController alloc] initWithRootViewController:footerVC];
    [self openContentNavigationController:nvc];
}

- (void) goToCategoryPageProduct:(NSString*)APIUrl withTitle:(NSString*)title
{
    [DataSingleton instance].disableTouchOnLeftMenu = YES;
    UINavigationController *nvc;
    UIViewController *rootVC;
    
    CatalogueViewController *categoryView = [[CatalogueViewController alloc] initWithNibName:@"CatalogueViewController" bundle:nil];
    categoryView.pageTitle = title;
    categoryView.APIUrl = APIUrl;
    categoryView.leftMenuReference = self;
    
    rootVC = categoryView;
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self shallShowOverlay:NO];
    [self openContentNavigationController:nvc];
}

- (void)logoutAccount{
    
    UIAlertView *logoutConfirmation = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                         message:@"Anda yakin ingin logout?"
                                                        delegate:self
                                               cancelButtonTitle:@"Tidak"
                                               otherButtonTitles:@"Ya", nil];
    logoutConfirmation.tag = logoutAlert;
    [logoutConfirmation show];
}

#pragma mark - ASIHTTPRequest request
-(void)logoutProcess{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus == NotReachable){
        [DataSingleton instance].networkError = true;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Koneksi Internet Error"
                                                        message:@"Koneksi internet dibutuhkan untuk logout"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        [self shallShowOverlay:YES];
        [DataSingleton instance].networkError = false;
        NSString * logoutUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,logoutURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:logoutUrl]];
        request.tag = userLogout;
        [request setRequestMethod:@"POST"];
        
        NSString* accessToken = [DataSingleton instance].loggedInUser==nil? @"-1":[DataSingleton instance].loggedInUser.token;
        [request addPostValue:accessToken forKey:@"token"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)fetchHomeMenuFromAPI{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus == NotReachable){
        [DataSingleton instance].networkError = true;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Koneksi Internet Error"
                                                        message:@"Koneksi internet dibutuhkan untuk logout"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        [self shallShowOverlay:YES];
        [DataSingleton instance].networkError = false;
        
        NSMutableString *targetURL = [NSMutableString stringWithFormat:@"%@%@",y2BaseURL,getUserMenuTreeURL];
        if ([DataSingleton instance].loggedInUser!=NULL) {
            [targetURL appendFormat:@"?user_id=%@",[DataSingleton instance].loggedInUser.id_user];
        }
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
        [request setDelegate:self];
        [request setTag:getUserMenuTree];
        [request setTimeOutSeconds:60];
        [request setRequestMethod:@"GET"];
        [request startAsynchronous];
    }
}

-(void)fetchInitialData{
    [self shallShowOverlay:YES];
    [networkQueue cancelAllOperations];
    networkQueue = [ASINetworkQueue queue];
    networkQueue.delegate = self;
    [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
	[networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
    [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
    [DataSingleton fetchInitiallData:networkQueue];
    currentSession = queueFetchInitial;
    [networkQueue go];
}

-(void)fetchData:(BOOL)isLogout{
    [self shallShowOverlay:YES];
    isLogoutProcess = isLogout;
    [networkQueue cancelAllOperations];
    networkQueue = [ASINetworkQueue queue];
    networkQueue.delegate = self;
    [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
	[networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
    [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
    NSMutableArray* urlStringsToRequest = [NSMutableArray array];
    NSDictionary *urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getTopProductURL], @"url",
                  [NSNumber numberWithInt:getTopProduct],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                   [NSString stringWithFormat:@"%@%@",y2BaseURL,getTopSellerURL], @"url",
                   [NSNumber numberWithInt:getTopSeller],@"tag",
                   nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getSlideShowPromoURL], @"url",
                  [NSNumber numberWithInt:getSlideShowPromo],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getUserMenuURL], @"url",
                  [NSNumber numberWithInt:getUserMenu],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    if (isLogout) {
        urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                      [NSString stringWithFormat:@"%@%@",y2BaseURL,getUserMenuTreeURL], @"url",
                      [NSNumber numberWithInt:getUserMenuTree],@"tag",
                      nil];
        [urlStringsToRequest addObject:urlToFetch];
    }
    
    
    for (NSDictionary* _urlData in urlStringsToRequest) {
        NSString* _url = [_urlData valueForKey:@"url"];
        int tag = [(NSNumber*)[_urlData valueForKey:@"tag"] intValue];
        NSURL *url = [NSURL URLWithString:_url];
        
        if (tag==getTopProduct) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            
            NSString* user_id = @"-1";
            if ([DataSingleton instance].loggedInUser!=NULL) {
                user_id = [DataSingleton instance].loggedInUser.id_user;
            }
            [request addPostValue:user_id forKey:@"user_id"];
            [networkQueue addOperation:request];
        } else if (tag==getTopSeller) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* userID = [DataSingleton instance].loggedInUser==nil? @"-1":[DataSingleton instance].loggedInUser.id_user;
            [request addPostValue:userID forKey:@"user_id"];
            [networkQueue addOperation:request];
            
        }else if (tag==getSlideShowPromo) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* userID = [DataSingleton instance].loggedInUser==nil? @"-1":[DataSingleton instance].loggedInUser.id_user;
            [request addPostValue:userID forKey:@"user_id"];
            [networkQueue addOperation:request];
        }else if (tag==getUserMenu) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* userID = [DataSingleton instance].loggedInUser==nil? @"-1":[DataSingleton instance].loggedInUser.id_user;
            [request addPostValue:userID forKey:@"user_id"];
            [networkQueue addOperation:request];
        }else if (tag==getUserMenuTree) {
            NSMutableString *composedURL = [NSMutableString stringWithString:_url];
            if ([DataSingleton instance].loggedInUser!=NULL) {
                [composedURL appendFormat:@"?user_id=%@",[DataSingleton instance].loggedInUser.id_user];
            }
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:composedURL]];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"GET"];
            [networkQueue addOperation:request];
        }
        
    }
    
    for (M_Cart* cart in [DataSingleton retrieveShopCart]) {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",y2BaseURL,[cart.is_grosir boolValue]? getProductGrosirURL:getProductURL]]];
        [request setDelegate:self];
        [request setTag:getProductShopCart];
        [request setTimeOutSeconds:60];
        [request setRequestMethod:@"POST"];
        
        [request addPostValue:cart.id_product forKey:@"prd_id"];
        [networkQueue addOperation:request];
    }
    [[DataSingleton instance].usedCart removeAllItems];
    [DataSingleton instance].shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[[DataSingleton instance].usedCart.totalItem intValue]];
    
    currentSession = queueFetch;
    [networkQueue go];
}

- (void)unregisterToken:(NSString*)myToken andUserID:(NSString*)userID
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus == NotReachable)
    {
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: message_connection_error
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }else
    {
        if (userID.length>0 && myToken.length>0) {
            NSString * _loginURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,unregisterDeviceTokenURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_loginURL]];
            request.tag = unregisterDeviceToken;
            [request setRequestMethod:@"POST"];
            
            [request addPostValue:userID forKey:@"user_id"];
            [request addPostValue:myToken forKey:@"device_token"];
            
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
        
    }
    
}

#pragma mark - ASIHTTPRequest callback
- (void)oneRequestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    [DataSingleton instance].networkError |= false;
    [DataSingleton processAPIRequestResult:responseString withRequestCode:request.tag];
    NSLog(@"Request finished");
}

- (void)oneRequestFailed:(ASIHTTPRequest *)request
{
    [DataSingleton instance].networkError |= true;
	NSLog(@"Request failed");
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	// You could release the queue here if you wanted
	if ([networkQueue requestsCount] == 0) {
		networkQueue = nil;
	}
	NSLog(@"Queue finished");
    [self shallShowOverlay:NO];
    if ([DataSingleton instance].errorNotificationMessage.length>0) {
        [[DataSingleton instance].errorNotificationMessage insertString:[NSString stringWithFormat:@"There're some error occured on API (%@): \n",y2BaseURL] atIndex:0];
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: [DataSingleton instance].errorNotificationMessage
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
        [DataSingleton instance].errorNotificationMessage = [NSMutableString string];
    }
    
    if (currentSession==queueFetch) {
        [self initializeData];
        [self.tableView reloadData];
        [self goToHome];
        
        if (isLogoutProcess) {
            //[self unregisterToken:deviceTokenTemp andUserID:userIDTemp];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                            message:@"Anda berhasil logout"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                            message:@"Login sukses"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }else if (currentSession==queueFetchInitial){
        if (![DataSingleton instance].networkError) {
            [self initializeData];
            [self.tableView reloadData];
            [self goToHome];
        }
        
        
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self shallShowOverlay:NO];
    if (request.tag==userLogout) {
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: message_connection_error
                     delegate: self
                     cancelButtonTitle: @"OK" otherButtonTitles: nil];
        
        [errorView show];

    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self shallShowOverlay:NO];
    if (request.tag==userLogout){
        NSString *responseString = [request responseString];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
        BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
        if (success) {
            [DataSingleton deleteUser];
            [DataSingleton instance].userSellerIDs = [NSArray array];
            [self fetchData:YES];
        }else{
            NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: errorMessage
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
            [DataSingleton deleteUser];
            [self fetchData:YES];
        }

    }else if (request.tag==getUserMenuTree){
        NSString *responseString = [request responseString];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
        BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
        if (success) {
            NSDictionary* responseData = [jsonDictionary objectForKey:@"data"];
            if ([responseData objectForKey:@"menu_tree"]!=nil) {
                [DataSingleton setUserMenuTree:(NSArray *)[responseData objectForKey:@"menu_tree"]];
            }
            
            if ([responseData objectForKey:@"seller_ids"]!=nil) {
                [DataSingleton instance].userSellerIDs = [NSArray arrayWithArray:[responseData objectForKey:@"seller_ids"]];
            }
            [self constructMaleMenu];
            [self constructFemaleMenu];
            [self populateMenuWithHomeMenu];
        }
    }
}

- (void) updateMenuWithChild:(NSMutableArray*)child
{
    [self pushCurrentMenuList];
    [tableData removeAllObjects];
    for (NSMutableDictionary* childInfo in child) {
        [tableData addObject:((NSString*)[childInfo valueForKey:@"name"]).length>0? [childInfo valueForKey:@"name"]:@"<no name>"];
    }
    [self.tableView reloadData];
    
    currentMenu = menu_api;
    header = header_back;
}

//input: array of NSString
- (void) updateMenuWithCustomList:(NSArray*)customList
{
    [self pushCurrentMenuList];
    
    [tableData removeAllObjects];
    
    for (NSString* elementOfCustomList in customList) {
        [tableData addObject:elementOfCustomList];
    }
    
    [self.tableView reloadData];
    
}

- (void)pushCurrentMenuList{
    if (NULL==prevTableData) {
        prevTableData = [NSMutableArray array];
    }
    NSArray *currentList = [tableData copy];
    [prevTableData addObject:currentList];
    
    if(prevTableData.count == 1){
        rootTableData = [NSMutableArray array];
        [rootTableData addObject:currentList];
    }
}

-(void)popBackPrevMenu{
    [tableData removeAllObjects];
    tableData = [[prevTableData lastObject] mutableCopy];
    [self.tableView reloadData];
    [prevTableData removeLastObject];
    switch (currentMenu) {
        case menu_api:
            [listOfParent removeLastObject];
            if ([listOfParent count]==1) {
                currentMenu = menu_main;
                header = header_segment;
            }else{
                currentMenu = menu_api;
                header = header_back;
            }
            currentParent = [listOfParent lastObject];
            break;
        case menu_account:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_product:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_sales:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_login:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_footer1:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_footer2:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_footer3:
            currentMenu = menu_main;
            header = header_segment;
            break;
        case menu_footer4:
            currentMenu = menu_main;
            header = header_segment;
            break;
        default:
            break;
    }
    if (currentMenu==menu_main) {
        selectedCategory = nil;
    }
}

- (void) backPressed:(id)sender
{
    [self popBackPrevMenu];
}
- (void) homePressed:(id)sender
{
    [self populateMenuWithHomeMenu];
    [self goToHome];
}

- (void) populateMenuWithHomeMenu{
    if ([catType isEqualToString:Male]) {
        [self populateMenuWithMaleMenu];
    }else{
        [self populateMenuWithFemaleMenu];
    }
    
    listOfParent = [NSMutableArray arrayWithObjects:currentParent, nil];
    prevTableData = [NSMutableArray array];
    
    currentMenu = menu_main;
    header = header_segment;
}

- (void) showNetworkErrorPage{
    UINavigationController *nvc;
    UIViewController *rootVC;
    
    BlankPageViewController *blankView = [[BlankPageViewController alloc] initWithNibName:@"BlankPageViewController" bundle:nil];
    
    blankView.imageNamed = @"icon_no_con";//nama image ketika koneksi error
    
    rootVC = blankView;
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self shallShowOverlay:NO];
    [self openContentNavigationController:nvc];
}
- (void) showNoProductPage{
    UINavigationController *nvc;
    UIViewController *rootVC;
    
    BlankPageViewController *blankView = [[BlankPageViewController alloc] initWithNibName:@"BlankPageViewController" bundle:nil];
    
    blankView.imageNamed = @"icon_no_prod";//nama image ketika no product
    
    rootVC = blankView;
    
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self openContentNavigationController:nvc];
}

- (void) setAllOwnerProductStatus:(BOOL)allOwnerProduct{
    isAllOwnerProduct = allOwnerProduct;
}
- (BOOL) getAllOwnerProductStatus{
    return isAllOwnerProduct;
}

-(void)shallShowOverlay:(BOOL)shallShow{
    UIViewController* upperView = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-1];
    
    upperView.view.userInteractionEnabled = !shallShow;
    self.view.userInteractionEnabled = !shallShow;
    [self.tableView setUserInteractionEnabled:!shallShow];
    
    if (shallShow) {
        [upperView.view addSubview:loader];
        [upperView.view bringSubviewToFront:loader];
        loader.center = CGPointMake(upperView.view.frame.size.width / 2, upperView.view.frame.size.height / 2);
        
        
        upperView.view.alpha = 0.5f;
        [loader startAnimating];
    }else{
        [loader stopAnimating];
        upperView.view.alpha = 1.0f;
        [loader removeFromSuperview];
    }
}

-(void)updateTableWidth{
//    CGFloat maxWidth = 0.0;
//    CGSize maxSize = CGSizeMake(400,99999);
//    CGFloat cellIndent = 10; //Use this to account for any cell indenting
//    for(NSString * text in tableData){
//        
//        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:17]
//                           constrainedToSize:maxSize
//                               lineBreakMode:NSLineBreakByWordWrapping];
//        
////        CGRect textRect = [text boundingRectWithSize:maxSize
////                                             options:NSStringDrawingUsesLineFragmentOrigin
////                                          attributes:nil
////                                             context:nil];
////        CGSize textSize = textRect.size;
//        
//        maxWidth = MAX(maxWidth,textSize.width + 2.0*cellIndent);
//    }
//    
//    //Now change the tableView's frame
//    CGRect newFrame = self.tableView.frame;
//    newFrame.size.width = maxWidth;
//    self.tableView.frame = newFrame;
}


@end
