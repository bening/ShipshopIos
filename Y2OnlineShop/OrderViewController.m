//
//  OrderViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 1/7/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "OrderViewController.h"
#import "DataSingleton.h"
#import "OrderPageViewController.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import "Constants.h"
#import "Checkout2ndViewController.h"

static NSString * const OrderCellIdentifier = @"OrderCell";

@interface OrderViewController ()

@end

@implementation OrderViewController
@synthesize userName,orderTable,loading,loadingOverlay,loadingWrapper,searchBarRef,emptyOrderImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeData];
    [self initializeComponent];
    [self requestOrderList];
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
    UIView* wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthContentView, CGRectGetHeight(contentView.frame))];
    //contentView.backgroundColor = [UIColor redColor];
    UIImageView *imageLogo = [[UIImageView alloc]init];
    imageLogo.contentMode = UIViewContentModeScaleAspectFit;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [imageLogo sizeToFit];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
    titleLabel.text = @"Daftar Pesanan";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapper addSubview:imageLogo];
    [wrapper addSubview:titleLabel];
    float spaceLeftLogoToSuperview = 0.0;
    //    if (IS_IPAD) {
    //        spaceLeftLogoToSuperview = 10.0f;
    //    }else {
    //        spaceLeftLogoToSuperview = 5.0f;
    //    }
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(wrapper,titleLabel,imageLogo);
    //padding left constraint for imageLogo
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-constantSpace-[imageLogo]" options:0 metrics: @{@"constantSpace":@(spaceLeftLogoToSuperview)} views:viewsDictionary]];
    //height constraint in order to not exceed navigationBar height
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageLogo(<=constantHeight)]" options:0 metrics:@{@"constantHeight":@(self.navigationController.navigationBar.frame.size.height)} views:viewsDictionary]];
    
    NSLayoutConstraint *aspectRatioConstraint =[NSLayoutConstraint
                                                constraintWithItem:imageLogo
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:imageLogo
                                                attribute:NSLayoutAttributeWidth
                                                multiplier:CGRectGetHeight(imageLogo.frame)/CGRectGetWidth(imageLogo.frame) //Aspect ratio: height:width
                                                constant:0.0f];
    [wrapper addConstraint:aspectRatioConstraint];
    
    //space constraint between imageLogo and titleLabel
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageLogo]-constantSpace-[titleLabel]-0-|" options:0 metrics: @{@"constantSpace":@(spaceLogoToTitle)} views:viewsDictionary]];
    
    [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    wrapper.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [contentView addSubview:wrapper];
    
    self.searchBarRef = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(contentView.frame),CGRectGetHeight(contentView.frame))];
    self.searchBarRef.alpha=0;
    self.searchBarRef.transform = CGAffineTransformMakeScale(0,0);
    [self.searchBarRef setBackgroundColor:[UIColor clearColor]];
    self.searchBarRef.barTintColor=[UIColor clearColor];
    searchBarRef.placeholder = @"Cari: No. Order...";
    searchBarRef.delegate= self;
    
    searchBarRef.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [contentView addSubview:self.searchBarRef];
    
    viewsDictionary = NSDictionaryOfVariableBindings(contentView, searchBarRef);
    //constraint for searchBar in order to extend its width to the fullest width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarRef]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    //constraint for searchBar in order to extend its height to the height width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarRef]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = self.searchBarRef;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects: [DataSingleton instance].searchBarProductRetail, nil];
    //[DataSingleton enableCartButton:false];
    if (self.isMovingToParentViewController == NO)
    {
        isFiltered = false;
        [orderTable reloadData];
    }
}

- (void)initializeComponent{
    loadingWrapper.layer.cornerRadius = 10.0f;
    orderTable.delegate = self;
    orderTable.dataSource = self;
    [orderTable registerNib:[UINib nibWithNibName:@"OrderTableViewCell" bundle:nil] forCellReuseIdentifier:OrderCellIdentifier];
    [DataSingleton retrieveUser];
    if ([DataSingleton instance].loggedInUser!=nil) {
        userName.text = [DataSingleton instance].loggedInUser.name;
    }
    orderTable.hidden = NO;
    emptyOrderImage.hidden = YES;
}

- (void)initializeData{
    orderList = [NSMutableArray array];
    orderDateFormat = [[NSDateFormatter alloc] init];
    [orderDateFormat setDateFormat:order_date_format];
    isFiltered = false;
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    [DataSingleton instance].disableTouchOnLeftMenu = show;
    loadingOverlay.hidden = !show;
    
}

- (void)requestOrderList
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
        NSString * _url = [NSString stringWithFormat:@"%@%@",y2BaseURL,getOrderListURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_url]];
        
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        
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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"finished");
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case getPaymentInformation:{
                if (success) {
                    [DataSingleton instance].paymentInfo = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[jsonDictionary objectForKey:@"data"]];
                    
                    [self getAllRekeningWithOwnerId:[orderInfo valueForKey:@"seller_id"]];
                }else{
                    NSString* errorMessage = (NSString*)[jsonDictionary objectForKey:@"message"];
                
                    UIAlertView *errorView;
                
                    errorView = [[UIAlertView alloc]
                                 initWithTitle: title_error
                                 message: errorMessage
                                 delegate: self
                                 cancelButtonTitle: @"Close" otherButtonTitles: nil];
                    [errorView setTag:0];
                    [errorView show];
                    [self shallShowLoadingOverlay:NO];
                }
            
            }
            break;
        case getAllRekening:{
            if (success) {
                [DataSingleton processAPIRequestResult:responseString withRequestCode:getAllAccount];
                
                Checkout2ndViewController *checkout2ndPage = [[Checkout2ndViewController alloc] initWithNibName:@"Checkout2ndViewController" bundle:nil];
                checkout2ndPage.orderNumber = [orderInfo valueForKey:@"ord_order_number"];
                
                [self.navigationController pushViewController:checkout2ndPage animated:YES];
            }else{
                NSString* errorMessage = (NSString*)[jsonDictionary objectForKey:@"message"];
                
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_error
                             message: errorMessage
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
            }
            [self shallShowLoadingOverlay:NO];
        }
        break;
            
        default:
            if (success) {
                orderList = [NSMutableArray array];
                //orderInfo = [jsonDictionary objectForKey:@"data"];
                if(![[jsonDictionary objectForKey:@"data"] isEqual:[NSNull null]]){
                    NSArray* _orderList = (NSArray*)[jsonDictionary objectForKey:@"data"];
                    
                    for (NSDictionary* thisOrderInfo in _orderList) {
                        NSMutableDictionary* orderData = [[NSMutableDictionary alloc] init];
                        NSEnumerator *enumerator = [thisOrderInfo keyEnumerator];
                        id key;
                        while ((key = [enumerator nextObject])) {
                            [orderData setValue:[thisOrderInfo objectForKey:key] forKey:key];
                        }
                        [orderList addObject:orderData];
                    }
                }
                
                [orderTable reloadData];
                if(orderList.count > 0){
                    orderTable.hidden = NO;
                    emptyOrderImage.hidden = YES;
                } else{
                    orderTable.hidden = YES;
                    emptyOrderImage.hidden = NO;
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
    }
    
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isFiltered?[orderListFiltered count]:[orderList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //heightForRowAtIndexPath 1st, this will be called afterward
    //static NSString* simpleTableIdentifier = @"CommentCell";
    OrderTableViewCell *cell = (OrderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:OrderCellIdentifier forIndexPath:indexPath];
    int row = (int)[indexPath row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.tag = row;
    NSDictionary *orderData = isFiltered?[orderListFiltered objectAtIndex:row]:[orderList objectAtIndex:row];
    
    NSNumber *orderTotal = [orderData valueForKey:@"ord_item_summary_total"];
    int price = [orderTotal intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double orderPrice = (price / 1000.0);
    //NSDate *orderDate = [orderDateFormat dateFromString:[orderData valueForKey:@"ord_date"]];
    
    cell.orderNumber.text = [orderData valueForKey:@"ord_order_number"];
    cell.orderDate.text = [orderData valueForKey:@"ord_date"];
    cell.orderTotal.text = [NSString stringWithFormat:@"Rp %@,-",
                            [commas stringFromNumber:[NSNumber numberWithDouble:orderPrice * 1000]]];
    cell.orderStatus.text = [orderData valueForKey:@"ord_status_name"];
    [cell.detailButton setTag:row];
    [cell.detailButton addTarget:self
                      action:@selector(goToDetail:)
            forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 112;
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static OrderTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [orderTable dequeueReusableCellWithIdentifier:OrderCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(orderTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    int row = (int)[indexPath row];
    NSDictionary *orderData = isFiltered?[orderListFiltered objectAtIndex:row]:[orderList objectAtIndex:row];
    
    if([[orderData valueForKey:@"ord_status_id"] isEqualToString:@"1"]){
        //order status awaiting payment go to payment
        [self getPaymentInfo:orderData];
    } else{
        OrderPageViewController *orderDetailPage = [[OrderPageViewController alloc] initWithNibName:@"OrderPageViewController" bundle:nil];
        orderDetailPage.orderNumber = [orderData valueForKey:@"ord_order_number"];
        orderDetailPage.orderStatus = [orderData valueForKey:@"ord_status_name"];
        orderDetailPage.needConfirmation = [(NSNumber*)[orderData valueForKey:@"ord_status"] intValue]==needConfirmationOrderCode;
        orderDetailPage.orderCode = (NSNumber*)[orderData valueForKey:@"ord_status"];
        orderDetailPage.delegate = self;
        [self.navigationController pushViewController:orderDetailPage animated:YES];
    }
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        isFiltered = FALSE;
    }
    else
    {
        isFiltered = TRUE;
        orderListFiltered = [[NSMutableArray alloc] init];
        
        for (NSDictionary* orderData in orderList)
        {
            NSString* orderNumber = [orderData valueForKey:@"ord_order_number"];
            NSRange orderNumberRange = [orderNumber rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(orderNumberRange.location != NSNotFound)
            {
                [orderListFiltered addObject:orderData];
            }
        }
    }
    
    [orderTable reloadData];
}

#pragma mark - VCDelegate
#pragma respond to confirmation if any

- (void)shippingArrivalConfirmed:(BOOL)confirmed{
    if (confirmed) {
        [self requestOrderList];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goToDetail:(id)sender{
    //NSLog(@"retur product at index: %d",((UIButton*)sender).tag);
    int row = (int)((UIButton*)sender).tag;
    NSDictionary *orderData = isFiltered?[orderListFiltered objectAtIndex:row]:[orderList objectAtIndex:row];
    
    OrderPageViewController *orderDetailPage = [[OrderPageViewController alloc] initWithNibName:@"OrderPageViewController" bundle:nil];
    orderDetailPage.orderNumber = [orderData valueForKey:@"ord_order_number"];
    orderDetailPage.orderStatus = [orderData valueForKey:@"ord_status_name"];
    orderDetailPage.needConfirmation = [(NSNumber*)[orderData valueForKey:@"ord_status"] intValue]==needConfirmationOrderCode;
    orderDetailPage.orderCode = (NSNumber*)[orderData valueForKey:@"ord_status"];
    orderDetailPage.delegate = self;
    [self.navigationController pushViewController:orderDetailPage animated:YES];
}


-(void) getPaymentInfo:(NSDictionary*)orderData{
    if(orderData != nil){
        orderInfo = orderData;
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
        }
        else
        {
            [self shallShowLoadingOverlay:YES];
            
            NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,getPaymentInfoURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
            request.tag = getPaymentInformation;
            [request setRequestMethod:@"POST"];
            [request addPostValue:[orderData valueForKey:@"ord_order_number"] forKey:@"order_number"];
                        
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
            
        }
        
    }
    
}

-(void) getAllRekeningWithOwnerId:(NSString*)ownerId{
    //get info rekening penjual
    NSString * allAccountURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllAccountURL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:allAccountURL]];
    request.tag = getAllRekening;
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request setRequestMethod:@"POST"];
    if(ownerId != nil)
        [request addPostValue:ownerId forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setUseSessionPersistence:YES];
}

@end
