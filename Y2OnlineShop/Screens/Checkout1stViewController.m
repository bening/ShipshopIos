//
//  Checkout1stViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/24/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Checkout1stViewController.h"
#import "Checkout2ndViewController.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import <QuartzCore/QuartzCore.h>
#define pickTitipToko 1
#define pickY2Pool 2
#define pickAddressMine 3
#define pickAddressOther 4
#define addToCart 1
#define checkout 2

@interface Checkout1stViewController ()

@end

@implementation Checkout1stViewController
@synthesize titipToko,y2Pool,tokoName,myAddress,otherAddress,addressLayout,name,phone,city,fee,address,cityPickerLayout,cityTable,loading,popover,helpMsgTextView,wrapper,metodePengirimanWrapper,helpBtn,isRetail,loadingOverlay,loadingWrapper,mainScroller,metodePengirimanLabel,alamatPengirimanLabel,dataPengirimanLabel,expedisi;

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
    self.navigationItem.hidesBackButton = YES;
    UIView *mainView = self.view;
    UIButton *tempNextBtn = self.nextBtn;
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(mainScroller, wrapper, mainView,tempNextBtn);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainScroller]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainScroller]-8-[tempNextBtn]" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wrapper]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wrapper]|" options:0 metrics: 0 views:viewsDictionary]];
    
    //hack to tie contentView width to the width of the screen
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[wrapper(==mainView)]" options:0 metrics:0 views:viewsDictionary]];
    [self initializeView];
    [self shallShowLoadingOverlay:YES];
    if ([[DataSingleton instance].checkoutItemsIsRetail boolValue]) {
        [self hideMetodePengiriman];
    }else{
        [self showMetodePengiriman];
    }
}

- (void)showMetodePengiriman{
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(alamatPengirimanLabel, metodePengirimanWrapper);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[metodePengirimanWrapper]-8-[alamatPengirimanLabel]"
                                                                      options:0
                                                                      metrics:0
                                                                        views:viewsDictionary]];
}

- (void)hideMetodePengiriman{
    metodePengirimanLabel.hidden = YES;
    metodePengirimanWrapper.hidden = YES;
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(alamatPengirimanLabel,dataPengirimanLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dataPengirimanLabel]-8-[alamatPengirimanLabel]"
                                                                      options:0
                                                                      metrics:0
                                                                        views:viewsDictionary]];
}

- (void)viewWillAppear:(BOOL)animated{
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,widthContentView-30,self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"Checkout";
    if (!IS_IPAD) {
        [titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.searchBarRef = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
    self.searchBarRef.alpha=0;
    self.searchBarRef.transform = CGAffineTransformMakeScale(0,0);
    [self.searchBarRef setBackgroundColor:[UIColor clearColor]];
    self.searchBarRef.barTintColor=[UIColor clearColor];
    
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [contentView addSubview:self.searchBarRef];
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = self.searchBarRef;
}

- (void)viewDidAppear:(BOOL)animated{
    //Start an activity indicator here
    [self shallShowLoadingOverlay:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Call your function or whatever work that needs to be done
        //Code in this part is run on a background thread
        [self populateExpedisiList];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            [cityTable reloadData];
            [self useMyAddress];
            [self shallShowLoadingOverlay:NO];
            
        });
    });
}

-(void)initializeView{
    float fontSize = 0.0;
    if (IS_IPAD) {
        fontSize = 17.0;
    }else{
        fontSize = 12.0;
    }
    titipToko.titleLabel.text = @"Titip Toko";
    [titipToko.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    titipToko.checkAlignment = M13CheckboxAlignmentLeft;
    [titipToko addTarget:self action:@selector(checkChangedValue:) forControlEvents:UIControlEventValueChanged];
    titipToko.checkState = M13CheckboxStateUnchecked;
    titipToko.tag = pickTitipToko;
    
    y2Pool.titleLabel.text = @"Y2 Pool";
    [y2Pool.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    y2Pool.checkAlignment = M13CheckboxAlignmentLeft;
    [y2Pool addTarget:self action:@selector(checkChangedValue:) forControlEvents:UIControlEventValueChanged];
    y2Pool.checkState = M13CheckboxStateChecked;
    y2Pool.tag = pickY2Pool;
    
    myAddress.titleLabel.text = @"Gunakan Alamat Saya";
    [myAddress.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    myAddress.checkAlignment = M13CheckboxAlignmentLeft;
    [myAddress addTarget:self action:@selector(checkChangedValue:) forControlEvents:UIControlEventValueChanged];
    myAddress.checkState = M13CheckboxStateChecked;
    myAddress.tag = pickAddressMine;
    
    otherAddress.titleLabel.text = @"Gunakan Alamat Lain";
    [otherAddress.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    otherAddress.checkAlignment = M13CheckboxAlignmentLeft;
    [otherAddress addTarget:self action:@selector(checkChangedValue:) forControlEvents:UIControlEventValueChanged];
    otherAddress.checkState = M13CheckboxStateUnchecked;
    otherAddress.tag = pickAddressOther;
    
    tokoName.delegate = self;
    tokoName.enabled = false;
    tokoName.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
    [self border:tokoName];
    name.delegate = self;
    phone.delegate = self;
    city.delegate = self;
    address.delegate = self;
    fee.delegate = self;
    expedisi.delegate = self;
    
    [name addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [phone addTarget:self
             action:@selector(textFieldDidChange:)
    forControlEvents:UIControlEventEditingChanged];
    
    [fee addTarget:self
             action:@selector(textFieldDidChange:)
    forControlEvents:UIControlEventEditingChanged];
    
    name.isMandatory = YES;
    phone.isMandatory = YES;
    city.isMandatory = YES;
    fee.isMandatory = NO;
    expedisi.isMandatory = YES;
    tokoName.isMandatory = YES;
    fee.enabled = NO;
    [name addRegx:regex_name withMsg:@"Format nama tidak valid"];
    address.placeholder = @"Alamat Lengkap";
    address.placeholderTextColor = [UIColor colorWithWhite: 0.80 alpha:1];
    
    for (id view in addressLayout.subviews) {
        if ([view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UITextField class]]) {
            [self border:view];
        }
    }
    viewLiftedUp = false;
    cityList = [NSMutableArray array];
    selectedCity = -1;
    
    loadingWrapper.layer.cornerRadius = 10.0f;
}

-(void)populateExpedisiList{
    [[DataSingleton instance].allCity sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"kota" ascending:YES], nil]];
    for (NSDictionary* cityInfo in [DataSingleton instance].allCity) {
        NSString* cityName = [cityInfo valueForKey:@"kota"];
        [cityList addObject:cityName];
    }
}

-(void)border:(id)sender{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, ((UIView*)sender).frame.size.height)];
    if ([sender isKindOfClass:[UITextField class]]) {
        //((UITextField*)sender).layer.cornerRadius=8.0f;
        ((UITextField*)sender).layer.masksToBounds=YES;
        ((UITextField*)sender).layer.borderColor=[[UIColor grayColor]CGColor];
        ((UITextField*)sender).layer.borderWidth= 1.0f;
        ((UITextField*)sender).leftView = paddingView;
        ((UITextField*)sender).leftViewMode = UITextFieldViewModeAlways;
    }else if ([sender isKindOfClass:[UITextView class]]) {
        //((UITextView*)sender).layer.cornerRadius=8.0f;
        ((UITextView*)sender).layer.masksToBounds=YES;
        ((UITextView*)sender).layer.borderColor=[[UIColor grayColor]CGColor];
        ((UITextView*)sender).layer.borderWidth= 1.0f;
    }
    
}

- (void)checkChangedValue:(id)sender{
    int tag = (int)((M13Checkbox*)sender).tag;
    switch (tag) {
        case pickTitipToko:
            y2Pool.checkState = M13CheckboxStateUnchecked;
            tokoName.enabled = true;
            tokoName.backgroundColor = [UIColor whiteColor];
            break;
        case pickY2Pool:
            titipToko.checkState = M13CheckboxStateUnchecked;
            tokoName.enabled = false;
            tokoName.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
            break;
        case pickAddressMine:
            otherAddress.checkState = M13CheckboxStateUnchecked;
            [self useMyAddress];
            break;
        case pickAddressOther:
            myAddress.checkState = M13CheckboxStateUnchecked;
            [self useOtherAddress];
            break;
        default:
            break;
    }
}

-(void)textFieldDidChange:(UITextField*)textfield{
    if (myAddress.checkState == M13CheckboxStateChecked) {
        if (textfield==name || textfield == phone || textfield == fee) {
            myAddress.checkState = M13CheckboxStateUnchecked;
            otherAddress.checkState = M13CheckboxStateChecked;
            [self useOtherAddressWithoutClear];
        }
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    if (myAddress.checkState == M13CheckboxStateChecked) {
        if (textView==address) {
            myAddress.checkState = M13CheckboxStateUnchecked;
            otherAddress.checkState = M13CheckboxStateChecked;
            [self useOtherAddressWithoutClear];
        }
    }
}

- (void)useMyAddress{
    [DataSingleton retrieveUser];
    if ([DataSingleton instance].loggedInUser!=nil) {
        NSDictionary* allData = [DataSingleton convertStringToDictionary:[DataSingleton instance].loggedInUser.raw_data];
        name.text = [DataSingleton instance].loggedInUser.name;
        phone.text = [DataSingleton instance].loggedInUser.phone;
        address.text = [allData valueForKey:@"address"];
        fee.text = @"";
        
        if (![[allData valueForKey:@"location"] isEqual:[NSNull null]]) {
            NSString* cityID = [allData valueForKey:@"location"];
            NSArray *filteredCity = [[DataSingleton instance].allCity filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", cityID]];
            if (filteredCity.count>0) {
                NSDictionary *myCity = (NSDictionary*)[filteredCity objectAtIndex:0];
                expedisi.text = [myCity valueForKey:@"kota"];
                if ([[myCity valueForKey:@"price"] isEqual:[NSNull null]]) {
                    fee.text = @"0";
                }else{
                    fee.text = [myCity valueForKey:@"price"];
                }
                if (cityList.count>0) { 
                    selectedCity = (int)[cityList indexOfObject:[myCity valueForKey:@"kota"]];
                }
            }
            
        }
        
        name.rightView = nil;
        phone.rightView = nil;
        city.rightView = nil;
    }
}

- (void)useOtherAddress{
    name.text = nil;
    phone.text = nil;
    address.text = nil;
    city.text = nil;
    fee.text = nil;
    name.enabled = true;
    phone.enabled = true;
    address.editable = true;
    city.enabled = true;
    name.rightView = nil;
    phone.rightView = nil;
    city.rightView = nil;
}

- (void)useOtherAddressWithoutClear{
    name.enabled = true;
    phone.enabled = true;
    address.editable = true;
    city.enabled = true;
}

-(void)animateExpedisiIn{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{cityPickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {[city resignFirstResponder];}];
}

-(void)animateExpedisiOut{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{cityPickerLayout.alpha = 0.0f;}
                     completion:^(BOOL finished) {
                         if (selectedCity!=-1 && [DataSingleton instance].allCity.count>0) {
                             NSDictionary* _selectedCity = [[DataSingleton instance].allCity objectAtIndex:selectedCity];
                             if ([[_selectedCity valueForKey:@"price"] isEqual:[NSNull null]]) {
                                 fee.text = @"0";
                             }else{
                                 fee.text = [_selectedCity valueForKey:@"price"];
                             }
                         }
                         [expedisi validate];
                     }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    bool disturb = false;
    if (activeTextField==expedisi) {
        [self dismissCityPicker:nil];
    }else{
        if (activeTextField!=nil) {
            NSLog(@"previous textfield: %@",activeTextField.placeholder);
            [self setEditing:NO animated:YES];
            disturb = true;
        }
    }
    activeTextField = textField;
    if (textField==expedisi){
        if (!disturb) {
            [textField resignFirstResponder];
        }
        [self animateExpedisiIn];
    }
    else if (textField==fee){
        [self animateViewUp];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return YES;
}

-(void)animateViewUp{
    int liftUp = 80;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 40;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 140;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 140;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 120;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 100;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 100;
        }
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame; frame.origin.y = -1*liftUp;
    [self.view setFrame:frame]; [UIView commitAnimations];
    viewLiftedUp =true;
}

-(void)animateViewDown{
    int liftDown = 45;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftDown = 45;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftDown = 43;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftDown = 43;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftDown = 45;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftDown = 32;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftDown = 32;
        }
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame; frame.origin.y = liftDown;
    [self.view setFrame:frame]; [UIView commitAnimations];
    viewLiftedUp = false;
}

#pragma mark - UITableView
#pragma mark - datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==cityTable){
        return [cityList count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    int row = (int)indexPath.row;
    cell.tag = row;
    if (_tableView==cityTable) {
        cell.textLabel.text = (NSString*)[cityList objectAtIndex:row];
        if (cell.tag==selectedCity) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (_tableView==cityTable){
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        selectedCity = cell.tag;
    }
    
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissCityPicker:(id)sender {
    [self animateExpedisiOut];
}

- (IBAction)pickCity:(id)sender {
    if (selectedCity!=-1) {
        expedisi.text = [cityList objectAtIndex:selectedCity];
        myAddress.checkState = M13CheckboxStateUnchecked;
        otherAddress.checkState = M13CheckboxStateChecked;
        [self useOtherAddressWithoutClear];
    }
    [self dismissCityPicker:sender];
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToNextStep:(id)sender {
    BOOL infoComplete = true;
    if (titipToko.checkState == M13CheckboxStateChecked) {
        if (![tokoName validate]) {
            infoComplete = false;
        }
    }
    if (infoComplete) {
        for (id subview in addressLayout.subviews) {
            if ([subview isKindOfClass:[TextFieldValidator class]]) {
                if (![(TextFieldValidator*)subview validate]) {
                    infoComplete = false;
                }
            }
        }
    }
    if (address.text.length==0) {
        infoComplete = false;
    }
    if (infoComplete) {
        NSMutableArray * arrayOfJsonData = [[NSMutableArray alloc]init];
        SBJsonParser *parser = [[SBJsonParser alloc]init];
        for (NSDictionary* cartItem in [DataSingleton instance].checkoutItems) {
            Product* _product = [cartItem valueForKey:productKey];
            NSNumber *quantity = [cartItem valueForKey:quantityKey];
            NSDictionary* productRawData = _product.completeData;
            BOOL isGrosirProduct = [(NSNumber*)[productRawData objectForKey:@"is_grosir"]boolValue];
            NSString *varID = @"0";
            if (!isGrosirProduct) {
                NSMutableArray* productSelectedOption = [productRawData valueForKey:product_option_key];
                NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productRawData valueForKey:@"stock"] usingOptionData:productSelectedOption];
                
                if (stockInfo) {
                    varID = [stockInfo valueForKey:@"var_id"];
                }
            }
            NSString *prdSKU = [_product.completeData valueForKey:@"prd_id"];
            NSDictionary* newData = [[NSDictionary alloc] initWithObjectsAndKeys:prdSKU,@"prd_id",[quantity stringValue],@"qty",varID,@"var_id", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newData options:kNilOptions error:nil];
            NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSDictionary * parsedJsonData = [parser objectWithString:result error:nil];
            [arrayOfJsonData addObject:parsedJsonData];
        }
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:arrayOfJsonData options:0 error:nil];
        NSString* dataString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        [self addCartBulk:dataString];
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Harap isi semua data alamat dengan benar"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
}

- (IBAction)showHelpPopup:(id)sender {
    popover = [DXPopover new];
    popover.maskType = DXPopoverMaskTypeNone;
    CGPoint showPoint = CGPointMake(CGRectGetMinX(metodePengirimanWrapper.frame)+CGRectGetMidX(helpBtn.frame), CGRectGetMinY(metodePengirimanWrapper.frame)+CGRectGetMaxY(helpBtn.frame));
    NSString* y2PoolMsg = [[DataSingleton instance].messageCollection valueForKey:@"checkout_what_is_y2_pool"];
    if (y2PoolMsg) {
        helpMsgTextView.text = y2PoolMsg;
    }
    helpMsgTextView.font = [UIFont systemFontOfSize:15];
    helpMsgTextView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    helpMsgTextView.layer.borderWidth = 2.5f;
    helpMsgTextView.layer.borderColor = [UIColor blueColor].CGColor;
    [popover showAtPoint:showPoint popoverPostion:DXPopoverPositionDown withContentView:helpMsgTextView inView:wrapper];
}

- (void)addCartBulk:(NSString*)jsonString{
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
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,addItemToCartBulkURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = addToCart;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser.id_user forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser.token forKey:@"access_token"];
        [request addPostValue:[NSNumber numberWithBool:!isRetail] forKey:@"is_grosir"];
        [request addPostValue:jsonString forKey:@"bulk"];
        
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)checkoutToServer{
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
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,cartCheckoutURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = checkout;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser.id_user forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser.token forKey:@"access_token"];
        
        if (titipToko.checkState == M13CheckboxStateChecked) {
            //pick TitipToko
            [request addPostValue:@"toko" forKey:@"metode_pengiriman"];
            [request addPostValue:tokoName.text forKey:@"shipping_toko"];
        }else{
            [request addPostValue:@"" forKey:@"metode_pengiriman"];
            [request addPostValue:@"" forKey:@"shipping_toko"];
        }
        
        if (myAddress.checkState == M13CheckboxStateChecked) {
            //pick Alamat saya
            [request addPostValue:@"saya" forKey:@"alamat_pengiriman"];
        }else{
            [request addPostValue:@"lain" forKey:@"alamat_pengiriman"];
        }
        
        [request addPostValue:fee.text forKey:@"shipping_charge"];
        [request addPostValue:name.text forKey:@"name"];
        [request addPostValue:address.text forKey:@"address"];
        [request addPostValue:phone.text forKey:@"phone"];
        
        
        if (selectedCity< [[DataSingleton instance].allCity count]) {
            NSDictionary *selectedCityInfo = [[DataSingleton instance].allCity objectAtIndex:selectedCity];
            [request addPostValue:[selectedCityInfo valueForKey:@"id"] forKey:@"location_id"];
        }
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)getPaymentInfo:(NSString*)_orderNumber{
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
        [request addPostValue:_orderNumber forKey:@"order_number"];
        
        
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
    [self shallShowLoadingOverlay:NO];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case addToCart:
            if (success) {
                [self checkoutToServer];
            }else{
                NSString* errorMessage = (NSString*)[jsonDictionary objectForKey:@"message"];
                if (!errorMessage) {
                    errorMessage = message_error_server;
                }
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
        case checkout:
            if (success) {
                orderNumber = (NSString*)[jsonDictionary objectForKey:@"order_number"];
                if (orderNumber.length > 0) {
                    [self getPaymentInfo:orderNumber];
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
            break;
        case getPaymentInformation:
            if (success) {
                //delete cart
                for (NSDictionary* cartData in [DataSingleton instance].checkoutItems) {
                    Product* _product = [cartData valueForKey:productKey];
                    int cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product];
                    if (cartItemIndex>=0) {
                        [DataSingleton deleteShopCartOnIndex:cartItemIndex];
                    }
                }
                [DataSingleton instance].paymentInfo = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[jsonDictionary objectForKey:@"data"]];
                Checkout2ndViewController *checkout2ndPage = [[Checkout2ndViewController alloc] initWithNibName:@"Checkout2ndViewController" bundle:nil];
                checkout2ndPage.orderNumber = orderNumber;
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
            break;
        default:
            break;
    }
    
}

- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"request login started");
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
}

@end
