//
//  ReturPageViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "ReturPageViewController.h"
#import "ReturDetailViewController.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "ReturCell.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#define orderStatusDropDown 10
#define datePickerDropDown 11
#define tableBgColorEven [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]
#define tableBgColorOdd [UIColor whiteColor]
#define limitReturList 8

static NSString * const ReturCellIdentifier = @"ReturCellId";

@interface ReturPageViewController ()

@end

@implementation ReturPageViewController
@synthesize rootWrapper,pageTitle,orderNumber,returStatus,dateAdded,customer,filterBtn,tableHeader,tableTitle,tableRetur,popover,returStatusTable,datePickerView,myDatePicker,datePickerToolbar,datePickerCancelBtn,datePickerDoneBtn,loadingOverlay,loadingWrapper,loading;

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
    titleLabel.text = returMenu;
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
    [self requestReturList];
}

- (void)initializeData{
    returList = [NSMutableArray array];
    returStatusList = [NSMutableArray array];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:sales_order_date_format];
    indexOfSelecetedStatusRetur = -1;
    selectedOrderNumber = @"";
    selectedReturStatusId = [NSNumber numberWithInt:indexOfSelecetedStatusRetur];
    selectedDateAdded = @"";
    selectedCustomer = @"";
    
    [returStatusList addObject:@""];
    for (NSDictionary* returStatusData in [DataSingleton instance].allReturStatus) {
        [returStatusList addObject:[returStatusData valueForKey:@"status_decription"]];
    }
    [self initializeReturParameter];
}

- (void)initializeReturParameter{
    currentPage = 0;
    refreshReturList = true;
    returListReachEnd = false;
}

- (void)initializeComponent{
    dateAdded.rightViewDistance = 10;
    [dateAdded useRightView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"83-calendar.png"]]];
    orderNumber.delegate = self;
    returStatus.delegate = self;
    dateAdded.delegate = self;
    customer.delegate = self;
    
    tableRetur.delegate = self;
    tableRetur.dataSource = self;
    [tableRetur registerNib:[UINib nibWithNibName:@"ReturCell" bundle:nil] forCellReuseIdentifier:ReturCellIdentifier];
    tableRetur.alwaysBounceVertical = NO;
    returStatusTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200.0, 265.0) style:UITableViewStylePlain];
    returStatusTable.delegate = self;
    returStatusTable.dataSource = self;
    returStatusTable.alwaysBounceVertical = NO;
    myDatePicker.timeZone = [NSTimeZone localTimeZone];
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

- (void)requestReturList
{
    if (!returListReachEnd) {
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
            NSString * _loginURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,getReturListURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_loginURL]];
            
            [request setRequestMethod:@"POST"];
            [DataSingleton retrieveUser];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
            
            [request addPostValue:selectedOrderNumber forKey:@"rtn_det_order_number_fk"];
            [request addPostValue:selectedDateAdded forKey:@"rtn_det_date"];
            [request addPostValue:indexOfSelecetedStatusRetur==-1?@"":(selectedReturStatusId.intValue == -1 ? @"" : selectedReturStatusId) forKey:@"rtn_status"];
            [request addPostValue:selectedCustomer forKey:@"rtn_ship_name"];
            [request addPostValue:[NSNumber numberWithInt:currentPage] forKey:@"page"];
            [request addPostValue:[NSNumber numberWithInt:limitReturList] forKey:@"limit"];
            
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
        if (returList==nil || refreshReturList) {
            returList = [NSMutableArray array];
            refreshReturList = false;
        }
        NSArray* resultReturList = (NSArray*)[jsonDictionary objectForKey:@"data"];
        if (resultReturList.count<limitReturList) {
            returListReachEnd = true;
        }
        for (NSDictionary* returInfo in resultReturList) {
            NSMutableDictionary* returData = [[NSMutableDictionary alloc] init];
            NSEnumerator *enumerator = [returInfo keyEnumerator];
            id key;
            while ((key = [enumerator nextObject])) {
                [returData setValue:[returInfo objectForKey:key] forKey:key];
            }
            [returList addObject:returData];
        }
        [tableRetur reloadData];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==returStatus) {
        [activeTextField resignFirstResponder];
        if (activeTextField!=returStatus) {
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
                if (returStatusList.count>0) {
                    [self showDropDownAtPoint:showPoint withContent:returStatusTable];
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
            if (returStatusList.count>5) {
                [returStatusTable setFrame:CGRectMake(0, 0, 200.0, 216.0)];
                [popover setFrame:returStatusTable.bounds];
                [returStatusTable reloadData];
            }else if (returStatusList.count>0){
                [returStatusTable setFrame:CGRectMake(0, 0, 200.0, 44.0*returStatusList.count)];
                [popover setFrame:returStatusTable.bounds];
                [returStatusTable reloadData];
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
    if (tableView==tableRetur) {
        return [returList count];
    }else if (tableView==returStatusTable){
        return [returStatusList count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==tableRetur) {
        ReturCell *cell = (ReturCell*)[tableView dequeueReusableCellWithIdentifier:ReturCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        cell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
        NSDictionary* returData = [returList objectAtIndex:row];
        
        cell.orderNumber.text = [returData valueForKey:@"ord_order_number"];
        cell.customer.text = [returData valueForKey:@"ord_ship_name"];
        
        cell.dateAdded.text = [returData valueForKey:@"rtn_det_date"];
        cell.status.text = [returData valueForKey:@"rtn_status"];
        
        if (indexPath.row == [returList count] - 1)
        {
            [self requestReturList];
        }
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        int row = (int)indexPath.row;
        if (row==indexOfSelecetedStatusRetur) {
            cell.selected = YES;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[returStatusList objectAtIndex:row]];
        cell.tag = row;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==tableRetur) {
        return [self heightForBasicCellAtIndexPath:indexPath];
    }else{
        return 44.0;
    }
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static ReturCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableRetur dequeueReusableCellWithIdentifier:ReturCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    sizingCell.backgroundColor = row%2==0?tableBgColorOdd:tableBgColorEven;
    NSDictionary* returData = [returList objectAtIndex:row];
    
    sizingCell.orderNumber.text = [returData valueForKey:@"ord_order_number"];
    sizingCell.customer.text = [returData valueForKey:@"ord_ship_name"];
    
    sizingCell.dateAdded.text = [returData valueForKey:@"rtn_det_date"];
    sizingCell.status.text = [returData valueForKey:@"rtn_status"];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableRetur.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    int row = (int)[indexPath row];
    if (tableView==returStatusTable) {
        returStatus.text = [returStatusList objectAtIndex:row];
        indexOfSelecetedStatusRetur = row;
        [self hideDropDown];
        activeTextField = nil;
    }else{
        NSDictionary *returData = [returList objectAtIndex:row];
        
        ReturDetailViewController *salesOrderDetailPage = [[ReturDetailViewController alloc] initWithNibName:@"ReturDetailViewController" bundle:nil];
        salesOrderDetailPage.orderNumberString = [returData valueForKey:@"ord_order_number"];
        salesOrderDetailPage.returStatusString = [returData valueForKey:@"rtn_status"];
        salesOrderDetailPage.delegate = self;
        [self.navigationController pushViewController:salesOrderDetailPage animated:YES];
    }
}

#pragma mark - VCDelegate
#pragma respond to confirmation if any

- (void)confirmRetur:(BOOL)didConfirm{
    if (didConfirm) {
        [self initializeReturParameter];
        [self requestReturList];
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

- (IBAction)filterReturList:(id)sender{
    [activeTextField resignFirstResponder];
    selectedOrderNumber = orderNumber.text;
    if (indexOfSelecetedStatusRetur>=1) {
        NSDictionary* returStatusData = [[DataSingleton instance].allReturStatus objectAtIndex:indexOfSelecetedStatusRetur-1];
        selectedReturStatusId = [returStatusData valueForKey:@"status_return_id"];
    } else{
        selectedReturStatusId = [NSNumber numberWithInt:-1];
    }
    selectedDateAdded = dateAdded.text;
    selectedCustomer = customer.text;
    [self initializeReturParameter];
    [self requestReturList];
}

- (IBAction)dismissDatePicker:(id)sender{
    [self animateDatePickerOut];
    dateAdded.text = @"";
}

- (IBAction)pickDatePicker:(id)sender{
    dateAdded.text = [dateFormat stringFromDate:myDatePicker.date];
    [self animateDatePickerOut];
}

@end
