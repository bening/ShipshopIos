//
//  CatalogueViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "CatalogueViewController.h"
#import "DescriptionViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "DataSingleton.h"
#import "Constants.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define item_per_page 10

@interface CatalogueViewController ()

@end

@implementation CatalogueViewController
@synthesize pageTitle,searchBarRetail,searchBarGrosir,category,store,products,loading,leftMenuReference, noProductImg, noNetworkImg,loadingOverlay,loadingWrapper, APIUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        widthContentView = 175;
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
        
        noProductImg.hidden = YES;
        noNetworkImg.hidden = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshProduct)];
        singleTap.numberOfTapsRequired = 1;
        [noNetworkImg setUserInteractionEnabled:YES];
        [noNetworkImg addGestureRecognizer:singleTap];
        
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
    titleLabel.text = pageTitle;
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
//    if (IS_IPAD) {
//        spaceLeftLogoToSuperview = 10.0f;
//    }else {
//        spaceLeftLogoToSuperview = 5.0f;
//    }
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
}

-(void)refreshProduct{
    noNetworkImg.hidden = YES;
    [self fetchProduct];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CatalogueItem" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Catalogue"];
    products = [NSMutableArray array];
    
    /*
     experiment
     */
    productsExperiment = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    /*
     end of experiment
     */
    
    loadingWrapper.layer.cornerRadius = 10.0f;
    
    currentPage = 0;
    listReachEnd = NO;
    
    [self fetchProduct];
    
}

/*
 experiment
 */

- (void)viewDidAppear:(BOOL)animated{
    [self setFetcingParameter];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self setFetcingParameter];
}

- (void)setFetcingParameter{
    /*
     experiment
     */
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            numberOfItemToFetch = 15;
            limitToFetchNewData = 3;
        }else if(IS_IPHONE_5)
        {
            numberOfItemToFetch = 9;
            limitToFetchNewData = 4;
        }else{
            numberOfItemToFetch = 9;
            limitToFetchNewData = 4;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            numberOfItemToFetch = 16;
            limitToFetchNewData = 4;
        }else if(IS_IPHONE_5)
        {
            numberOfItemToFetch = 9;
            limitToFetchNewData = 4;
        }else{
            numberOfItemToFetch = 9;
            limitToFetchNewData = 4;
        }
    }
    
    /*
     end of experiment
     */
}

/*
 end of experiment
 */

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    [DataSingleton instance].disableTouchOnLeftMenu = show;
    
}

-(void)fetchProduct{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus == NotReachable){
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: [NSString stringWithFormat:@"Tidak dapat mengakses data barang \n%@",message_connection_error]
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        //[errorView show];
        noNetworkImg.hidden = NO;
    }else{
        //useOwner means take shop/agent into consideration
        //isRetail means shall fetch retail product
        //isAllOwnerProduct means shall fetch all products of given shop/agent
        /*NSString * _myURL; = [NSString stringWithFormat:@"%@%@",y2BaseURL,useOwner? (isRetail? (isAllOwnerProduct? getAllProductByOwnerURL:getStoreProduct):(isAllOwnerProduct? getAllProductGrosirByOwnerURL:getStoreProductGrocier)):getProductByCatIdURL];*/
        if (!APIUrl) {
            noProductImg.hidden = NO;
        }else{
            currentPage++;
            [self shallShowLoadingOverlay:YES];
            NSMutableString *composedUrl = [NSMutableString stringWithString:APIUrl];
            [composedUrl appendFormat:@"&limit=%d&page=%d",item_per_page,currentPage];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:composedUrl]];
            
            [request setRequestMethod:@"GET"];
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [self shallShowLoadingOverlay:NO];
    NSLog(@"%@", request.error.description);
    UIAlertView *errorView;
    
    errorView = [[UIAlertView alloc]
                 initWithTitle: title_error
                 message: message_request_failed
                 delegate: self
                 cancelButtonTitle: @"OK" otherButtonTitles: nil];
    
    if(products){
        if(products.count == 0){
            noProductImg.hidden = NO;
        }
    } else{
        noProductImg.hidden = NO;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"finished");
    [self shallShowLoadingOverlay:NO];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (request.tag!=getProduct) {
        if (success) {
            
            NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
            if (data.count < item_per_page) {
                listReachEnd = true;
            }
            for (int i = 0; i<data.count; i++) {
                NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                NSMutableDictionary* productData = [[NSMutableDictionary alloc] init];
                NSEnumerator *enumerator = [datum keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    [productData setValue:[datum objectForKey:key] forKey:key];
                }
                [products addObject:productData];
                
                NSString* productSKU = [productData valueForKey:@"prd_SKU"];
                NSNumber* productStock = [[productData valueForKey:@"stock"] isEqual:[NSNull null]]? [NSNumber numberWithInt:0]:[productData valueForKey:@"stock"];
                NSNumber* productStockID = [[productData valueForKey:@"stock_id"] isEqual:[NSNull null]]? [NSNumber numberWithInt:0]:[productData valueForKey:@"stock_id"];
                
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
            }
            [self.collectionView reloadData];
            
        }else{
            if(products){
                if(products.count == 0){
                    noProductImg.hidden = NO;
                }
            } else{
                noProductImg.hidden = NO;
            }
        }
    }
}

- (void)oneRequestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
	//... Handle success
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
        
        if (displayProducts == nil) {
            displayProducts = [[DataSingleton instance].topProduct mutableCopy];
        }
        //add a mark that this data already got its detail
        [productData setValue:[NSNumber numberWithBool:true] forKey:markDetailedProduct];
        
        [displayProducts replaceObjectAtIndex:request.tag withObject:productData];
        
        
    }else{
        if (request.tag>=0 && request.tag<[DataSingleton instance].topProduct.count) {
            if (removedProductIndexes == nil) {
                removedProductIndexes = [NSMutableArray array];
            }
            [removedProductIndexes addObject:[NSNumber numberWithInt:request.tag]];
        }
        
    }
	NSLog(@"Request finished");
}

- (void)oneRequestFailed:(ASIHTTPRequest *)request
{
    if (request.tag>=0 && request.tag<[DataSingleton instance].topProduct.count) {
        if (removedProductIndexes == nil) {
            removedProductIndexes = [NSMutableArray array];
        }
        [removedProductIndexes addObject:[NSNumber numberWithInt:request.tag]];
    }
    
	NSLog(@"Request failed");
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	// You could release the queue here if you wanted
	if ([networkQueue requestsCount] == 0) {
		networkQueue = nil;
	}
    [self shallShowLoadingOverlay:NO];
    DescriptionViewController *descriptionPage = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
    descriptionPage.indexProduct = tappedItem;
    
    descriptionPage.products = displayProducts;
    descriptionPage.productToDisplay = [displayProducts objectAtIndex:tappedItem];
    descriptionPage.type = CART_CATEGORY;
    [descriptionPage setMainPagerIndex:tappedItem];
    
    [self.navigationController pushViewController:descriptionPage animated:YES];
	NSLog(@"Queue finished");
    
}

- (void)removeErrorProduct{
    BOOL decreaseIndex = false;
    for (NSNumber* prdIndex in removedProductIndexes) {
        [displayProducts removeObjectAtIndex:[prdIndex intValue]];
        if ([prdIndex intValue]<=tappedItem) {
            //if previous or selected item detaill failed to get, decrease the index
            //since the (failed) item will be removed from the list
            decreaseIndex = true;
        }
    }
    if (decreaseIndex) {
        tappedItem--;
        if (tappedItem<0) {
            tappedItem = 0;
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return products.count;
}

- (BOOL)isKey:(NSString*)key ValidOnDictionary:(NSDictionary*)dictionary{
    return (![[dictionary objectForKey:key] isEqual:[NSNull null]]
            && [dictionary objectForKey:key] != nil);
}

- (CatalogueItem *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CatalogueItem *product = [collectionView dequeueReusableCellWithReuseIdentifier:@"Catalogue" forIndexPath:indexPath];
    int row = (int)[indexPath row];
    
    NSDictionary* thisProduct = [products objectAtIndex:row];
    if ([self isKey:@"img_url" ValidOnDictionary:thisProduct]) {
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = product.image.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* tempImage = product.image;
        [product.image setImageWithURL:[NSURL URLWithString:[thisProduct valueForKey:@"img_url"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     tempImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for description");
             }
             [[thisProduct valueForKey:@"img_url"] isEqual:[NSNull null]];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
             
         }];
        [product.image addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }else{
        product.image.image = [UIImage imageNamed:@"icon_no_img.png"];
    }
    
    if ([(NSNumber*)[thisProduct valueForKey:@"stock"] intValue]==0) {
        product.name.textColor = [UIColor redColor];
        product.price.textColor = [UIColor redColor];
    }else{
        product.name.textColor = [UIColor blackColor];
        product.price.textColor = [UIColor blackColor];
    }
    product.name.text = [thisProduct valueForKey:@"prd_name"];
    NSNumber* appropriatePrice = [thisProduct valueForKey:@"prd_price"];
    int price = [appropriatePrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    product.price.text = [NSString stringWithFormat:@"Rp %@",
                        [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    
    if(indexPath.row == products.count-1){
        //load more data
        if(!listReachEnd){
            [self fetchProduct];
        }
    }
    
    /*
     experiment
     */
//    if ((int)[indexPath row]==products.count-limitToFetchNewData) {
//        NSLog(@"row : %d",(int)[indexPath row]);
//        NSLog(@"load another data");
//        BOOL useOwner = store!=nil;
//        [self fetchProductBaseOnCategoryOnly:useOwner];
//    }
    
    
    
    /*
     end of experiment
     */
    return product;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self shallShowLoadingOverlay:YES];
    int row = (int)[indexPath row];
    tappedItem = row;
    [networkQueue cancelAllOperations];
    networkQueue = [ASINetworkQueue queue];
    networkQueue.delegate = self;
    [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
	[networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
    [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
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
        [self shallShowLoadingOverlay:NO];
    }else{
        //request product detail
        NSDictionary* singleProduct = [products objectAtIndex:tappedItem];
        NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,[[singleProduct valueForKey:@"prd_type"] isEqualToString:@"RT"]? getProductURL:getProductGrosirURL];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
        request.tag = tappedItem;
        [request setRequestMethod:@"POST"];
        
        //[request setUseKeychainPersistence:YES];
        [request addPostValue:[singleProduct valueForKey:@"prd_id"] forKey:@"prd_id"];
        
        [request setTimeOutSeconds:60];
        [networkQueue addOperation:request];
        if (tappedItem>0) {
            //fetched also previous item
            NSDictionary* singleProduct = [products objectAtIndex:tappedItem-1];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = tappedItem-1;
            [request setRequestMethod:@"POST"];
            
            //[request setUseKeychainPersistence:YES];
            [request addPostValue:[singleProduct valueForKey:@"prd_id"] forKey:@"prd_id"];
            
            [request setTimeOutSeconds:60];
            [networkQueue addOperation:request];
        }
        
        if (tappedItem<products.count-1) {
            //fetched also next item
            NSDictionary* singleProduct = [products objectAtIndex:tappedItem+1];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = tappedItem+1;
            [request setRequestMethod:@"POST"];
            
            //[request setUseKeychainPersistence:YES];
            [request addPostValue:[singleProduct valueForKey:@"prd_id"] forKey:@"prd_id"];
            
            [request setTimeOutSeconds:60];
            [networkQueue addOperation:request];
        }
        displayProducts = [products mutableCopy];
        removedProductIndexes = [NSMutableArray array];
        [networkQueue go];
    }

}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
//    NSLog(@"visiblePaths number : %d",visiblePaths.count);
//    if([indexPath row] == ((NSIndexPath*)[[self.collectionView indexPathsForVisibleItems] lastObject]).row){
//        //end of loading
//        //for example [activityIndicator stopAnimating];
//        
//    }
//}

//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadDataForOnscreenRows
{
    if (products.count > 0)
    {
        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSLog(@"visible row: %d",(int)indexPath.row);
//            CatalogueItem *product = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Catalogue" forIndexPath:indexPath];
//            
//            NSDictionary* thisProduct = (products)[indexPath.row];
//            NSArray* images = (NSArray*)[thisProduct valueForKey:@"images"];
//            
//            if (images.count >0) {
//                NSString* imageUrl = (NSString*)[images objectAtIndex:0];
//                [product.image setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
//            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scrollViewDidEndDragging");
    if (!decelerate)
	{
        //NSLog(@"scrollViewDidEndDragging and stop");
        ///[self loadDataForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    //[self loadDataForOnscreenRows];
}


@end
