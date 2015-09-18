//
//  ProductListViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 1/22/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "ProductListViewController.h"
#import "AddNewProductViewController.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define deleteAlert 17

#define gender_dropdown 2
#define category_dropdown 3
#define item_per_page 10

static NSString * const ProductCellIdentifier = @"ProductCell";
@interface ProductListViewController ()

@end

@implementation ProductListViewController
@synthesize pageTitle,addProductBtn,searchLabel,searchField,tableTitle,productTable,isRetailProduct,loadingOverlay,loadingWrapper,loading, sku, gender, productName, category, dropdownTableView, wraper, mainScroller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
        
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
    titleLabel.text = [NSString stringWithFormat:@"Produk %@",isRetailProduct?@"Retail":@"Grosir"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    float spaceLeftLogoToSuperview = 0.0;
//    if (IS_IPAD) {
//        spaceLeftLogoToSuperview = 10.0f;
//    }else {
//        spaceLeftLogoToSuperview = 5.0f;
//    }
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(contentView,titleLabel,imageLogo);
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
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    
    [self filterProductList:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations)
    {
        [req clearDelegatesAndCancel];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeData];
    [self initializeComponent];
    [self initializeParameter];
//    [self requestProductList];
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    if(!IS_IPAD){
        UIView *mainView = self.view;
        
        // Set the constraints for the scroll view and the image view.
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(mainScroller, wraper, mainView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainScroller]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wraper]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wraper]|" options:0 metrics: 0 views:viewsDictionary]];
        
        //hack to tie contentView width to the width of the screen
        [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[wraper(==mainView)]" options:0 metrics:0 views:viewsDictionary]];
    }
    
}

- (void)initializeComponent{
    productTable.delegate  = self;
    productTable.dataSource = self;
    [productTable registerNib:[UINib nibWithNibName:@"ProductListCell" bundle:nil] forCellReuseIdentifier:ProductCellIdentifier];
    productTable.layer.borderWidth = 2.0;
    productTable.layer.borderColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1].CGColor;
    
    searchField.delegate = self;
    if (IS_IPAD) {
        pageTitle.font = FONT_ARSENAL(25);
        searchLabel.font = FONT_ARSENAL(17);
        tableTitle.font = FONT_ARSENAL(17);
    }else{
        pageTitle.font = FONT_ARSENAL(17);
        searchLabel.font = FONT_ARSENAL(13);
        tableTitle.font = FONT_ARSENAL(13);
    }
    
    
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    dropdownPopover = [DXPopover new];
    dropdownPopover.maskType = DXPopoverMaskTypeNone;
    dropdownTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240.0, 265.0) style:UITableViewStylePlain];
    dropdownTableView.backgroundColor = [UIColor lightGrayColor];
    dropdownTableView.delegate = self;
    dropdownTableView.dataSource = self;
    
    for (id subview in wraper.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, ((UITextField*)subview).frame.size.height)];
            ((UITextField*)subview).leftView = paddingView;
            ((UITextField*)subview).leftViewMode = UITextFieldViewModeAlways;
        }
    }
    
    if(isRetailProduct){
        if([DataSingleton instance].menuTambahProduct){
            addProductBtn.hidden = NO;
        } else{
            addProductBtn.hidden = YES;
        }
    } else{
        if([DataSingleton instance].menuTambahProductGrosir){
            addProductBtn.hidden = NO;
        } else{
            addProductBtn.hidden = YES;
        }
    }
}

- (void)initializeData{
    productList = [NSMutableArray array];
    indexOfSelectedProduct = -1;
    
    selectedGenderIndex = -1;
    selectedCategoryIndex = -1;
    
    dropdownValues = [NSMutableArray array];
    genderValues = [NSMutableArray array];
    categoryValues = [NSMutableArray array];
    categoryDict = [NSMutableDictionary dictionary];
    
    [genderValues addObject:@""];
    for (NSDictionary* catData in [DataSingleton instance].categoryData) {
        [genderValues addObject:[catData valueForKey:@"gender"]];
    }
    
    selectedSKU = @"";
    selectedGender = @"";
    selectedProductName = @"";
    selectedCategory = @"";
    
    currentPage = 0;
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    [DataSingleton instance].disableTouchOnLeftMenu = show;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField
#pragma mark - delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ASIHTTPRequest
#pragma mark - request

- (void)requestProductList
{
    if(!productListReachEnd){
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
        }else
        {
            [self shallShowLoadingOverlay:YES];
            currentPage++;
            NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,getProductListURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
            
            [request setRequestMethod:@"POST"];
            [DataSingleton retrieveUser];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
            
            [request addPostValue:isRetailProduct?@"R":@"G" forKey:@"prd_type"];
            [request addPostValue:selectedSKU forKey:@"prd_sku"];
            [request addPostValue:selectedProductName forKey:@"prd_name"];
            [request addPostValue:selectedGender forKey:@"prd_gender"];
            [request addPostValue:selectedCategory forKey:@"prd_category"];
            [request addPostValue:[NSNumber numberWithInteger:currentPage] forKey:@"page"];
            [request addPostValue:[NSNumber numberWithInteger:item_per_page] forKey:@"limit"];
            
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
    }
}

- (void)deleteProductAtIndex:(int)indexOfProduct
{
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
    }else
    {
        [self shallShowLoadingOverlay:YES];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,deleteProductURL];
        NSDictionary *productData = [productList objectAtIndex:indexOfProduct];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = deleteProduct;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[productData valueForKey:@"prd_id"] forKey:@"prd_id"];
        [request addPostValue:[NSNumber numberWithBool:!isRetailProduct] forKey:@"is_grosir"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestForCategory
{
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
    }else
    {
        [self shallShowLoadingOverlay:YES];
        NSMutableString* composedUrl = [NSMutableString stringWithFormat:@"%@%@?gender_id=%@&prd_type=%@",y2BaseURL,getProductCategoryURL,[selectedGenderName isEqualToString:@"Pria"]?@"P":@"W",isRetailProduct?@"RT":@"GR"];
                
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:composedUrl]];
        request.tag = getProductCategory;
        [request setRequestMethod:@"GET"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

#pragma mark - delegate

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self shallShowLoadingOverlay:NO];
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
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (request.tag==deleteProduct) {
        [self shallShowLoadingOverlay:NO];
        if (success) {
            [productList removeObjectAtIndex:indexOfSelectedProduct];
            [productTable reloadData];
        }else{
            NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: errorMessage
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
        }
    }else if (request.tag==getProductCategory) {
        [self shallShowLoadingOverlay:NO];
        if (success) {
            NSArray* catList = [NSArray arrayWithArray:(NSArray*)[jsonDictionary objectForKey:@"data"]];
            [categoryDict setObject:catList forKey:selectedGenderName];
            for (NSDictionary* catGender in catList) {
                [categoryValues addObject:[catGender valueForKey:@"path"]];
            }
        }else{
            NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: errorMessage
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
        }
    }else{
        if (success) {
            
            NSArray* resultProductList = (NSArray*)[jsonDictionary objectForKey:@"data"];
            if (resultProductList.count<item_per_page) {
                productListReachEnd = true;
            }
            for (NSDictionary* productInfo in resultProductList) {
                NSMutableDictionary* productData = [[NSMutableDictionary alloc] init];
                NSEnumerator *enumerator = [productInfo keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    [productData setValue:[productInfo objectForKey:key] forKey:key];
                }
                [productList addObject:productData];
            }
            [productTable reloadData];
            [self shallShowLoadingOverlay:NO];
        }else{
            [self shallShowLoadingOverlay:NO];
            NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: errorMessage
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            if (productList.count==0) {
                [errorView show];
            }
        }
    }
}

#pragma mark - UITableView
#pragma mark - datasource, delegate

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == productTable){
        return [productList count];
    } else if(tableView == dropdownTableView){
        return [dropdownValues count];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == productTable){
        
        ProductListCell *cell = (ProductListCell*)[tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier forIndexPath:indexPath];
        int row = (int)[indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = row;
        
        NSDictionary *productData = [productList objectAtIndex:row];
        NSDictionary *categoryData = [productData valueForKey:@"cat_data"];
        NSDictionary *brandData = [productData valueForKey:@"brand_data"];
        NSNumber *itemPrice = [productData valueForKey:@"prd_price"];
        int price = [itemPrice intValue];
        NSNumberFormatter *commas = [NSNumberFormatter new];
        commas.numberStyle = NSNumberFormatterDecimalStyle;
        double formattedItemPrice = (price / 1000.0);
        
        //[cell.image setImageWithURL:[productData valueForKey:@"img_url"] placeholderImage:nil];
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = cell.image.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* thisImage = cell.image;
        [thisImage setImageWithURL:[productData valueForKey:@"img_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
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
        
        cell.sku.text = [productData valueForKey:@"prd_SKU"];
        cell.name.text = [productData valueForKey:@"prd_name"];
        cell.category.text = [categoryData valueForKey:@"cat_name"];
        cell.brand.text = [brandData valueForKey:@"brand_name"];
        cell.price.text = [NSString stringWithFormat:@"Rp %@,-",
                           [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
//        cell.stock.text = [productData valueForKey:@"stock"];
        cell.stock.text = [NSString stringWithFormat:@"%@", [productData valueForKey:@"stock"]];
        [cell.deleteBtn addTarget:self action:@selector(deleteItemAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        cell.deleteBtn.tag = row;
        [cell.editBtn addTarget:self action:@selector(editItemAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        cell.editBtn.tag =row;
        
        if(isRetailProduct){
            cell.stockLabel.hidden = YES;
            cell.stockLabelDoublePeriod.hidden = YES;
            cell.stock.hidden = YES;
        }
        
        [cell layoutIfNeeded];        
        
         
        if (indexPath.row == [productList count] - 1)
        {
            [self requestProductList];
        }
        
        return cell;
    } else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
            
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        int row = (int)indexPath.row;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[dropdownValues objectAtIndex:row]];
        cell.tag = row;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == productTable)
        return [self heightForBasicCellAtIndexPath:indexPath];
    else
        return 44.0;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static ProductListCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [productTable dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    
    NSDictionary *productData = [productList objectAtIndex:row];
    NSDictionary *categoryData = [productData valueForKey:@"cat_data"];
    NSDictionary *brandData = [productData valueForKey:@"brand_data"];
    NSNumber *itemPrice = [productData valueForKey:@"prd_price"];
    int price = [itemPrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double formattedItemPrice = (price / 1000.0);
    
    //[sizingCell.image setImageWithURL:[productData valueForKey:@"img_url"] placeholderImage:nil];
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setColor:COLOR_PINK_Y2];
    activityIndicator.center = sizingCell.image.center;
    activityIndicator.hidesWhenStopped = YES;
    __weak UIImageView* thisImage = sizingCell.image;
    [thisImage setImageWithURL:[productData valueForKey:@"img_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
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
    
    sizingCell.sku.text = [productData valueForKey:@"prd_SKU"];
    sizingCell.name.text = [productData valueForKey:@"prd_name"];
    sizingCell.category.text = [categoryData valueForKey:@"cat_name"];
    sizingCell.brand.text = [brandData valueForKey:@"brand_name"];
    sizingCell.price.text = [NSString stringWithFormat:@"Rp %@,-",
                       [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
    sizingCell.stock.text = [NSString stringWithFormat:@"%@", [productData valueForKey:@"stock"]];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(productTable.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    if(tableView == productTable){
        int row = (int)[indexPath row];
        indexOfSelectedProduct = row;
        NSDictionary* selectedProduct = [productList objectAtIndex:row];
        [self goToEditPage:selectedProduct];
    } else if(tableView == dropdownTableView){
        UITableViewCell *cell = [dropdownTableView cellForRowAtIndexPath:indexPath];
        int _row = (int)cell.tag;
        NSString* selectedValue = [dropdownValues objectAtIndex:_row];
        if (activeTextField!=nil) {
            activeTextField.text = [NSString stringWithFormat:@"%@",selectedValue];
            if (activeTextField==gender) {
                if (selectedGenderIndex!=_row) {
                    //gender changed
                    //repopulate category
                    selectedGenderIndex = _row;
                    categoryValues = [NSMutableArray array];
                    [categoryValues addObject:@""];
                    if(selectedGenderIndex > 0){
                        selectedGenderName = [(NSDictionary*)[[DataSingleton instance].categoryData objectAtIndex:selectedGenderIndex - 1] valueForKey:@"gender"];
                        NSMutableArray *catForGender = (NSMutableArray*)[categoryDict objectForKey:selectedGenderName];
                        
                        if (!catForGender) {
                            //category unavailable yet, request for it
                            [self requestForCategory];
                        }else{
                            for (NSDictionary* catGender in catForGender) {
                                [categoryValues addObject:[catGender valueForKey:@"path"]];
                            }
                        }
                        
                    }
                    selectedCategoryIndex = -1;
                    category.text = @"";
                }
                
            }else if (activeTextField==category){
                selectedCategoryIndex = _row;
            }
  
        }
        [self hideDropDown];
        
        [tableView reloadData];
    }
}

#pragma mark - IBOutlet Event

- (IBAction)addProduct:(id)sender {
    [self goToEditPage:nil];
}

- (void)goToEditPage:(NSDictionary*)productData{
    AddNewProductViewController *editPoductPage = [[AddNewProductViewController alloc] initWithNibName:@"AddNewProductViewController" bundle:nil];
    editPoductPage.productData = productData;
    editPoductPage.delegate = self;
    editPoductPage.isRetailProduct = isRetailProduct;
    [self.navigationController pushViewController:editPoductPage animated:YES];
}

- (void)editItemAtIndex:(id)sender{
    int row = (int)((UIButton*)sender).tag;
    indexOfSelectedProduct = row;
    NSDictionary* selectedProduct = [productList objectAtIndex:row];
    [self goToEditPage:selectedProduct];
    
}

- (void)deleteItemAtIndex:(id)sender{
    int row = (int)((UIButton*)sender).tag;
    indexOfSelectedProduct = row;
    UIAlertView *deleteConfirmation = [[UIAlertView alloc] initWithTitle:@"Konfirmasi"
                                                                 message:@"Anda yakin ingin menghapus produk ini?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Tidak"
                                                       otherButtonTitles:@"Ya", nil];
    deleteConfirmation.tag = deleteAlert;
    [deleteConfirmation show];
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==deleteAlert){
        if (buttonIndex==0) {
            NSLog(@"delete produk: tidak");
        }else{
            NSLog(@"delete produk: ya");
            [self deleteProductAtIndex:indexOfSelectedProduct];
        }
    }
    
}

#pragma mark - VCDelegate
#pragma respond to submited edited product (updated product) if any

-(void)submitEditedProduct:(BOOL)didSubmit{
//    if (didSubmit) {
//        //refresh product list
//        [self requestProductList];
//    }
}

-(void)addNewProduct:(BOOL)didAddSuccessfully{
//    if (didAddSuccessfully) {
//        [self requestProductList];
//    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeTextField = textField;
    
    if(textField == gender){
        if(popoverShown){
            [self hideDropDown];
        } else{
            [self setOptionListFor:gender_dropdown withTextFieldRef:gender];
            [self updateDropDownPopover];
            [self showDropDownInside:self.wraper];
        }
        return  NO;
    } else if (textField == category) {
        if(popoverShown){
            [self hideDropDown];
        } else{
            [self setOptionListFor:category_dropdown withTextFieldRef:category];
            [self updateDropDownPopover];
            [self showDropDownInside:self.wraper];
        }
        return NO;
    } else{
        if(popoverShown){
            [self hideDropDown];
        }
    }
    
    return YES;
}

- (void)setOptionListFor:(int)thisOptionKind withTextFieldRef:(UITextField*)referenceTextField{
    switch (thisOptionKind) {
        case gender_dropdown:
            dropdownValues = [genderValues mutableCopy];
            [dropdownTableView reloadData];
            [dropdownTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            break;
        case category_dropdown:
            dropdownValues = [categoryValues mutableCopy];
            [dropdownTableView reloadData];
            [dropdownTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            break;
        
        default:
            break;
    }
}

- (void)showDropDownInside:(UIView*)wrapper{
    CGPoint showPoint = CGPointMake(CGRectGetMinX(wrapper.frame)+CGRectGetMidX(activeTextField.frame), CGRectGetMinY(wrapper.frame)+CGRectGetMaxY(activeTextField.frame));
    dropdownPopover.maskType = DXPopoverMaskTypeNotExist;
    [dropdownPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionDown withContentView:dropdownTableView inView:self.wraper];
    [dropdownTableView flashScrollIndicators];
    popoverShown = true;
}

- (void)hideDropDown{
    CGPoint showPoint = CGPointMake(-500, -500);
    dropdownPopover.maskType = DXPopoverMaskTypeNotExist;
    [dropdownPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionUp withContentView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] inView:self.wraper];
    popoverShown = false;
}

-(void)updateDropDownPopover{
    if (dropdownValues.count>5) {
        [dropdownTableView setFrame:CGRectMake(0, 0, 240.0, 120.0+80.0)];
    }else{
        [dropdownTableView setFrame:CGRectMake(0, 0, 240.0, 44.0 * (dropdownValues.count > 0 ? dropdownValues.count : 1))];
    }
    [dropdownPopover setFrame:dropdownTableView.bounds];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
    if(popoverShown){
        [self hideDropDown];
    }
}

- (void)initializeParameter{
    currentPage = 0;
    selectedSKU = sku.text;
    selectedProductName = productName.text;
    switch (selectedGenderIndex) {
        case 0:
            selectedGender = @"";
            break;
        case 1:
            selectedGender = @"P";
            break;
        case 2:
            selectedGender = @"W";
            break;
        default:
            break;
    }
    
    if(selectedCategoryIndex > 0 && categoryValues != nil && categoryValues.count > selectedCategoryIndex){
        NSArray* genderCategory = [(NSDictionary*)[[DataSingleton instance].categoryData objectAtIndex:selectedGenderIndex - 1] valueForKey:@"data"];
        NSDictionary *chosenCategory = [genderCategory objectAtIndex:selectedCategoryIndex - 1];
        selectedCategory = [chosenCategory valueForKey:@"cat_id"];
//        selectedCategory = [categoryValues objectAtIndex:selectedCategoryIndex];
    } else{
        selectedCategory = @"";
    }
    
    productListReachEnd = false;
}

-(void) clearProductList{
    productList = [NSMutableArray array];
    [productTable reloadData];
}

- (IBAction)filterProductList:(id)sender{
    [self clearProductList];
    [self initializeParameter];
    [self requestProductList];
}

@end
