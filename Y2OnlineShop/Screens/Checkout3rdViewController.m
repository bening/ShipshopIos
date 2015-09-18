//
//  Checkout3rdViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/29/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Checkout3rdViewController.h"
#import "Constants.h"
#import "Checkout2ndViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"

@interface Checkout3rdViewController ()

@end

@implementation Checkout3rdViewController
@synthesize thanksText,messageText,messageBox,backToHomeBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.hidesBackButton = true;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeComponent];
}

- (void)initializeComponent{
    thanksText.font = FONT_ARSENAL(27);
    messageText.font = FONT_ARSENAL(13);
    messageBox.layer.borderColor = [UIColor blackColor].CGColor;
    messageBox.layer.borderWidth = 3.0f;
    backToHomeBtn.titleLabel.font = FONT_ARSENAL(20);
    backToHomeBtn.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToHome:(id)sender {
    //[self.navigationController popToViewController:[HomeViewController getCurrentInstance] animated:YES];
    UIViewController *vc = [[self.navigationController viewControllers] firstObject];
    if (![vc isEqual:[HomeViewController getCurrentInstance]]) {
        NSMutableArray* viewControllers = [self.navigationController.viewControllers mutableCopy];
        [viewControllers insertObject:[HomeViewController getCurrentInstance] atIndex:0];
        self.navigationController.viewControllers = viewControllers;
    }
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}
@end
