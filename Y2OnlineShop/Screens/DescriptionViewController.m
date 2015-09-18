//
//  DescriptionViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "DescriptionViewController.h"
#import "SingleProductImageViewController.h"
#import "UIIndexedPageViewController.h"
#import "DataSingleton.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "DropDownTextField.h"
#import "CustomRightViewTextfield.h"
#import <Twitter/Twitter.h>

#define default_selected_optionvalue 0
#define productIDKey @"product_id"
#define indexProductKey @"index"
#define typeProductKey @"prd_type"
#define addToCartBtnTitle @"Tambahkan ke Tas"
#define optionBtnTitle @"Pilihan"
#define shareDialog 3

@interface DescriptionViewController ()
@end

@implementation DescriptionViewController

@synthesize productToDisplay = _productToDisplay,shareBtn,detailBtn,nameLabel,priceLabel,favoriteBtn,chooseSizeBtn,addToBagBtn, products, indexProduct, imageProduct, colorBtn, loading, variantView, buttonWrapper, buttonWrapperPilihan,buttonWrapperSingle,variantTableOption,addToBagBtnSingle,searchBarGrosir,searchBarRetail,productToShare,titleLabel,quantityBox,quantityTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        varIpadHeight = 0;
        varIpadWidth = 0;
        marginWidth = 0;
        marginHeight= 0;
        widthContentView = 175;
        
        if (IS_IPAD) {
            varIpadHeight = 321;
            varIpadWidth = 408;
            
            marginWidth = 20;
            marginHeight = 76;
            widthContentView = (widthContentView*4)-80;
        }
        
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    if ([self isDeviceRotatingToLandscape])
    {
        [self manageColorToggleForLandscapeOrientation];
        deviceIsInLandscape = true;
        
    }
    else if([self isDeviceRotatingToPortrait])
    {
        [self manageColorToggleForPortraitOrientation];
        deviceIsInLandscape = false;
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations)
        {
            [req clearDelegatesAndCancel];
        }
        [networkQueue cancelAllOperations];
    }
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL poppedOut = false;
    if (self.isMovingToParentViewController == NO)
    {
        // we're already on the navigation stack
        // another controller must have been popped off
        poppedOut = true;
    }
    if (!poppedOut) {
        self.viewColor.translatesAutoresizingMaskIntoConstraints = YES;
        colorBtn.translatesAutoresizingMaskIntoConstraints = YES;
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
            //landscape
            if (IS_IPAD) {
                [self.viewColor setFrame:CGRectMake(1024-39, 130, 130, 507)];
            }else if(IS_IPHONE_5){
                //NSLog(@"IS_IPHONE_5");
                [self.viewColor setFrame:CGRectMake(568-33, 10, 97, 258)];
            }else{
                //NSLog(@"~IS_IPHONE & ~IS_IPAD");
                [self.viewColor setFrame:CGRectMake(480-33, 10, 97, 258)];
            }
            deviceIsInLandscape = true;
        }else{
            //potrait
            if (IS_IPAD) {
                [self.viewColor setFrame:CGRectMake(768-39, 258, 130, 507)];
            }else if(IS_IPHONE_5){
                //NSLog(@"IS_IPHONE_5");
                [self.viewColor setFrame:CGRectMake(320-33, 168, 97, 258)];
            }else{
                //NSLog(@"~IS_IPHONE & ~IS_IPAD");
                [self.viewColor setFrame:CGRectMake(320-33, 108, 97, 258)];
            }
            deviceIsInLandscape = false;
        }
        viewColorIsHidden = true;
        [self disableSlidePanGestureForLeftMenu];
        
        colorBtn.layer.borderWidth = 2;
        colorBtn.layer.borderColor = [UIColor darkTextColor].CGColor;
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        UIBezierPath* layerPath = [UIBezierPath bezierPathWithRoundedRect:colorBtn.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(5.0, 5.0)];
        shapeLayer.frame = colorBtn.bounds;
        shapeLayer.path = layerPath.CGPath;
        colorBtn.layer.mask = shapeLayer;
        
        
        [colorBtn setTitleEdgeInsets:UIEdgeInsetsMake(1.0, 4.0, 0, 4.0)];
        colorBtn.transform = CGAffineTransformMakeRotation(-1*(M_PI /2));
        
        
        
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
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
        titleLabel.text = [_productToDisplay valueForKey:@"prd_name"];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
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
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        [DataSingleton instance].navigationController = self.navigationController;
        [DataSingleton instance].searchBarRetail = searchBarRetail;
        [DataSingleton instance].searchBarGrosir = searchBarGrosir;
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].wishBarButtonItem, [DataSingleton instance].shopBarButtonItem, [DataSingleton instance].searchBarProductRetail,[DataSingleton instance].searchBarProductGrosir, nil];
    }
    
}

- (void)viewDidLoad
{
    [self disableSlidePanGestureForRightMenu];
    [self disableSlidePanGestureForLeftMenu];
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
    #endif
    
    [super viewDidLoad];
    if (IS_IPAD) {
        textFieldWidth = 230.0;
        textFieldHeight = 40.0;
        wrapperWidth = 240.0;
        fontSize = 17.0;
        variantTableOptionWidth = 240.0;
    }else{
        textFieldWidth = 160.0;
        textFieldHeight = 25.0;
        wrapperWidth = 170.0;
        fontSize = 13.0;
        variantTableOptionWidth = 140.0;
    }
    variantTableOption = [[UITableView alloc] initWithFrame:CGRectMake(wrapperWidth,0,variantTableOptionWidth,CGRectGetHeight(variantView.frame)) style:UITableViewStylePlain];
    variantTableOption.delegate = self;
    variantTableOption.dataSource = self;
    variantView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
    variantTableOption.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.3];
    if ([variantTableOption respondsToSelector:@selector(setSeparatorInset:)]) {
        [variantTableOption setSeparatorInset:UIEdgeInsetsZero];
    }
    variantOptions = [NSMutableArray array];
    variantPopover = [DXPopover new];
    variantPopover.maskType = DXPopoverMaskTypeNone;
    [variantPopover setFrame:CGRectMake(0, 0, variantView.frame.size.width, variantView.frame.size.height+10)];
    
    [quantityTextField addRegx:regex_value withMsg:@"harap diisi hanya dengan angka"];
    quantityTextField.delegate = self;
    quantityBoxPopover = [DXPopover new];
    quantityBoxPopover.maskType = DXPopoverMaskTypeBlack;
    [quantityBoxPopover setFrame:CGRectMake(0, 0, quantityBox.frame.size.width, quantityBox.frame.size.height+10)];
    quantityBoxPopover.center = self.view.center;
    
    subPagerIndex = 0;
    currentIndex = mainPagerIndex;
    currentSubIndex = subPagerIndex;
    [self.collColor registerNib:[UINib nibWithNibName:@"ImageColorItem" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ImageColor"];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    [self.pageController setDelegate:self];
    [self.imageWrapper addSubview:[self.pageController view]];
    [self.pageController.view setFrame:self.imageWrapper.bounds];
    [self.pageController view].clipsToBounds = YES;
    
    colorOfProduct = [NSMutableArray array];
    
    NSDictionary* _product;
    if (products.count<1) {
        _product = self.productToDisplay;
        colorBtn.hidden = YES;
    }else{
        _product = (NSDictionary*)[products objectAtIndex:mainPagerIndex];
    }
    
    //create variant option for current visible product
    [self generateOptionForIndex:mainPagerIndex];
    
    //create list of color for current visible product
    colorOfProduct = [NSMutableArray arrayWithArray:(NSArray*)[_product valueForKey:@"images_color"]];
    colorBtn.hidden = NO;
    [self.collColor reloadData];
    UIIndexedPageViewController *initialViewController = [self subPageViewerControllerAtIndex:mainPagerIndex];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumber* stockValue = [NSNumber numberWithInt:0];
    if ([_product objectForKey:@"is_grosir"]!=nil) {
        BOOL isProductRetail = ![[_product valueForKey:@"is_grosir"] boolValue];
        
        if (isProductRetail) {
            //product retail
            //sum stock for each variant
            int stockValueInt = 0;
            for (NSDictionary* stockVariant in [_product valueForKey:@"stock"]) {
                stockValueInt += [[stockVariant valueForKey:@"stock"] intValue];
            }
            stockValue = [NSNumber numberWithInt:stockValueInt];
            NSNumber *_ownerID = [f numberFromString:[_product valueForKey:@"owner_id"]];
            if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                [self showAddToCartAndVariantButton];
            }else{
                [self showVariantOnlyButton];
            }
            
        }else{
            stockValue = [_product valueForKey:@"stock"];
            NSNumber *_ownerID = [f numberFromString:[_product valueForKey:@"owner_id"]];
            if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                [self showAddToCartOnlyButton];
            }
            
        }
    }else if([_product objectForKey:@"prd_type"]!=nil){
        BOOL isProductRetail = [[_product valueForKey:@"prd_type"] isEqualToString:@"RT"]?YES:NO;
        if (isProductRetail) {
            //product retail
            //sum stock for each variant
            int stockValueInt = 0;
            for (NSDictionary* stockVariant in [_product valueForKey:@"stock"]) {
                stockValueInt += [[stockVariant valueForKey:@"stock"] intValue];
            }
            stockValue = [NSNumber numberWithInt:stockValueInt];
            NSNumber *_ownerID = [f numberFromString:[_product valueForKey:@"owner_id"]];
            if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                [self showAddToCartAndVariantButton];
            }else{
                [self showVariantOnlyButton];
            }
        }else{
            stockValue = [_product valueForKey:@"stock"];
            NSNumber *_ownerID = [f numberFromString:[_product valueForKey:@"owner_id"]];
            if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                [self showAddToCartOnlyButton];
            }
        }
    }
    [self handlePriceAndTitleTextColor:stockValue];
    
    nameLabel.text = [_product valueForKey:@"prd_name"];
    NSNumber* appropriatePrice = [_product valueForKey:@"prd_price"];
    int price = [appropriatePrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    priceLabel.text = [NSString stringWithFormat:@"Rp %@",
                       [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:self.imageWrapper];
    [self.pageController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:nameLabel];
    [self.view bringSubviewToFront:priceLabel];
    [self.view bringSubviewToFront:self.viewColor];
    [self.view bringSubviewToFront:self.favoriteBtn];
    
    [self checkForUndetailedProduct];
    if (IS_IPAD) {
        self.addToBagBtnSingle.titleLabel.font = FONT_ARSENAL_BOLD(25);
        addToBagBtn.titleLabel.font = FONT_ARSENAL_BOLD(25);
        chooseSizeBtn.titleLabel.font = FONT_ARSENAL_BOLD(25);
    }else{
        self.addToBagBtnSingle.titleLabel.font = FONT_ARSENAL_BOLD(13);
        addToBagBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
        chooseSizeBtn.titleLabel.font = FONT_ARSENAL_BOLD(13);
    }
    
}

- (BOOL)isDeviceRotatingToLandscape{
    return  UIDeviceOrientationIsLandscape(self.interfaceOrientation)&&!deviceIsInLandscape;
}

- (BOOL)isDeviceRotatingToPortrait{
    return  !UIDeviceOrientationIsLandscape(self.interfaceOrientation)&&deviceIsInLandscape;
}

- (void)manageColorToggleForLandscapeOrientation{
    self.viewColor.translatesAutoresizingMaskIntoConstraints = YES;
    colorBtn.translatesAutoresizingMaskIntoConstraints = YES;
    int screenOffset = 0;
    if (IS_IPAD) {
        if (!viewColorIsHidden) {
            //color layout are being shown
            screenOffset  = 90;
        }
        [self.viewColor setFrame:CGRectMake(1024-39-screenOffset, 130, 130, 507)];
    }else if(IS_IPHONE_5){
        if (!viewColorIsHidden) {
            //color layout are being shown
            screenOffset  = 64;
        }
        [self.viewColor setFrame:CGRectMake(568-33-screenOffset, 10, 97, 258)];
    }else{
        if (!viewColorIsHidden) {
            //color layout are being shown
            screenOffset  = 64;
        }
        [self.viewColor setFrame:CGRectMake(480-33-screenOffset, 10, 97, 258)];
    }
}

- (void)manageColorToggleForPortraitOrientation{
    self.viewColor.translatesAutoresizingMaskIntoConstraints = YES;
    colorBtn.translatesAutoresizingMaskIntoConstraints = YES;
    int screenOffset = 0;
    if (IS_IPAD) {
        if (!viewColorIsHidden) {
            //color layout are being shown
            screenOffset  = 90;
        }
        [self.viewColor setFrame:CGRectMake(768-39-screenOffset, 258, 130, 507)];
    }else if(IS_IPHONE_5){
        //NSLog(@"IS_IPHONE_5");
        if (!viewColorIsHidden) {
            //color layout are being shown
            screenOffset  = 64;
        }
        [self.viewColor setFrame:CGRectMake(320-33-screenOffset, 168, 97, 258)];
    }else{
        if (!viewColorIsHidden) {
            //color layout are being shown
            screenOffset  = 64;
        }
        [self.viewColor setFrame:CGRectMake(320-33-screenOffset, 108, 97, 258)];
    }
}

- (void)showAddToCartOnlyButton{
    buttonWrapper.hidden = YES;
    buttonWrapperSingle.hidden = NO;
}

- (void)showVariantOnlyButton{
    buttonWrapper.hidden = YES;
    buttonWrapperSingle.hidden = YES;
    buttonWrapperPilihan.hidden = NO;
}

- (void)showAddToCartAndVariantButton{
    buttonWrapper.hidden = NO;
    buttonWrapperSingle.hidden = YES;
}

- (void)handlePriceAndTitleTextColor:(NSNumber*)productStock{
    if ([productStock intValue]==0) {
        nameLabel.textColor = [UIColor redColor];
        priceLabel.textColor = [UIColor redColor];
    }else{
        nameLabel.textColor = [UIColor blackColor];
        priceLabel.textColor = [UIColor blackColor];
    }
}

- (void)generateOptionForIndex:(int)indexOfProduct{
    //read variant data
    variantCollection = [NSMutableArray array];
    //[variantView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (UIView *v in variantView.subviews) {
        if (![v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    NSDictionary* _product;
    if (products.count<1) {
        _product = self.productToDisplay;
    }else{
        _product = (NSDictionary*)[products objectAtIndex:indexOfProduct];
    }
    
    NSArray* variantOption = [_product objectForKey:@"option"];
    int optionIndex = 0;
    int selectedOptionIndex = -1;
    for (NSDictionary* optionData in variantOption) {
        NSString* optionName = [optionData valueForKey:@"opt_name"];
        NSArray* optionValueRaw = [optionData valueForKey:@"opt_values"];
        NSArray *optionValueKey = [optionValueRaw valueForKeyPath:@"@distinctUnionOfObjects.opt_val_id"];
        NSMutableArray* optionValueParsed = [NSMutableArray array];
        int indexOfOption = 0;
        for (NSNumber* valueID in optionValueKey) {
            NSMutableArray *distinctOptionValue = [NSMutableArray arrayWithArray:[optionValueRaw filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"opt_val_id = %@", valueID]]];
            [optionValueParsed addObject:[distinctOptionValue objectAtIndex:0]];
            if (self.selectedOptionProduct!=nil) {
                if ([(NSNumber*)[(NSDictionary*)[distinctOptionValue objectAtIndex:0] valueForKey:@"opt_val_id"] intValue] == [(NSNumber*)[self.selectedOptionProduct objectAtIndex:optionIndex] intValue]) {
                    selectedOptionIndex = indexOfOption;
                }
            }
            indexOfOption++;
        }
        NSMutableDictionary* optionDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:optionName,variant_option_key,optionValueParsed,variant_value_key, nil];
        [optionDictionary setValue:[NSNumber numberWithInt:selectedOptionIndex>-1?selectedOptionIndex:default_selected_optionvalue] forKeyPath:variant_selected_key];
        [optionDictionary setValue:(NSDictionary*)[optionValueParsed objectAtIndex:selectedOptionIndex>-1?selectedOptionIndex:default_selected_optionvalue] forKeyPath:variant_selected_data];
        [variantCollection addObject:optionDictionary];
        optionIndex++;
    }
    
    //update the stock
    NSString* productSKU = [_product valueForKey:@"prd_SKU"];
    
    //get the stock for default_selected_optionvalue
    NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[_product valueForKey:@"stock"] usingOptionData:[self createArrayOfSelectedOption]];
    
    NSNumber* productStockID;
    NSNumber* productStock;
    if (stockInfo) {
        productStock = [stockInfo valueForKey:@"stock"];
        productStockID = [stockInfo valueForKey:@"stock_id"];
    }
    
    [DataSingleton insertThisProductToStockKeeper:productSKU withStock:productStock andStockID:productStockID];
    
    int y=10;
    for (int i = 0; i< variantCollection.count; i++) {
        NSString* optionName = [[variantCollection objectAtIndex:i] valueForKey:variant_option_key];
        NSMutableArray* optionValues = [[variantCollection objectAtIndex:i] valueForKey:variant_value_key];
        int selectedIndex = [(NSNumber*)[[variantCollection objectAtIndex:i] valueForKey:variant_selected_key] intValue];
        NSDictionary* selectedOptionValue = [optionValues objectAtIndex:selectedIndex];
        UILabel* optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, y, textFieldWidth, 21)];
        y += 25;
        CustomRightViewTextfield *variantText = [[CustomRightViewTextfield alloc] initWithFrame:CGRectMake(5, y, textFieldWidth, textFieldHeight)];
        variantText.tag = i;
        variantText.delegate = self;
        variantText.layer.masksToBounds=YES;
        variantText.layer.borderColor=[[UIColor grayColor]CGColor];
        variantText.layer.borderWidth= 1.0f;
        variantText.layer.cornerRadius = 5.0f;
        //create padding left
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, variantText.frame.size.height)];
        variantText.leftView = paddingView;
        variantText.leftViewMode = UITextFieldViewModeAlways;
        //create dropdown icon
        variantText.rightViewDistance = 10;
        [variantText useRightView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-01-16.png"]]];
        variantText.placeholder = [NSString stringWithFormat:@"Pilih %@",optionName];
        NSString* valueName = [selectedOptionValue valueForKey:@"opt_val_name"];
        //Capitalize 1st letter
        if (valueName && [valueName length]>0) {
            valueName = [valueName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                           withString:[[valueName substringToIndex:1] capitalizedString]];
        }
        if (optionName && [optionName length]>0) {
            optionName = [optionName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                             withString:[[optionName substringToIndex:1] capitalizedString]];
        }
        optionNameLabel.text = optionName;
        variantText.text = valueName;
        [optionNameLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [variantText setFont:[UIFont systemFontOfSize:fontSize]];
        [variantView addSubview:optionNameLabel];
        [variantView addSubview:variantText];
        y += 55;
    }
    variantView.contentSize = CGSizeMake(wrapperWidth, (variantCollection.count*(textFieldHeight+20))+55);
    variantView.clipsToBounds = YES;
}

- (void)checkForUndetailedProduct{
    //check product that has yet been detailed
    needDetailProducts = [NSMutableArray array];
    for (int i=0; i<products.count; i++) {
        NSDictionary* prdData = [products objectAtIndex:i];
        BOOL detailedAlready = [[prdData valueForKey:markDetailedProduct] boolValue];
        if (!detailedAlready) {
            if ([prdData valueForKey:@"prd_id"]) {
                NSString* prdType = [prdData valueForKey:@"prd_type"] ;
                NSDictionary * _prdData = [NSDictionary dictionaryWithObjectsAndKeys:[prdData valueForKey:@"prd_id"],productIDKey,[NSNumber numberWithInt:i],indexProductKey,prdType,typeProductKey, nil];
                [needDetailProducts addObject:_prdData];
            }
            
        }
    }
    
    if (needDetailProducts.count>0) {
        [networkQueue cancelAllOperations];
        networkQueue = [ASINetworkQueue queue];
        networkQueue.delegate = self;
        [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
        [networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
        [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if(internetStatus != NotReachable)
        {
            for (NSDictionary* prdData in needDetailProducts) {
                NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,[[prdData valueForKey:@"prd_type"] isEqualToString:@"RT"]? getProductURL:getProductGrosirURL];
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
                request.tag = [(NSNumber*)[prdData valueForKey:indexProductKey] intValue];
                [request setRequestMethod:@"POST"];
                [request addPostValue:[prdData valueForKey:productIDKey] forKey:@"prd_id"];
                
                [request setTimeOutSeconds:60];
                [networkQueue addOperation:request];
            }
            removedProductIndexes = [NSMutableArray array];
            [networkQueue go];
        }
    }
}

- (void)oneRequestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (success) {
        NSDictionary* datum = (NSDictionary *)[jsonDictionary objectForKey:@"data"];
        NSMutableDictionary* productData = [[NSMutableDictionary alloc] init];
        NSEnumerator *enumerator = [datum keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            [productData setValue:[datum objectForKey:key] forKey:key];
        }
        BOOL isRetailProduct = ![(NSNumber*)[productData valueForKey:@"is_grosir"]boolValue];
        NSString* productSKU = [productData valueForKey:@"prd_SKU"];
        NSNumber* productStock;
        NSNumber* productStockID;
        if (!isRetailProduct) {
            //produk grosir
            productStock = [[productData valueForKey:@"stock"] isEqual:[NSNull null]]? [NSNumber numberWithInt:0]:[productData valueForKey:@"stock"];
            productStockID = [[productData valueForKey:@"stock_id"] isEqual:[NSNull null]]? [NSNumber numberWithInt:0]:[productData valueForKey:@"stock_id"];
        }else{
            productStock = [NSNumber numberWithInt:0];
            productStockID = [NSNumber numberWithInt:-1];
        }
        
        
        if (!productStock) {
            productStock = [NSNumber numberWithInt:0];
        }
        if (!productStockID) {
            productStockID = [NSNumber numberWithInt:0];
        }
        NSNumber *stockOnCart = [NSNumber numberWithInt:0];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber* productId = [nf numberFromString:(NSString*)[productData valueForKey:@"prd_id"]];
        for (NSDictionary* cartItem in [DataSingleton instance].usedCart.items) {
            Product* thisProduct = [cartItem valueForKey:productKey];
            NSNumber * thisProductQty = [cartItem valueForKey:quantityKey];
            if ([thisProduct.ID intValue] == [productId intValue]) {
                stockOnCart = [NSNumber numberWithInt:[thisProductQty intValue]];
            }
        }
        
        productStock = [NSNumber numberWithInt:([productStock intValue]-[stockOnCart intValue])];
        if ([productStock intValue]<0) {
            productStock = [NSNumber numberWithInt:0];
        }
        
        [DataSingleton insertThisProductToStockKeeper:productSKU withStock:productStock andStockID:productStockID];
        
        //add a mark that this data already got its detail
        [productData setValue:[NSNumber numberWithBool:true] forKey:markDetailedProduct];
        
        [products replaceObjectAtIndex:request.tag withObject:productData];
        
        
    }else{
        if (request.tag>=0 && request.tag<products.count) {
            if (removedProductIndexes == nil) {
                removedProductIndexes = [NSMutableArray array];
            }
            [removedProductIndexes addObject:[NSNumber numberWithInt:request.tag]];
        }
    }
}

- (void)oneRequestFailed:(ASIHTTPRequest *)request
{
    if (request.tag>=0 && request.tag<products.count) {
        if (removedProductIndexes == nil) {
            removedProductIndexes = [NSMutableArray array];
        }
        [removedProductIndexes addObject:[NSNumber numberWithInt:request.tag]];
    }
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	if ([networkQueue requestsCount] == 0) {
		networkQueue = nil;
	}
}

- (void)removeInvalidData{
    for (NSNumber* prdIndex in removedProductIndexes) {
        [products removeObjectAtIndex:[prdIndex intValue]];
        if ([prdIndex intValue]<mainPagerIndex) {
            mainPagerIndex--;
            indexProduct--;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [colorOfProduct count];
}

- (ImageColorItem *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageColorItem *imageColor = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageColor" forIndexPath:indexPath];
    int row = (int)[indexPath row];
    
    NSDictionary *thisProductColor = [colorOfProduct objectAtIndex:row];
    __weak UIImageView* thisColorImage = imageColor.image;
    [imageColor.image setImageWithURL:[thisProductColor valueForKey:@"image_ref"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (!image) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 thisColorImage.image = [UIImage imageNamed:@"icon_no_img.png"];
             });
             
             NSLog(@"failed load image for color");
         }
     }];
    
    return imageColor;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{   //pick warna
    int row = (int)indexPath.row;
    currentColorIndex = row;
    //self.pageController.viewControllers always consist of 1 viewcontroller
    UIIndexedPageViewController * ipv = [self.pageController.viewControllers objectAtIndex:0];
    ipv.selectedColorIndex = row;
    
    SingleProductImageViewController *initialViewController = [self viewControllerAtIndex:0 parentIndex:mainPagerIndex colorIndex:row];
    
     NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
     
     [ipv setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIIndexedPageViewController *)subPageViewerControllerAtIndex:(NSUInteger)index {
    
    UIIndexedPageViewController * ipv = [[UIIndexedPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    ipv.index = index;
    //0 is default color index
    ipv.selectedColorIndex = 0;
    
    [ipv setDelegate:self];
    
    //NSLog(@"LOADING SUBPAGE %d",(int)index);
    ipv.dataSource = self;
    [self.imageWrapper setNeedsLayout];
    [self.imageWrapper layoutIfNeeded];
    [[ipv view] setFrame:[[self imageWrapper] frame]];
    ipv.view.clipsToBounds = YES;
    
    SingleProductImageViewController *initialViewController = [self viewControllerAtIndex:0 parentIndex:index colorIndex:(int)ipv.selectedColorIndex];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [ipv setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    return ipv;
    
}

- (SingleProductImageViewController *)viewControllerAtIndex:(NSUInteger)index parentIndex:(NSUInteger)parentIndex colorIndex:(int)colorIndex{
    //set ui vertical swiping
    SingleProductImageViewController * spv = [[SingleProductImageViewController alloc] init];
    spv.index = index;//vertical reference
    spv.parentIndex =parentIndex;//horizontal reference
 
    NSDictionary* thisProduct;
    if (products.count>0) {
        thisProduct = [products objectAtIndex:parentIndex];
    }else{
        thisProduct = self.productToDisplay;
    }
    
    NSArray* imagesColorData = [NSMutableArray arrayWithArray:(NSArray*)[thisProduct valueForKey:@"images_color"]];
    if (colorIndex<imagesColorData.count){
        NSDictionary* defaultImagesColor = [imagesColorData objectAtIndex:colorIndex];
        NSArray* defaultImages = [defaultImagesColor valueForKey:@"images"];
        [spv setImages:[NSMutableArray arrayWithArray:defaultImages]];
    }else{
        [spv makeAsEmptyImage];
    }
    
    
    return spv;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if([pageViewController isKindOfClass:[UIIndexedPageViewController class]])
    {
        //kalau sub pager view kasih SingleProductImageViewController a.k.a vertical swiping
         subPagerIndex = (int)[(SingleProductImageViewController *)viewController index];
        
        if (subPagerIndex == 0) {
            return nil;
        }
        
        subPagerIndex--;
        
        SingleProductImageViewController * retView = [self viewControllerAtIndex:subPagerIndex parentIndex:((UIIndexedPageViewController*) pageViewController).index colorIndex:currentColorIndex];
        
        return retView;
    }
    else
    {
        //kalau main pager view kasih UIIndexedPageViewController a.k.a horizontal swiping

        mainPagerIndex = (int)[(UIIndexedPageViewController *)viewController index];
    
    
        if (mainPagerIndex == 0) {
            return nil;
        }
        
        mainPagerIndex--;
        
        return [self subPageViewerControllerAtIndex:mainPagerIndex];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if([pageViewController isKindOfClass:[UIIndexedPageViewController class]])
    {
        //kalau sub pager view kasih SingleProductImageViewController a.k.a vertical swiping
        subPagerIndex = (int)[(SingleProductImageViewController *)viewController index];
        
        if (subPagerIndex == [(SingleProductImageViewController *)viewController images].count - 1) {
            return nil;
        }
        
        subPagerIndex++;
        SingleProductImageViewController * retView = [self viewControllerAtIndex:subPagerIndex parentIndex:((UIIndexedPageViewController*) pageViewController).index colorIndex:currentColorIndex];
        return retView;
    }
    else
    {   // horizontal swiping
        mainPagerIndex = (int)[(UIIndexedPageViewController *)viewController index];
        
        
        if (mainPagerIndex >= [products count]-1) {
            return nil;
        }
        mainPagerIndex++;
        return [self subPageViewerControllerAtIndex:mainPagerIndex];
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    
    
    if([pendingViewControllers count]>0)
    {
        if([pageViewController isKindOfClass:[UIIndexedPageViewController class]])
        {
            //vertical
            //kalau sub pager view set image produknya aja (gambar2 alternatifnya)
            NSUInteger index =[(UIIndexedPageViewController*)[pendingViewControllers objectAtIndex:0] index];
            currentSubIndex = (int)index;
        }
        else
        {
            //kalau mai pager view set image dan data produknya
            //horizontal
            //set data
            NSUInteger index =[(UIIndexedPageViewController*)[pendingViewControllers objectAtIndex:0] index];
            currentColorIndex =[(UIIndexedPageViewController*)[pendingViewControllers objectAtIndex:0] selectedColorIndex];
            currentIndex = (int)index;

        }

        
        
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(finished && completed)
    {
        if([pageViewController isKindOfClass:[UIIndexedPageViewController class]])
        {
            //kalau sub pager view set image produknya aja (gambar2 alternatifnya) a.k.a vertical swiping
        }
        else
        {
            //kalau main pager view set image dan data produknya a.k.a horizontal swiping
            NSUInteger index = currentIndex;
            NSDictionary* thisProduct;
            if (products.count<1) {
                thisProduct = self.productToDisplay;
            }else{
                thisProduct = [products objectAtIndex:index];
            }
            
            //create variant option for current visible product
            [self generateOptionForIndex:index];
            //create list of color for current visible product
            colorOfProduct = [NSMutableArray arrayWithArray:(NSArray*)[thisProduct valueForKey:@"images_color"]];
            colorBtn.hidden = NO;
            [self.collColor reloadData];
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            
            NSNumber* stockValue = [NSNumber numberWithInt:0];
            if ([thisProduct objectForKey:@"is_grosir"]!=nil) {
                BOOL isProductRetail = ![[thisProduct valueForKey:@"is_grosir"] boolValue];
                if (isProductRetail) {
                    //product retail
                    //sum stock for each variant
                    int stockValueInt = 0;
                    for (NSDictionary* stockVariant in [thisProduct valueForKey:@"stock"]) {
                        stockValueInt += [[stockVariant valueForKey:@"stock"] intValue];
                    }
                    stockValue = [NSNumber numberWithInt:stockValueInt];
                    NSNumber *_ownerID = [f numberFromString:[thisProduct valueForKey:@"owner_id"]];
                    if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                        [self showAddToCartAndVariantButton];
                    }else{
                        [self showVariantOnlyButton];
                    }
                }else{
                    stockValue = [thisProduct valueForKey:@"stock"];
                    NSNumber *_ownerID = [f numberFromString:[thisProduct valueForKey:@"owner_id"]];
                    if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                        [self showAddToCartOnlyButton];
                    }
                }
            }else if([thisProduct objectForKey:@"prd_type"]!=nil){
                BOOL isProductRetail = [[thisProduct valueForKey:@"prd_type"] isEqualToString:@"RT"]?YES:NO;
                if (isProductRetail) {
                    //product retail
                    //sum stock for each variant
                    int stockValueInt = 0;
                    for (NSDictionary* stockVariant in [thisProduct valueForKey:@"stock"]) {
                        stockValueInt += [[stockVariant valueForKey:@"stock"] intValue];
                    }
                    stockValue = [NSNumber numberWithInt:stockValueInt];
                    NSNumber *_ownerID = [f numberFromString:[thisProduct valueForKey:@"owner_id"]];
                    if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                        [self showAddToCartAndVariantButton];
                    }else{
                        [self showVariantOnlyButton];
                    }
                }else{
                    stockValue = [thisProduct valueForKey:@"stock"];
                    NSNumber *_ownerID = [f numberFromString:[thisProduct valueForKey:@"owner_id"]];
                    if ([DataSingleton isLoggedInUserOwnProductOwner:_ownerID]) {
                        [self showAddToCartOnlyButton];
                    }
                }
                
            }
            [self handlePriceAndTitleTextColor:stockValue];
            
            nameLabel.text = [thisProduct valueForKey:@"prd_name"];
            NSNumber* appropriatePrice = [thisProduct valueForKey:@"prd_price"];
            int price = [appropriatePrice intValue];
            NSNumberFormatter *commas = [NSNumberFormatter new];
            commas.numberStyle = NSNumberFormatterDecimalStyle;
            double incomeValue = (int)(price / 1000.0);
            priceLabel.text = [NSString stringWithFormat:@"Rp %@",
                               [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
            titleLabel.text = [thisProduct valueForKey:@"prd_name"];
        }
    }
}

-(void) setMainPagerIndex: (NSInteger) index
{
    mainPagerIndex = (int)index;
}

- (IBAction)addToWishlist:(id)sender
{
    NSDictionary* _product;
    if (products.count<1) {
        _product = self.productToDisplay;
    }else{
        _product = (NSDictionary*)[products objectAtIndex:currentIndex];
    }
    [DataSingleton addItemToWishlist:_product isProductGrosir:[[_product valueForKey:@"prd_type"] isEqualToString:@"GR"]];
}

- (IBAction)addToCart:(id)sender
{
    [DataSingleton retrieveUser];
    if ([DataSingleton instance].loggedInUser!=nil) {
        [self showQuantityBox];
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

- (void)showQuantityBox{
    quantityBoxPopover.clipsToBounds = YES;
    CGPoint showPoint = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    [quantityBoxPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionUp withContentView:quantityBox inView:self.view];
    quantityBoxShown = true;
    currentQty = 1;
    [self updateQuantity];
    __weak typeof(self)weakSelf = self;
    quantityBoxPopover.didDismissHandler = ^{
        [weakSelf dismissQuantityBox];
    };
}

- (void)updateQuantity{
    quantityTextField.text = [NSString stringWithFormat:@"%d",currentQty];
}

- (void)putCurrentViewedItemToCart{
    NSMutableDictionary* _product;
    if (products.count<1) {
        _product = [NSMutableDictionary dictionaryWithDictionary:self.productToDisplay];
    }else{
        _product = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[products objectAtIndex:currentIndex]];
    }
    
    NSNumber* stock = [NSNumber numberWithInt:0];
    NSNumber* stockID;
    BOOL isProductGrosir = false;
    if ([_product objectForKey:@"is_grosir"]!=nil) {
        isProductGrosir = [[_product valueForKey:@"is_grosir"] boolValue];
    }else if([_product objectForKey:@"prd_type"]!=nil){
        isProductGrosir = [[_product valueForKey:@"prd_type"] isEqualToString:@"GR"]?YES:NO;
    }
    
    if (isProductGrosir) {
        stockID = [_product valueForKey:@"stock_id"];
    }else{
        NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[_product valueForKey:@"stock"] usingOptionData:[self createArrayOfSelectedOption]];
        
        stockID = [stockInfo valueForKey:@"stock_id"];
    }
    NSString* productSKU = [_product valueForKey:@"prd_SKU"];
    NSArray *filteredStock = [[DataSingleton instance].stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",productSKU,stockID]];
    if (filteredStock.count > 0) {
        NSMutableDictionary *existingStock = (NSMutableDictionary*)[filteredStock objectAtIndex:0];
        stock = (NSNumber*)[existingStock valueForKey:stock_qty_key];
        //stock = [NSNumber numberWithInt:([stock intValue]-[stockOnCart intValue])];
        if ([stock intValue]>=currentQty) {
            if (!isProductGrosir) {
                //set the variant option for retail product
                [_product setValue:[self createArrayOfSelectedOption] forKey:product_option_key];
                [_product setValue:[self createArrayOfSelectedOptionComplete] forKey:product_option_complete_key];
            }
            
            [DataSingleton addItemToCart:_product isProductGrosir:isProductGrosir asManyAs:currentQty];
            //decrease the stock
            stock = [NSNumber numberWithInt:([stock intValue]-currentQty)];
            [existingStock setValue:stock forKey:stock_qty_key];
        }else{
            UIAlertView *errorView;
            NSString *errorMsg = [NSString
                                  stringWithFormat:@"Stok yang tersedia untuk produk ini adalah %d, mohon ubah kembali jumlah pesanan anda",
                                  [stock intValue]];
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: errorMsg
                         delegate: self
                         cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
            
            [errorView show];
        }
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: [[_product valueForKey:@"prd_type"] isEqualToString:@"RT"]?message_out_of_stock_variant:message_out_of_stock
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
}

-(UIView *)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        return roundedView;
    } else {
        return view;
    }
    
}

-(IBAction)toggleColorLayout:(id)sender{
    self.viewColor.translatesAutoresizingMaskIntoConstraints = YES;
    colorBtn.translatesAutoresizingMaskIntoConstraints = YES;
    float movement = 90.0;
    if (IS_IPAD) {
        movement = 90.0;
    }else{
        movement = 64.0;
    }
    movement = viewColorIsHidden?movement:0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.viewColor.transform = CGAffineTransformMakeTranslation(-movement, 0);
                     }
                     completion:^(BOOL finished) {
                         /*self.view.userInteractionEnabled = YES;*/
                     }];
    viewColorIsHidden = !viewColorIsHidden;
}

- (IBAction)goToDetailProduct:(id)sender {
    DetailViewController *detailPage = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    NSMutableDictionary* _product;
    if (products.count<1) {
        _product = [self.productToDisplay mutableCopy];
    }else{
        _product = [(NSDictionary*)[products objectAtIndex:currentIndex] mutableCopy];
    }
    [_product setValue:[self createArrayOfSelectedOption] forKey:product_option_key];
    detailPage.productToDisplay = _product;
    detailPage.isRetail = [[_product valueForKey:@"prd_type"] isEqualToString:@"RT"];
    
    [self.navigationController pushViewController:detailPage animated:YES];
}

- (IBAction)selectVariant:(id)sender {
    [self showVariantViewPopover];
}

- (IBAction)submitQuantity:(id)sender {
    if ([quantityTextField validate]) {
        [quantityBoxPopover dismiss];
        currentQty = [quantityTextField.text intValue];
        [self putCurrentViewedItemToCart];
    }
    
}

- (IBAction)increaseQty:(id)sender {
    if ([quantityTextField validate]) {
        currentQty = [quantityTextField.text intValue];
        currentQty++;
        [self updateQuantity];
    }
    
}

- (IBAction)decreaseQty:(id)sender {
    if ([quantityTextField validate]) {
        currentQty = [quantityTextField.text intValue];
        currentQty--;
        if (currentQty<0) {
            currentQty=0;
        }
        [self updateQuantity];
    }
}

-(void)showVariantViewPopover{
    if (variantCollection.count>0) {
        variantPopover.clipsToBounds = YES;
        CGPoint showPoint = CGPointMake(CGRectGetMidX(chooseSizeBtn.frame), CGRectGetMinY(buttonWrapper.frame));
        [variantPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionUp withContentView:variantView inView:self.view];
        variantOptShown = true;
        __weak typeof(self)weakSelf = self;
        variantPopover.didDismissHandler = ^{
            [weakSelf dismissVariantOption];
        };
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: @""
                     message: @"Maaf tidak ada pilihan untuk produk ini"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
    
}

-(void)animateVariantTableIn{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{variantTableOption.alpha = 1.0f;}
                     completion:^(BOOL finished) {variantTableShown = true;}];
}

-(void)animateVariantTableOut{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{variantTableOption.alpha = 0.0f;}
                     completion:^(BOOL finished) {variantTableShown = false;}];
}

-(void)showVariantValue:(id)sender{
//    optionPopover = [DXPopover new];
//    [optionPopover setFrame:((UITextField*)sender).bounds];
//    [optionPopover showAtView:sender withContentView:nil inView:variantView];
    [variantView addSubview:variantTableOption];
    NSMutableDictionary *variantData = (NSMutableDictionary*)[variantCollection objectAtIndex:activeTextField.tag];
    NSNumber *selectedVal = [variantData valueForKey:variant_selected_key];
    selectedOption = [selectedVal intValue];
    NSArray* variantVal = [variantData valueForKey:variant_value_key];
    variantOptions = [[NSMutableArray alloc] initWithArray:variantVal];
    [variantTableOption reloadData];
    [self animateVariantTableIn];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (!variantTableShown) {
        if (textField==quantityTextField) {
            return YES;
        }
        activeTextField = textField;
        [self showVariantValue:textField];
    }else{
        if (activeTextField==textField) {
            [self animateVariantTableOut];
        }else{
            activeTextField = textField;
            [self showVariantValue:textField];
        }
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==quantityTextField) {
        [quantityTextField validate];
    }
    return YES;
}

-(void)dismissVariantOption{
    variantOptShown = false;

    NSMutableDictionary* _product;
    if (products.count<1) {
         _product = [NSMutableDictionary dictionaryWithDictionary:self.productToDisplay];
    }else{
         _product = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[products objectAtIndex:currentIndex]];
    }
    
    //update the stock
    NSString* productSKU = [_product valueForKey:@"prd_SKU"];
    NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[_product valueForKey:@"stock"] usingOptionData:[self createArrayOfSelectedOption]];
    NSNumber* productStockID;
    NSNumber* productStock;
    if (stockInfo) {
        productStock = [stockInfo valueForKey:@"stock"];
        productStockID = [stockInfo valueForKey:@"stock_id"];
    }
    
//    NSArray *filteredStock = [[DataSingleton instance].stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",productSKU,productStockID]];
//    if (filteredStock.count==0) {
//        [DataSingleton insertThisProductToStockKeeper:productSKU withStock:productStock andStockID:productStockID];
//    }
    [DataSingleton insertThisProductToStockKeeper:productSKU withStock:productStock andStockID:productStockID];
    
}

-(void)dismissQuantityBox{
    quantityBoxShown = false;
}

- (IBAction)showHideColorLayout:(id)sender {
}

- (void)addToCartToServer:(NSDictionary*)_product{
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
        [loading startAnimating];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,addItemToCartURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser.id_user forKey:@"user_id"];
        [request addPostValue:[_product valueForKey:@"prd_id"] forKey:@"product_id"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [loading stopAnimating];
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
    NSLog(@"finished");
    [loading stopAnimating];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (success) {
        //NSNumber* rowID = (NSNumber*)[jsonDictionary objectForKey:@"status"];
        NSDictionary* _product;
        if (products.count<1) {
            _product = self.productToDisplay;
        }else{
            _product = (NSDictionary*)[products objectAtIndex:currentIndex];
        }
        [DataSingleton addItemToCart:_product
                     isProductGrosir:[[_product valueForKey:@"prd_type"] isEqualToString:@"GR"]
                            asManyAs:currentQty];
        
    }else{
        NSString* errorMessage = (NSString*)[jsonDictionary objectForKey:@"message"];
        
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

- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"request login started");
}

#pragma mark - UITableView
#pragma mark - datasource

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==variantTableOption) {
        return variantOptions.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    int row = (int)indexPath.row;
    
    if (_tableView==variantTableOption) {
        NSDictionary* oneOptionValue = [variantOptions objectAtIndex:row];
        NSString* valueName = [oneOptionValue valueForKey:@"opt_val_name"];
        //Does the string live in memory and it has atleast one letter?
        if (valueName && [valueName length]>0) {
            //Yes. It is
            
            valueName = [valueName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                             withString:[[valueName substringToIndex:1] capitalizedString]];
        }
        cell.textLabel.text = valueName;
        [cell.textLabel setFont:[UIFont systemFontOfSize:fontSize]];
        cell.tag = row;
        if (cell.tag==selectedOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return textFieldHeight;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (_tableView==variantTableOption) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        selectedOption = (int)cell.tag;
        if (activeTextField!=nil) {
            activeTextField.text = cell.textLabel.text;
            NSMutableDictionary *variantData = (NSMutableDictionary*)[variantCollection objectAtIndex:activeTextField.tag];
            NSMutableArray* availableOpt = [variantData valueForKey:variant_value_key];
            NSDictionary* selectedOptData = [availableOpt objectAtIndex:selectedOption];
            //NSNumber *selectedVal = [variantData valueForKey:variant_selected_key];
            [variantData setValue:[NSNumber numberWithInt:selectedOption] forKey:variant_selected_key];
            [variantData setValue:selectedOptData forKey:variant_selected_data];
        }
        
    }
    
    [_tableView reloadData];
    [self animateVariantTableOut];
}

- (NSArray*)createArrayOfSelectedOption{
    NSMutableArray* optionValueHolder = [NSMutableArray array];
    for (int i = 0; i< variantCollection.count; i++) {
        NSMutableArray* optionValues = [[variantCollection objectAtIndex:i] valueForKey:variant_value_key];
        int selectedIndex = [(NSNumber*)[[variantCollection objectAtIndex:i] valueForKey:variant_selected_key] intValue];
        NSDictionary* selectedOptionValue = [optionValues objectAtIndex:selectedIndex];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *optionValueNumber = [f numberFromString:[selectedOptionValue valueForKey:@"opt_val_id"]];
        [optionValueHolder addObject:optionValueNumber];
    }
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [optionValueHolder sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    
    return optionValueHolder;
}

- (NSArray*)createArrayOfSelectedOptionComplete{
    NSMutableArray* optionValueHolder = [NSMutableArray array];
    for (int i = 0; i< variantCollection.count; i++) {
        //                    NSString* optionName = [[variantCollection objectAtIndex:i] valueForKey:variant_option_key];
        NSMutableArray* optionValues = [[variantCollection objectAtIndex:i] valueForKey:variant_value_key];
        int selectedIndex = [(NSNumber*)[[variantCollection objectAtIndex:i] valueForKey:variant_selected_key] intValue];
        NSDictionary* selectedOptionValue = [optionValues objectAtIndex:selectedIndex];
        [optionValueHolder addObject:selectedOptionValue];
    }
    
    return optionValueHolder;
}

- (IBAction)shareProduct:(id)sender
{
    if (products.count<1) {
        self.productToShare = self.productToDisplay;
    }else{
        self.productToShare = (NSDictionary*)[products objectAtIndex:currentIndex];
    }
    
    UIAlertView *dialog;
    
    dialog = [[UIAlertView alloc]
                 initWithTitle: @"Share produk via"
                 message: nil
                 delegate: self
                 cancelButtonTitle: @"Batal" otherButtonTitles: @"Facebook",@"Twitter", nil];
    dialog.tag = shareDialog;
    
    [dialog show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == shareDialog){
        switch (buttonIndex) {
            case 1:
                //share via facebook
                [self shareViaFacebookWithProduct:self.productToShare];
                break;
            case 2:
                //share via twitter
                [self shareViaTwitterWithProduct:self.productToShare];
                break;
            default:
                break;
        }
    }
    
}

-(void) shareViaFacebookWithProduct:(NSDictionary*)product{
    if(product){
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            SLComposeViewControllerCompletionHandler handler = ^(SLComposeViewControllerResult result){
                if(result == SLComposeViewControllerResultCancelled){
                    NSLog(@"cancelled");
                } else{
                    NSLog(@"done");
                }
                
                [controller dismissViewControllerAnimated:YES completion:nil];
            };
            
            controller.completionHandler = handler;
            
            [controller setTitle:@"Ayo belanja di Y2 Online Shop"];
            
            NSNumber* appropriatePrice = [product valueForKey:@"prd_price"];
            int price = [appropriatePrice intValue];
            NSNumberFormatter *commas = [NSNumberFormatter new];
            commas.numberStyle = NSNumberFormatterDecimalStyle;
            double incomeValue = (price / 1000.0);
            NSString *formattedPrice = [NSString stringWithFormat:@"Rp %@",
                                        [commas stringFromNumber:[NSNumber numberWithInt:incomeValue * 1000]]];
            
            NSString *message = [NSString stringWithFormat:@"Ayo belanja di Y2 Online Shop.\n%@, brand %@, dari %@, %@", [product valueForKey:@"prd_name"], [product valueForKey:@"brand_name"], [product valueForKey:@"nama_toko"], formattedPrice];
            
            [controller setInitialText:message];
            [controller addURL:[NSURL URLWithString:y2website]];
            
            NSMutableArray *imageArray = [NSMutableArray arrayWithArray:[product valueForKey:@"images"]];
            if(imageArray){
                UIImage *productImage = [self getImageFromURL:[imageArray objectAtIndex:0]];
                if(productImage){
                    [controller addImage:productImage];
                }
            }
            
            [self presentViewController:controller animated:YES completion:nil];
        } else{
            UIAlertView *dialog;
            
            dialog = [[UIAlertView alloc]
                      initWithTitle: title_error
                      message: @"Akun Facebook belum diset"
                      delegate: nil
                      cancelButtonTitle: @"OK" otherButtonTitles: nil];
            
            [dialog show];
        }
    } else{
        UIAlertView *dialog;
        
        dialog = [[UIAlertView alloc]
                  initWithTitle: title_error
                  message: @"Data produk tidak ditemukan"
                  delegate: nil
                  cancelButtonTitle: @"OK" otherButtonTitles: nil];
        
        [dialog show];
    }
}

-(void) shareViaTwitterWithProduct:(NSDictionary*)product{
    if(product){
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            SLComposeViewControllerCompletionHandler handler = ^(SLComposeViewControllerResult result){
                if(result == SLComposeViewControllerResultCancelled){
                    NSLog(@"cancelled");
                } else{
                    NSLog(@"done");
                }
                
                [controller dismissViewControllerAnimated:YES completion:nil];
            };
            
            controller.completionHandler = handler;
            
            NSNumber* appropriatePrice = [product valueForKey:@"prd_price"];
            int price = [appropriatePrice intValue];
            NSNumberFormatter *commas = [NSNumberFormatter new];
            commas.numberStyle = NSNumberFormatterDecimalStyle;
            double incomeValue = (price / 1000.0);
            NSString *formattedPrice = [NSString stringWithFormat:@"Rp %@",
                                        [commas stringFromNumber:[NSNumber numberWithInt:incomeValue * 1000]]];
            
            NSString *message = [NSString stringWithFormat:@"Ayo belanja di Y2 Online Shop.\n%@, brand %@, dari %@, %@", [product valueForKey:@"prd_name"], [product valueForKey:@"brand_name"], [product valueForKey:@"nama_toko"], formattedPrice];
            
            [controller setInitialText:message];
            [controller addURL:[NSURL URLWithString:y2website]];

            NSMutableArray *imageArray = [NSMutableArray arrayWithArray:[product valueForKey:@"images"]];
            if(imageArray){
                UIImage *productImage = [self getImageFromURL:[imageArray objectAtIndex:0]];
                if(productImage){
                    [controller addImage:productImage];
                }
            }
            
            [self presentViewController:controller animated:YES completion:nil];
        } else{
            UIAlertView *dialog;
            
            dialog = [[UIAlertView alloc]
                      initWithTitle: title_error
                      message: @"Akun Twitter belum diset"
                      delegate: nil
                      cancelButtonTitle: @"OK" otherButtonTitles: nil];
            
            [dialog show];
        }
    } else{
        UIAlertView *dialog;
        
        dialog = [[UIAlertView alloc]
                  initWithTitle: title_error
                  message: @"Data produk tidak ditemukan"
                  delegate: nil
                  cancelButtonTitle: @"OK" otherButtonTitles: nil];
        
        [dialog show];
    }
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    if(fileURL){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        result = [UIImage imageWithData:data];
    }
    
    return result;
}

@end
