//
//  HomeViewController.m
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/3/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "HomeViewController.h"
#import "DataSingleton.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DescriptionViewController.h"
#import "SearchResultPageViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
static HomeViewController * currentInstance;

@synthesize leftMenuReference;
@synthesize mainWrapper;
@synthesize searchBarRetail, iCarouselWrapper,videoWrapper,scrollerBot,scrollerTop,loading,searchBarGrosir,imageScroller, pageControl;

+(HomeViewController*)getCurrentInstance
{
    return currentInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentInstance = self;
        heightContentView = 170;
        widthContentView = 175;
        heightScreenVideo = 0;
        varIpad = 0;
        varIpadImage = 0;
        carouselItemsTop = [[DataSingleton instance].topBrand copy];
        //[DataSingleton retrieveShop];
        carouselItemsBot = [[DataSingleton instance].topProduct copy];//[DataSingleton retrieveY2];
        
        if (IS_IPAD) {
            varIpad = 150;
            varIpadImage = 0;
            widthContentView = (widthContentView*4)-80;
            heightScreenVideo = 420;
            
        }
        else
        {
            heightScreenVideo = IS_IPHONE_5?240:150;
        }
        touchBlocked = false;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

- (void)setUpScroller{
    for (id v in scrollerTop.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    for (id v in scrollerBot.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    
    scrollerTop.canCancelContentTouches = NO;
    scrollerBot.canCancelContentTouches= NO;
    scrollerTop.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollerBot.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollerTop.showsHorizontalScrollIndicator = YES;
    scrollerBot.showsHorizontalScrollIndicator = YES;
    scrollerTop.alwaysBounceVertical = NO;
    scrollerBot.alwaysBounceVertical = NO;
    scrollerTop.clipsToBounds = YES;
    scrollerTop.scrollEnabled = YES;
    scrollerTop.pagingEnabled = NO;
    scrollerBot.clipsToBounds = YES;
    scrollerBot.scrollEnabled = YES;
    scrollerBot.pagingEnabled = NO;
    
    [scrollerTop setNeedsLayout];
    [scrollerTop layoutIfNeeded];
    [scrollerBot setNeedsLayout];
    [scrollerBot layoutIfNeeded];
}

- (void)setupHorizontalScrollView
{
    [self setUpScroller];
    CGFloat coordinatex = 0;
    for (int i=0; i<[DataSingleton instance].topSeller.count; i++) {
        NSDictionary* singleProduct = [[DataSingleton instance].topSeller objectAtIndex:i];
        
        UIImageView *productImage = [[UIImageView alloc]initWithFrame:CGRectMake(coordinatex, 0, scrollerTop.frame.size.height-5, scrollerTop.frame.size.height-5)];
        productImage.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        productImage.contentMode = UIViewContentModeScaleAspectFit;
        productImage.backgroundColor = [UIColor whiteColor];
        productImage.tag = i;
        
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = productImage.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* thisProductImage = productImage;
        [productImage setImageWithURL:[singleProduct valueForKey:@"seller_img"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     thisProductImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for top product");
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
         }];
        [productImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sellerTapped:)];
        singleTap.numberOfTapsRequired = 1;
        [productImage setUserInteractionEnabled:YES];
        [productImage addGestureRecognizer:singleTap];
        [scrollerTop addSubview:productImage];
        coordinatex += productImage.frame.size.width+5;
    }
    [scrollerTop setContentSize:CGSizeMake(coordinatex, [scrollerTop bounds].size.height-5)];

    coordinatex = 0;
    for (int i=0; i<[DataSingleton instance].topProduct.count; i++) {
        NSDictionary* singleSeller = [[DataSingleton instance].topProduct objectAtIndex:i];
        
        UIImageView *productImage = [[UIImageView alloc]initWithFrame:CGRectMake(coordinatex, 0, scrollerBot.frame.size.height-5, scrollerBot.frame.size.height-5)];
        productImage.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        productImage.contentMode = UIViewContentModeScaleAspectFit;
        productImage.backgroundColor = [UIColor whiteColor];
        productImage.tag = i;

        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = productImage.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* thisProductImage = productImage;
        [productImage setImageWithURL:[singleSeller valueForKey:@"img_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     thisProductImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for top product");
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
         }];
        [productImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productTapped:)];
        singleTap.numberOfTapsRequired = 1;
        [productImage setUserInteractionEnabled:YES];
        [productImage addGestureRecognizer:singleTap];
        [scrollerBot addSubview:productImage];
        coordinatex += productImage.frame.size.width+5;
    }
    [scrollerBot setContentSize:CGSizeMake(coordinatex, [scrollerBot bounds].size.height-5)];
    
}

- (void)shallShowOverlay:(BOOL)shallShow{
    if (shallShow) {
        [loading startAnimating];
        mainWrapper.userInteractionEnabled = NO;
        mainWrapper.alpha = 0.5;
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    }else{
        [loading stopAnimating];
        mainWrapper.userInteractionEnabled = YES;
        mainWrapper.alpha = 1.0;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }
}

- (void)prepareAPIRequestQueue{
    [networkQueue cancelAllOperations];
    networkQueue = [ASINetworkQueue queue];
    networkQueue.delegate = self;
    [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
    [networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
    [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
}

- (void)addProductToAPIRequestQueueAtIndex:(int)productIndex{
    NSDictionary* product = [[DataSingleton instance].topProduct objectAtIndex:productIndex];
    NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,[[product valueForKey:@"product_type"] isEqualToString:@"RT"]? getProductURL:getProductGrosirURL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
    request.tag = productIndex;
    [request setRequestMethod:@"POST"];
    [request addPostValue:[product valueForKey:@"prd_id"] forKey:@"prd_id"];
    [request setTimeOutSeconds:60];
    
    [networkQueue addOperation:request];
}

- (void)getDetailProductForTappedProduct{
    [self addProductToAPIRequestQueueAtIndex:indexOfSelectedTopProduct];
}

- (void)getDetailProductForPreviousProduct{
    [self addProductToAPIRequestQueueAtIndex:indexOfSelectedTopProduct-1];
}

- (void)getDetailProductForNextProduct{
    [self addProductToAPIRequestQueueAtIndex:indexOfSelectedTopProduct+1];
}

-(void)productTapped:(id)sender{
    if (!touchBlocked) {
        touchBlocked = true;
        
        UIGestureRecognizer *recognizer = (UIGestureRecognizer*)sender;
        UIImageView *imageView = (UIImageView *)recognizer.view;
        indexOfSelectedTopProduct = (int)imageView.tag;
        
        if([DataSingleton deviceHasInternetConnection])
        {
            [self shallShowOverlay:YES];
            [self prepareAPIRequestQueue];
            
            [self getDetailProductForTappedProduct];
            if (indexOfSelectedTopProduct>0) {
                [self getDetailProductForPreviousProduct];
            }
            
            if (indexOfSelectedTopProduct<[DataSingleton instance].topProduct.count-1) {
                [self getDetailProductForNextProduct];
            }
            displayProducts = [[DataSingleton instance].topProduct mutableCopy];
            removedProductIndexes = [NSMutableArray array];
            [networkQueue go];
        }else{
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: message_connection_error
                         delegate: self
                         cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
            
            [errorView show];
        }
    }
    
}

-(void)sellerTapped:(id)sender{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*)sender;
    UIImageView *imageView = (UIImageView *)recognizer.view;
    indexOfSelectedTopSeller = (int)imageView.tag;
    NSDictionary *tappedSeller = [[DataSingleton instance].topSeller objectAtIndex:indexOfSelectedTopSeller];
    if (tappedSeller) {
        [leftMenuReference goToCategoryPageProduct:[tappedSeller valueForKey:@"api_url"] withTitle:[tappedSeller valueForKey:@"seller_name"]];
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
        
        if (displayProducts == nil) {
            displayProducts = [[DataSingleton instance].topProduct mutableCopy];
        }
        //add a mark that this data already had its detail
        [productData setValue:[NSNumber numberWithBool:true] forKey:markDetailedProduct];
        
        [displayProducts replaceObjectAtIndex:request.tag withObject:productData];
        
        
    }else{
        if (request.tag==indexOfSelectedTopProduct) {
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
	if ([networkQueue requestsCount] == 0) {
		networkQueue = nil;
	}
    [self shallShowOverlay:NO];

    DescriptionViewController *descriptionPage = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
    descriptionPage.indexProduct = indexOfSelectedTopProduct;
    
    descriptionPage.products = displayProducts;
    descriptionPage.productToDisplay = [displayProducts objectAtIndex:indexOfSelectedTopProduct];
    descriptionPage.isRetail = [DataSingleton instance].isTopProductRetail;//![[[displayProducts objectAtIndex:indexOfSelectedTopProduct] valueForKey:@"is_grosir"] boolValue];//[DataSingleton instance].isTopProductRetail;
    descriptionPage.type = CART_CATEGORY;
    [descriptionPage setMainPagerIndex:indexOfSelectedTopProduct];
    touchBlocked = false;
    [self.navigationController pushViewController:descriptionPage animated:YES];
	NSLog(@"Queue finished");
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self shallShowOverlay:NO];
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
    [self shallShowOverlay:NO];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case getProduct:
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
                DescriptionViewController *descriptionPage = [[DescriptionViewController alloc] initWithNibName:@"DescriptionViewController" bundle:nil];
                descriptionPage.indexProduct = indexOfSelectedTopProduct;
                displayProducts = [[DataSingleton instance].topProduct mutableCopy];
                [displayProducts replaceObjectAtIndex:indexOfSelectedTopProduct withObject:productData];
                descriptionPage.products = displayProducts;
                descriptionPage.productToDisplay = productData;
                descriptionPage.isRetail = isRetailProduct;//[DataSingleton instance].isTopProductRetail;
                descriptionPage.type = CART_CATEGORY;
                [descriptionPage setMainPagerIndex:indexOfSelectedTopProduct];
                
                [self.navigationController pushViewController:descriptionPage animated:YES];
                
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
            break;
        default:
            break;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"view did appear");
    [self setupHorizontalScrollView];
    [self setupImageSlider];
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
    titleLabel.text = @"Home";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapper addSubview:imageLogo];
    [wrapper addSubview:titleLabel];
    float spaceLeftLogoToSuperview = 0.0;
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
    viewsDictionary = NSDictionaryOfVariableBindings(contentView,searchBarRetail,searchBarGrosir);
    //constraint for searchBar in order to extend its width to the fullest width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarRetail]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarGrosir]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    //constraint for searchBar in order to extend its height to the height width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarRetail]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarGrosir]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.navigationItem.titleView = contentView;
        
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = searchBarRetail;
    [DataSingleton instance].searchBarGrosir = searchBarGrosir;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].wishBarButtonItem, [DataSingleton instance].shopBarButtonItem, [DataSingleton instance].searchBarProductRetail,[DataSingleton instance].searchBarProductGrosir, nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
}

- (void)resumeHomeVideo{
    if (moviePlayerController.playbackState == MPMoviePlaybackStatePaused||moviePlayerController.playbackState == MPMoviePlaybackStateStopped) {
        if (moviePlayerController.playbackState == MPMoviePlaybackStateStopped) {
            NSURL *fileURL = [NSURL URLWithString:[DataSingleton instance].homeVideoUrl];
            
            moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
            [moviePlayerController setControlStyle:MPMovieControlStyleNone];
        }
        [moviePlayerController play];
        moviePlayerController.repeatMode = MPMovieRepeatModeOne;
    }
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self setupHorizontalScrollView];
    [self setupImageSlider];
}

- (void)viewWillLayoutSubviews
{
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
    {
        //x,y as you want
        isPortrait = false;
    }
    else
    {
        //In potrait
        isPortrait= true;
    }
    
}

- (void)viewDidLoad
{
    [self disableSlidePanGestureForRightMenu];
    [self disableSlidePanGestureForLeftMenu];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString* text = searchBar.text;
    if (text.length>0) {
        [searchBar resignFirstResponder];
        SearchResultPageViewController *searchViewController = [[SearchResultPageViewController alloc] initWithNibName:@"SearchResultPageViewController" bundle:nil];
        switch (searchBar.tag) {
            case search_bar_grosir:
                searchViewController.isRetail = false;
                break;
            case search_bar_retail:
                searchViewController.isRetail = true;
                break;
            default:
                break;
        }
        searchViewController.searchKey = text;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    
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

- (void)setupImageSlider
{
    for (id v in imageScroller.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    
    imageScroller.canCancelContentTouches = NO;
    imageScroller.canCancelContentTouches= NO;
    imageScroller.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    imageScroller.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    imageScroller.showsHorizontalScrollIndicator = YES;
    imageScroller.showsHorizontalScrollIndicator = YES;
    imageScroller.alwaysBounceVertical = NO;
    imageScroller.alwaysBounceVertical = NO;
    imageScroller.clipsToBounds = YES;
    imageScroller.scrollEnabled = YES;
    imageScroller.clipsToBounds = YES;
    imageScroller.scrollEnabled = YES;
    imageScroller.pagingEnabled = YES;

    //populate slide show
    CGFloat coordinatex = 0;
    [imageScroller setNeedsLayout];
    [imageScroller layoutIfNeeded];
   
    if([DataSingleton instance].promoList){
        pageControl.numberOfPages = [DataSingleton instance].promoList.count;
        pageControl.currentPage = 0;
        
        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:[DataSingleton instance].sliderTime.intValue target:self selector:@selector(scrollingTimer) userInfo:nil repeats:YES];
        
        for (int i=0; i<[DataSingleton instance].promoList.count; i++) {
            NSDictionary* singlePromo = [[DataSingleton instance].promoList objectAtIndex:i];
            
            UIImageView *productImage = [[UIImageView alloc]initWithFrame:CGRectMake(coordinatex, 0, imageScroller.frame.size.width-5, imageScroller.frame.size.height-5)];
            productImage.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
            productImage.contentMode = UIViewContentModeScaleAspectFit;
            productImage.backgroundColor = [UIColor whiteColor];
            productImage.tag = i;
            __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [activityIndicator setColor:COLOR_PINK_Y2];
            activityIndicator.center = productImage.center;
            activityIndicator.hidesWhenStopped = YES;
            __weak UIImageView* thisProductImage = productImage;
            [productImage setImageWithURL:[singlePromo valueForKey:@"promotion_image_url"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
             {
                 if (!image) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         thisProductImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                     });
                     
                     NSLog(@"failed load image for slide show");
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [activityIndicator removeFromSuperview];
                 });
             }];
            [productImage addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoTapped:)];
            singleTap.numberOfTapsRequired = 1;
            [productImage setUserInteractionEnabled:YES];
            [productImage addGestureRecognizer:singleTap];
            [imageScroller addSubview:productImage];
            
            coordinatex += productImage.frame.size.width+5;
        }
        [imageScroller setContentSize:CGSizeMake(coordinatex, [scrollerTop bounds].size.height-5)];
    }
}

-(void)promoTapped:(id)sender{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*)sender;
    UIImageView *imageView = (UIImageView *)recognizer.view;
    
    int index = (int)imageView.tag;
    if([DataSingleton instance].promoList && [DataSingleton instance].promoList.count > index){
        NSDictionary *singlePromo = [[DataSingleton instance].promoList objectAtIndex:index];
        if([singlePromo valueForKey:@"promotion_url"]){
            if([self validateUrl:[singlePromo valueForKey:@"promotion_url"]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [singlePromo valueForKey:@"promotion_url"]]];
            } else{
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_error
                             message: @"Link tidak bisa dibuka. Format url tidak valid."
                             delegate: nil
                             cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
                
                [errorView show];
            }
        } else{
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: @"Link tidak bisa dibuka. Data url tidak ditemukan."
                         delegate: nil
                         cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
            
            [errorView show];
        }
    } else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Link tidak bisa dibuka. Data url tidak ditemukan."
                     delegate: nil
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
}

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed, do your thing!
        // ...
        // Finally, update previous page
        previousPage = page;
        pageControl.currentPage = page;
    }
}

- (void)scrollingTimer {
    CGFloat contentOffset = imageScroller.contentOffset.x;
    // calculate next page to display
    int nextPage = (int)(contentOffset/imageScroller.frame.size.width) + 1 ;
    // if page is not 10, display it
    if( nextPage != pageControl.numberOfPages )  {
        [imageScroller scrollRectToVisible:CGRectMake(nextPage*imageScroller.frame.size.width, 0, imageScroller.frame.size.width, imageScroller.frame.size.height) animated:YES];
        pageControl.currentPage=nextPage;
        // else start sliding form 1 :)
    } else {
        [imageScroller scrollRectToVisible:CGRectMake(0, 0, imageScroller.frame.size.width, imageScroller.frame.size.height) animated:YES];
        pageControl.currentPage=0;
    }
}

@end
