//
//  MainVC.m
//  testProject
//
//  Created by artur on 2/14/14.
//  Copyright (c) 2014 artur. All rights reserved.
//

#import "MainVC.h"
#import "LeftMenuTVC.h"

@interface MainVC ()

@end

@implementation MainVC


- (void)viewDidLoad
{
    
    /*******************************
     *     Initializing menus
     *******************************/
    self.leftMenu = [[LeftMenuTVC alloc] initWithNibName:@"LeftMenuTVC" bundle:nil];
    /*******************************
     *     End Initializing menus
     *******************************/
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

#pragma mark - Overriding methods
- (void)configureLeftMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){40,40};
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"icon-menu-transparent.png"] forState:UIControlStateNormal];
    
}

- (CGFloat)leftMenuWidth
{
    return 250;
}

@end
