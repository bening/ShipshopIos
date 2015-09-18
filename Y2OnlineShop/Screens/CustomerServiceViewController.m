//
//  CustomerServiceViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/20/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "CustomerServiceViewController.h"

@interface CustomerServiceViewController ()

@end

@implementation CustomerServiceViewController

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
    titleLabel.text = @"Customer Service";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.navigationItem.titleView = contentView;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [[UIImage imageNamed:@"bg-cs.PNG"] drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
}

-(IBAction)postingQuestion:(id)sender
{
    PostingQuestionViewController *postingQuestionViewController = [[PostingQuestionViewController alloc] initWithNibName:@"PostingQuestionViewController" bundle:nil];
    [self.navigationController pushViewController:postingQuestionViewController animated:YES];

}

-(IBAction)chatCustomerService:(id)sender
{
    ChatCustomerServiceViewController *chatCustomerServiceViewController = [[ChatCustomerServiceViewController alloc] initWithNibName:@"ChatCustomerServiceViewController" bundle:nil];
    [self.navigationController pushViewController:chatCustomerServiceViewController animated:YES];
}

-(IBAction)retur:(id)sender
{
    ReturViewController *returViewController = [[ReturViewController alloc] initWithNibName:@"ReturViewController" bundle:nil];
    [self.navigationController pushViewController:returViewController animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
