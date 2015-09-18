//
//  WishListViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/24/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "WishListViewController.h"
#import "DataSingleton.h"
#import "DescriptionViewController.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WishListViewController ()

@end

@implementation WishListViewController
@synthesize collItem, viewColl, viewEmpty;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
        
        itemWish = [[NSMutableArray alloc] initWithObjects:@"bawahan0.jpg", nil];
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35,0,widthContentView-30,self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"Wishlist";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:titleLabel];
    
    self.searchBarRef = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
    self.searchBarRef.alpha=0;
    self.searchBarRef.transform = CGAffineTransformMakeScale(0,0);
    [self.searchBarRef setBackgroundColor:[UIColor clearColor]];
    self.searchBarRef.barTintColor=[UIColor clearColor];
    
    [contentView addSubview:self.searchBarRef];
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = self.searchBarRef;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].wishBarButtonItem, [DataSingleton instance].shopBarButtonItem, [DataSingleton instance].searchBarProductRetail, nil];
    [DataSingleton enableWishlistButton:false];
}

-(void)viewDidDisappear:(BOOL)animated{
    [DataSingleton enableWishlistButton:true];
    
    [super viewDidDisappear:animated];
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    if (parent==nil) {
        //back button is pressed
        [DataSingleton instance].wishCartStack = [NSNumber numberWithInt:[[DataSingleton instance].wishCartStack intValue]-1];
        if ([[DataSingleton instance].wishCartStack intValue]<0) {
            [DataSingleton instance].wishCartStack = [NSNumber numberWithInt:0];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [collItem registerNib:[UINib nibWithNibName:@"ItemCollection" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ItemCollection"];
    isEmpty = [[DataSingleton instance].userWishList.items count]==0;
    if (isEmpty) {
        viewEmpty.hidden = false;
        viewColl.hidden = true;
    }
    else
    {
        viewEmpty.hidden = true;
        viewColl.hidden = false;
        NSMutableArray *sorter = [[NSMutableArray alloc]initWithArray:[DataSingleton instance].userWishList.items];
        
        [DataSingleton instance].userWishList.items = [NSMutableArray arrayWithArray:[sorter sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            Product* first = a;
            Product* second = b;
            if ([first.ID intValue] < [second.ID intValue]) {
                return NSOrderedAscending;
            }else if ([first.ID intValue] > [second.ID intValue]){
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
        }]];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[DataSingleton instance].userWishList.items count];
}

- (ItemCollection *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)[indexPath row];
    Product* _product = [[DataSingleton instance].userWishList.items objectAtIndex:row];
    ItemCollection *itemWishColl = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCollection" forIndexPath:indexPath];
    
    if (_product.image != nil) {
        [itemWishColl.image setImageWithURL:[NSURL URLWithString:_product.image] placeholderImage:nil];
    }
    itemWishColl.name.text = _product.name;
    itemWishColl.shopName.text = @"toko 1";
    int price = [_product.price intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    itemWishColl.price.text = [NSString stringWithFormat:@"Rp %@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    itemWishColl.deleteButton.tag = row;
    [itemWishColl.deleteButton addTarget:self action:@selector(deleteItemAtIndex:) forControlEvents:UIControlEventTouchUpInside];
    
    return itemWishColl;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)[indexPath row];
    Product* _product = [[DataSingleton instance].userWishList.items objectAtIndex:row];
    NSDictionary* productData = _product.completeData;
    DescriptionViewController *descriptionPage = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
    descriptionPage.indexProduct = 0;
    descriptionPage.products = [NSMutableArray arrayWithObjects:productData, nil];
    descriptionPage.productToDisplay = productData;
    //find out logged in as other store owner / agent / subagent
    M_Wishlist* data = [DataSingleton getWishDataAboutThisProduct:_product];
    descriptionPage.isRetail = ![data.is_grosir boolValue];
    descriptionPage.type = CART_CATEGORY;
    [descriptionPage setMainPagerIndex:0];
    
    [self.navigationController pushViewController:descriptionPage animated:YES];
}

-(void)deleteItemAtIndex:(id)sender{
    int index = (int)((UIButton*)sender).tag;
    if ([DataSingleton deleteWishListOnIndex:index]) {
        isEmpty = [[DataSingleton instance].userWishList.items count]==0;
        if (isEmpty) {
            viewEmpty.hidden = false;
            viewColl.hidden = true;
        }
        else
        {
            [self.collItem reloadData];
        }
        
    }
}

-(void)toggleSearch:(id)sender {
    if(self.searchBarRef.alpha==0) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.searchBarRef.alpha = 1.0;
                             self.searchBarRef.transform = CGAffineTransformIdentity;
                         }];
        
    }else {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.searchBarRef.alpha = 0.0;
                             self.searchBarRef.transform = CGAffineTransformMakeScale(0,0);
                         }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
