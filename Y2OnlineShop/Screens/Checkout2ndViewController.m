//
//  Checkout2ndViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/29/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Checkout2ndViewController.h"
#import "Checkout3rdViewController.h"
#import "Constants.h"
#import "M13Checkbox.h"
#import "DataSingleton.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "CartViewController.h"
#import "Checkout1stViewController.h"
#define paymentConfirmation 1

@interface Checkout2ndViewController ()

@end

@implementation Checkout2ndViewController
@synthesize transBtn,viewTrans,viewCC,transScroller,ccScroller,saveAccountCheckBox,transferAccount,transferBank,transferDate,transferName,uploadBtn,popover,uploadOptView,takePicBtn,selectPicBtn,orderNumberLabel,orderNumber,transScript,datePicker,datePickerCancelBtn,datePickerDoneBtn,datePickerLayout,datePickerToolbar,loading,loadingOverlay,loadingWrapper,progressLabel,progressView,uploadingLabel,accountListTable,destinationAcc,subTotalLabel,ongkosKirimLabel,discOngkosKirimLabel,totalPaymentLabel, mainScroller, wrapper;

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
    self.navigationItem.hidesBackButton = YES; // Important
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali"
//                                            style:UIBarButtonItemStyleBordered target:self action:@selector(backBtnPressed)];
    if(!IS_IPAD){
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
    }
    
    [self initializeComponent];
    [self transSelected:nil];
    
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

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    
}

- (void)initializeComponent{
    transBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
    uploadBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
    orderNumberLabel.text = [NSString stringWithFormat:@"(No. Order: %@)",orderNumber];
    for (id subview in uploadOptView.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            ((UITextField*)subview).layer.cornerRadius=5.0f;
        }else if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton*)subview).layer.cornerRadius=5.0f;
        }
    }
    
    for (id subview in transScroller.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            ((UITextField*)subview).delegate = self;
        }
    }
    format = [[NSDateFormatter alloc] init];
    [format setDateFormat:date_format];
    [transBtn addTarget:self action:@selector(transSelected:) forControlEvents:UIControlEventTouchDown];
    saveAccountCheckBox.titleLabel.text = @"Simpan Informasi Kartu Saya";
    saveAccountCheckBox.checkAlignment = M13CheckboxAlignmentLeft;
    [saveAccountCheckBox addTarget:self action:@selector(checkSaveAccount:) forControlEvents:UIControlEventValueChanged];
    saveAccountCheckBox.checkState = M13CheckboxStateUnchecked;
    for (id view in ccScroller.subviews) {
        if ([view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UITextField class]]) {
            [self border:view];
        }
    }
    for (id view in transScroller.subviews) {
        if ([view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UITextField class]]) {
            [self border:view];
        }
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    pngFilePath = [NSString stringWithFormat:@"%@%@",docDir,transscript_filepath];
    
    accountListTable.delegate = self;
    accountListTable.dataSource = self;
    accountListTable.backgroundColor = [UIColor lightGrayColor];
    int longestLength = 0;
    NSString* longestString = @"";
    for (NSDictionary* accountInfo in [DataSingleton instance].allAccount) {
        NSString* accNumber = (NSString*)[accountInfo valueForKey:@"no_rekening"];
        NSString* bankName = (NSString*)[accountInfo valueForKey:@"name_bank"];
        NSString* accountName = (NSString*)[accountInfo valueForKey:@"name_account"];
        NSString* formattedName = [NSString stringWithFormat:@"%@ (%@), A/N: %@",accNumber,bankName,accountName];
        if (formattedName.length>longestLength) {
            longestLength = formattedName.length;
            longestString = formattedName;
        }
    }
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    accountTableWidth = [longestString
                         boundingRectWithSize:tempLabel.frame.size
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{ NSFontAttributeName:tempLabel.font }
                         context:nil].size.width+70.0;
    [accountListTable setFrame:CGRectMake(0, 0, 400, 176)];
    [accountListTable reloadData];
    selectedAccount = -1;
    
    [transferBank addRegx:regex_bankname withMsg:@"Nama bank memiliki format yang salah"];
    [transferAccount addRegx:regex_accountnumber withMsg:@"Masukkan angka saja sebagai nomer rekening"];
    [transferName addRegx:regex_name withMsg:@"Nama rekening tidak boleh mengandung angka"];
    NSDictionary *paymentData = [NSDictionary dictionaryWithDictionary:[DataSingleton instance].paymentInfo];
    int subTotal = [[paymentData valueForKey:@"subtotal_amount"] intValue];
    int ongkir = [[paymentData valueForKey:@"shipping_cost"] intValue];
    int discOngkir = [[paymentData valueForKey:@"discount_shipping_cost"] intValue];
    int total = [[paymentData valueForKey:@"total_amount"] intValue];
    double _subTotal = (subTotal/1000.0);
    double _ongkir = (ongkir/1000.0);
    double _discOngkir = (discOngkir/1000.0);
    double _total = (total/1000.0);
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    
    subTotalLabel.text = [NSString stringWithFormat:@"Rp %@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:_subTotal * 1000]]];
    ongkosKirimLabel.text = [NSString stringWithFormat:@"Rp %@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:_ongkir * 1000]]];
    discOngkosKirimLabel.text = [NSString stringWithFormat:@"Rp %@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:_discOngkir * 1000]]];
    totalPaymentLabel.text = [NSString stringWithFormat:@"Rp %@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:_total * 1000]]];
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    [datePicker setDate:[NSDate date]];
    [datePicker setMaximumDate:[NSDate date]];
    
    [self registerForKeyboardNotifications];
}

- (void)checkSaveAccount:(id)sender{

}

-(void)border:(id)sender{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, ((UIView*)sender).frame.size.height)];
    if ([sender isKindOfClass:[UITextField class]]) {
        ((UITextField*)sender).layer.masksToBounds=YES;
        ((UITextField*)sender).layer.borderColor=[[UIColor grayColor]CGColor];
        ((UITextField*)sender).layer.borderWidth= 1.0f;
        ((UITextField*)sender).leftView = paddingView;
        ((UITextField*)sender).leftViewMode = UITextFieldViewModeAlways;
    }else if ([sender isKindOfClass:[UITextView class]]) {
        ((UITextView*)sender).layer.masksToBounds=YES;
        ((UITextView*)sender).layer.borderColor=[[UIColor grayColor]CGColor];
        ((UITextView*)sender).layer.borderWidth= 1.0f;
    }
    
}

-(void)transSelected:(id)sender{
    transBtn.backgroundColor = COLOR_PINK_Y2;
    viewTrans.hidden = NO;
    viewCC.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAccountOption {
    if ([DataSingleton instance].allAccount.count) {
        [self updateTableViewFrame];
        popover = [DXPopover new];
        [popover setFrame:accountListTable.bounds];
        CGPoint startPoint = CGPointMake(CGRectGetMidX(destinationAcc.frame), CGRectGetMaxY(destinationAcc.frame));
        popover.maskType = DXPopoverMaskTypeNone;
        [popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:accountListTable inView:IS_IPAD ? transScroller : viewTrans];
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Tidak terdapat pilihan rekening"
                     delegate: self
                     cancelButtonTitle: @"Close" otherButtonTitles: nil];
        [errorView setTag:0];
        [errorView show];
    }
}

- (int)getIndexOfCartViewControllerInViews:(NSArray*)views{
    int cartViewIndex = -1;
    for (int i = (int)views.count-1; i >= 0; i--) {
        UIViewController *view = (UIViewController*)[views objectAtIndex:i];
        if ([view isKindOfClass:[CartViewController class]]) {
            cartViewIndex = i;
            break;
        }
    }
    return cartViewIndex;
}

- (void)goToCartViewController{
    NSArray *views = [self.navigationController viewControllers];
    int cartViewIndex = [self getIndexOfCartViewControllerInViews:views];
    if (cartViewIndex>=0) {
        [self.navigationController popToViewController:[views objectAtIndex:cartViewIndex] animated:YES];
    }else{
        CartViewController *cartViewController = [[CartViewController alloc] initWithNibName:@"CartViewController" bundle:nil];
        [self.navigationController pushViewController:cartViewController animated:YES];
    }
}

- (BOOL)previousViewIsShippingScreen{
    NSArray *views = [self.navigationController viewControllers];
    UIViewController *view = (UIViewController*)[views objectAtIndex:views.count-2];
    return [view isKindOfClass:[Checkout1stViewController class]];
}

- (IBAction)goBack:(id)sender {
    if ([self previousViewIsShippingScreen]) {
        [self goToCartViewController];
    }else{
        //just go back to previous screen
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)backBtnPressed {
    [self goBack:nil];
}

- (BOOL)validateForm{
    bool valid = [transferBank validate];
    valid &= [transferAccount validate];
    valid &= [transferName validate];
    valid &= [transferDate validate];
    //valid &= [phoneOther validate];
    if (valid){
        if (selectedAccount==-1) {
            valid = false;
            validatorMsg = @"Harap pilih rekening tujuan";
            return false;
        }
        if (valid) {
            if (transScript.image == nil) {
                valid = false;
                validatorMsg = @"Harap sertakan bukti transfer dengan menekan tombol \"Upload Bukti Transfer\"";
                return false;
            }
        }
        return true;
    }else{
        validatorMsg = @"Data tidak valid";
        return false;
    }
    valid &= transScript.image!=nil;
    return valid;
}

- (IBAction)proceedToNextStep:(id)sender {
    [self.view endEditing:YES];
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    if ([self validateForm]) {
        [self confirmPayment];
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: validatorMsg
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
    
}

- (IBAction)uploadBtnSelected:(id)sender {
    popover = [DXPopover new];
    popover.maskType = DXPopoverMaskTypeNone;
    //[popover showAtView:uploadBtn withContentView:uploadOptView inView:transScroller];
    [popover showAtView:uploadBtn popoverPostion:DXPopoverPositionUp withContentView:uploadOptView inView: IS_IPAD ? transScroller : viewTrans];
}

- (IBAction)selectPicture:(id)sender {
    [popover dismiss];
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    [imgPicker setDelegate:self];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setAllowsEditing:YES];
    [imgPicker setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:imgPicker animated:YES completion:NULL];
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return YES;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (IBAction)takePicture:(id)sender {
    [popover dismiss];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:title_error
                                                              message:@"Perangkat tidak didukung kamera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)dismissDatePicker:(id)sender {
    [self animateDatePickerOut];
}

- (IBAction)pickDate:(id)sender {
    transferDate.text = [format stringFromDate:datePicker.date];
    [self dismissDatePicker:sender];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    transScript.image = chosenImage;
    
    //delete existing file
    [DataSingleton removeFile:pngFilePath];
    //write file
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    //NSString* base64Image = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:0];
    //NSData *data = [NSData dataFromBase64String:[DataSingleton instance].outletImage64Encoding];
    [imageData writeToFile:pngFilePath atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //    [self.pickerView setHidden:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)animateViewUp{
    int liftUp = 80;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 120;
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
            liftUp = 210;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==destinationAcc) {
        [self showAccountOption];
        return NO;
    }
    if (textField == transferDate){
        [self animateDatePickerIn];
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextField =textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    activeTextField = nil;
}

-(void)animateDatePickerIn{
    [uploadBtn setEnabled:NO];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datePickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {[transferDate resignFirstResponder];}];
}

-(void)animateDatePickerOut{
    [uploadBtn setEnabled:YES];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datePickerLayout.alpha = 0.0f;}
                     completion:^(BOOL finished) {
                         NSDate* _date = [format dateFromString:transferDate.text];
                         if (_date!=nil) {
                             datePicker.date = _date;
                         }
                         [transferDate validate];
                         
                     }];
}

- (void)confirmPayment{
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
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,paymentConfirmURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = paymentConfirmation;
        [request setUploadProgressDelegate:self];
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser.id_user forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser.token forKey:@"access_token"];
        [request addPostValue:orderNumber forKey:@"order_number"];
        [request addPostValue:transferBank.text forKey:@"bank_name"];
        [request addPostValue:transferAccount.text forKey:@"bank_account"];
        [request addPostValue:transferName.text forKey:@"name_account"];
        [request addPostValue:[DataSingleton instance].checkoutExpense forKey:@"transfer_amount"];
        
        NSDateFormatter *format2nd = [[NSDateFormatter alloc] init];
        [format2nd setDateFormat:@"dd-MM-yyyy"];
        [request addPostValue:[format2nd stringFromDate:[datePicker date]] forKey:@"date"];
        
        NSURL *_path = [NSURL URLWithString:pngFilePath];
        NSString* imagePath = [_path path];
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
        if (imageData.length >0) {
            [request setData:imageData withFileName:@"transscript.png" andContentType:@"image/png" forKey:@"img_name"];
        }
        
        NSDictionary* bankData = [[DataSingleton instance].allAccount objectAtIndex:selectedAccount];
        [request addPostValue:[bankData valueForKey:@"id_bank"] forKey:@"bank_destination_id"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request{
    [progressView setProgress:0];
    [progressLabel setText:@"0%"];
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
        case paymentConfirmation:
            if (success) {
//                //delete cart
//                for (NSDictionary* cartData in [DataSingleton instance].checkoutItems) {
//                    Product* _product = [cartData valueForKey:productKey];
//                    int cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product];
//                    if (cartItemIndex>=0) {
//                        [DataSingleton deleteShopCartOnIndex:cartItemIndex];
//                    }
//                }
                Checkout3rdViewController *checkout3rdPage = [[Checkout3rdViewController alloc] initWithNibName:@"Checkout3rdViewController" bundle:nil];
                [self.navigationController pushViewController:checkout3rdPage animated:YES];
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
        default:
            break;
    }
    
}

- (void)setProgress:(float)progress
{
    [progressLabel setText:[NSString stringWithFormat:@"%d%%",(int)(progress*100)]];
    [progressView setProgress:progress];
}

#pragma mark - UITableView
#pragma mark - datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==accountListTable) {
        return [DataSingleton instance].allAccount.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    int row = (int)indexPath.row;
    
    if (_tableView==accountListTable) {
        NSDictionary* accountInfo = [[DataSingleton instance].allAccount objectAtIndex:row];
        NSString* accNumber = (NSString*)[accountInfo valueForKey:@"no_rekening"];
        NSString* bankName = (NSString*)[accountInfo valueForKey:@"name_bank"];
        NSString* accountName = (NSString*)[accountInfo valueForKey:@"name_account"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@), A/N: %@",accNumber,bankName,accountName];
//        accountTableWidth = [cell.textLabel.text
//         boundingRectWithSize:cell.textLabel.frame.size
//         options:NSStringDrawingUsesLineFragmentOrigin
//         attributes:@{ NSFontAttributeName:cell.textLabel.font }
//         context:nil].size.width;
        cell.tag = row;
        if (cell.tag==selectedAccount) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_tableView==accountListTable){
        UITableViewCell *cell = [accountListTable cellForRowAtIndexPath:indexPath];
        selectedAccount = (int)cell.tag;
        NSDictionary* accountInfo = [[DataSingleton instance].allAccount objectAtIndex:selectedAccount];
        NSString* accNumber = (NSString*)[accountInfo valueForKey:@"no_rekening"];
        NSString* bankName = (NSString*)[accountInfo valueForKey:@"name_bank"];
        destinationAcc.text = [NSString stringWithFormat:@"%@ (%@)",accNumber,bankName];
        [popover dismiss];
        [_tableView reloadData];
    }
    
}

- (void)updateTableViewFrame
{
    //CGRect tableViewFrame = accountListTable.frame;
    
    if (IS_IPAD) {
        if ([DataSingleton instance].allAccount.count>5) {
            [accountListTable setFrame:CGRectMake(0, 0, accountTableWidth==0? 320.0:accountTableWidth, 120.0+80.0)];
        }else{
            [accountListTable setFrame:CGRectMake(0, 0, accountTableWidth==0? 320.0:accountTableWidth, 44.0*[DataSingleton instance].allAccount.count)];
        }
    } else{
        if ([DataSingleton instance].allAccount.count>5) {
            [accountListTable setFrame:CGRectMake(0, 0, 317.0, 120.0+80.0)];
        }else{
            [accountListTable setFrame:CGRectMake(0, 0, 317.0, 44.0*[DataSingleton instance].allAccount.count)];
        }
    }
    
//    tableViewFrame.size = CGSizeMake(500, 176);
//    accountListTable.frame = tableViewFrame;
}

// Call this method somewhere in your view controller setup code.

- (void)registerForKeyboardNotifications

{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    
}



// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification

{
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    
    UIEdgeInsets contentInsets;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.width, 0.0);
    } else{
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    }
    
    mainScroller.contentInset = contentInsets;
    
    mainScroller.scrollIndicatorInsets = contentInsets;
    
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        aRect.size.height -= kbSize.width;
    } else{
        aRect.size.height -= kbSize.height;
    }
    
    if (!CGRectContainsPoint(aRect, activeTextField.frame.origin) ) {
        
        [self.mainScroller scrollRectToVisible:activeTextField.frame animated:YES];
        
    }
    
}



// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    mainScroller.contentInset = contentInsets;
    
    mainScroller.scrollIndicatorInsets = contentInsets;
    
}




@end
