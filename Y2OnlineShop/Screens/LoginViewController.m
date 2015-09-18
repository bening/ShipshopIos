//
//  LoginViewController.m
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/4/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "Manager.h"
#import "LeftMenuTVC.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Constants.h"
#import "M_User.h"
#import "DataSingleton.h"
#import "ForgotPasswordViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize leftMenuReference,loginBtn,password,username,loading,loadingWrapper,loadingOverlay,scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.title = NSLocalizedString(@"Login", @"Login");
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
    titleLabel.text = loginMenu;
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    if (IS_IPAD) {
//        self.scrollView.contentSize = CGSizeMake(1024, 470);
//        [self.scrollView setScrollEnabled:YES];
//    }
//    else
//    {
//        self.scrollView.contentSize = CGSizeMake(320, 670);
//        [self.scrollView setScrollEnabled:YES];
//    }
    
    [username setReturnKeyType:UIReturnKeyDone];
    [username setDelegate:self];
    [password setReturnKeyType:UIReturnKeyDone];
    [password setDelegate:self];
    loadingWrapper.layer.cornerRadius = 10.0f;
    UIImageView *usernameIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_username.png"]];
    UIImageView *passwordIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_password.png"]];
    usernameIcon.contentMode = UIViewContentModeScaleAspectFit;
    passwordIcon.contentMode = UIViewContentModeScaleAspectFit;
    [usernameIcon setFrame:CGRectMake(0, 0, CGRectGetHeight(username.frame), CGRectGetHeight(username.frame))];
    [passwordIcon setFrame:CGRectMake(0, 0, CGRectGetHeight(password.frame), CGRectGetHeight(password.frame))];
    [username useRightView:usernameIcon];
    [password useRightView:passwordIcon];
    userNameTyped = false;
    passwordTyped = false;
    loginBtn.enabled = false;
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    [self registerForKeyboardNotifications];
}

-(void)animateViewUp{
    int liftUp = 80;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 30;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 73;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 75;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 70;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 30;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 30;
        }
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame; frame.origin.y = -1*liftUp;
    [self.view setFrame:frame]; [UIView commitAnimations];
    viewLiftedUp =true;  
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
}

-(void)animateViewDown{
    int liftDown = 45;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftDown = 43;
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
//    if (IS_IPAD) {
//        if (textField==password) {
//            [self animateViewUp];
//        }
//    }else{
//        //animateViewUp for every textfield
//        [self animateViewUp];
//    }
}

-(void)keyboardWillHide:(NSNotification *)notification {
    //chenge the view back to its original position
//    if (viewLiftedUp) {
//        [self animateViewDown];
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)buttonLoginTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    [self processLogin];
}

- (IBAction)userNameChanged:(id)sender {
    userNameTyped=((UITextField*)sender).text.length>0;
    if (userNameTyped&&passwordTyped) {
        loginBtn.enabled = true;
    }else{
        loginBtn.enabled = false;
    }
}

- (IBAction)passwordChanged:(id)sender {
    passwordTyped=((UITextField*)sender).text.length>0;
    if (userNameTyped&&passwordTyped) {
        loginBtn.enabled = true;
    }else{
        loginBtn.enabled = false;
    }
}

- (IBAction)forgotPassword:(id)sender {
    ForgotPasswordViewController *forgotPassPage = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forgotPassPage animated:YES];
}

- (void)processLogin
{
    loginBtn.enabled = false;
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
        loginBtn.enabled = true;
    }else
    {
        [self shallShowLoadingOverlay:YES];
        NSString * _loginURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,loginURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_loginURL]];
        
        [request setRequestMethod:@"POST"];
        //Following code will retain username and password for Re-login.
        [request setUsername:username.text];
        [request setPassword:password.text];
        //[request setUseKeychainPersistence:YES];
        
        [request addPostValue:username.text forKey:@"username"];
        [request addPostValue:password.text forKey:@"password"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    loginBtn.enabled = true;
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
    loginBtn.enabled = true;
    NSLog(@"finished");
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (success) {
        //login successfull
        NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
        NSDictionary* data = (NSDictionary *)[jsonDictionary objectForKey:@"data"];
        NSDictionary* user = (NSDictionary*)[data objectForKey:@"user"];
        NSNumber*_gender = [nf numberFromString:[user objectForKey:@"gender"]];
        if (_gender==nil) {
            _gender = [NSNumber numberWithInt:0];
        }
        NSEnumerator *enumerator = [user keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            if ([(NSString*)key isEqualToString:@"gender"]) {
                [userData setValue:_gender forKey:@"gender"];
            }else{
                [userData setValue:[user objectForKey:key] forKey:key];
            }
        }
        [userData setValue:[data objectForKey:@"token"] forKey:@"token"];
        
        if ([DataSingleton saveUserWithThisData:userData]) {
            /*register for device token if login successfull*/
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            /**
             Your app can find out which types of push notifications are enabled through:
             UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
             */
            if ([data objectForKey:@"menu_tree"]!=nil) {
                [DataSingleton setUserMenuTree:(NSArray *)[data objectForKey:@"menu_tree"]];
            }
            
            if ([data objectForKey:@"seller_ids"]!=nil) {
                [DataSingleton instance].userSellerIDs = [NSArray arrayWithArray:[data objectForKey:@"seller_ids"]];
            }
            
            [DataSingleton insertAllFreeCartToLoggedInUser];
            [DataSingleton instance].isLogin = true;
            [leftMenuReference fetchData:NO];
        }else{
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: @"Terdapat kesalahan dalam menyimpan data"
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(IS_IPAD){
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
           [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            aRect.size.height -= kbSize.width;
        } else{
            aRect.size.height -= kbSize.height;
        }
    } else{
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            // code for landscape orientation
            aRect.size.height -= kbSize.width;
        } else{
            aRect.size.height -= kbSize.height;
        }
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
