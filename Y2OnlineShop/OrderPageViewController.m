//
//  OrderPageViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/23/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "OrderPageViewController.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataSingleton.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import "UILabel+VerticalAlignment.h"
#define dummyOrderNum 6

static NSString * const OrderItemCellIdentifier = @"OrderItemCell";

@interface OrderPageViewController ()

@end

@implementation OrderPageViewController
@synthesize orderNumber,orderStatus,needConfirmation,orderItemTable,loading,confirmBtn,shippingService,orderStatusLabel,loadingWrapper,loadingOverlay,orderCode,infoPengiriman,ipAddress,ipFee,ipNama,ipPhone,searchBarRef;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeData];
    [self initializeComponent];
}

- (void)viewDidAppear:(BOOL)animated{
    [self populateData];
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
    
    titleLabel.text = [NSString stringWithFormat:@"Detail Order: %@",orderNumber];
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
    
    self.searchBarRef = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
    self.searchBarRef.alpha=0;
    self.searchBarRef.transform = CGAffineTransformMakeScale(0,0);
    [self.searchBarRef setBackgroundColor:[UIColor clearColor]];
    self.searchBarRef.barTintColor=[UIColor clearColor];
    self.searchBarRef.placeholder = @"Cari: Nama Produk...";
    self.searchBarRef.delegate= self;
    
    self.searchBarRef.translatesAutoresizingMaskIntoConstraints = NO;
    
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
}

- (void)initializeComponent{
    loadingWrapper.layer.cornerRadius = 10.0f;
    orderItemTable.delegate = self;
    orderItemTable.dataSource = self;
    [orderItemTable registerNib:[UINib nibWithNibName:@"OrderItemCell" bundle:nil] forCellReuseIdentifier:OrderItemCellIdentifier];
    confirmBtn.layer.cornerRadius = 5.0f;
    if (IS_IPAD) {
        shippingService.font = FONT_ARSENAL_BOLD(15);
        orderStatusLabel.font = FONT_ARSENAL_BOLD(15);
    }else{
        shippingService.font = FONT_ARSENAL_BOLD(13);
        orderStatusLabel.font = FONT_ARSENAL_BOLD(13);
    }
    shippingService.text = @"JNE";
    orderStatusLabel.text = orderStatus;
    confirmBtn.hidden = !needConfirmation;
    
    infoPengiriman.translatesAutoresizingMaskIntoConstraints = YES;
    orderItemTable.tableFooterView = infoPengiriman;
    [ipNama setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [ipPhone setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [ipAddress setTextVerticalAlignment:UITextVerticalAlignmentTop];
    [ipFee setTextVerticalAlignment:UITextVerticalAlignmentTop];
}

- (void)initializeData{
    orderItemList = [NSMutableArray array];
    isFiltered =false;
    hasConfirmShipping = false;
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    //    if (show)
    //        [loading startAnimating];
    //    else
    //        [loading stopAnimating];
    //
    
    loadingOverlay.hidden = !show;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if (hasConfirmShipping) {
            if(_delegate && [_delegate respondsToSelector:@selector(shippingArrivalConfirmed:)])
            {
                [_delegate shippingArrivalConfirmed:true];
            }
        }
    }
    [super viewWillDisappear:animated];
}

- (void)populateData{
    [self requestOrderDetail];
}

- (void)requestOrderDetail
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
        NSString * _URL = [NSString stringWithFormat:@"%@%@",y2BaseURL,getOrderDetailURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_URL]];
        request.tag = getOrderDetail;
        
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        
        [request addPostValue:orderNumber forKey:@"order_number"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)orderArrivalConfirmation
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
        NSString * _URL = [NSString stringWithFormat:@"%@%@",y2BaseURL,confirmShippingURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_URL]];
        request.tag = confirmShipping;
        
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        [request addPostValue:orderNumber forKey:@"order_number"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestReturnItemAtIndex:(int)itemIndex
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
        NSArray *correctList = isFiltered?orderItemListFiltered:orderItemList;
        NSDictionary *orderItem = [correctList objectAtIndex:itemIndex];
        NSString * _URL = [NSString stringWithFormat:@"%@%@",y2BaseURL,requestReturnURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_URL]];
        request.tag = requestReturn;
        
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        [request addPostValue:orderNumber forKey:@"order_number"];
        [request addPostValue:[orderItem valueForKey:@"ord_det_item_fk"] forKey:@"prd_id"];
        
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
        case getOrderDetail:
            if (success) {
                orderItemList = [NSMutableArray array];
                orderData = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
                NSArray* _orderItem = (NSArray*)[orderData objectForKey:@"list_order_details"];
                for (NSDictionary* orderInfo in _orderItem) {
                    NSMutableDictionary* orderDetails = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [orderInfo keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [orderDetails setValue:[orderInfo objectForKey:key] forKey:key];
                    }
                    [orderItemList addObject:orderDetails];
                }
                
                if([orderData valueForKey:@"ord_ship_name"] && ((NSString*)[orderData valueForKey:@"ord_ship_name"]).length > 0){
                    ipNama.text = [orderData valueForKey:@"ord_ship_name"];
                }
                
                if([orderData valueForKey:@"ord_phone"] && ((NSString*)[orderData valueForKey:@"ord_phone"]).length > 0){
                    ipPhone.text = [orderData valueForKey:@"ord_phone"];
                }
                
                if([orderData valueForKey:@"ord_ship_address_01"] && ((NSString*)[orderData valueForKey:@"ord_ship_address_01"]).length > 0){
                    ipAddress.text = [orderData valueForKey:@"ord_ship_address_01"];
                }
                
                if([orderData valueForKey:@"ord_ship_charges"]){
                    NSNumber *itemPrice = [orderData valueForKey:@"ord_ship_charges"];
                    int price = [itemPrice intValue];
                    NSNumberFormatter *commas = [NSNumberFormatter new];
                    commas.numberStyle = NSNumberFormatterDecimalStyle;
                    double formattedItemPrice = (price / 1000.0);
                    
                    ipFee.text = [NSString stringWithFormat:@"Rp %@",
                                  [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
                }
                                
                infoPengiriman.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(infoPengiriman.frame), CGRectGetHeight(infoPengiriman.frame)+25.0);
                
                [infoPengiriman setNeedsLayout];
                [infoPengiriman layoutIfNeeded];
                
                [orderItemTable reloadData];
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
        case confirmShipping:
            {
                [self shallShowLoadingOverlay:NO];
                NSString* message = [jsonDictionary objectForKey:@"message"];
                UIAlertView *errorView;
            
                errorView = [[UIAlertView alloc]
                             initWithTitle: success? title_success:title_error
                             message: message
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
                hasConfirmShipping = true;
            }
            break;
        case requestReturn:
        {
            [self shallShowLoadingOverlay:NO];
            NSString* message = [jsonDictionary objectForKey:@"message"];
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: success? title_success:title_error
                         message: message
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
            hasConfirmShipping = true;
        }
            break;
        default:
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
    return isFiltered?[orderItemListFiltered count]:[orderItemList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //heightForRowAtIndexPath 1st, this will be called afterward
    OrderItemCell *cell = (OrderItemCell*)[tableView dequeueReusableCellWithIdentifier:OrderItemCellIdentifier forIndexPath:indexPath];
    int row = (int)[indexPath row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = row;
    NSDictionary *orderItem = isFiltered?[orderItemListFiltered objectAtIndex:row]:[orderItemList objectAtIndex:row];
    
    NSNumber *itemPrice = [orderItem valueForKey:@"ord_det_price"];
    int price = [itemPrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedItemPrice = (price / 1000.0);
    
//    NSArray* itemSpec = [orderItem valueForKey:@"list_option"];
//    NSMutableString *itemSpecString = [NSMutableString string];
//    for (NSDictionary* singleItemSpec in itemSpec) {
//        NSString* optionName = [singleItemSpec valueForKey:@"opt_name"];
//        NSString* optionValue = [singleItemSpec valueForKey:@"value"];
//        if (itemSpecString.length==0)
//            itemSpecString = [NSMutableString stringWithFormat:@"%@: %@",optionName, optionValue];
//        else
//            [itemSpecString appendFormat:@"\n%@: %@",optionName, optionValue];
//        
//    }
    
    //[cell.productImage setImageWithURL:[orderItem valueForKey:@"images"] placeholderImage:nil];
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setColor:COLOR_PINK_Y2];
    activityIndicator.center = cell.productImage.center;
    activityIndicator.hidesWhenStopped = YES;
    __weak UIImageView* thisBrandImage = cell.productImage;
    [cell.productImage setImageWithURL:[orderItem valueForKey:@"img_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (!image) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 thisBrandImage.image = [UIImage imageNamed:@"icon_no_img.png"];
             });
             
             NSLog(@"failed load image for brand");
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [activityIndicator removeFromSuperview];
         });
     }];
    [cell.productImage addSubview:activityIndicator];
    [activityIndicator startAnimating];
    cell.productOwner.text = [orderItem valueForKey:@"nama_toko"];
    cell.productName.text  = [orderItem valueForKey:@"ord_det_item_name"];
    cell.productSKU.text = [orderItem valueForKey:@"prd_SKU"];
    cell.productPrice.text = [NSString stringWithFormat:@"Harga: Rp %@,-",
                              [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
    //cell.productSpec.text =itemSpecString;
    cell.productAmount.text = [NSString stringWithFormat:@"Jumlah: %d",[(NSNumber*)[orderItem valueForKey:@"ord_det_quantity"] intValue]];
    BOOL needToShowReturnBtn = [[orderItem valueForKey:@"return_btn"] boolValue];
    if (needToShowReturnBtn) {
        cell.returBtn.hidden = NO;
        cell.returBtn.tag = row;
        [cell.returBtn addTarget:self
                          action:@selector(doReturProduct:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 200;
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static OrderItemCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [orderItemTable dequeueReusableCellWithIdentifier:OrderItemCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    
    NSDictionary *orderItem = isFiltered?[orderItemListFiltered objectAtIndex:row]:[orderItemList objectAtIndex:row];
    
    NSNumber *itemPrice = [orderItem valueForKey:@"ord_det_price"];
    int price = [itemPrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedItemPrice = (price / 1000.0);
    
//    NSArray* itemSpec = [orderItem valueForKey:@"list_option"];
//    NSMutableString *itemSpecString = [NSMutableString string];
//    for (NSDictionary* singleItemSpec in itemSpec) {
//        NSString* optionName = [singleItemSpec valueForKey:@"opt_name"];
//        NSString* optionValue = [singleItemSpec valueForKey:@"value"];
//        if (itemSpecString.length==0)
//            itemSpecString = [NSMutableString stringWithFormat:@"%@: %@",optionName, optionValue];
//        else
//            [itemSpecString appendFormat:@"\n%@: %@",optionName, optionValue];
//        
//    }
    
    //[sizingCell.productImage setImageWithURL:[orderItem valueForKey:@"images"] placeholderImage:nil];
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setColor:COLOR_PINK_Y2];
    activityIndicator.center = sizingCell.productImage.center;
    activityIndicator.hidesWhenStopped = YES;
    __weak UIImageView* thisBrandImage = sizingCell.productImage;
    [sizingCell.productImage setImageWithURL:[orderItem valueForKey:@"img_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (!image) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 thisBrandImage.image = [UIImage imageNamed:@"icon_no_img.png"];
             });
             
             NSLog(@"failed load image for brand");
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [activityIndicator removeFromSuperview];
         });
     }];
    [sizingCell.productImage addSubview:activityIndicator];
    [activityIndicator startAnimating];
    sizingCell.productOwner.text = [orderItem valueForKey:@"nama_toko"];
    sizingCell.productName.text  = [orderItem valueForKey:@"ord_det_item_name"];
    sizingCell.productSKU.text = [orderItem valueForKey:@"prd_SKU"];
    sizingCell.productPrice.text = [NSString stringWithFormat:@"Harga: Rp %@,-",
                              [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];;
    //sizingCell.productSpec.text =itemSpecString;
    sizingCell.productAmount.text = [NSString stringWithFormat:@"Jumlah: %d",[(NSNumber*)[orderItem valueForKey:@"ord_det_quantity"] intValue]];
    BOOL needToShowReturnBtn = [[orderItem valueForKey:@"return_btn"] boolValue];
    if (needToShowReturnBtn) {
        sizingCell.returBtn.hidden = NO;
        sizingCell.returBtn.tag = row;
        [sizingCell.returBtn addTarget:self
                          action:@selector(doReturProduct:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(orderItemTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    //    NSUInteger row = [indexPath row];
    //    NSLog(@"%lu",(unsigned long)row);
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
        orderItemListFiltered = [[NSMutableArray alloc] init];
        
        for (NSDictionary* orderInfo in orderItemList)
        {
            NSString* productName = [orderInfo valueForKey:@"ord_det_item_name"];
            NSRange productNameRange = [productName rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(productNameRange.location != NSNotFound)
            {
                [orderItemListFiltered addObject:orderInfo];
            }
        }
    }
    
    [orderItemTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmOrderArrival:(id)sender {
    [self orderArrivalConfirmation];
}

- (void)doReturProduct:(id)sender{
    //NSLog(@"retur product at index: %d",((UIButton*)sender).tag);
    [self requestReturnItemAtIndex:(int)((UIButton*)sender).tag];
}
@end
