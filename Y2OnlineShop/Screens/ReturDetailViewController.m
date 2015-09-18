//
//  ReturDetailViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "ReturDetailViewController.h"
#import "ReturDetailCell.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import <SDWebImage/UIImageView+WebCache.h>

//#define orderStatusDropDown 10
#define tableBgColorEven [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1.0]
#define tableBgColorOdd [UIColor whiteColor]
#define request_retur_detail 11
#define confirm_retur_detail 12

static NSString * const ReturDetailCellIdentifier = @"ReturDetailCell";

@interface ReturDetailViewController ()

@end

@implementation ReturDetailViewController
@synthesize orderNumberString,returStatusString,rootContainer,rootScroller,pageTitle,tableTitleOrder,tableTitleShipping,tableTitleContact,tableTitleReturList,orderNumber,orderDate,returStatus,tableReturDetail,shippingName,shippingAddress,shippingMethod,shippingEmail,shippingPhone,loadingOverlay,loadingWrapper,loading;

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
    
    UIImageView *imageLogo = [[UIImageView alloc]
                              initWithFrame:CGRectMake(0,0,3,44)];
    imageLogo.contentMode = UIViewContentModeLeft;
    imageLogo.clipsToBounds = NO;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [contentView addSubview:imageLogo];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35,0,widthContentView-30,self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"";
    if (!IS_IPAD) {
        [titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if (didUpdateReturStatus) {
            if(_delegate && [_delegate respondsToSelector:@selector(confirmRetur:)])
            {
                [_delegate confirmRetur:true];
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
    [self requestReturDetail];
}

- (void)initializeData{
    returDetailList = [NSMutableArray array];
    didUpdateReturStatus = false;
    
    selectedStatusReturIndex = -1;
    selectedStatusReturId = [NSNumber numberWithInt:0];
}

- (void)initializeComponent{
    rootScroller.alwaysBounceVertical = NO;
    
    tableReturDetail.delegate = self;
    tableReturDetail.dataSource = self;
    [tableReturDetail registerNib:[UINib nibWithNibName:@"ReturDetailCell" bundle:nil] forCellReuseIdentifier:ReturDetailCellIdentifier];
    tableReturDetail.alwaysBounceVertical = NO;
    
    pageTitle.font = FONT_ARSENAL(25);
    tableTitleOrder.font = FONT_ARSENAL(17);
    tableTitleShipping.font = FONT_ARSENAL(17);
    tableTitleContact.font = FONT_ARSENAL(17);
    tableTitleReturList.font = FONT_ARSENAL(17);
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    orderDate.text = @"";
    returStatus.text = @"";
    shippingName.text = @"";
    shippingAddress.text = @"";
    shippingMethod.text = @"";
    shippingEmail.text = @"";
    shippingPhone.text = @"";
    
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
    returStatus.text = returStatusString;
    
    if (returData) {
        orderDate.text = [returData valueForKey:@"ord_date"];
        NSMutableArray* returDetailedData = [NSMutableArray arrayWithArray:[returData valueForKey:@"return_detail"]];
//        [returDetailedData addObject:[(NSArray*)[returData valueForKey:@"return_detail"] objectAtIndex:0]];
//        [returDetailedData addObject:[(NSArray*)[returData valueForKey:@"return_detail"] objectAtIndex:0]];
//        [returDetailedData addObject:[(NSArray*)[returData valueForKey:@"return_detail"] objectAtIndex:0]];
        returDetailList = [NSMutableArray arrayWithArray:returDetailedData];
        shippingName.text = [returData valueForKey:@"ord_ship_name"];
        shippingAddress.text = [returData valueForKey:@"ord_ship_address_01"];
        shippingMethod.text = [returData valueForKey:@"ord_ship_method"];
        shippingEmail.text = [returData valueForKey:@"ord_email"];
        shippingPhone.text = [returData valueForKey:@"ord_phone"];
        
        [tableReturDetail reloadData];
        //[self updateTableSize];
    }
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

- (void)requestReturDetail
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
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,getReturDetailURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = request_retur_detail;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        
        [request addPostValue:orderNumberString forKey:@"order_number"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)confirmReturDetailAtIndex:(int)indexOfReturDetail
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
        NSDictionary* returDetailData = [returDetailList objectAtIndex:indexOfReturDetail];
        ReturDetailCell *cell = (ReturDetailCell*)[tableReturDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfReturDetail inSection:0]];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,updateReturStatusURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = confirm_retur_detail;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        
        [request addPostValue:[returDetailData valueForKey:@"rtn_det_id"] forKey:@"return_id"];
        [request addPostValue:cell.quantityField.text forKey:@"quantity"];
        
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
        case request_retur_detail:
            if (success) {
                returData = [NSDictionary dictionaryWithDictionary:(NSDictionary*)[jsonDictionary objectForKey:@"data"]];
                [self populateData];
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
        case confirm_retur_detail:
            if (success) {
                didUpdateReturStatus = true;
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
        default:
            break;
    }
}

#pragma mark - UITextField
#pragma mark - datasource, delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeTextField = textField;
    return YES;
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==tableReturDetail) {
        return [returDetailList count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==tableReturDetail) {
        ReturDetailCell *cell = (ReturDetailCell*)[tableView dequeueReusableCellWithIdentifier:ReturDetailCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        cell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
        NSDictionary* returDetailData = [returDetailList objectAtIndex:row];
        
        NSNumber *totalAmount = [returDetailData valueForKey:@"rtn_det_price_total"];
        NSNumber *priceAmount = [returDetailData valueForKey:@"rtn_det_price"];
        int totalAmountInt = [totalAmount intValue];
        int priceAmountInt = [priceAmount intValue];
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        double formattedTotalAmount = (totalAmountInt / 1000.0);
        double formattedPriceAmount = (priceAmountInt / 1000.0);
        
        cell.item.text = [returDetailData valueForKey:@"rtn_det_item_name"];
        cell.price.text = [NSString stringWithFormat:@"Rp %@,-",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedPriceAmount * 1000]]];
        cell.total.text = [NSString stringWithFormat:@"Rp %@,-",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedTotalAmount * 1000]]];
        cell.status.text = [returDetailData valueForKey:@"rtn_status_desc"];
        cell.quantityField.tag = row;
        cell.quantityField.text = [NSString stringWithFormat:@"%d",[[returDetailData valueForKey:@"rtn_det_quantity"] intValue]];
        cell.quantityField.delegate = self;
        cell.confirmBtn.tag = row;
        [cell.confirmBtn addTarget:self
                            action:@selector(doConfirmReturDetail:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        
        return cell;
    }else{
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==tableReturDetail) {
        return [self heightForBasicReturDetailCellAtIndexPath:indexPath];
    }else{
        return 0.0;
    }
}

- (CGFloat)heightForBasicReturDetailCellAtIndexPath:(NSIndexPath *)indexPath {
    static ReturDetailCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableReturDetail dequeueReusableCellWithIdentifier:ReturDetailCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    sizingCell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
    NSDictionary* returDetailData = [returDetailList objectAtIndex:row];
    
    NSNumber *totalAmount = [returDetailData valueForKey:@"rtn_det_price_total"];
    NSNumber *priceAmount = [returDetailData valueForKey:@"rtn_det_price"];
    int totalAmountInt = [totalAmount intValue];
    int priceAmountInt = [priceAmount intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedTotalAmount = (totalAmountInt / 1000.0);
    double formattedPriceAmount = (priceAmountInt / 1000.0);
    
    sizingCell.item.text = [returDetailData valueForKey:@"rtn_det_item_name"];
    sizingCell.price.text = [NSString stringWithFormat:@"Rp %@,-",
                       [commas stringFromNumber:[NSNumber numberWithDouble:formattedPriceAmount * 1000]]];
    sizingCell.total.text = [NSString stringWithFormat:@"Rp %@,-",
                       [commas stringFromNumber:[NSNumber numberWithDouble:formattedTotalAmount * 1000]]];
    sizingCell.status.text = [returDetailData valueForKey:@"rtn_status_desc"];
    sizingCell.quantityField.tag = row;
    sizingCell.quantityField.text = [NSString stringWithFormat:@"%d",[[returDetailData valueForKey:@"rtn_det_quantity"] intValue]];
    sizingCell.quantityField.delegate = self;
    sizingCell.confirmBtn.tag = row;
    [sizingCell.confirmBtn addTarget:self
                        action:@selector(doConfirmReturDetail:)
              forControlEvents:UIControlEventTouchUpInside];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell forTable:tableReturDetail];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell forTable:(UITableView*)refTable {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(refTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    //int row = (int)[indexPath row];
}

#pragma mark UI Events
- (void)doConfirmReturDetail:(id)sender{
    int itemConfirmIndex = ((UIButton*)sender).tag;
    [self confirmReturDetailAtIndex:itemConfirmIndex];
}

@end
