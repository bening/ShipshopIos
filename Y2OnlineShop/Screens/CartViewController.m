//
//  CartViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/25/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "CartViewController.h"
#import "DataSingleton.h"
#import "Constants.h"
#import "DescriptionViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CartItemCell.h"
#import "Checkout1stViewController.h"
#import "DXPopover.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "UIButton+CustomData.h"
#define product_data_id @"prd_data_id"
#define product_data_prd_id @"prd_data_prd_id"
#define product_data_prd_qty @"prd_data_prd_qty"
#define index_key @"indexpath"
#define delete_item 3

static NSString * const CartCellIdentifier = @"CartCell";

@interface CartViewController ()

@end

@implementation CartViewController

@synthesize viewColl,viewEmpty,totalPrice,cartTable,popover,popoverView,quantityInc,quantityDec,quantityBox,quantityDone,loading,cartInfoWrapper,nextBtn,isRetail,searchBarGrosir,searchBarRetail,loadingWrapper,loadingOverlay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        isEmpty = true;
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
        
        itemCart = [[NSMutableArray alloc] initWithObjects:@"bawahan0.jpg", nil];
        _total = 0;
        
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
    titleLabel.text = @"Tas Belanja";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    searchBarRetail = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(contentView.frame),CGRectGetHeight(contentView.frame))];
    searchBarRetail.alpha=0;
    searchBarRetail.transform = CGAffineTransformMakeScale(0,0);
    [searchBarRetail setBackgroundColor:[UIColor clearColor]];
    searchBarRetail.barTintColor=[UIColor clearColor];
    searchBarRetail.placeholder = @"Cari Produk Retail...";
    searchBarRetail.delegate= [DataSingleton instance];
    searchBarRetail.tag = search_bar_retail;
    
    searchBarGrosir = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(contentView.frame),CGRectGetHeight(contentView.frame))];
    searchBarGrosir.alpha=0;
    searchBarGrosir.transform = CGAffineTransformMakeScale(0,0);
    [searchBarGrosir setBackgroundColor:[UIColor clearColor]];
    searchBarGrosir.barTintColor=[UIColor clearColor];
    searchBarGrosir.placeholder = @"Cari Produk Grosir...";
    searchBarGrosir.delegate= [DataSingleton instance];
    searchBarGrosir.tag = search_bar_grosir;
    
    searchBarRetail.translatesAutoresizingMaskIntoConstraints = NO;
    searchBarGrosir.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:searchBarRetail];
    [contentView addSubview:searchBarGrosir];
    
    float spaceLeftLogoToSuperview = 0.0;
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(contentView,titleLabel,imageLogo,searchBarRetail,searchBarGrosir);
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
    
    //constraint for searchBar in order to extend its width to the fullest width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarRetail]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarGrosir]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    //constraint for searchBar in order to extend its height to the height width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarRetail]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarGrosir]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = searchBarRetail;
    [DataSingleton instance].searchBarGrosir = searchBarGrosir;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].wishBarButtonItem, [DataSingleton instance].shopBarButtonItem, [DataSingleton instance].searchBarProductRetail,[DataSingleton instance].searchBarProductGrosir, nil];
    [DataSingleton enableCartButton:NO];
    
    [self refreshCart];
}

-(void)viewDidDisappear:(BOOL)animated{
    [DataSingleton enableCartButton:true];
    
    [super viewDidDisappear:animated];
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    if (parent==nil) {
        //back button is pressed
        [self decreaseTheStack];
    }
}

-(void)decreaseTheStack{
    [DataSingleton instance].wishCartStack = [NSNumber numberWithInt:[[DataSingleton instance].wishCartStack intValue]-1];
    if ([[DataSingleton instance].wishCartStack intValue]<0) {
        [DataSingleton instance].wishCartStack = [NSNumber numberWithInt:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [cartTable setDelegate:self];
    [cartTable setDataSource:self];
    [cartTable registerNib:[UINib nibWithNibName:@"CartItemCell" bundle:nil] forCellReuseIdentifier:CartCellIdentifier];
    cartTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cartTable.bounds.size.width, 0.01f)];
    cartTable.layer.borderWidth = 2.0;
    cartTable.layer.borderColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1].CGColor;
    popover = [DXPopover new];
    isEmpty = [[DataSingleton instance].usedCart.items count]==0;
    [quantityBox addRegx:regex_value withMsg:@"harap diisi hanya dengan angka"];
    quantityBox.delegate = self;
    quantityDone.titleLabel.font = FONT_ARSENAL(15);
    for (id subview in popoverView.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            ((UITextField*)subview).layer.cornerRadius=5.0f;
        }else if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton*)subview).layer.cornerRadius=5.0f;
        }
    }
    loadingWrapper.layer.cornerRadius = 10.0f;
    cartInfoWrapper.hidden = YES;
    nextBtn.hidden = YES;
    if (isEmpty) {
        viewEmpty.hidden = false;
        viewColl.hidden = true;
    }
    else
    {
        viewEmpty.hidden = true;
        viewColl.hidden = false;
        //[self initializeTableData];
        
        _total = [[DataSingleton instance].usedCart.totalPrice intValue];
        double total = (_total/1000.0);
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        totalPrice.text = [NSString stringWithFormat:@"Rp %@",
                           [commas stringFromNumber:[NSNumber numberWithDouble:total * 1000]]];
    }
}

- (void)initializeTableData{
    NSMutableArray *sorter = [[NSMutableArray alloc]initWithArray:[DataSingleton instance].usedCart.items];
    groupOfProducts = [NSMutableArray array];
    NSArray* sorted = [NSArray arrayWithArray:[sorter sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber* ownerID1 = [(NSDictionary*)a valueForKey:ownerIDKey];
        NSNumber* ownerID2 = [(NSDictionary*)b valueForKey:ownerIDKey];
        if ([ownerID1 intValue] < [ownerID2 intValue]) {
            return NSOrderedAscending;
        }else if ([ownerID1 intValue] > [ownerID2 intValue]){
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }]];
    
    NSArray *groupOfOwners = [sorted valueForKeyPath:@"@distinctUnionOfObjects.cart_owner"];
    NSArray* groupOfOwnerSorted = [NSArray arrayWithArray:[groupOfOwners sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber* ownerID1 = a;
        NSNumber* ownerID2 = b;
        if ([ownerID1 intValue] < [ownerID2 intValue]) {
            return NSOrderedAscending;
        }else if ([ownerID1 intValue] > [ownerID2 intValue]){
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }]];
    
    for (NSNumber* ownerID in groupOfOwnerSorted) {
        //sorted is items of cart.items
        NSMutableArray *productsInSameOwner = [NSMutableArray arrayWithArray:[sorted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"cart_owner = %@", ownerID]]];
        [groupOfProducts addObject:productsInSameOwner];
        
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 15, sectionHeaderView.frame.size.width, 25.0)];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerYConstraint =
    [NSLayoutConstraint constraintWithItem:headerLabel
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:sectionHeaderView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0.0];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:headerLabel
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:sectionHeaderView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:20.f];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [headerLabel setFont:FONT_ARSENAL_BOLD(IS_IPAD ? 20 : 15)];
    [sectionHeaderView addSubview:headerLabel];
    [sectionHeaderView addConstraint:centerYConstraint];
    [sectionHeaderView addConstraint:leading];
    
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSDictionary *productData = [[NSDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:0]];
    //NSDictionary *productData = [[NSDictionary alloc]initWithDictionary:[[DataSingleton instance].usedCart.items objectAtIndex:row]];
    NSString* ownerName = [productData valueForKey:ownerNameKey];
    headerLabel.text = ownerName;
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return IS_IPAD ? 50.0f : 40.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    int total = 0;
    for (NSDictionary* productData in oneOwnerProduct) {
        Product* _product = [productData valueForKey:productKey];
        NSNumber* _quantity = [productData valueForKey:quantityKey];
        NSNumber *subTotal = [NSNumber numberWithInt:[_quantity intValue]*[_product.price intValue]];
        total += [subTotal intValue];
    }
    
    UIView *sectionFooterView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
    sectionFooterView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    
    UIView* labelWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionFooterView.frame.size.width, 25.0)];
    labelWrapper.backgroundColor = [UIColor clearColor];
    labelWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 15, 150.0, 25.0)];
    leftLabel.numberOfLines = 0;
    leftLabel.lineBreakMode = NSLineBreakByWordWrapping;
    leftLabel.textAlignment = NSTextAlignmentLeft;
    [leftLabel setFont:FONT_ARSENAL_BOLD(IS_IPAD ? 20 : 15)];
    
    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerYConstraintLeft =
    [NSLayoutConstraint constraintWithItem:leftLabel
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:labelWrapper
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0.0];
    NSLayoutConstraint *leadingLeft = [NSLayoutConstraint
                                   constraintWithItem:leftLabel
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:labelWrapper
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:20.f];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(15, 15, 150.0, 25.0)];
    rightLabel.numberOfLines = 0;
    rightLabel.lineBreakMode = NSLineBreakByWordWrapping;
    rightLabel.textAlignment = NSTextAlignmentRight;
    [rightLabel setFont:FONT_ARSENAL_BOLD(IS_IPAD ? 20 : 15)];
    
    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerYConstraintRight =
    [NSLayoutConstraint constraintWithItem:rightLabel
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:labelWrapper
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0.0];
    NSLayoutConstraint *leadingRight = [NSLayoutConstraint
                                       constraintWithItem:rightLabel
                                       attribute:NSLayoutAttributeTrailing
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:labelWrapper
                                       attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0f
                                       constant:-20.f];
    
    
    NSLayoutConstraint *top = [NSLayoutConstraint
                                    constraintWithItem:labelWrapper
                                    attribute:NSLayoutAttributeTop
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:sectionFooterView
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                    constant:0.f];

    NSLayoutConstraint *labelWrapperLeading = [NSLayoutConstraint
                                        constraintWithItem:labelWrapper
                                        attribute:NSLayoutAttributeLeading
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:sectionFooterView
                                        attribute:NSLayoutAttributeLeading
                                        multiplier:1.0f
                                        constant:0.f];
    NSLayoutConstraint *labelWrapperTrailing = [NSLayoutConstraint
                                               constraintWithItem:labelWrapper
                                               attribute:NSLayoutAttributeTrailing
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:sectionFooterView
                                               attribute:NSLayoutAttributeTrailing
                                               multiplier:1.0f
                                               constant:0.f];
    
    NSLayoutConstraint *labelWrapperHeight = [NSLayoutConstraint constraintWithItem:labelWrapper attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1  constant:50.0];
    
    UIButton* checkOutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50.0, sectionFooterView.frame.size.width, 50)];
    [checkOutButton setTitle:@"Bayar" forState:UIControlStateNormal];
    checkOutButton.titleLabel.font = FONT_ARSENAL_BOLD(18);
    checkOutButton.titleLabel.textColor = [UIColor whiteColor];
    checkOutButton.backgroundColor = [UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1];
    
    checkOutButton.tag = section;
    [checkOutButton setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:total],cartExpenseKey, nil]];
    [checkOutButton addTarget:self
                       action:@selector(checkOutItems:)
             forControlEvents:UIControlEventTouchUpInside];
    
    checkOutButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *checkoutBtntop = [NSLayoutConstraint
                               constraintWithItem:checkOutButton
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:labelWrapper
                               attribute:NSLayoutAttributeBottom
                               multiplier:1.0f
                               constant:0.f];
    
    NSLayoutConstraint *checkoutBtnLeading = [NSLayoutConstraint
                                               constraintWithItem:checkOutButton
                                               attribute:NSLayoutAttributeLeading
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:sectionFooterView
                                               attribute:NSLayoutAttributeLeading
                                               multiplier:1.0f
                                               constant:0.f];
    NSLayoutConstraint *checkoutBtnTrailing = [NSLayoutConstraint
                                                constraintWithItem:checkOutButton
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:sectionFooterView
                                                attribute:NSLayoutAttributeTrailing
                                                multiplier:1.0f
                                                constant:0.f];
    
    NSLayoutConstraint *checkoutBtnHeight = [NSLayoutConstraint constraintWithItem:checkOutButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1  constant:50.0];
    
    [labelWrapper addSubview:leftLabel];
    [labelWrapper addSubview:rightLabel];
    
    [labelWrapper addConstraint:centerYConstraintLeft];
    [labelWrapper addConstraint:leadingLeft];
    [labelWrapper addConstraint:centerYConstraintRight];
    [labelWrapper addConstraint:leadingRight];
    
    [sectionFooterView addSubview:labelWrapper];
    [sectionFooterView addSubview:checkOutButton];
    [sectionFooterView addConstraint:top];
    [sectionFooterView addConstraint:labelWrapperLeading];
    [sectionFooterView addConstraint:labelWrapperTrailing];
    [sectionFooterView addConstraint:labelWrapperHeight];
    [sectionFooterView addConstraint:checkoutBtntop];
    [sectionFooterView addConstraint:checkoutBtnLeading];
    [sectionFooterView addConstraint:checkoutBtnTrailing];
    [sectionFooterView addConstraint:checkoutBtnHeight];
    
    leftLabel.text = @"Total Pesanan";
    double totalPricePerSection = (total/1000.0);
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    rightLabel.text = [NSString stringWithFormat:@"Rp %@",
                       [commas stringFromNumber:[NSNumber numberWithDouble:totalPricePerSection * 1000]]];
    
    return sectionFooterView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [groupOfProducts count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray* oneOwnerProducts = groupOfProducts[section];
    return [oneOwnerProducts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CartItemCell *cell = (CartItemCell*)[tableView dequeueReusableCellWithIdentifier:CartCellIdentifier forIndexPath:indexPath];
    int row = (int)[indexPath row];
    int section = (int)[indexPath section];
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSDictionary *productData = [[NSDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:row]];
    Product* _product = [productData valueForKey:productKey];
    NSNumber *quantity = [productData valueForKey:quantityKey];
    NSDictionary* productRawData = _product.completeData;
    BOOL isGrosirProduct = [(NSNumber*)[productRawData valueForKey:@"is_grosir"] boolValue];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = row;
    if (_product.image != nil) {
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = cell.productImg.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* thisImage = cell.productImg;
        [thisImage setImageWithURL:[NSURL URLWithString:_product.image] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     thisImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for product");
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
         }];
        [thisImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
    cell.productOwner.text = [productRawData valueForKey:@"brand_name"];
    cell.productName.text = _product.name;
    int price = [_product.price intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    cell.productPrice.text = [NSString stringWithFormat:@"Rp %@",
                               [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    cell.productQty.text = [quantity stringValue];
    double _totalPrice = incomeValue*[quantity intValue];
    cell.productTotalPrice.text = [NSString stringWithFormat:@"Rp %@",
                                   [commas stringFromNumber:[NSNumber numberWithDouble:_totalPrice * 1000]]];
    if (isGrosirProduct) {
        cell.productDetail.text = @"";
    }else{
        NSMutableArray* retailVariantInfo = [NSMutableArray arrayWithArray:(NSArray*)[productRawData valueForKey:product_option_complete_key]];
        NSMutableString* detailString = [NSMutableString string];
        for (NSDictionary* retailVariantInfoData in retailVariantInfo) {
            if (detailString.length>0) {
                [detailString appendString:@"\n"];
            }
            [detailString appendString:[NSString stringWithFormat:@"%@: %@",[retailVariantInfoData valueForKey:@"opt_name"],[retailVariantInfoData valueForKey:@"opt_val_name"]]];
        }
        cell.productDetail.text = detailString;
    }
    cell.deleteBtn.tag = row;
    cell.editBtn.tag = row;
    [cell.deleteBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:indexPath,index_key, nil]];
    [cell.editBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:indexPath,index_key, nil]];
    [cell.deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editBtn addTarget:self action:@selector(editItemAtIndex:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 191;
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CartItemCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [cartTable dequeueReusableCellWithIdentifier:CartCellIdentifier];
    });
    
    int row = (int)[indexPath row];
    int section = (int)[indexPath section];
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSDictionary *productData = [[NSDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:row]];
    Product* _product = [productData valueForKey:productKey];
    NSNumber *quantity = [productData valueForKey:quantityKey];
    NSDictionary* productRawData = _product.completeData;
    BOOL isGrosirProduct = [(NSNumber*)[productRawData valueForKey:@"is_grosir"] boolValue];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = row;
    if (_product.image != nil) {
        //[sizingCell.productImg setImageWithURL:[NSURL URLWithString:_product.image] placeholderImage:nil];
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = sizingCell.productImg.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* thisImage = sizingCell.productImg;
        [thisImage setImageWithURL:[NSURL URLWithString:_product.image] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     thisImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for product");
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
         }];
        [thisImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
    sizingCell.productOwner.text = [productRawData valueForKey:@"brand_name"];
    sizingCell.productName.text = _product.name;
    int price = [_product.price intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    sizingCell.productPrice.text = [NSString stringWithFormat:@"Rp %@",
                              [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    sizingCell.productQty.text = [quantity stringValue];
    double _totalPrice = incomeValue*[quantity intValue];
    sizingCell.productTotalPrice.text = [NSString stringWithFormat:@"Rp %@",
                                   [commas stringFromNumber:[NSNumber numberWithDouble:_totalPrice * 1000]]];
    if (isGrosirProduct) {
        sizingCell.productDetail.text = @"";
    }else{
        NSMutableArray* retailVariantInfo = [NSMutableArray arrayWithArray:(NSArray*)[productRawData valueForKey:product_option_complete_key]];
        NSMutableString* detailString = [NSMutableString string];
        for (NSDictionary* retailVariantInfoData in retailVariantInfo) {
            if (detailString.length>0) {
                [detailString appendString:@"\n"];
            }
            [detailString appendString:[NSString stringWithFormat:@"%@: %@",[retailVariantInfoData valueForKey:@"opt_name"],[retailVariantInfoData valueForKey:@"opt_val_name"]]];
        }
        sizingCell.productDetail.text = detailString;
    }
    sizingCell.deleteBtn.tag = row;
    sizingCell.editBtn.tag = row;
    [sizingCell.deleteBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:indexPath,index_key, nil]];
    [sizingCell.editBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:indexPath,index_key, nil]];
    [sizingCell.deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [sizingCell.editBtn addTarget:self action:@selector(editItemAtIndex:) forControlEvents:UIControlEventTouchUpInside];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(cartTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    int row = (int)[indexPath row];
    int section = (int)[indexPath section];
    
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSMutableDictionary *selectedCartItem = [[NSMutableDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:row]];
    Product* selectedProduct = [selectedCartItem valueForKey:productKey];
    NSDictionary* productRawData = selectedProduct.completeData;
    BOOL  isGrosirProduct = [(NSNumber*)[productRawData valueForKey:@"is_grosir"] boolValue];
    int cartItemIndex = -1;
    if (isGrosirProduct) {
        cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:selectedProduct];
    }else{
        cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:selectedProduct andOption:[productRawData valueForKey:product_option_key]];
    }
    
    NSDictionary* productData = selectedProduct.completeData;
    DescriptionViewController *descriptionPage = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
    descriptionPage.indexProduct = 0;
    descriptionPage.products = [NSMutableArray arrayWithObjects:productData, nil];
    descriptionPage.productToDisplay = productData;
    if (!isGrosirProduct) {
        descriptionPage.selectedOptionProduct = [productRawData valueForKey:product_option_key];
    }else{
        descriptionPage.selectedOptionProduct = nil;
    }
    //M_Cart* data = [DataSingleton getCartDataAboutThisProduct:_product];
    descriptionPage.isRetail = ![(NSNumber*)[productData valueForKey:@"is_grosir"] boolValue];//![data.is_grosir boolValue];
    descriptionPage.type = CART_CATEGORY;
    [descriptionPage setMainPagerIndex:0];
    
    [self.navigationController pushViewController:descriptionPage animated:YES];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == delete_item){
        if (buttonIndex==0) {
            NSLog(@"delete produk: tidak");
        }else{
            NSLog(@"delete produk: ya");
            [self deleteItemAtRow:rowToDelete andSection:sectionToDelete];
        }
    }
    
}

-(void) deleteItem:(id)sender{
    NSIndexPath *indexPath = [[(UIButton*)sender getDataDictionary] valueForKey:index_key];
    rowToDelete = (int)[indexPath row];
    sectionToDelete = (int)[indexPath section];
    
    UIAlertView *dialog;
    
    dialog = [[UIAlertView alloc]
                 initWithTitle: nil
                 message: @"Anda yakin mau menghapus pesanan anda?"
                 delegate: self
                 cancelButtonTitle: @"Tidak" otherButtonTitles: @"Ya", nil];
    dialog.tag = delete_item;
    
    [dialog show];
}

-(void)deleteItemAtRow:(int)row andSection:(int)section{
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSMutableDictionary *newProductData = [[NSMutableDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:row]];
    Product* _product = [newProductData valueForKey:productKey];
    NSNumber *quantity = [newProductData valueForKey:quantityKey];
    NSDictionary* productRawData = _product.completeData;
    NSString* productSKU = [productRawData valueForKey:@"prd_SKU"];
    BOOL  isGrosirProduct = [(NSNumber*)[productRawData valueForKey:@"is_grosir"] boolValue];
    int cartItemIndex = -1;
    if (isGrosirProduct) {
        cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product];
    }else{
        cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product andOption:[productRawData valueForKey:product_option_key]];
    }
    
    if (cartItemIndex>=0) {
        if ([DataSingleton deleteShopCartOnIndex:cartItemIndex]) {
            //[groupOfProducts removeObjectAtIndex:section];
            NSNumber* availableStock = [NSNumber numberWithInt:0];
            NSNumber *stockID;
            //get stock for given productSKU and stock ID
            if (isGrosirProduct) {
                stockID = [productRawData valueForKey:@"stock_id"];
            }else{
                NSArray* selectedOptionProduct = (NSArray*)[productRawData valueForKey:product_option_key];
                NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productRawData valueForKey:@"stock"] usingOptionData:selectedOptionProduct];
                
                stockID = [stockInfo valueForKey:@"stock_id"];
            }
            
            NSArray *filteredStock = [[DataSingleton instance].stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",productSKU,stockID]];
            NSMutableDictionary *existingStock;
            if (filteredStock.count > 0) {
                existingStock = (NSMutableDictionary*)[filteredStock objectAtIndex:0];
                availableStock = (NSNumber*)[existingStock valueForKey:stock_qty_key];
                //here's the total available stock for this product: _product
                availableStock = [NSNumber numberWithInt:([availableStock intValue]+[quantity intValue])];
                [existingStock setValue:availableStock forKey:stock_qty_key];
            }
            
            isEmpty = [[DataSingleton instance].usedCart.items count]==0;
            if (isEmpty) {
                viewEmpty.hidden = false;
                viewColl.hidden = true;
            }
            else
            {
                [self refreshCart];
            }
            
        }
    }
}

-(void)deleteItemAtIndex:(id)sender{
    NSIndexPath *indexPath = [[(UIButton*)sender getDataDictionary] valueForKey:index_key];
    int row = (int)[indexPath row];
    int section = (int)[indexPath section];
    
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSMutableDictionary *newProductData = [[NSMutableDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:row]];
    Product* _product = [newProductData valueForKey:productKey];
    NSNumber *quantity = [newProductData valueForKey:quantityKey];
    NSDictionary* productRawData = _product.completeData;
    NSString* productSKU = [productRawData valueForKey:@"prd_SKU"];
    BOOL  isGrosirProduct = [(NSNumber*)[productRawData valueForKey:@"is_grosir"] boolValue];
    int cartItemIndex = -1;
    if (isGrosirProduct) {
        cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product];
    }else{
        cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product andOption:[productRawData valueForKey:product_option_key]];
    }
    
    if (cartItemIndex>=0) {
        if ([DataSingleton deleteShopCartOnIndex:cartItemIndex]) {
            //[groupOfProducts removeObjectAtIndex:section];
            NSNumber* availableStock = [NSNumber numberWithInt:0];
            NSNumber *stockID;
            //get stock for given productSKU and stock ID
            if (isGrosirProduct) {
                stockID = [productRawData valueForKey:@"stock_id"];
            }else{
                NSArray* selectedOptionProduct = (NSArray*)[productRawData valueForKey:product_option_key];
                NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productRawData valueForKey:@"stock"] usingOptionData:selectedOptionProduct];
                
                stockID = [stockInfo valueForKey:@"stock_id"];
            }
            
            NSArray *filteredStock = [[DataSingleton instance].stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",productSKU,stockID]];
            NSMutableDictionary *existingStock;
            if (filteredStock.count > 0) {
                existingStock = (NSMutableDictionary*)[filteredStock objectAtIndex:0];
                availableStock = (NSNumber*)[existingStock valueForKey:stock_qty_key];
                //here's the total available stock for this product: _product
                availableStock = [NSNumber numberWithInt:([availableStock intValue]+[quantity intValue])];
                [existingStock setValue:availableStock forKey:stock_qty_key];
            }
            
            isEmpty = [[DataSingleton instance].usedCart.items count]==0;
            if (isEmpty) {
                viewEmpty.hidden = false;
                viewColl.hidden = true;
            }
            else
            {
                [self refreshCart];
            }
            
        }
    }
    
}

-(void)editItemAtIndex:(id)sender{
    NSIndexPath *indexPath = [[(UIButton*)sender getDataDictionary] valueForKey:index_key];
    int index = (int)[indexPath row];
    int section = (int)[indexPath section];
    editedIndex = indexPath;
    NSMutableArray* oneOwnerProduct = groupOfProducts[section];
    NSDictionary *productData = [[NSMutableDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:index]];
    NSNumber *quantity = [productData valueForKey:quantityKey];
    currentQty = [quantity intValue];
    [self updateQuantity];
    
    CartItemCell *cell = (CartItemCell*)[cartTable cellForRowAtIndexPath:indexPath];
    CGPoint showPoint = CGPointMake(CGRectGetMinX(cell.frame)+CGRectGetMinX(cell.productQty.frame)+20, CGRectGetMinY(cell.frame)+CGRectGetMinY(cell.productQty.frame)+10);
    UIView *helperView = [[UIView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width / 2,showPoint.y, 10, 10)];
    popover.maskType = DXPopoverMaskTypeNone;
    [popover showAtView:helperView withContentView:popoverView inView:cartTable];
    [quantityBox validate];
}

- (void)updateQuantity{
    quantityBox.text = [NSString stringWithFormat:@"%d",currentQty];
}

- (void)refreshCart{
    [self initializeTableData];
    [cartTable reloadData];
    _total = [[DataSingleton instance].usedCart.totalPrice intValue];
    double total = (_total/1000.0);
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    totalPrice.text = [NSString stringWithFormat:@"Rp %@",
                       [commas stringFromNumber:[NSNumber numberWithDouble:total * 1000]]];
    
    isEmpty = [[DataSingleton instance].usedCart.items count]==0;
    if (isEmpty) {
        viewEmpty.hidden = false;
        viewColl.hidden = true;
    }
}

- (void)refreshCartItemAtIndex:(NSIndexPath*)indexPath{
    [cartTable beginUpdates];
    [cartTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [cartTable reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
    [cartTable endUpdates];
    //[cartTable reloadData];
    _total = [[DataSingleton instance].usedCart.totalPrice intValue];
    double total = (_total/1000.0);
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    totalPrice.text = [NSString stringWithFormat:@"Rp %@",
                       [commas stringFromNumber:[NSNumber numberWithDouble:total * 1000]]];
    [DataSingleton instance].shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[[DataSingleton instance].usedCart.totalItem intValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkOutItems:(id)sender{
    //check for logged in user
    [DataSingleton retrieveUser];
    if ([DataSingleton instance].loggedInUser!=nil) {
        int section = (int)((UIButton*)sender).tag;
        //checkout expense is expense for this checkout process
        [DataSingleton instance].checkoutExpense = [[(UIButton*)sender getDataDictionary] valueForKey:cartExpenseKey];
        NSMutableArray* oneOwnerProducts = [groupOfProducts objectAtIndex:section];
        [DataSingleton instance].checkoutItems = oneOwnerProducts;
        NSDictionary* ownerData = [oneOwnerProducts objectAtIndex:0];
        if ([[ownerData valueForKey:ownerIDKey] intValue] == cartOwnerIDRetail) {
            [DataSingleton instance].checkoutItemsIsRetail = [NSNumber numberWithBool:YES];
        }else{
            [DataSingleton instance].checkoutItemsIsRetail = [NSNumber numberWithBool:NO];
        }
        [self stockCheckingForProductOf:[ownerData valueForKey:ownerIDKey]];
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Anda harus login terlebih dahulu sebelum memesan barang!"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
}

- (IBAction)goToCheckout:(id)sender {
    [DataSingleton instance].checkoutItems = [DataSingleton instance].usedCart.items;
    [self stockCheckingForProductOf:nil];
}

- (IBAction)increaseQty:(id)sender {
    currentQty = [quantityBox.text intValue];
    currentQty++;
    [self updateQuantity];
}

- (IBAction)decreaseQty:(id)sender {
    currentQty = [quantityBox.text intValue];
    currentQty--;
    if (currentQty<0) {
        currentQty=0;
    }
    [self updateQuantity];
}

- (IBAction)saveQuantity:(id)sender {
    if ([quantityBox validate]) {
        int index = (int)[editedIndex row];
        int section = (int)[editedIndex section];
        NSMutableArray* oneOwnerProduct = groupOfProducts[section];
        NSMutableDictionary *newProductData = [[NSMutableDictionary alloc]initWithDictionary:[oneOwnerProduct objectAtIndex:index]];
        
        Product* _product = [newProductData valueForKey:productKey];
        NSNumber *quantity = [newProductData valueForKey:quantityKey];
        NSDictionary* productRawData = _product.completeData;
        
        currentQty = [quantityBox.text intValue];
        NSNumber* availableStock = [NSNumber numberWithInt:0];
        NSString* productSKU = [productRawData valueForKey:@"prd_SKU"];
        BOOL isGrosirProduct = [[productRawData valueForKey:@"is_grosir"] boolValue];
        NSNumber *stockID;
        //get stock for given productSKU and stock ID
        if (isGrosirProduct) {
            stockID = [productRawData valueForKey:@"stock_id"];
        }else{
            NSArray* selectedOptionProduct = (NSArray*)[productRawData valueForKey:product_option_key];
            NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productRawData valueForKey:@"stock"] usingOptionData:selectedOptionProduct];
            
            stockID = [stockInfo valueForKey:@"stock_id"];
        }
        NSArray *filteredStock = [[DataSingleton instance].stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",productSKU,stockID]];
        NSMutableDictionary *existingStock;
        if (filteredStock.count > 0) {
            existingStock = (NSMutableDictionary*)[filteredStock objectAtIndex:0];
            availableStock = (NSNumber*)[existingStock valueForKey:stock_qty_key];
        }
        //here's the total available stock for this product: _product
        availableStock = [NSNumber numberWithInt:([availableStock intValue]+[quantity intValue])];
        if (currentQty<=0) {
            [((UIButton*)sender) setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:editedIndex,index_key, nil]];
            [self deleteItemAtIndex:sender];
            [popover dismiss];
        }else if(currentQty> [availableStock intValue]){
            NSString *errorMsg = [NSString stringWithFormat:@"Stok yang tersedia untuk produk ini adalah %d, mohon ubah kembali order anda", [availableStock intValue]];
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: errorMsg
                         delegate: self
                         cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
            
            [errorView show];
        }else{
            //here currentQty is below "total available quantity", currentQty is valid
            quantity = [NSNumber numberWithInt:currentQty];
            [newProductData setValue:quantity forKey:quantityKey];
            if ([DataSingleton updateCartItem:_product withQuantity:quantity]) {
                //here's the remaining stock: "total available quantity" - valid currentQty
                availableStock = [NSNumber numberWithInt:([availableStock intValue]-[quantity intValue])];
                if (existingStock) {
                    [existingStock setValue:availableStock forKey:stock_qty_key];
                }
                int cartItemIndex = [DataSingleton getCartItemIndexForThisProduct:_product];
                if (cartItemIndex>=0) {
                    [[DataSingleton instance].usedCart updateItemAtIndex:cartItemIndex with:newProductData];
                    [self refreshCartItemAtIndex:editedIndex];
                }
            }
            [popover dismiss];
        }
        
        
    }
    
}

- (void)stockCheckingForProductOf:(NSNumber*)ownerID{
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
        [self shallShowLoadingOverlay:YES];
        [networkQueue cancelAllOperations];
        networkQueue = [ASINetworkQueue queue];
        networkQueue.delegate = self;
        [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
        [networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
        [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        checkedProduct = [NSMutableArray array];
        unavailableProducts = [NSMutableArray array];
        failedToCheckProducts = [NSMutableArray array];
        int i = 1;
        for (NSDictionary* cartItem in [DataSingleton instance].checkoutItems) {
            Product *_product = [cartItem valueForKey:productKey];
            NSNumber *qty = [cartItem valueForKey:quantityKey];
            NSDictionary* productRawData = _product.completeData;
            BOOL isGrosirProduct = [(NSNumber*)[productRawData objectForKey:@"is_grosir"]boolValue];
            NSString *varID = @"";
            if (!isGrosirProduct) {
                NSMutableArray* productSelectedOption = [productRawData valueForKey:product_option_key];
                NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productRawData valueForKey:@"stock"] usingOptionData:productSelectedOption];
                
                if (stockInfo) {
                    varID = [stockInfo valueForKey:@"var_id"];
                }
            }

            
            NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,getStockByIdURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
            request.tag = i;
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            
            [request addPostValue:[_product.ID stringValue] forKey:@"prd_id"];
            [request addPostValue:isGrosirProduct?@"-1":varID forKey:@"var_id"];
            isRetail = !isGrosirProduct;
            NSDictionary *productData = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:i],product_data_id,_product.ID,product_data_prd_id,qty,product_data_prd_qty, nil];
            [checkedProduct addObject:productData];
            [networkQueue addOperation:request];
            i++;
        }
        
        //get info rekening penjual
        NSString * allAccountURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllAccountURL];
        
        ASIFormDataRequest *requestForAccount = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:allAccountURL]];
        requestForAccount.tag = -1;
        [requestForAccount setDelegate:self];
        [requestForAccount setTimeOutSeconds:60];
        [requestForAccount setRequestMethod:@"POST"];
        
        if ([ownerID intValue]!=cartOwnerIDRetail && [ownerID intValue]!=cartOwnerIDToko) {
            [requestForAccount addPostValue:ownerID forKey:@"user_id"];
        }
        [networkQueue addOperation:requestForAccount];
        
        //get ongkir
        
        NSString *getAllCityParams = @"";
        if ([ownerID intValue]!=cartOwnerIDRetail && [ownerID intValue]!=cartOwnerIDToko) {
            getAllCityParams = [NSString stringWithFormat:@"?seller_id=%d", [ownerID intValue]];
        }
        
        NSString * allCityURL = [NSString stringWithFormat:@"%@%@%@",y2BaseURL,getAllCityURL,getAllCityParams];
        ASIFormDataRequest *requestForCity = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:allCityURL]];
        requestForCity.tag = -2;
        [requestForCity setDelegate:self];
        [requestForCity setTimeOutSeconds:60];
        [requestForCity setRequestMethod:@"GET"];
        
        [networkQueue addOperation:requestForCity];
        [networkQueue go];
    }
}

- (void)oneRequestFinished:(ASIHTTPRequest *)request
{
	NSLog(@"Request finished");
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    if (request.tag==-1) {
        [DataSingleton processAPIRequestResult:responseString withRequestCode:getAllAccount];
    }else if (request.tag==-2) {
        [DataSingleton processAPIRequestResult:responseString withRequestCode:getAllCity];
    } else{
        BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
        if (success) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            
            NSNumber* productQty = [nf numberFromString:[jsonDictionary objectForKey:@"data"]];
            if (productQty==nil) {
                productQty = [NSNumber numberWithInt:0];
            }
            for (NSDictionary* productData in checkedProduct) {
                if ([(NSNumber*)[productData valueForKey:product_data_id] intValue] == (int)request.tag) {
                    //get the product, compare the quantity
                    NSNumber* desiredProductQty = [productData valueForKey:product_data_prd_qty];
                    if ([desiredProductQty intValue]>[productQty intValue]) {
                        NSNumber* productID = [productData valueForKey:product_data_prd_id];
                        NSDictionary *productQtyInfo = [[NSDictionary alloc] initWithObjectsAndKeys:productQty,product_data_prd_qty,productID,product_data_prd_id, nil];
                        [unavailableProducts addObject:productQtyInfo];
                    }
                }
            }
        }else{
            for (NSDictionary* productData in checkedProduct) {
                if ([(NSNumber*)[productData valueForKey:product_data_id] intValue] == (int)request.tag) {
                    //get the product, compare the quantity
                    NSNumber* productID = [productData valueForKey:product_data_prd_id];
                    [failedToCheckProducts addObject:productID];
                }
            }
        }
    }
    
}

- (void)oneRequestFailed:(ASIHTTPRequest *)request
{
	// You could release the queue here if you wanted
    //	if ([networkQueue requestsCount] == 0) {
    //		networkQueue = nil;
    //	}
	
	//... Handle failure
    for (NSDictionary* productData in checkedProduct) {
        if ([(NSNumber*)[productData valueForKey:product_data_id] intValue] == (int)request.tag) {
            //get the product, compare the quantity
            NSNumber* productID = [productData valueForKey:product_data_prd_id];
            [failedToCheckProducts addObject:productID];
        }
    }
	NSLog(@"Request failed");
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
    NSLog(@"Queue finished");
	// You could release the queue here if you wanted
	if ([networkQueue requestsCount] == 0) {
		networkQueue = nil;
	}
    [self shallShowLoadingOverlay:NO];
    
    if (unavailableProducts.count>0) {
        //some product out of stock
        NSMutableString *productNames = [NSMutableString string];
        for (NSDictionary* productQtyInfo in unavailableProducts) {
            NSNumber *productID = [productQtyInfo valueForKey:product_data_prd_id];
            NSNumber *qtyLimit = [productQtyInfo valueForKey:product_data_prd_qty];
            int row = 0;
            for (NSDictionary* cartItem in [DataSingleton instance].usedCart.items) {
                Product* thisProduct = [cartItem valueForKey:productKey];
                if ([thisProduct.ID intValue]==[productID intValue]) {
                    if (productNames.length==0) {
                        productNames = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@:%@",thisProduct.name,qtyLimit]];
                    }else{
                        [productNames appendFormat:@"\n %@",[NSString stringWithFormat:@"%@:%@",thisProduct.name,qtyLimit]];
                    }
                }
                row++;
            }
        }
        [productNames insertString:@"Jumlah stock yang tersedia: \n" atIndex:0];
        
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: @"Stock barang tidak tersedia"
                     message: productNames
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }else if([failedToCheckProducts count]>0){
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Stock barang tidak dapat diperiksa, coba kembali beberapa saat lagi"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
        
    }else{
        //all valid quantity go to checkout page
        Checkout1stViewController *checkoutPage = [[Checkout1stViewController alloc] initWithNibName:@"Checkout1stViewController" bundle:nil];
        checkoutPage.isRetail = isRetail;
        [self decreaseTheStack];
        [self.navigationController pushViewController:checkoutPage animated:YES];
    }
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
}


@end
