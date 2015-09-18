//
//  RegisterViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/1/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "RegisterViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "TextFieldValidator.h"
#import "Constants.h"
#import "DataSingleton.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize birthdate,email,gender,name,password,passwordConfirmation,phone,submitBtn,scrollView,loading,loadingOverlay,loadingWrapper,datePicker,datePickerToolbar,datepickerLayout,genderPickerLayout,tableView, username, wrapper;


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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        // Portrait
        // Do the same for the rest of your objects
    }
    
    else
    {
        // Landscape
        // Do the same for the rest of your objects
    }
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
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    UIImageView *imageLogo = [[UIImageView alloc] init];
    imageLogo.contentMode = UIViewContentModeScaleAspectFit;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [imageLogo sizeToFit];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
    titleLabel.text = registerMenu;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    float spaceLeftLogoToSuperview = 0.0;
    
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
    
    selectedGender = UNSELECT_GENDER;
    format = [[NSDateFormatter alloc] init];
    [format setDateFormat:date_format];
    [datePicker setDate:[NSDate date]];
    [datePicker setMaximumDate:[NSDate date]];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    username.delegate = self;
    email.delegate = self;
    password.delegate = self;
    passwordConfirmation.delegate = self;
    name.delegate = self;
    birthdate.delegate = self;
    gender.delegate = self;
    phone.delegate = self;
    [scrollView setScrollEnabled:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];
    // Add regex for validating characters limit
    [email addRegx:regex_email withMsg:@"Masukkan alamat email yang valid"];
    [password addRegx:regex_password withMsg:@"Password minimal terdiri dari 3 karakter"];
    [passwordConfirmation addConfirmValidationTo:password withMsg:@"Konfirmasi Password harus sesuai dengan Password"];
    [name addRegx:regex_name withMsg:@"Nama harus diisi, tidak boleh mengandung angka atau simbol"];
    [gender addRegx:regex_gender withMsg:@"Jenis kelamin harus diisi"];
    [birthdate addRegx:regex_birthdate withMsg:@"Tanggal lahir harus diisi"];
    [phone addRegx:regex_phone withMsg:@"Nomor Telepon/HP harus terdiri dari 6-16 angka"];
    
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    [self registerForKeyboardNotifications];
    
    if(!IS_IPAD){
        UIView *mainView = self.view;
        
        // Set the constraints for the scroll view and the image view.
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(scrollView, wrapper, mainView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wrapper]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wrapper]|" options:0 metrics: 0 views:viewsDictionary]];
        
        //hack to tie contentView width to the width of the screen
        [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[wrapper(==mainView)]" options:0 metrics:0 views:viewsDictionary]];
    }
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    
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

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    bool disturb = false;
    if (activeTextField==birthdate) {
        [self datepickerDismiss:nil];
    }else if (activeTextField==gender){
        [self genderPickerDismiss:nil];
    }else{
        if (activeTextField!=nil) {
            NSLog(@"previous textfield: %@",activeTextField.placeholder);
            [self setEditing:NO animated:YES];
            disturb = true;
        }
    }
    
    if (textField==birthdate) {
        //[self.view endEditing:YES];
        if (!disturb) {
            [textField resignFirstResponder];
        }
        
        [self animateDatePickerIn];
    }else if (textField==gender){
        //[self.view endEditing:YES];
        [tableView reloadData];
        if (!disturb) {
            [textField resignFirstResponder];
        }
        [self animateGenderPickerIn];
    }
    activeTextField =textField;
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    NSLog(@"should end editing: %@",textField.placeholder);
//    return YES;
//}
//
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
}

-(void)animateDatePickerIn{
    [submitBtn setEnabled:NO];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datepickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {[birthdate resignFirstResponder];}];
}

-(void)animateDatePickerOut{
    [submitBtn setEnabled:YES];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datepickerLayout.alpha = 0.0f;}
                     completion:^(BOOL finished) {
                         NSDate* _date = [format dateFromString:birthdate.text];
                         if (_date!=nil) {
                             datePicker.date = _date;
                         }
                         [birthdate validate];
                         
                     }];
}

-(void)animateGenderPickerIn{
    [submitBtn setEnabled:NO];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{genderPickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {[gender resignFirstResponder];}];
}

-(void)animateGenderPickerOut{
    [submitBtn setEnabled:YES];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{genderPickerLayout.alpha = 0.0f;}
                     completion:^(BOOL finished) {[gender validate];}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)validateForm{

    bool valid = [email validate];
    valid &= [password validate];
    valid &= [passwordConfirmation validate];
    valid &= [name validate];
    valid &= [gender validate];
    valid &= [birthdate validate];
    valid &= [phone validate];
    valid &= [username validate];
    if (valid){
        return true;
    }else{
        validatorMessage = @"Data registrasi tidak valid";
        return false;
    }
}


- (void)doRegister{
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
        NSString * _registerURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,registerURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_registerURL]];
        
        [request setRequestMethod:@"POST"];
        //Following code will retain username and password for Re-login.
        [request setUsername:username.text];
        [request setPassword:password.text];
        [request addPostValue:username.text forKey:@"username"];
        [request addPostValue:email.text forKey:@"email"];
        [request addPostValue:password.text forKey:@"password"];
        [request addPostValue:name.text forKey:@"name"];
        [request addPostValue:[NSString stringWithFormat:@"%d",selectedGender] forKey:@"gender"];
        [request addPostValue:birthdate.text forKey:@"birthdate"];
        [request addPostValue:phone.text forKey:@"phone"];
                
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (IBAction)registrationProcess:(id)sender {
    [self.view endEditing:YES];
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    if ([self validateForm]) {
        [self doRegister];
    }else
    {
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: @"Registrasi"
                     message: validatorMessage
                     delegate: self
                     cancelButtonTitle: @"Close" otherButtonTitles: nil];
        
        [errorView show];
    }
}

- (IBAction)datepickerDismiss:(id)sender {
    //[birthdate resignFirstResponder];
    [self animateDatePickerOut];
}

- (IBAction)datepickerDone:(id)sender {
    birthdate.text = [format stringFromDate:datePicker.date];
    [self datepickerDismiss:sender];
}

- (IBAction)genderPickerDismiss:(id)sender {
    //[gender resignFirstResponder];
    if ([gender.text isEqualToString:Male]) {
        selectedGender = MALE_ID;
    }else if ([gender.text isEqualToString:Female]){
        selectedGender = FEMALE_ID;
    }else{
        selectedGender = UNSELECT_GENDER;
    }
    [self animateGenderPickerOut];
}

- (IBAction)genderPickerDone:(id)sender {
    if (selectedGender==MALE_ID) {
        gender.text = Male;
    }else if (selectedGender==FEMALE_ID){
        gender.text = Female;
    }
    [self genderPickerDismiss:sender];
}

#pragma mark - UITableView
#pragma mark - datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    int row = (int)indexPath.row;
    
    if (row==0) {
        cell.textLabel.text = Male;
        cell.tag = MALE_ID;
    }else{
        cell.textLabel.text = Female;
        cell.tag = FEMALE_ID;
    }
    if (cell.tag==selectedGender) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_tableView==tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        selectedGender = cell.tag;
        
        
    }
    
    [_tableView reloadData];
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
    if (success) {
            UIAlertView *errorView;
        
            errorView = [[UIAlertView alloc]
                        initWithTitle: title_success
                        message: [jsonDictionary objectForKey:@"message"]
                        delegate: self
                        cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:1];
            [errorView show];
    }else{
        NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: @"Gagal"
                     message: errorMessage
                     delegate: self
                     cancelButtonTitle: @"Close" otherButtonTitles: nil];
        [errorView setTag:0];
        [errorView show];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"request login started");
}

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
    if(IS_IPAD){
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
           [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.width, 0.0);
        } else{
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        }
    } else{
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            // code for landscape orientation
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.width, 0.0);
        } else{
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        }
    }
    
    scrollView.contentInset = contentInsets;
    
    scrollView.scrollIndicatorInsets = contentInsets;
    
    
    
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
        
        [self.scrollView scrollRectToVisible:activeTextField.frame animated:YES];
        
    }
    
}



// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    scrollView.contentInset = contentInsets;
    
    scrollView.scrollIndicatorInsets = contentInsets;
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

@end
