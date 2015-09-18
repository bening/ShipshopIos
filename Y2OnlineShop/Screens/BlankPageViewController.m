//
//  BlankPageViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/8/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "BlankPageViewController.h"
#import "Constants.h"

@interface BlankPageViewController ()

@end

@implementation BlankPageViewController
@synthesize blankImage, imageNamed;

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
    titleLabel.text = @"Have an account?";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    //self.navigationItem.titleView = contentView;
    blankImage.image = [UIImage imageNamed:imageNamed];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
