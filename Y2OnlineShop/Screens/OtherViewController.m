//
//  OtherViewController.m
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "OtherViewController.h"

@interface OtherViewController ()

@end

@implementation OtherViewController

@synthesize textFaq;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.title = NSLocalizedString(@"FAQ", @"FAQ");
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
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,170,self.navigationController.navigationBar.frame.size.height)];
    
    UIImageView *imageLogo = [[UIImageView alloc]
                              initWithFrame:CGRectMake(0,0,3,44)];
    imageLogo.contentMode = UIViewContentModeLeft;
    imageLogo.clipsToBounds = NO;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [contentView addSubview:imageLogo];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35,0,140,self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"FAQ";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.navigationItem.titleView = contentView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    textFaq.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam efficitur, nisi sed vehicula ultrices, urna elit aliquam augue, sit amet ornare leo massa nec nisl. Duis gravida fringilla porttitor. Maecenas facilisis consectetur ipsum vel egestas. Nullam turpis arcu, lacinia eu lobortis tincidunt, fermentum eget orci. Aliquam vel neque sem. Vestibulum volutpat diam tristique facilisis interdum. Curabitur pellentesque mauris quis varius viverra. Donec lobortis dui aliquet molestie gravida. In convallis, augue sit amet auctor sodales, diam mi condimentum lectus, at congue felis mauris faucibus nisl. Integer placerat pulvinar ante, vel tincidunt nisl venenatis nec. Donec id turpis libero. Praesent viverra libero et quam posuere, at finibus nulla tempus. Nam fermentum in purus vel luctus. Nullam interdum orci urna, aliquet tristique turpis porttitor et. Aenean tempor orci enim, non convallis tortor lobortis id.";
}

-(void)searchAction
{
    NSLog(@"search button clicked");
}

-(void)shopAction
{
    NSLog(@"shop button clicked");
    CartViewController *cartViewController = [[CartViewController alloc] initWithNibName:@"CartViewController" bundle:nil];
    [self.navigationController pushViewController:cartViewController animated:YES];
}

-(void)wishListAction
{
    NSLog(@"wish list button clicked");
    WishListViewController *wishListViewController = [[WishListViewController alloc] initWithNibName:@"WishListViewController" bundle:nil];
    [self.navigationController pushViewController:wishListViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
