//
//  SalesOrderDetailViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 1/29/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "SalesOrderDetailViewController.h"
#import "OrderDetailListCell.h"
#import "SummaryDetailListCell.h"
#import "SellerListCell.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TGRImageViewController.h"

#define orderStatusDropDown 10
#define tableBgColorEven [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]
#define tableBgColorOdd [UIColor whiteColor]
#define request_sales_order_detail 11
#define update_sales_order_detail 12
#define awaitingPaymentId 1
#define shouldCreateCommentTextView [selectedStatusOrderId intValue]==awaitingPaymentId && [preSelectedStatusOrderId intValue]!=awaitingPaymentId

static NSString * const OrderDetailCellIdentifier = @"OrderDetailCell";
static NSString * const ProductDetailCellIdentifier = @"SummaryDetailCell";
static NSString * const SellerCellIdentifier = @"SellerCell";

@interface SalesOrderDetailViewController ()

@end

@implementation SalesOrderDetailViewController
@synthesize orderNumberString,rootContainer,rootScroller,pageTitle,tableTitleOrder,tableTitleShipping,tableTitleContactShipping,tableTitleTransfer,tableTitleContact,tableTitleSummary,tableTitleOrderSummary,orderNumber,orderDate,orderStatus,tableTransferPayment,totalTrans,tableSeller,shippingName,shippingAddress,shippingLocation,shippingMethod,shippingEmail,shippingPhone,tableProductList,itemSummaryTotal,statusOrder,statusOrderForm,statusOrderUpdateBtn,shippingCharge, shippingChargeLabel,subtotal,grandTotal,loading,loadingOverlay,loadingWrapper,popover,orderStatusTable,updateStatusOrderBtnTopConstraint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1.0f];
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,widthContentView,self.navigationController.navigationBar.frame.size.height)];
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    UIImageView *imageLogo = [[UIImageView alloc] init];
    imageLogo.contentMode = UIViewContentModeScaleAspectFit;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [imageLogo sizeToFit];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
    titleLabel.text = @"Sales Order Detail";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    float spaceLeftLogoToSuperview = 0.0;
    //    if (IS_IPAD) {
    //        spaceLeftLogoToSuperview = 10.0f;
    //    }else {
    //        spaceLeftLogoToSuperview = 5.0f;
    //    }
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(contentView,titleLabel,imageLogo);
    //padding left constraint for imageLogo
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-constantSpace-[imageLogo]" options:0 metrics: @{@"constantSpace":@(spaceLeftLogoToSuperview)} views:viewsDictionary]];
    //height constraint in order to not exceed navigationBar height
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageLogo(<=constantHeight)]" options:0 metrics:@{@"constantHeight":@(self.navigationController.navigationBar.frame.size.height)} views:viewsDictionary]];
    
    NSLayoutConstraint *aspectRatioConstraint =[NSLayoutConstraint
                                                constraintWithItem:imageLogo
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:imageLogo
                                                attribute:NSLayoutAttributeWidth
                                                multiplier:CGRectGetHeight(imageLogo.frame)/CGRectGetWidth(imageLogo.frame) //Aspect ratio: height:width
                                                constant:0.0f];
    [contentView addConstraint:aspectRatioConstraint];
    
    //space constraint between imageLogo and titleLabel
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageLogo]-constantSpace-[titleLabel]-0-|" options:0 metrics: @{@"constantSpace":@(spaceLogoToTitle)} views:viewsDictionary]];
    
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if (didUpdateOrderStatus) {
            if(_delegate && [_delegate respondsToSelector:@selector(updateOrderStatus:)])
            {
                [_delegate updateOrderStatus:true];
            }
        }
        else{
            for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations)
            {
                [req clearDelegatesAndCancel];
            }
        }
    }
    
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeData];
    [self initializeComponent];
    [self populateData];
    [self requestSalesOrderDetail];
}

//- (void)updateTableSize{
//    int maxRowOrderDetail = 3;
//    int maxRowSeller = 3;
//    int maxRowSummaryDetail = 3;
//    float height = 0.0;
//    height = orderDetailList.count>maxRowOrderDetail?142.0*maxRowOrderDetail:142.0*orderDetailList.count;
//    
//    tableOrderDetail.translatesAutoresizingMaskIntoConstraints = NO;
//    CGRect tableFrame = tableOrderDetail.frame;
//    tableFrame.size = CGSizeMake(tableFrame.size.width, height);
//    [tableOrderDetail setFrame:tableFrame];
//    
//    height = sellerList.count>maxRowSeller?142.0*maxRowSeller:142.0*sellerList.count;
//    tableSeller.translatesAutoresizingMaskIntoConstraints = NO;
//    tableFrame = tableOrderDetail.frame;
//    tableFrame.size = CGSizeMake(tableFrame.size.width, height);
//    [tableSeller setFrame:tableFrame];
//    
//    height = summaryDetailList.count>maxRowSummaryDetail?142.0*maxRowSummaryDetail:142.0*summaryDetailList.count;
//    tableProductList.translatesAutoresizingMaskIntoConstraints = NO;
//    tableFrame = tableOrderDetail.frame;
//    tableFrame.size = CGSizeMake(tableFrame.size.width, height);
//    [tableProductList setFrame:tableFrame];
//}

- (void)initializeData{
    transPaymentList = [NSMutableArray array];
    sellerList = [NSMutableArray array];
    productList = [NSMutableArray array];
    orderStatusList = [NSMutableArray array];
    groupOfProduct = [NSMutableArray array];
    didUpdateOrderStatus = false;
    
    selectedStatusOrderIndex = -1;
    selectedStatusOrderId = [NSNumber numberWithInt:0];
    nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
}

- (void)initializeComponent{
    rootScroller.alwaysBounceVertical = NO;
    statusOrder.delegate = self;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, statusOrder.frame.size.height)];
    statusOrder.leftView = paddingView;
    statusOrder.leftViewMode = UITextFieldViewModeAlways;
    
    tableTransferPayment.delegate = self;
    tableTransferPayment.dataSource = self;
    [tableTransferPayment registerNib:[UINib nibWithNibName:@"OrderDetailListCell" bundle:nil] forCellReuseIdentifier:OrderDetailCellIdentifier];
    tableTransferPayment.alwaysBounceVertical = NO;
    
    
    tableSeller.delegate = self;
    tableSeller.dataSource = self;
    [tableSeller registerNib:[UINib nibWithNibName:@"SellerListCell" bundle:nil] forCellReuseIdentifier:SellerCellIdentifier];
    tableSeller.alwaysBounceVertical = NO;
    
    
    tableProductList.delegate = self;
    tableProductList.dataSource = self;
    [tableProductList registerNib:[UINib nibWithNibName:@"SummaryDetailListCell" bundle:nil] forCellReuseIdentifier:ProductDetailCellIdentifier];
    tableProductList.alwaysBounceVertical = NO;
    
    
    orderStatusTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240.0, 265.0) style:UITableViewStylePlain];
    orderStatusTable.delegate = self;
    orderStatusTable.dataSource = self;
    orderStatusTable.alwaysBounceVertical = NO;
    
    popover = [DXPopover new];
    
    if (IS_IPAD) {
        pageTitle.font = FONT_ARSENAL(25);
        tableTitleOrder.font = FONT_ARSENAL(17);
        tableTitleShipping.font = FONT_ARSENAL(17);
        tableTitleContactShipping.font = FONT_ARSENAL(17);
        tableTitleTransfer.font = FONT_ARSENAL(17);
        tableTitleContact.font = FONT_ARSENAL(17);
        tableTitleSummary.font = FONT_ARSENAL(17);
        tableTitleOrderSummary.font = FONT_ARSENAL(17);
    }else{
        pageTitle.font = FONT_ARSENAL(18);
        tableTitleOrder.font = FONT_ARSENAL(13);
        tableTitleShipping.font = FONT_ARSENAL(13);
        tableTitleContactShipping.font = FONT_ARSENAL(13);
        tableTitleTransfer.font = FONT_ARSENAL(13);
        tableTitleContact.font = FONT_ARSENAL(13);
        tableTitleSummary.font = FONT_ARSENAL(13);
        tableTitleOrderSummary.font = FONT_ARSENAL(13);
    }
    
    
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    orderDate.text = @"";
    orderStatus.text = @"";
    shippingName.text = @"";
    shippingAddress.text = @"";
    shippingLocation.text = @"";
    shippingMethod.text = @"";
    shippingEmail.text = @"";
    shippingPhone.text = @"";
    totalTrans.text = @"";
    itemSummaryTotal.text = @"";
    shippingCharge.text = @"";
    subtotal.text = @"";
    grandTotal.text = @"";
    
    [orderNumber setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [orderDate setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [orderStatus setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [shippingName setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [shippingAddress setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [shippingLocation setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [shippingMethod setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [shippingEmail setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [shippingPhone setTextVerticalAlignment:UITextVerticalAlignmentTop];
    
    UIView *mainView = self.view;
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(rootScroller, rootContainer, mainView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rootScroller]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rootScroller]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rootContainer]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rootContainer]|" options:0 metrics: 0 views:viewsDictionary]];
    
    //hack to tie contentView width to the width of the screen
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rootContainer(==mainView)]" options:0 metrics:0 views:viewsDictionary]];
}

- (void)populateData{
    orderNumber.text = orderNumberString;
    
    if (dataOrder) {
        orderDate.text = [dataOrder valueForKey:@"ord_date"];
        orderStatus.text = [dataOrder valueForKey:@"ord_status_description"];
        shippingName.text = [dataOrder valueForKey:@"ord_ship_name"];
        shippingAddress.text = [dataOrder valueForKey:@"ord_ship_address_01"];
        shippingLocation.text = @"";
        shippingMethod.text = [dataOrder valueForKey:@"ord_ship_method"];
        shippingEmail.text = [dataOrder valueForKey:@"ord_email"];
        shippingPhone.text = [dataOrder valueForKey:@"ord_phone"];
        
        NSNumber *totalTransferData = [NSNumber numberWithInt:0];
        for (NSDictionary* transPaymentInfo in transPaymentList) {
            NSNumber *payment = [transPaymentInfo valueForKey:@"transfer_amount"];
            totalTransferData = [NSNumber numberWithInt:([payment intValue]+[totalTransferData intValue])];
        }
        NSNumber *summaryTotalData = [dataOrder valueForKey:@"ord_total"];
        NSNumber *shippingChargeData = [dataOrder valueForKey:@"ord_ship_charges"];
        NSNumber *subTotalData = summaryTotalData;
        NSNumber *grandTotalData = [NSNumber numberWithInt:[subTotalData intValue]+[shippingChargeData intValue]];
        int priceTotalTransfer = [totalTransferData intValue];
        int priceSummaryTotal = [summaryTotalData intValue];
        int priceShippingCharge = [shippingChargeData intValue];
        int priceSubtotal = [subTotalData intValue];
        int priceGrandtotal = [grandTotalData intValue];
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        double formattedTotalTrans = (priceTotalTransfer / 1000.0);
        double formattedSumTotal = (priceSummaryTotal / 1000.0);
        double formattedShippingCharge = (priceShippingCharge / 1000.0);
        double formattedSubtotal = (priceSubtotal / 1000.0);
        double formattedGrandtotal = (priceGrandtotal / 1000.0);
        
        totalTrans.text = [NSString stringWithFormat:@"Rp %@",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedTotalTrans * 1000]]];
        itemSummaryTotal.text = [NSString stringWithFormat:@"Rp %@",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedSumTotal * 1000]]];
        /**
         if toko, hidden shipping charge
         */
//        [self hideShippingCharge];
        shippingCharge.text = [NSString stringWithFormat:@"Rp %@",
                                 [commas stringFromNumber:[NSNumber numberWithDouble:formattedShippingCharge * 1000]]];
        
        subtotal.text = [NSString stringWithFormat:@"Rp %@",
                                 [commas stringFromNumber:[NSNumber numberWithDouble:formattedSubtotal * 1000]]];
        
        grandTotal.text = [NSString stringWithFormat:@"Rp %@",
                                 [commas stringFromNumber:[NSNumber numberWithDouble:formattedGrandtotal * 1000]]];
        
        preSelectedStatusOrderId = [nf numberFromString:(NSString*)[dataOrder valueForKey:@"ord_status_id"]];
        //create list of string, for dropdown purpose
        orderStatusList = [NSMutableArray array];
        for (NSDictionary* orderStatusInfo in orderStatusData) {
            [orderStatusList addObject:[orderStatusInfo valueForKey:@"ord_status_description"]];
        }
        
        //fill status order text
        //set default dropdown value to first data
        if (orderStatusData.count>0) {
            selectedStatusOrderIndex = 0;
            NSDictionary* orderStatusInfo = [orderStatusData objectAtIndex:selectedStatusOrderIndex];
            selectedStatusOrderId = [nf numberFromString:(NSString*)[orderStatusInfo valueForKey:@"ord_status_id"]];
            statusOrder.text = [orderStatusInfo valueForKey:@"ord_status_description"];
            //show comment text view if necessary
            if (shouldCreateCommentTextView) {
                [self createCommentView];
            }
        }else{
            [self hideUpdateStatusForm];
        }
        
        [orderStatusTable reloadData];
        if (transPaymentList.count) {
            tableTransferPayment.hidden = NO;
            [tableTransferPayment reloadData];
        }else{
            tableTransferPayment.hidden = YES;
        }
        [tableSeller reloadData];
        [tableProductList reloadData];
        //[self updateTableSize];
    }
}

- (void)hideShippingCharge{
    shippingChargeLabel.hidden = YES;
    shippingCharge.hidden = YES;
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ASIHTTPRequest
#pragma mark - delegate

- (void)requestSalesOrderDetail
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
        [self shallShowLoadingOverlay:YES];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,getSalesOrderDetailURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = request_sales_order_detail;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        
        [request addPostValue:orderNumberString forKey:@"ord_number"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)updateSalesOrderDetail
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
        [self shallShowLoadingOverlay:YES];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,updateSalesOrderDetailURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = update_sales_order_detail;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        
        [request addPostValue:orderNumberString forKey:@"ord_number"];
        [request addPostValue:selectedStatusOrderId forKey:@"status_id"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self shallShowLoadingOverlay:NO];
    UIAlertView *errorView;
    
    errorView = [[UIAlertView alloc]
                 initWithTitle: title_error
                 message: message_request_failed
                 delegate: self
                 cancelButtonTitle: @"OK" otherButtonTitles: nil];
    
    [errorView show];
}

- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"request started");
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"finished");
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case request_sales_order_detail:
            if (success) {
                NSDictionary* allData = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
                if (allData) {
                    if ([allData objectForKey:@"data_order"]) {
                        dataOrder = [NSDictionary dictionaryWithDictionary:(NSDictionary*)[allData objectForKey:@"data_order"]];
                    }
                    if ([allData objectForKey:@"status_detail_order"]) {
                        statusDetailOrder = [NSDictionary dictionaryWithDictionary:(NSDictionary*)[allData objectForKey:@"status_detail_order"]];
                    }
                    if ([[dataOrder objectForKey:@"payment_order"] isKindOfClass:[NSArray class]]) {
                        transPaymentList = [NSMutableArray arrayWithArray:(NSArray*)[dataOrder objectForKey:@"payment_order"]];
                    }
                    if ([[dataOrder objectForKey:@"order_status_detail"] isKindOfClass:[NSArray class]]) {
                        sellerList = [NSMutableArray arrayWithArray:(NSArray*)[dataOrder objectForKey:@"order_status_detail"]];
                    }
                    if ([[dataOrder objectForKey:@"list_order_status"] isKindOfClass:[NSArray class]]) {
                        orderStatusData = [NSMutableArray arrayWithArray:[dataOrder objectForKey:@"list_order_status"]];

                    }
                    if ([[dataOrder objectForKey:@"detail_order"] isKindOfClass:[NSArray class]]) {
                        productList = [NSMutableArray arrayWithArray:(NSArray*)[dataOrder objectForKey:@"detail_order"]];
                        groupOfProduct = [NSMutableArray array];
                        NSArray* sortedProductList = [NSArray arrayWithArray:[productList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                            
                            NSDictionary* first = a;
                            NSDictionary* second = b;
                            NSNumber* ownerID1 = [first valueForKey:@"owner_id"];
                            NSNumber* ownerID2 = [second valueForKey:@"owner_id"];
                            if ([ownerID1 intValue] < [ownerID2 intValue]) {
                                return NSOrderedAscending;
                            }else if ([ownerID1 intValue] > [ownerID2 intValue]){
                                return NSOrderedDescending;
                            }
                            
                            return NSOrderedSame;
                        }]];
                        
                        if (sellerList.count>0) {
                            for (NSDictionary* oneSeller in sellerList) {
                                NSNumber* ownerID = [oneSeller valueForKey:@"ord_userid_det"];
                                NSMutableArray *oneOwnerProducts = [NSMutableArray arrayWithArray:[sortedProductList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"owner_id = %@", ownerID]]];
                                [groupOfProduct addObject:oneOwnerProducts];
                            }
                        }else{
                            [groupOfProduct addObject:productList];
                        }
                        
                    }
                    
                    
                    [self populateData];
                }
                [self shallShowLoadingOverlay:NO];
                
                
            }else{
                [self shallShowLoadingOverlay:NO];
                NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_error
                             message: errorMessage
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
            }
            break;
        case update_sales_order_detail:
            if (success) {
                didUpdateOrderStatus = true;
                [self shallShowLoadingOverlay:NO];
                NSString* message = [jsonDictionary objectForKey:@"message"];
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_success
                             message: message
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
                
                
            }else{
                [self shallShowLoadingOverlay:NO];
                NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_error
                             message: errorMessage
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
            }
            break;
        default:
            break;
    }
}

#pragma mark - UITextField
#pragma mark - datasource, delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==statusOrder) {
        if (orderStatusList.count>0) {
            [activeTextField resignFirstResponder];
            if (activeTextField!=statusOrder) {
                shouldDismissPopover = false;
            }else{
                shouldDismissPopover = !shouldDismissPopover;
            }
            activeTextField = textField;
            [self showOptionListFor:orderStatusDropDown];
        }
        
        return NO;
    }else{
        activeTextField = textField;
        if (popoverShown) {
            [self hideDropDown];
        }
        return YES;
    }
    
}

- (void)showOptionListFor:(int)optionKind{
    if (!shouldDismissPopover) {
        [self updateDropDownPopoverFor:optionKind];
        switch (optionKind) {
            case orderStatusDropDown:
            {
                CGPoint showPoint = CGPointMake(CGRectGetMinX(statusOrderForm.frame)+CGRectGetMidX(statusOrder.frame), CGRectGetMinY(statusOrderForm.frame)+CGRectGetMaxY(statusOrder.frame));
                [self showDropDownAtPoint:showPoint withContent:orderStatusTable inView:rootContainer];
            }
                break;
            default:
                break;
        }
        
    }else{
        [self hideDropDown];
    }
    
}

-(void)updateDropDownPopoverFor:(int)optionKind{
    switch (optionKind) {
        case orderStatusDropDown:
            if (orderStatusList.count>5) {
                [orderStatusTable setFrame:CGRectMake(0, 0, 320.0, 216.0)];
                [popover setFrame:orderStatusTable.bounds];
                [orderStatusTable reloadData];
            }else if (orderStatusList.count>0){
                [orderStatusTable setFrame:CGRectMake(0, 0, 320.0, 44.0*orderStatusList.count)];
                [popover setFrame:orderStatusTable.bounds];
                [orderStatusTable reloadData];
            }
            
            break;
        default:
            break;
    }
    
}

- (void)showDropDownAtPoint:(CGPoint)showPoint withContent:(UIView *)content inView:(UIView*)container{
    popover.maskType = DXPopoverMaskTypeNotExist;
    [popover showAtPoint:showPoint popoverPostion:DXPopoverPositionDown withContentView:content inView:container];
    popoverShown = true;
}

- (void)hideDropDown{
    CGPoint showPoint = CGPointMake(-500, -500);
    popover.maskType = DXPopoverMaskTypeNotExist;
    [popover showAtPoint:showPoint popoverPostion:DXPopoverPositionUp withContentView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] inView:rootContainer];
    popoverShown = false;
}

#pragma mark - UITableView
#pragma mark - datasource, delegate
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView==tableProductList) {
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                     CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
        sectionHeaderView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                                CGRectMake(15, 15, sectionHeaderView.frame.size.width, 25.0)];
        headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *centerYConstraint =
        [NSLayoutConstraint constraintWithItem:headerLabel
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:sectionHeaderView
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0.0];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:headerLabel
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:sectionHeaderView
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:20.f];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        [headerLabel setFont:FONT_ARSENAL_BOLD(17)];
        [sectionHeaderView addSubview:headerLabel];
        [sectionHeaderView addConstraint:centerYConstraint];
        [sectionHeaderView addConstraint:leading];
        
        if ((int)section<sellerList.count) {
            NSDictionary* sellerInfo = sellerList[section];
            
            NSString* ownerName = [sellerInfo valueForKey:@"first_name"];
            headerLabel.text = ownerName;
        }
        
        
        return sectionHeaderView;
    }else{
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==tableProductList) {
        return 35.0f;
    }else{
        return 0.01f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==tableProductList) {
        return [groupOfProduct count];
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==tableTransferPayment) {
        return [transPaymentList count];
    }else if (tableView==tableSeller) {
        return [sellerList count];
    }else if (tableView==tableProductList) {
        NSMutableArray* oneOwnerProducts = groupOfProduct[section];
        return [oneOwnerProducts count];
    }else if (tableView==orderStatusTable){
        return [orderStatusList count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==tableTransferPayment) {
        OrderDetailListCell *cell = (OrderDetailListCell*)[tableView dequeueReusableCellWithIdentifier:OrderDetailCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        cell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
        NSDictionary* transferPaymentData = [transPaymentList objectAtIndex:row];
        
        NSNumber *transferAmount = [transferPaymentData valueForKey:@"transfer_amount"];
        int transferAmountInt = [transferAmount intValue];
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        double formattedTransferAmount = (transferAmountInt / 1000.0);
        
        cell.buttonToHandleImageTap.tag = row;
        NSString* imageUrl = [transferPaymentData valueForKey:@"image"];
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = cell.image.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIButton* referenceButtonForImageHandling = cell.buttonToHandleImageTap;
        __weak UIImageView* referenceImage = cell.image;
        __weak SalesOrderDetailViewController* weakVC = self;
        [cell.image setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     referenceImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for description");
             }else{
                 [referenceButtonForImageHandling addTarget:weakVC action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
             
         }];
        [cell.image addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        cell.destinationBank.text = [NSString stringWithFormat:@"%@ %@",(NSString*)[transferPaymentData valueForKey:@"name_bank"],(NSString*)[transferPaymentData valueForKey:@"no_rekening"]];
        cell.bankName.text = [transferPaymentData valueForKey:@"bank_name"];
        cell.bankAccount.text = [transferPaymentData valueForKey:@"bank_account"];
        cell.accountName.text = [transferPaymentData valueForKey:@"name_account"];
        cell.transDate.text = [transferPaymentData valueForKey:@"date"];
        cell.transAmount.text = [NSString stringWithFormat:@"Rp %@,-",
                                 [commas stringFromNumber:[NSNumber numberWithDouble:formattedTransferAmount * 1000]]];
        
        return cell;
    }else if (tableView==tableSeller) {
        SellerListCell *cell = (SellerListCell*)[tableView dequeueReusableCellWithIdentifier:SellerCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        cell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
        NSDictionary* sellerData = [sellerList objectAtIndex:row];
        cell.username.text = [sellerData valueForKey:@"username"];
        cell.name.text = [sellerData valueForKey:@"first_name"];
        cell.phone.text = [sellerData valueForKey:@"phone"];
        cell.orderStatus.text = [sellerData valueForKey:@"ord_status_description"];
        
        return cell;
    }else if (tableView==tableProductList) {
        SummaryDetailListCell *cell = (SummaryDetailListCell*)[tableView dequeueReusableCellWithIdentifier:ProductDetailCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        int section = (int)[indexPath section];
        NSMutableArray* oneOwnerProduct = groupOfProduct[section];
        NSDictionary *productData = [[NSDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        cell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
        //NSDictionary* summaryDetailData = [productList objectAtIndex:row];
        NSNumber *unitPrice = [productData valueForKey:@"ord_det_price"];
        NSNumber *totalPrice = [productData valueForKey:@"ord_det_price_total"];
        int unitPriceInt = [unitPrice intValue];
        int totalPriceInt = [totalPrice intValue];
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        double formattedUnitPrice = (unitPriceInt / 1000.0);
        double formattedTotalPrice = (totalPriceInt / 1000.0);
        
        cell.item.text = [productData valueForKey:@"ord_det_item_name"];
        cell.price.text = [NSString stringWithFormat:@"Rp %@,-",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedUnitPrice * 1000]]];
        cell.quantity.text = [NSString stringWithFormat:@"%d",[(NSNumber*)[productData valueForKey:@"ord_det_quantity"] intValue]];
        cell.total.text = [NSString stringWithFormat:@"Rp %@,-",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedTotalPrice * 1000]]];
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        int row = (int)indexPath.row;
        if (row==selectedStatusOrderIndex) {
            cell.selected = YES;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.selected = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[orderStatusList objectAtIndex:row]];
        cell.tag = row;
        return cell;
    }
    
}

- (void)viewImage:(id)sender
{
    int indexOfTransferPaymentImage = ((UIButton*)sender).tag;
    NSIndexPath *imageIndexPath = [NSIndexPath indexPathForRow:indexOfTransferPaymentImage inSection:0];
    OrderDetailListCell *transferPaymentTableCell = (OrderDetailListCell*)[tableTransferPayment cellForRowAtIndexPath:imageIndexPath];
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:transferPaymentTableCell.image.image];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==tableTransferPayment) {
        return [self heightForBasicOrderDetailCellAtIndexPath:indexPath];
    }else if (tableView==tableSeller) {
        return [self heightForBasicSellerCellAtIndexPath:indexPath];
    }else if (tableView==tableProductList) {
        return [self heightForBasicSummaryDetailCellAtIndexPath:indexPath];
    }else{
        return 44.0;
    }
}

- (CGFloat)heightForBasicOrderDetailCellAtIndexPath:(NSIndexPath *)indexPath {
    static OrderDetailListCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableTransferPayment dequeueReusableCellWithIdentifier:OrderDetailCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    sizingCell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
    NSDictionary* orderDetailData = [transPaymentList objectAtIndex:row];
    
    NSNumber *transferAmount = [orderDetailData valueForKey:@"transfer_amount"];
    int transferAmountInt = [transferAmount intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedTransferAmount = (transferAmountInt / 1000.0);
    
    [sizingCell.image setImageWithURL:[orderDetailData valueForKey:@"image"] placeholderImage:nil];
    sizingCell.destinationBank.text = [NSString stringWithFormat:@"%@ %@",[orderDetailData valueForKey:@"name_bank"],[orderDetailData valueForKey:@"no_rekening"]];
    sizingCell.bankName.text = [orderDetailData valueForKey:@"bank_name"];
    sizingCell.bankAccount.text = [orderDetailData valueForKey:@"bank_account"];
    sizingCell.accountName.text = [orderDetailData valueForKey:@"name_account"];
    sizingCell.transDate.text = [orderDetailData valueForKey:@"date"];
    sizingCell.transAmount.text = [NSString stringWithFormat:@"Rp %@,-",
                             [commas stringFromNumber:[NSNumber numberWithDouble:formattedTransferAmount * 1000]]];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell forTable:tableTransferPayment];
}

- (CGFloat)heightForBasicSellerCellAtIndexPath:(NSIndexPath *)indexPath {
    static SellerListCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableSeller dequeueReusableCellWithIdentifier:SellerCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    sizingCell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
    NSDictionary* sellerData = [sellerList objectAtIndex:row];
    sizingCell.username.text = [sellerData valueForKey:@"username"];
    sizingCell.name.text = [sellerData valueForKey:@"first_name"];
    sizingCell.phone.text = [sellerData valueForKey:@"phone"];
    sizingCell.orderStatus.text = [sellerData valueForKey:@"ord_status_description"];
    return [self calculateHeightForConfiguredSizingCell:sizingCell forTable:tableSeller];
}

- (CGFloat)heightForBasicSummaryDetailCellAtIndexPath:(NSIndexPath *)indexPath {
    static SummaryDetailListCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableProductList dequeueReusableCellWithIdentifier:ProductDetailCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    sizingCell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
    NSDictionary* summaryDetailData = [productList objectAtIndex:row];
    NSNumber *unitPrice = [summaryDetailData valueForKey:@"ord_det_price"];
    NSNumber *totalPrice = [summaryDetailData valueForKey:@"ord_det_price_total"];
    int unitPriceInt = [unitPrice intValue];
    int totalPriceInt = [totalPrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedUnitPrice = (unitPriceInt / 1000.0);
    double formattedTotalPrice = (totalPriceInt / 1000.0);
    
    sizingCell.item.text = [summaryDetailData valueForKey:@"ord_det_item_name"];
    sizingCell.price.text = [NSString stringWithFormat:@"Rp %@,-",
                       [commas stringFromNumber:[NSNumber numberWithDouble:formattedUnitPrice * 1000]]];
    sizingCell.quantity.text = [NSString stringWithFormat:@"%d",[(NSNumber*)[summaryDetailData valueForKey:@"ord_det_quantity"] intValue]];
    sizingCell.total.text = [NSString stringWithFormat:@"Rp %@,-",
                       [commas stringFromNumber:[NSNumber numberWithDouble:formattedTotalPrice * 1000]]];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell forTable:tableProductList];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell forTable:(UITableView*)refTable {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(refTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    int row = (int)[indexPath row];
    if (tableView==orderStatusTable) {
        statusOrder.text = [orderStatusList objectAtIndex:row];
        selectedStatusOrderIndex = row;
        if (selectedStatusOrderIndex>=0) {
            NSDictionary* orderStatusInfo = [orderStatusData objectAtIndex:selectedStatusOrderIndex];
            selectedStatusOrderId = [nf numberFromString:(NSString*)[orderStatusInfo valueForKey:@"ord_status_id"]];
            if (shouldCreateCommentTextView) {
                [self createCommentView];
            }else{
                [self removeCommentView];
            }
        }
        [self hideDropDown];
        activeTextField = nil;
    }
}

#pragma mark UI Events

- (IBAction)updateOrderStatus:(id)sender {
    [self updateSalesOrderDetail];
}

- (void)createCommentView{
    [rootContainer setNeedsLayout];
    [rootContainer layoutIfNeeded];
    CGFloat commentViewHeight = 200.0f;
    commentView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(statusOrderForm.frame), CGRectGetMaxY(statusOrderForm.frame)+20, CGRectGetWidth(rootContainer.frame), commentViewHeight)];
    [commentView setReturnKeyType:UIReturnKeyDone];
    [commentView setTag:1];
    [commentView.layer setBorderWidth:3.0f];
    [commentView.layer setBorderColor:[UIColor grayColor].CGColor];
    commentView.translatesAutoresizingMaskIntoConstraints = NO;
    [rootContainer addSubview:commentView];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                               constraintWithItem:commentView
                                               attribute:NSLayoutAttributeLeading
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:rootContainer
                                               attribute:NSLayoutAttributeLeading
                                               multiplier:1.0f
                                               constant:20.f];
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                                constraintWithItem:commentView
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:rootContainer
                                                attribute:NSLayoutAttributeTrailing
                                                multiplier:1.0f
                                                constant:-20.f];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:commentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1  constant:commentViewHeight];
    [rootContainer addConstraint:leading];
    [rootContainer addConstraint:trailing];
    [rootContainer addConstraint:height];
    //remove top constraint
    [rootContainer removeConstraint:updateStatusOrderBtnTopConstraint];
    NSDictionary* viewsDictionary =  NSDictionaryOfVariableBindings(rootContainer,statusOrderUpdateBtn,commentView,statusOrderForm);
    //constraint to place commentview between update order status button and status order form by 10
    updateStatusOrderBtnTopConstraintTemp = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[statusOrderForm]-10-[commentView]-10-[statusOrderUpdateBtn]" options:0 metrics: 0 views:viewsDictionary];
    [rootContainer addConstraints:updateStatusOrderBtnTopConstraintTemp];
    NSLog(@"createCommentView");
}

- (void)removeCommentView{
    if (commentView) {
        
        [rootContainer removeConstraints:updateStatusOrderBtnTopConstraintTemp];
        [commentView removeFromSuperview];
        
        //add back the top constraint
        [rootContainer addConstraint:updateStatusOrderBtnTopConstraint];
        commentView = nil;
        NSLog(@"removeCommentView");
    }
    
}

- (void)hideUpdateStatusForm{
    statusOrderForm.hidden = YES;
    statusOrderUpdateBtn.hidden = YES;
}
@end
