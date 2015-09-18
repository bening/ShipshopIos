//
//  ChatCustomerServiceViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/20/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "ChatCustomerServiceViewController.h"
#import "Constants.h"

@interface ChatCustomerServiceViewController ()

@end

@implementation ChatCustomerServiceViewController
@synthesize chatBox;

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
    titleLabel.text = @"Chat Customer Service";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.navigationItem.titleView = contentView;
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if ([chatBox isFirstResponder]) {
        NSLog(@"first responder");
        [self animateViewUp];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateViewUp];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self sendChat:nil];
    return YES;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendChat:(id)sender {
    if (chatBox.text.length>0) {
        //send chat
    }
}
@end
