//
//  PostingQuestionViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/20/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "PostingQuestionViewController.h"
#import "Constants.h"

@interface PostingQuestionViewController ()

@end

@implementation PostingQuestionViewController
@synthesize nameTextfield,noTelpTextfield,emailTextfield,questionTextfield;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        widthContentView = 175;
        
        if (IS_IPAD) {
            widthContentView = widthContentView+25;
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35,0,widthContentView,self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"Kirim Pertanyaan";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.navigationItem.titleView = contentView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg-cs.PNG"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(IBAction)sendButton:(id)sender
{
    [self.view endEditing:YES];
    if (viewLiftedUp) {
        [self animateViewDown];
    }
    if ((self.nameTextfield.text.length > 0) && (self.noTelpTextfield.text.length > 0) && (self.emailTextfield.text.length > 0) && (self.questionTextfield.text.length > 0))
    {
        if([self validateEmail:[self.emailTextfield text]])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sukses"
                                                            message:@"Pertanyaan berhasil dikirim"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            // user entered invalid email address
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Peringatan" message:@"Alamat email tidak valid" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Peringatan"
                                                        message:@"Semua form harus terisi"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)validateEmail:(NSString *)emailStr
{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==questionTextfield) {
        [self animateViewUp];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)animateViewUp{
    int liftUp = 80;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 0;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 120;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 90;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 165;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 45;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 45;
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
            liftDown = 45;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftDown = 45;
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

@end
