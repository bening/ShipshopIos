//
//  SalesOrderViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 1/28/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "SalesOrderViewController.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "SalesOrderCell.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import "SalesOrderDetailViewController.h"
#define orderStatusDropDown 10
#define datePickerDropDown 11
#define salesOrderBgColorEven [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]
#define salesOrderBgColorOdd [UIColor whiteColor]
#define limitSalesOrderList 8

static NSString * const SalesOrderCellIdentifier = @"SalesOrderCell";

@interface SalesOrderViewController ()

@end

@implementation SalesOrderViewController
@synthesize rootWrapper,pageTitle,orderNumber,orderStatus,dateAdded,customer,filterBtn,tableHeader,tableTitle,salesOrderTable,popover,datePickerView,datePickerToolbar,datePickerCancelBtn,datePickerDoneBtn,orderStatusTable,loadingOverlay,loadingWrapper,loading;

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
    titleLabel.text = orderMenu;
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

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations)
        {
            [req clearDelegatesAndCancel];
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
    [self requestSalesOrderList];
}

- (void)initializeData{
    salesOrderList = [NSMutableArray array];
    orderStatusList = [NSMutableArray array];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:sales_order_date_format];
    indexOfSelecetedStatusOrder = -1;
    selectedOrderNumber = @"";
    selectedOrderStatusId = [NSNumber numberWithInt:indexOfSelecetedStatusOrder];
    selectedDateAdded = @"";
    selectedCustomer = @"";
    
    [orderStatusList addObject:@""];
    for (NSDictionary* orderStatusData in [DataSingleton instance].allOrderStatus) {
        [orderStatusList addObject:[orderStatusData valueForKey:@"ord_status_description"]];
    }
    [self initializeSalesOrderParameter];
}

- (void)initializeSalesOrderParameter{
    currentPage = 0;
    refreshSalesOrderList = true;
    salesOrderListReachEnd = false;
}

- (void)initializeComponent{
    dateAdded.rightViewDistance = 10;
    [dateAdded useRightView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"83-calendar.png"]]];
    orderNumber.delegate = self;
    orderStatus.delegate = self;
    dateAdded.delegate = self;
    customer.delegate = self;
    
    salesOrderTable.delegate = self;
    salesOrderTable.dataSource = self;
    [salesOrderTable registerNib:[UINib nibWithNibName:@"SalesOrderCell" bundle:nil] forCellReuseIdentifier:SalesOrderCellIdentifier];
    salesOrderTable.alwaysBounceVertical = NO;
    orderStatusTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200.0, 265.0) style:UITableViewStylePlain];
    orderStatusTable.delegate = self;
    orderStatusTable.dataSource = self;
    orderStatusTable.alwaysBounceVertical = NO;
    self.datePicker.timeZone = [NSTimeZone localTimeZone];
    datePickerView.layer.borderWidth = 2.0;
    datePickerView.layer.borderColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5].CGColor;
    popover = [DXPopover new];
    
    if (IS_IPAD) {
        pageTitle.font = FONT_ARSENAL(25);
        tableTitle.font = FONT_ARSENAL(17);
    }else{
        pageTitle.font = FONT_ARSENAL_BOLD(18);
        tableTitle.font = FONT_ARSENAL(13);
    }
    
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    for (id subview in rootWrapper.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, ((UITextField*)subview).frame.size.height)];
            ((UITextField*)subview).leftView = paddingView;
            ((UITextField*)subview).leftViewMode = UITextFieldViewModeAlways;
        }
    }
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    [DataSingleton instance].disableTouchOnLeftMenu = show;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ASIHTTPRequest
#pragma mark - delegate

- (void)requestSalesOrderList
{
    if (!salesOrderListReachEnd) {
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
            currentPage++;
            NSString * _loginURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,getSalesOrderListURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_loginURL]];
            
            [request setRequestMethod:@"POST"];
            [DataSingleton retrieveUser];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
            
            [request addPostValue:selectedOrderNumber forKey:@"ord_number"];
            [request addPostValue:selectedDateAdded forKey:@"ord_date"];
            [request addPostValue:indexOfSelecetedStatusOrder==-1?@"":([selectedOrderStatusId intValue] == -1? @"" : selectedOrderStatusId) forKey:@"ord_status_id"];
            [request addPostValue:selectedCustomer forKey:@"ord_customer_name"];
            [request addPostValue:[NSNumber numberWithInt:currentPage] forKey:@"page"];
            [request addPostValue:[NSNumber numberWithInt:limitSalesOrderList] forKey:@"limit"];
            
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
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
    if (success) {
        if (salesOrderList==nil || refreshSalesOrderList) {
            salesOrderList = [NSMutableArray array];
            refreshSalesOrderList = false;
        }
        NSArray* resultSalesOrderList = (NSArray*)[jsonDictionary objectForKey:@"data"];
        if (resultSalesOrderList.count<limitSalesOrderList) {
            salesOrderListReachEnd = true;
        }
        for (NSDictionary* salesOrderInfo in resultSalesOrderList) {
            NSMutableDictionary* salesOrderData = [[NSMutableDictionary alloc] init];
            NSEnumerator *enumerator = [salesOrderInfo keyEnumerator];
            id key;
            while ((key = [enumerator nextObject])) {
                [salesOrderData setValue:[salesOrderInfo objectForKey:key] forKey:key];
            }
            [salesOrderList addObject:salesOrderData];
        }
        [salesOrderTable reloadData];
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
}

#pragma mark - UITextField
#pragma mark - datasource, delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==orderStatus) {
        [activeTextField resignFirstResponder];
        if (activeTextField!=orderStatus) {
            shouldDismissPopover = false;
        }else{
            shouldDismissPopover = !shouldDismissPopover;
        }
        activeTextField = textField;
        [self showOptionListFor:orderStatusDropDown];
        
        
        return NO;
    }else if (textField==dateAdded) {
        [activeTextField resignFirstResponder];
        [self animateDatePickerIn];
        
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
                CGPoint showPoint = CGPointMake(CGRectGetMidX(activeTextField.frame), CGRectGetMaxY(activeTextField.frame));
                if (orderStatusList.count>0) {
                    [self showDropDownAtPoint:showPoint withContent:orderStatusTable];
                }
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
                [orderStatusTable setFrame:CGRectMake(0, 0, 200.0, 216.0)];
                [popover setFrame:orderStatusTable.bounds];
                [orderStatusTable reloadData];
            }else if (orderStatusList.count>0){
                [orderStatusTable setFrame:CGRectMake(0, 0, 200.0, 44.0*orderStatusList.count)];
                [popover setFrame:orderStatusTable.bounds];
                [orderStatusTable reloadData];
            }
            
            break;
        default:
            break;
    }
    
}

- (void)showDropDownAtPoint:(CGPoint)showPoint withContent:(UIView *)content{
    popover.maskType = DXPopoverMaskTypeNotExist;
    [popover showAtPoint:showPoint popoverPostion:DXPopoverPositionDown withContentView:content inView:rootWrapper];
    popoverShown = true;
}

- (void)hideDropDown{
    CGPoint showPoint = CGPointMake(-500, -500);
    popover.maskType = DXPopoverMaskTypeNotExist;
    [popover showAtPoint:showPoint popoverPostion:DXPopoverPositionUp withContentView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] inView:rootWrapper];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==salesOrderTable) {
        return [salesOrderList count];
    }else if (tableView==orderStatusTable){
        return [orderStatusList count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==salesOrderTable) {
        SalesOrderCell *cell = (SalesOrderCell*)[tableView dequeueReusableCellWithIdentifier:SalesOrderCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        cell.backgroundColor = row%2==0?salesOrderBgColorOdd:salesOrderBgColorEven;
        NSDictionary* salesOrderData = [salesOrderList objectAtIndex:row];
        NSNumber *itemTotalPrice = [salesOrderData valueForKey:@"ord_item_summary_total"];
        NSNumber *itemShippingCharge = [salesOrderData valueForKey:@"ord_ship_charges"];
        int price = [itemTotalPrice intValue] + [itemShippingCharge intValue];
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        double formattedItemPrice = (price / 1000.0);
        
        cell.orderNumber.text = [salesOrderData valueForKey:@"ord_order_number"];
        cell.customer.text = [salesOrderData valueForKey:@"ord_ship_name"];
        cell.totalItems.text = [NSString stringWithFormat:@"%d",[(NSNumber*)[salesOrderData valueForKey:@"ord_total_items"]intValue]];
        
        cell.total.text = [NSString stringWithFormat:@"Rp %@,-",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
        cell.dateAdded.text = [salesOrderData valueForKey:@"ord_date"];
        cell.status.text = [salesOrderData valueForKey:@"ord_status_description"];
        
        if (indexPath.row == [salesOrderList count] - 1)
        {
            [self requestSalesOrderList];
        }
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        int row = (int)indexPath.row;
        if (row==indexOfSelecetedStatusOrder) {
            cell.selected = YES;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[orderStatusList objectAtIndex:row]];
        cell.tag = row;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==salesOrderTable) {
        return [self heightForBasicCellAtIndexPath:indexPath];
    }else{
        return 44.0;
    }
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static SalesOrderCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [salesOrderTable dequeueReusableCellWithIdentifier:SalesOrderCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    sizingCell.backgroundColor = row%2==0?salesOrderBgColorOdd:salesOrderBgColorEven;
    NSDictionary* salesOrderData = [salesOrderList objectAtIndex:row];
    NSNumber *itemTotalPrice = [salesOrderData valueForKey:@"ord_item_summary_total"];
    int price = [itemTotalPrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedItemPrice = (price / 1000.0);
    
    sizingCell.orderNumber.text = [salesOrderData valueForKey:@"ord_order_number"];
    sizingCell.customer.text = [salesOrderData valueForKey:@"ord_ship_name"];
    sizingCell.totalItems.text = [NSString stringWithFormat:@"%d",[(NSNumber*)[salesOrderData valueForKey:@"ord_total_items"]intValue]];
    
    sizingCell.total.text = [NSString stringWithFormat:@"Rp %@,-",
                       [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
    sizingCell.dateAdded.text = [salesOrderData valueForKey:@"ord_date"];
    sizingCell.status.text = [salesOrderData valueForKey:@"ord_status_description"];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(salesOrderTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    int row = (int)[indexPath row];
    if (tableView==orderStatusTable) {
        orderStatus.text = [orderStatusList objectAtIndex:row];
        
        indexOfSelecetedStatusOrder = row;
        [self hideDropDown];
        activeTextField = nil;
    }else{
        NSDictionary *salesOrderData = [salesOrderList objectAtIndex:row];
        
        SalesOrderDetailViewController *salesOrderDetailPage = [[SalesOrderDetailViewController alloc] initWithNibName:@"SalesOrderDetailViewController" bundle:nil];
        salesOrderDetailPage.orderNumberString = [salesOrderData valueForKey:@"ord_order_number"];
        salesOrderDetailPage.delegate = self;
        [self.navigationController pushViewController:salesOrderDetailPage animated:YES];
    }
}

#pragma mark - VCDelegate
#pragma respond to confirmation if any

-(void)updateOrderStatus:(BOOL)didUpdate{
    if (didUpdate) {
        [self initializeSalesOrderParameter];
        [self requestSalesOrderList];
    }
}

#pragma mark UI Events

-(void)animateDatePickerIn{
    [filterBtn setEnabled:NO];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datePickerView.alpha = 1.0f;}
                     completion:^(BOOL finished) {
//                         [dateAdded resignFirstResponder];
                     }];
}

-(void)animateDatePickerOut{
    [filterBtn setEnabled:YES];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datePickerView.alpha = 0.0f;}
                     completion:^(BOOL finished) {
//                         NSDate* _date = [format dateFromString:transferDate.text];
//                         if (_date!=nil) {
//                             datePicker.date = _date;
//                         }
//                         [transferDate validate];
                         
                     }];
}

- (IBAction)filterSalesOrder:(id)sender {
    [activeTextField resignFirstResponder];
    selectedOrderNumber = orderNumber.text;
    if (indexOfSelecetedStatusOrder>=1) {
        NSDictionary* orderStatusData = [[DataSingleton instance].allOrderStatus objectAtIndex:indexOfSelecetedStatusOrder-1];
        selectedOrderStatusId = [orderStatusData valueForKey:@"ord_status_id"];
    } else{
        selectedOrderStatusId = [NSNumber numberWithInt:-1];
    }
    
    selectedDateAdded = dateAdded.text;
    selectedCustomer = customer.text;
    [self initializeSalesOrderParameter];
    [self requestSalesOrderList];
}

- (IBAction)dismissDatePicker:(id)sender {
    [self animateDatePickerOut];
    dateAdded.text = @"";
}

- (IBAction)pickDatePicker:(id)sender {
    dateAdded.text = [dateFormat stringFromDate:self.datePicker.date];
    [self animateDatePickerOut];
}
@end
