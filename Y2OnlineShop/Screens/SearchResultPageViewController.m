//
//  SearchResultPageViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 2/4/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "SearchResultPageViewController.h"
#import "DataSingleton.h"
#import "Constants.h"
#import "CatalogueItem.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"
#import "DescriptionViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+UrlEncoding.h"
#define limitSearchResult 15
#define searchingText @"Searching...";
#define loadingText @"Loading...";

@interface SearchResultPageViewController ()

@end

@implementation SearchResultPageViewController
@synthesize searchKey,searchKeyLabel,searchResultCollection,noProductImg,noNetworkImg,loading,loadingOverlay,loadingWrapper,searchBarGrosir,searchBarRetail,isRetail,loadingMsgLabel;

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
    UIView* wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthContentView, CGRectGetHeight(contentView.frame))];
    //contentView.backgroundColor = [UIColor redColor];
    UIImageView *imageLogo = [[UIImageView alloc]init];
    imageLogo.contentMode = UIViewContentModeScaleAspectFit;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [imageLogo sizeToFit];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
    
    titleLabel.text = @"Hasil Pencarian";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapper addSubview:imageLogo];
    [wrapper addSubview:titleLabel];
    float spaceLeftLogoToSuperview = 0.0;
    //    if (IS_IPAD) {
    //        spaceLeftLogoToSuperview = 10.0f;
    //    }else {
    //        spaceLeftLogoToSuperview = 5.0f;
    //    }
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(wrapper,titleLabel,imageLogo);
    //padding left constraint for imageLogo
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-constantSpace-[imageLogo]" options:0 metrics: @{@"constantSpace":@(spaceLeftLogoToSuperview)} views:viewsDictionary]];
    //height constraint in order to not exceed navigationBar height
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageLogo(<=constantHeight)]" options:0 metrics:@{@"constantHeight":@(self.navigationController.navigationBar.frame.size.height)} views:viewsDictionary]];
    
    NSLayoutConstraint *aspectRatioConstraint =[NSLayoutConstraint
                                                constraintWithItem:imageLogo
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:imageLogo
                                                attribute:NSLayoutAttributeWidth
                                                multiplier:CGRectGetHeight(imageLogo.frame)/CGRectGetWidth(imageLogo.frame) //Aspect ratio: height:width
                                                constant:0.0f];
    [wrapper addConstraint:aspectRatioConstraint];
    
    //space constraint between imageLogo and titleLabel
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageLogo]-constantSpace-[titleLabel]-0-|" options:0 metrics: @{@"constantSpace":@(spaceLogoToTitle)} views:viewsDictionary]];
    
    [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [wrapper addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    wrapper.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [contentView addSubview:wrapper];
    
    searchBarRetail = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
    searchBarRetail.alpha=0;
    searchBarRetail.transform = CGAffineTransformMakeScale(0,0);
    [searchBarRetail setBackgroundColor:[UIColor clearColor]];
    searchBarRetail.barTintColor=[UIColor clearColor];
    searchBarRetail.placeholder = @"Cari Produk Retail...";
    searchBarRetail.delegate= self;
    searchBarRetail.tag = search_bar_retail;
    
    searchBarGrosir = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
    searchBarGrosir.alpha=0;
    searchBarGrosir.transform = CGAffineTransformMakeScale(0,0);
    [searchBarGrosir setBackgroundColor:[UIColor clearColor]];
    searchBarGrosir.barTintColor=[UIColor clearColor];
    searchBarGrosir.placeholder = @"Cari Produk Grosir...";
    searchBarGrosir.delegate= self;
    searchBarGrosir.tag = search_bar_grosir;
    
    UISearchBar *ref = isRetail?searchBarRetail:searchBarGrosir;
    ref.text = searchKey;
    
    [contentView addSubview:searchBarRetail];
    [contentView addSubview:searchBarGrosir];
    
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = searchBarRetail;
    [DataSingleton instance].searchBarGrosir = searchBarGrosir;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].searchBarProductRetail,[DataSingleton instance].searchBarProductGrosir, nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeData];
    [self initializeComponent];
    [self searchForProduct];
}

- (void)initializeData{
    searchResultList = [NSMutableArray array];
    [self initializeList];
}

- (void)initializeComponent{
    searchResultCollection.delegate = self;
    searchResultCollection.dataSource = self;
    [searchResultCollection registerNib:[UINib nibWithNibName:@"CatalogueItem" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Catalogue"];
    loadingWrapper.layer.cornerRadius = 10.0f;
    loadingMsgLabel.text = searchingText;
}

- (void)initializeList{
    currentPage = 0;
    refreshList = true;
    listReachEnd = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
    
}

#pragma mark ASIHttpRequest
#pragma mark delegate, datasource

-(void)searchForProduct{
    if (!listReachEnd) {
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
            currentPage++;
            loadingMsgLabel.text = searchingText;
            [self shallShowLoadingOverlay:YES];
            NSMutableString *composedString = [NSMutableString stringWithString:@""];
            NSString *urlEncodedSearchKey = [searchKey urlencode];
            [composedString appendFormat:@"%@%@?prd_type=%@&page=%d&limit=%d&keyword=%@",y2BaseURL,searchProductURL,isRetail?@"RT":@"GR",currentPage,limitSearchResult,urlEncodedSearchKey];
            if ([DataSingleton instance].loggedInUser!=nil) {
                //logged in user
                [composedString appendFormat:@"&user_id=%@",[DataSingleton instance].loggedInUser.id_user];
            }
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:composedString]];
            request.tag = searchProduct;

            [request setRequestMethod:@"GET"];
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
    }
}

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
    [self shallShowLoadingOverlay:NO];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case searchProduct:
            if (success) {
                if (searchResultList==nil || refreshList) {
                    searchResultList = [NSMutableArray array];
                    refreshList = false;
                }
                NSArray* searchResult = (NSArray *)[jsonDictionary objectForKey:@"data"];
                if (searchResult.count<limitSearchResult) {
                    listReachEnd = true;
                }
                for (NSDictionary* searchItemInfo in searchResult) {
                    NSMutableDictionary* searchItemData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [searchItemInfo keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [searchItemData setValue:[searchItemInfo objectForKey:key] forKey:key];
                    }
                    [searchResultList addObject:searchItemData];
                }
                [searchResultCollection reloadData];
                if (searchKey!=nil && searchKey.length>0) {
                    searchKeyLabel.text = [NSString stringWithFormat:@"%@ (%d produk)",searchKey,(int)searchResultList.count];
                }

                [self shallShowLoadingOverlay:NO];
            }else{
                [self shallShowLoadingOverlay:NO];
                
                if (searchResultList==nil || refreshList) {
                    searchResultList = [NSMutableArray array];
                    refreshList = false;
                }
                [searchResultCollection reloadData];
                if (searchKey!=nil && searchKey.length>0) {
                    searchKeyLabel.text = [NSString stringWithFormat:@"%@ (%d produk)",searchKey,0];
                }
            }
        default:
            break;
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
    descriptionPage.isRetail = isRetail;
    descriptionPage.type = CART_CATEGORY;
    [descriptionPage setMainPagerIndex:tappedItem];
    
    [self.navigationController pushViewController:descriptionPage animated:YES];
	NSLog(@"Queue finished");
    
}

#pragma mark UISearchBar
#pragma mark delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString* text = searchBar.text;
    if (text.length>0) {
        [searchBar resignFirstResponder];
        switch (searchBar.tag) {
            case search_bar_grosir:
                isRetail = false;
                break;
            case search_bar_retail:
                isRetail = true;
                break;
            default:
                break;
        }
        searchKey = text;
        [self initializeList];
        [self searchForProduct];
    }
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    
}

#pragma mark UICollectionView
#pragma mark delegate, datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return searchResultList.count;
}

- (CatalogueItem *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CatalogueItem *product = [collectionView dequeueReusableCellWithReuseIdentifier:@"Catalogue" forIndexPath:indexPath];
    int row = (int)[indexPath row];
    
    NSDictionary* searchResultItem = [searchResultList objectAtIndex:row];
    
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setColor:COLOR_PINK_Y2];
    activityIndicator.center = product.image.center;
    activityIndicator.hidesWhenStopped = YES;
    __weak UIImageView* tempImage = product.image;
    [product.image setImageWithURL:[searchResultItem valueForKey:@"img_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (!image) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 tempImage.image = [UIImage imageNamed:@"icon_no_img.png"];
             });
             
             NSLog(@"failed load image for description");
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [activityIndicator removeFromSuperview];
         });
         
     }];
    [product.image addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    product.name.text = [searchResultItem valueForKey:@"prd_name"];
    NSNumber* appropriatePrice = [searchResultItem valueForKey:@"prd_price"];
    int price = [appropriatePrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    product.price.text = [NSString stringWithFormat:@"Rp %@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    
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
    }else{
        //request product detail
        [self shallShowLoadingOverlay:YES];
        NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,isRetail? getProductURL:getProductGrosirURL];
        NSDictionary* singleProduct = [searchResultList objectAtIndex:tappedItem];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
        request.tag = tappedItem;
        [request setRequestMethod:@"POST"];
        
        //[request setUseKeychainPersistence:YES];
        [request addPostValue:[singleProduct valueForKey:@"prd_id"] forKey:@"prd_id"];
        
        [request setTimeOutSeconds:60];
        [networkQueue addOperation:request];
        if (tappedItem>0) {
            //fetched also previous item
            NSDictionary* singleProduct = [searchResultList objectAtIndex:tappedItem-1];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = tappedItem-1;
            [request setRequestMethod:@"POST"];
            
            //[request setUseKeychainPersistence:YES];
            [request addPostValue:[singleProduct valueForKey:@"prd_id"] forKey:@"prd_id"];
            
            [request setTimeOutSeconds:60];
            [networkQueue addOperation:request];
        }
        
        if (tappedItem<searchResultList.count-1) {
            //fetched also next item
            NSDictionary* singleProduct = [searchResultList objectAtIndex:tappedItem+1];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = tappedItem+1;
            [request setRequestMethod:@"POST"];
            
            //[request setUseKeychainPersistence:YES];
            [request addPostValue:[singleProduct valueForKey:@"prd_id"] forKey:@"prd_id"];
            
            [request setTimeOutSeconds:60];
            [networkQueue addOperation:request];
        }
        displayProducts = [searchResultList mutableCopy];
        removedProductIndexes = [NSMutableArray array];
        [networkQueue go];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height)
    {
        //LOAD MORE
        // you can also add a isLoading bool value for better dealing :D
        NSLog(@"load more");
        [self searchForProduct];
    }
}

@end
