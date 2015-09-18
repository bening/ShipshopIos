//
//  ProfilePageViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/17/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "ProfilePageViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "TextFieldValidator.h"
#import "Constants.h"
#import "DataSingleton.h"
#import <QuartzCore/QuartzCore.h>
#define edit_profile 1
#define edit_pass 2

@interface ProfilePageViewController ()

@end

@implementation ProfilePageViewController
@synthesize birthdate,userName,email,gender,name,password,userNewPassword,phone,saveBtn,changePassBtn,infoAccScroller,loading,datePicker,datePickerToolbar,datepickerLayout,genderPickerLayout,genderTable,myProfile,leftMenuReference,dataAccBtn,infoAccBtn,dataAccScroller,address,infoAccount,dataAccount,city,cityPickerLayout,cityTable,cityToolbar,cancelCityPicker,doneCityPicker;

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

- (void)viewWillLayoutSubviews
{
//    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
//    {
//        //x,y as you want
//        isPortrait = false;
//    }
//    else
//    {
//        //In potrait
//        isPortrait= true;
//    }
    
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
    titleLabel.text = detailAccountMenu;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    float spaceLeftLogoToSuperview = 0.0;
    if (IS_IPAD) {
        spaceLeftLogoToSuperview = 10.0f;
    }else {
        spaceLeftLogoToSuperview = 5.0f;
    }
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
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].shopBarButtonItem, nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeComponent];
    //Start an activity indicator here
    if (myProfile!=nil) {
        [loading startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //Call your function or whatever work that needs to be done
            //Code in this part is run on a background thread
            allData = [[DataSingleton convertStringToDictionary:myProfile.raw_data] mutableCopy];
            [[DataSingleton instance].allCity sortUsingDescriptors:
             [NSArray arrayWithObjects:
              [NSSortDescriptor sortDescriptorWithKey:@"kota" ascending:YES], nil]];
            for (NSDictionary* cityInfo in [DataSingleton instance].allCity) {
                NSString* cityName = [cityInfo valueForKey:@"kota"];
                if (cityName != NULL) {
                    [cityList addObject:cityName];
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                //Stop your activity indicator or anything else with the GUI
                //Code here is run on the main thread
                [cityTable reloadData];
                [self populateData];
                [loading stopAnimating];
                
            });
        });
    }
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    [self registerForKeyboardNotifications];
}

-(void)viewDidAppear:(BOOL)animated{
    
    
}

- (void)initializeComponent{
    if (IS_IPAD) {
        infoAccBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
        dataAccBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
        saveBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
        changePassBtn.titleLabel.font = FONT_ARSENAL_BOLD(20);
    }else{
        infoAccBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
        dataAccBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
        saveBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
        changePassBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
    }
    
    [infoAccBtn addTarget:self action:@selector(infoAccSelected:) forControlEvents:UIControlEventTouchDown];
    [dataAccBtn addTarget:self action:@selector(dataAccSelected:) forControlEvents:UIControlEventTouchDown];
    [self infoAccSelected:nil];
    address.delegate = self;
    //address.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    address.placeholder = @"Alamat Lengkap";
    address.placeholderTextColor =[UIColor lightGrayColor];
    [email addRegx:regex_email withMsg:@"Masukkan alamat email yang valid"];
    [userName addRegx:regex_name withMsg:@"Nama tidak valid"];
    [password addRegx:regex_password withMsg:@"Password minimal terdiri dari 3 karakter"];
    //[passwordConfirmation addConfirmValidationTo:password withMsg:@"Konfirmasi Password harus sesuai dengan Password"];
    [userNewPassword addRegx:regex_password withMsg:@"Password minimal terdiri dari 3 karakter"];
    [name addRegx:regex_name withMsg:@"Nama tidak valid"];
    [gender addRegx:regex_gender withMsg:@"Jenis kelamin harus diisi"];
    [birthdate addRegx:regex_birthdate withMsg:@"Tanggal lahir harus diisi"];
    [phone addRegx:regex_phone withMsg:@"Nomor Telepon/HP harus terdiri dari 6-16 digit angka"];
    city.isMandatory = NO;
    for (id field in infoAccScroller.subviews) {
        if ([field isKindOfClass:[UITextView class]] || [field isKindOfClass:[UITextField class]]) {
            [self border:field];
        }
    }
    for (id field in dataAccScroller.subviews) {
        if ([field isKindOfClass:[UITextView class]] || [field isKindOfClass:[UITextField class]]) {
            [self border:field];
        }
    }
    format = [[NSDateFormatter alloc] init];
    [format setDateFormat:date_format];
    [datePicker setDate:[NSDate date]];
    [datePicker setMaximumDate:[NSDate date]];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    userName.delegate = self;
    password.delegate = self;
    userNewPassword.delegate = self;
    name.delegate = self;
    birthdate.delegate = self;
    gender.delegate = self;
    phone.delegate = self;
    city.delegate = self;
    email.delegate = self;
    [infoAccScroller setScrollEnabled:YES];
    [dataAccScroller setScrollEnabled:YES];
    cityList = [NSMutableArray array];
    genderTable.delegate = self;
    genderTable.dataSource =self;
    cityTable.delegate = self;
    cityTable.dataSource = self;
    selectedCity = -1;
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

-(void)infoAccSelected:(id)sender{
    infoAccBtn.backgroundColor = COLOR_PINK_Y2;
    dataAccBtn.backgroundColor = COLOR_GREY_Y2;
    dataAccount.hidden = YES;
    infoAccount.hidden = NO;
}

-(void)dataAccSelected:(id)sender{
    infoAccBtn.backgroundColor = COLOR_GREY_Y2;
    dataAccBtn.backgroundColor = COLOR_PINK_Y2;
    dataAccount.hidden = NO;
    infoAccount.hidden = YES;
}

- (void)populateData{
    userName.text = myProfile.username;
    name.text = myProfile.name ;
    selectedGender = [myProfile.gender intValue];
    [genderTable reloadData];
    if (selectedGender==MALE_ID) {
        gender.text = Male;
    }else if (selectedGender==FEMALE_ID) {
        gender.text = Female;
    }else{
        selectedGender = UNSELECT_GENDER;
    }
    [datePicker setDate:[NSDate date]];
    NSDate *_birthDate = [format dateFromString:myProfile.birthdate];
    if (_birthDate!=nil) {
        [datePicker setDate:_birthDate];
    }
    birthdate.text = [format stringFromDate:datePicker.date];
    phone.text = myProfile.phone;
    address.text = [allData valueForKey:@"address"];
    if (![[allData valueForKey:@"location"] isEqual:[NSNull null]]) {
        NSString* cityID = [allData valueForKey:@"location"];
        NSArray *filteredCity = [[DataSingleton instance].allCity filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", cityID]];
        if (filteredCity.count>0) {
            NSDictionary *myCity = (NSDictionary*)[filteredCity objectAtIndex:0];
            city.text = [myCity valueForKey:@"kota"];
            selectedCity =[cityList indexOfObject:[myCity valueForKey:@"kota"]];
        }
        
    }
    email.text = myProfile.email;
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self dismissLayoutIfShown];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    activeTextField = textView;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self dismissLayoutIfShown];
    
    if (textField==gender) {
        if ([address isFirstResponder]) {
            [address resignFirstResponder];
        }else if (activeTextField) {
            [activeTextField resignFirstResponder];
        }
        activeTextField = textField;
        [self animateGenderPickerIn];
        return NO;
    }else if (textField==birthdate) {
        if ([address isFirstResponder]) {
            [address resignFirstResponder];
        }else if (activeTextField) {
            [activeTextField resignFirstResponder];
        }
        activeTextField = textField;
        [self animateDatePickerIn];
        return NO;
    }else if (textField==city) {
        if ([address isFirstResponder]) {
            [address resignFirstResponder];
        }else if (activeTextField) {
            [activeTextField resignFirstResponder];
        }
        activeTextField = textField;
        [self animateCityPickerIn];
        return NO;
    }else{
        activeTextField = textField;
        return YES;
    }
}

- (void)dismissLayoutIfShown{
    if (activeTextField==gender) {
        if (genderPickerLayout.alpha==1) {
            [self animateGenderPickerOut];
        }
    }else if (activeTextField==birthdate){
        if (datepickerLayout.alpha==1) {
            [self animateDatePickerOut];
        }
    }else if (activeTextField==city){
        if (cityPickerLayout.alpha==1) {
            [self animateCityPickerOut];
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    bool disturb = false;
//    if (activeTextField==birthdate) {
//        [self datepickerDismiss:nil];
//    }else if (activeTextField==gender){
//        [self genderPickerDismiss:nil];
//    }else if (activeTextField==city){
//        [self cityPickerDismiss:nil];
//    }else{
//        if (activeTextField!=nil) {
//            NSLog(@"previous textfield: %@",activeTextField.placeholder);
//            [self setEditing:NO animated:YES];
//            disturb = true;
//        }
//    }
//    
//    if (textField==birthdate) {
//        //[self.view endEditing:YES];
//        if (!disturb) {
//            [textField resignFirstResponder];
//        }
//        
//        [self animateDatePickerIn];
//    }else if (textField==gender){
//        //[self.view endEditing:YES];
//        [genderTable reloadData];
//        if (!disturb) {
//            [textField resignFirstResponder];
//        }
//        [self animateGenderPickerIn];
//    }else if (textField==city){
//        //[self.view endEditing:YES];
//        [cityTable reloadData];
//        if (!disturb) {
//            [textField resignFirstResponder];
//        }
//        [self animateCityPickerIn];
//    }
////    else if (textField==phoneOther && !viewLiftedUp){
////        [self animateViewUp];
////    }
    activeTextField = textField;

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    return YES;
}

-(void)animateDatePickerIn{
    [saveBtn setEnabled:NO];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{datepickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {}];
}

-(void)animateDatePickerOut{
    [saveBtn setEnabled:YES];
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
    [saveBtn setEnabled:NO];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{genderPickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {
                     }];
}

-(void)animateGenderPickerOut{
    [saveBtn setEnabled:YES];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{genderPickerLayout.alpha = 0.0f;}
                     completion:^(BOOL finished) {
                         [gender validate];
                     }];
}

-(void)animateCityPickerIn{
    [saveBtn setEnabled:NO];
    [city resignFirstResponder];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{cityPickerLayout.alpha = 1.0f;}
                     completion:^(BOOL finished) {}];
}

-(void)animateCityPickerOut{
    [saveBtn setEnabled:YES];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{cityPickerLayout.alpha = 0.0f;}
                     completion:^(BOOL finished) {
                         [city validate];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)validateInfoAccount{
    
    bool valid = [name validate];
    valid &= [gender validate];
    valid &= [birthdate validate];
    valid &= [phone validate];
    valid &= [email validate];
    if (valid){
        return true;
    }else{
        validatorMessage = @"Data tidak valid";
        return false;
    }
}

-(BOOL)validateDataAccount{
    
    bool valid = [password validate];
    valid &= [userNewPassword validate];
    if (valid){
        return true;
    }else{
        validatorMessage = @"Data tidak valid";
        return false;
    }
}


- (void)updateProfile{
    myProfile.name = name.text;
    myProfile.gender = [NSNumber numberWithInt:selectedGender];
    myProfile.birthdate = [format stringFromDate:datePicker.date];
    myProfile.phone = phone.text;
    myProfile.email = email.text;
    
    [allData setValue:name.text forKey:@"first_name"];
    [allData setValue:[NSNumber numberWithInt:selectedGender] forKey:@"gender"];
    NSTimeInterval birthDateInUnix = [datePicker.date timeIntervalSince1970];
    [allData setValue:[NSString stringWithFormat:@"%f",birthDateInUnix] forKey:@"birthdate"];
    [allData setValue:phone.text forKey:@"phone"];
    [allData setValue:address.text forKey:@"address"];
    [allData setValue:city.text forKey:@"kota"];
    [allData setValue:email.text forKey:@"email"];
    
    myProfile.raw_data = [DataSingleton convertDictionaryToString:allData];
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (selectedCity!=-1) {
        NSDictionary* _selectedCity = [[DataSingleton instance].allCity objectAtIndex:selectedCity];
        NSString* cityId = [_selectedCity objectForKey:@"id"];
        [allData setValue:cityId forKey:@"location"];
    }
    
    if ([DataSingleton saveUserWithThisData:allData]) {
        [DataSingleton retrieveUser];
        myProfile = [DataSingleton instance].loggedInUser;
        [self updateProfileInServer];
    }

}

- (void)updateProfileInServer{
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
        [loading startAnimating];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,editProfileURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = edit_profile;
        [request setRequestMethod:@"POST"];
        //Following code will retain username and password for Re-login.
        [request setUsername:userName.text];
        [request setPassword:password.text];
        //[request setUseKeychainPersistence:YES];
        
        [request addPostValue:myProfile.id_user forKey:@"user_id"];
        [request addPostValue:myProfile.token forKey:@"access_token"];
        [request addPostValue:myProfile.phone forKey:@"phone"];
        [request addPostValue:myProfile.name forKey:@"name"];
        [request addPostValue:[NSString stringWithFormat:@"%d",selectedGender] forKey:@"gender"];
        [request addPostValue:address.text forKey:@"address"];
        [request addPostValue:email.text forKey:@"email"];
        
        NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        if (selectedCity!=-1) {
            NSDictionary* _selectedCity = [[DataSingleton instance].allCity objectAtIndex:selectedCity];
            NSNumber *cityID = [nf numberFromString:[_selectedCity objectForKey:@"id"]];
            
            [request addPostValue:cityID forKey:@"location"];
        }
        
        
        NSDateFormatter *format2nd = [[NSDateFormatter alloc] init];
        [format2nd setDateFormat:@"dd-MM-yyyy"];
        [request addPostValue:[format2nd stringFromDate:[datePicker date]] forKey:@"birthdate"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }

}

- (void)changePassword{
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
        [loading startAnimating];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,editPasswordURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = edit_pass;
        [request setRequestMethod:@"POST"];
        //Following code will retain username and password for Re-login.
        [request setUsername:userName.text];
        [request setPassword:password.text];
        //[request setUseKeychainPersistence:YES];
        
        [request addPostValue:userName.text forKey:@"username"];
        [request addPostValue:password.text forKey:@"old_password"];
        [request addPostValue:userNewPassword.text forKey:@"new_password"];
        [request addPostValue:myProfile.id_user forKey:@"user_id"];
        [request addPostValue:myProfile.token forKey:@"access_token"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (IBAction)saveProfile:(id)sender {
    [self dismissLayoutIfShown];
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    [address resignFirstResponder];
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    if ([self validateInfoAccount]) {
        [self updateProfile];
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

- (IBAction)updatePassword:(id)sender {
    [self dismissLayoutIfShown];
    [self.view endEditing:YES];
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    if ([self validateDataAccount]) {
        [self changePassword];
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

- (IBAction)cityPickerDismiss:(id)sender {
    [self animateCityPickerOut];
}

- (IBAction)cityPickerDone:(id)sender {
    if (selectedCity!=-1) {
        city.text = [cityList objectAtIndex:selectedCity];
    }
    [self cityPickerDismiss:sender];
}

#pragma mark - UITableView
#pragma mark - datasource

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==genderTable) {
        return 2;
    }else if (tableView==cityTable) {
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
    
    if (_tableView==genderTable) {
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
    }else if (_tableView==cityTable) {
        cell.textLabel.text = (NSString*)[cityList objectAtIndex:row];
        cell.tag = row;
        if (cell.tag==selectedCity) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (_tableView==genderTable) {
        UITableViewCell *cell = [genderTable cellForRowAtIndexPath:indexPath];
        selectedGender = cell.tag;
    }else if (_tableView==cityTable){
        UITableViewCell *cell = [cityTable cellForRowAtIndexPath:indexPath];
        selectedCity = cell.tag;
    }
    
    [_tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [loading stopAnimating];
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
    [loading stopAnimating];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case edit_profile:
            if (success) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title_success
                                                                message:@"Data profil berhasil disimpan"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }else{
                NSArray* errorMessages = (NSArray*)[jsonDictionary objectForKey:@"data"];
                NSMutableString *errorMessage = [NSMutableString string];
                for (NSString* message in errorMessages) {
                    if (errorMessage.length==0) {
                        [errorMessage appendString:message];
                    }else{
                        [errorMessage appendString:[NSString stringWithFormat:@", %@",message]];
                    }
                }
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: @"Gagal"
                             message: errorMessage
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
            }
            break;
        case edit_pass:
            if (success) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title_success
                                                                message:@"Password berhasil diubah"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }else{
                NSArray* errorMessages = (NSArray*)[jsonDictionary objectForKey:@"data"];
                NSMutableString *errorMessage = [NSMutableString string];
                for (NSString* message in errorMessages) {
                    if (errorMessage.length==0) {
                        [errorMessage appendString:message];
                    }else{
                        [errorMessage appendString:[NSString stringWithFormat:@", %@",message]];
                    }
                }
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: @"Gagal"
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

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
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
    
    infoAccScroller.contentInset = contentInsets;
    infoAccScroller.scrollIndicatorInsets = contentInsets;
    dataAccScroller.contentInset = contentInsets;
    dataAccScroller.scrollIndicatorInsets = contentInsets;
    
    
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
        if(activeTextField != userNewPassword && activeTextField != userName){
            [self.infoAccScroller scrollRectToVisible:activeTextField.frame animated:YES];
        } else{
            [self.dataAccScroller scrollRectToVisible:activeTextField.frame animated:YES];
        }
    }
    
}



// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    if(activeTextField != userNewPassword && activeTextField != userName){
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        
        infoAccScroller.contentInset = contentInsets;
        
        infoAccScroller.scrollIndicatorInsets = contentInsets;
    }
    
}

@end
