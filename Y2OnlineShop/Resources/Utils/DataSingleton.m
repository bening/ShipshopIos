//
//  DataSingleton.m
//  Y2OnlineShop
//
//  Created by maverick on 11/26/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "DataSingleton.h"
#import "CartViewController.h"
#import "Constants.h"
#import "SearchResultPageViewController.h"

@implementation DataSingleton
@synthesize searchBarProductRetail,shopBarButtonItem,wishBarButtonItem,userWishList,searchBarRetail,searchBarGrosir;

static DataSingleton *gInstance = NULL;

+ (DataSingleton *)instance
{
    @synchronized(self)
    {
        if (gInstance == NULL){
            gInstance = [[self alloc] init];
            gInstance.wishCartStack = [NSNumber numberWithInt:0];
            gInstance.topBrand = [NSMutableArray array];
            gInstance.topProduct = [NSMutableArray array];
            gInstance.allCategory = [NSMutableArray array];
            gInstance.allStore = [NSMutableArray array];
            gInstance.allAgent = [NSMutableArray array];
            gInstance.allCity = [NSMutableArray array];
            gInstance.allAccount = [NSMutableArray array];
            gInstance.stockKeeper = [NSMutableArray array];
            gInstance.footer1MenuList = [NSMutableArray array];
            gInstance.footer2MenuList = [NSMutableArray array];
            gInstance.footer3MenuList = [NSMutableArray array];
            gInstance.footer4MenuList = [NSMutableArray array];
            gInstance.messageCollection = [NSDictionary dictionary];
            NSDictionary* maleGender = [NSDictionary dictionaryWithObjectsAndKeys:@"Pria",@"gender", nil];
            NSDictionary* femaleGender = [NSDictionary dictionaryWithObjectsAndKeys:@"Wanita",@"gender", nil];
            gInstance.categoryData = [NSMutableArray arrayWithObjects:maleGender,femaleGender, nil];
            gInstance.allBrand = [NSMutableArray array];
            gInstance.allOrderStatus = [NSMutableArray array];
            gInstance.allReturStatus = [NSMutableArray array];
            gInstance.errorNotificationMessage = [NSMutableString string];
            gInstance.paymentInfo = [NSMutableDictionary dictionary];
            
            [self retrieveUser];
            if (gInstance.loggedInUser!=nil) {
                gInstance.isLogin = true;
            }
            gInstance.showShopMenu = false;
            gInstance.showAgentMenu = false;
            gInstance.showCategoryMenu = false;
            gInstance.showMyAccountMenu = false;
            gInstance.showRetailProduct = false;
            gInstance.showGrosirProduct = false;
            gInstance.showSalesOrder = false;
            gInstance.showSalesRetur = false;
            gInstance.isTopProductRetail = false;
            gInstance.disableTouchOnLeftMenu = false;
            gInstance.sliderTime = [NSNumber numberWithInt:5];
            //initialize wishlist
            gInstance.userWishList = [[Wishlist alloc] initWithID:[NSNumber numberWithInt:0] andProducts:[NSArray array]];
            
            //initialize shopping cart
            gInstance.usedCart = [[Cart alloc] initWithID:[NSNumber numberWithInt:1] andProducts:[NSArray array]];
            
            gInstance.cartCollection = [NSMutableArray array];
            
            //initialise cart button
            UIButton *shopBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
            [shopBarButton setImage:[UIImage imageNamed:@"icon_bag_32.png"] forState:UIControlStateNormal];
            [shopBarButton addTarget:self action:@selector(shopAction) forControlEvents:UIControlEventTouchUpInside];
            gInstance.shopBarButtonItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:shopBarButton];
            gInstance.shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.usedCart.items count]];
            gInstance.shopBarButtonItem.shouldHideBadgeAtZero = true;
            
            //initialize wishlist button
            UIButton *wishBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [wishBarButton setImage:[UIImage imageNamed:@"icon_wishlist_32.png"] forState:UIControlStateNormal];
            [wishBarButton addTarget:self action:@selector(wishListAction) forControlEvents:UIControlEventTouchUpInside];
            wishBarButton.hidden = YES;
            gInstance.wishBarButtonItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:wishBarButton];
            gInstance.wishBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.userWishList.items count]];
            gInstance.wishBarButtonItem.shouldHideBadgeAtZero = true;
            gInstance.wishBarButtonItem.badgePadding = 5.0;
            
            //initialize search button retail
            UIButton *searchBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
            [searchBarButton setImage:[UIImage imageNamed:@"icon_search_32.png"] forState:UIControlStateNormal];
            [searchBarButton addTarget:self action:@selector(toggleSearch:) forControlEvents:UIControlEventTouchUpInside];
            searchBarButton.tag = search_bar_retail;
            gInstance.searchBarProductRetail = [[UIBarButtonItem alloc] initWithCustomView:searchBarButton];
            
            //initialize search button
            UIButton *searchBarButtonG = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
            [searchBarButtonG setImage:[UIImage imageNamed:@"icon_search_pink.png"] forState:UIControlStateNormal];
            [searchBarButtonG addTarget:self action:@selector(toggleSearch:) forControlEvents:UIControlEventTouchUpInside];
            searchBarButtonG.tag = search_bar_grosir;
            gInstance.searchBarProductGrosir = [[UIBarButtonItem alloc] initWithCustomView:searchBarButtonG];
            
            gInstance.enableShopCartBtn = true;
            gInstance.enableWishListBtn = true;
            gInstance.menuDataString = @"{\"status\": true,\"message\": \"Success\",\"data\": [{\"id\": \"P\",\"name\": \"Pria\",\"url\": null,\"child\": [{\"id\": \"P-TOKO\",\"name\": \"Toko\",\"url\": null,\"child\": [{\"id\": \"P-TOKO-1\",\"name\": \"Yers 2\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1\",\"child\": [{\"id\": \"P-TOKO-1-ALL\",\"name\": \"Semua Produk\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1\",\"child\": []},{\"id\": \"P-TOKO-1-107\",\"name\": \"Pakaian\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1&cat_id=107\",\"child\": [{\"id\": \"TOKO-1-107-ALL\",\"name\": \"Semua\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1&cat_id=107\",\"child\": []},{\"id\": \"TOKO-1-107-117\",\"name\": \"Atasan\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1&cat_id=117\",\"child\": []}]}]}]},{\"id\": \"AGEN\",\"name\": \"Agen\",\"url\": null,\"child\": []},{\"id\": \"KATEGORI_GR\",\"name\": \"Kategori\",\"url\": null,\"child\": []},{\"id\": \"KATEGORI_RT\",\"name\": \"Kategori\",\"url\": null,\"child\": []}]},{\"id\": \"W\",\"name\": \"Wanita\",\"url\": null,\"child\": [{\"id\": \"W-TOKO\",\"name\": \"Toko\",\"url\": null,\"child\": [{\"id\": \"W-TOKO-1\",\"name\": \"Yers 2\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1\", \"child\": [{\"id\": \"W-TOKO-1-ALL\",\"name\": \"Semua Produk\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1\",\"child\": []},{\"id\": \"W-TOKO-1-107\",\"name\": \"Pakaian\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1&cat_id=107\",\"child\": [{\"id\": \"TOKO-1-107-ALL\",\"name\": \"Semua\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1&cat_id=107\",\"child\": []},{\"id\": \"TOKO-1-107-117\",\"name\": \"Atasan\",\"url\": \"https://tokoy2.com/api/product/get_all_product?user_id=212&owner_id=1&cat_id=117\",\"child\": []}]}]}]},{\"id\": \"AGEN\",\"name\": \"Agen\",\"url\": null,\"child\": []},{\"id\": \"KATEGORI_GR\",\"name\": \"Kategori\",\"url\": null,\"child\": []},{\"id\": \"KATEGORI_RT\",\"name\": \"Kategori\",\"url\": null,\"child\": []}]}]}";
            gInstance.userMenuTree = [NSArray array];
            gInstance.maleData = [NSMutableDictionary dictionary];
            gInstance.femaleData = [NSMutableDictionary dictionary];
            
        }
    }
    
    return(gInstance);
}


+(NSMutableDictionary*)createNTree:(NSDictionary*)parent{
    NSMutableDictionary* newNode = [NSMutableDictionary dictionary];
    [newNode setValue:[parent valueForKey:@"id"] forKey:@"id"];
    [newNode setValue:[parent valueForKey:@"name"] forKey:@"name"];
    [newNode setValue:[[parent valueForKey:@"url"] isEqual:[NSNull null]]?@"":[parent valueForKey:@"url"] forKey:@"url"];
    if ([[parent valueForKey:@"child"] isKindOfClass:[NSArray class]]) {
        if ([(NSArray*)[parent valueForKey:@"child"] count]) {
            NSMutableArray *newNodeChilds = [NSMutableArray array];
            for (int i=0; i<[(NSArray*)[parent valueForKey:@"child"] count]; i++) {
                if ([[(NSArray*)[parent valueForKey:@"child"] objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *childNode = [(NSArray*)[parent valueForKey:@"child"] objectAtIndex:i];
                    [newNodeChilds addObject:[self createNTree:childNode]];
                }
            }
            
            [newNode setValue:newNodeChilds forKey:@"child"];
        }else{
            [newNode setValue:[NSMutableArray array] forKey:@"child"];
        }
    }else{
        [newNode setValue:[NSMutableArray array] forKey:@"child"];
    }
    return newNode;
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
        if (NULL!=gInstance.navigationController)
            [gInstance.navigationController pushViewController:searchViewController animated:YES];
    }
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    
}

+(void)checkDevice{
    if(IS_IPAD)
    {
        NSLog(@"IS_IPAD");
    }
    if(IS_IPHONE)
    {
        NSLog(@"IS_IPHONE");
    }
    if(IS_RETINA)
    {
        NSLog(@"IS_RETINA");
    }
    if(IS_IPHONE_4_OR_LESS)
    {
        NSLog(@"IS_IPHONE_4_OR_LESS");
    }
    if(IS_IPHONE_5)
    {
        NSLog(@"IS_IPHONE_5");
    }
    if(IS_IPHONE_6)
    {
        NSLog(@"IS_IPHONE_6");
    }
    if(IS_IPHONE_6P)
    {
        NSLog(@"IS_IPHONE_6P");
    }
    
    NSLog(@"SCREEN_WIDTH: %f", SCREEN_WIDTH);
    NSLog(@"SCREEN_HEIGHT: %f", SCREEN_HEIGHT);
    NSLog(@"SCREEN_MAX_LENGTH: %f", SCREEN_MAX_LENGTH);
    NSLog(@"SCREEN_MIN_LENGTH: %f", SCREEN_MIN_LENGTH);
}

+(void)shopAction
{
    if (NULL!=gInstance.navigationController && gInstance.enableShopCartBtn) {
        CartViewController *cartViewController = [[CartViewController alloc] initWithNibName:@"CartViewController" bundle:nil];
        NSMutableArray* viewControllers = [gInstance.navigationController.viewControllers mutableCopy];
        if ([gInstance.wishCartStack intValue]>=2) {
            
            [viewControllers removeObjectAtIndex:[viewControllers count]-2];
            gInstance.navigationController.viewControllers = viewControllers;
            
            gInstance.wishCartStack = [NSNumber numberWithInt:[gInstance.wishCartStack intValue]+1];
            [gInstance.navigationController pushViewController:cartViewController animated:YES];
            
        }else if ([viewControllers count]>=2){
            if ([[viewControllers objectAtIndex:[viewControllers count]-2] isKindOfClass:[CartViewController class]]) {
                NSLog(@"previous page is cart");
                [viewControllers removeObjectAtIndex:[viewControllers count]-2];
                gInstance.navigationController.viewControllers = viewControllers;
            }
            gInstance.wishCartStack = [NSNumber numberWithInt:[gInstance.wishCartStack intValue]+1];
            [gInstance.navigationController pushViewController:cartViewController animated:YES];
        }else{
            gInstance.wishCartStack = [NSNumber numberWithInt:[gInstance.wishCartStack intValue]+1];
            [gInstance.navigationController pushViewController:cartViewController animated:YES];
        }
    }
    
}

+(void)wishListAction
{
    if (NULL!=gInstance.navigationController && gInstance.enableWishListBtn) {
        WishListViewController *wishListViewController = [[WishListViewController alloc] initWithNibName:@"WishListViewController" bundle:nil];
        if ([gInstance.wishCartStack intValue]>=2) {
            NSMutableArray* viewControllers = [gInstance.navigationController.viewControllers mutableCopy];
            [viewControllers removeObjectAtIndex:[viewControllers count]-2];
            gInstance.navigationController.viewControllers = viewControllers;
        }
        gInstance.wishCartStack = [NSNumber numberWithInt:[gInstance.wishCartStack intValue]+1];
        [gInstance.navigationController pushViewController:wishListViewController animated:YES];
    }
}

+(void)hideSearchBar:(UISearchBar*)searchBarTarget{
    searchBarTarget.alpha = 0.0;
    searchBarTarget.transform = CGAffineTransformMakeScale(0,0);
    [searchBarTarget resignFirstResponder];
}

+(void)showSearchBar:(UISearchBar*)searchBarTarget{
    searchBarTarget.alpha = 1.0;
    searchBarTarget.transform = CGAffineTransformIdentity;
    [searchBarTarget becomeFirstResponder];
}

+(void)toggleSearch:(id)sender {
    NSLog(@"search button clicked");
    switch (((UIButton*)sender).tag) {
        case search_bar_retail:
            if (NULL!=gInstance.searchBarRetail) {
                if(gInstance.searchBarRetail.alpha==0) {
                    [UIView animateWithDuration:0.25
                                     animations:^{
                                         //show retail, hide grosir if shown
                                         if (gInstance.searchBarGrosir.alpha==1) {
                                             [self hideSearchBar:gInstance.searchBarGrosir];
                                         }
                                         [self showSearchBar:gInstance.searchBarRetail];
                                         
                                     }];
                    
                }else {
                    [UIView animateWithDuration:0.25
                                     animations:^{
                                         //hide retail
                                         [self hideSearchBar:gInstance.searchBarRetail];
                                     }];
                }
            }
            break;
        case search_bar_grosir:
            if (NULL!=gInstance.searchBarGrosir) {
                if(gInstance.searchBarGrosir.alpha==0) {
                    [UIView animateWithDuration:0.25
                                     animations:^{
                                         //show grosir, hide retail if shown
                                         if (gInstance.searchBarRetail.alpha==1) {
                                             [self hideSearchBar:gInstance.searchBarRetail];
                                         }
                                         [self showSearchBar:gInstance.searchBarGrosir];
                                         
                                     }];
                    
                }else {
                    [UIView animateWithDuration:0.25
                                     animations:^{
                                         //hide grosir
                                         [self hideSearchBar:gInstance.searchBarGrosir];
                                     }];
                }
            }
            break;
        default:
            break;
    }
    
}


+(BOOL)isThisOptionValue:(NSArray*)optionValue1 equalTo:(NSArray*)optionValue2{
    BOOL equalOptionValue = true;
    if (optionValue1.count == optionValue2.count) {
        if (optionValue1.count==0 || optionValue2.count==0) {
            equalOptionValue &= false;
        }
        for (int i=0; i<optionValue1.count; i++) {
            equalOptionValue &= ([(NSNumber*)[optionValue1 objectAtIndex:i] intValue] == [(NSNumber*)[optionValue2 objectAtIndex:i] intValue]);
            if (!equalOptionValue) {
                break;
            }
        }
    }else{
        equalOptionValue = false;
    }
    
    return equalOptionValue;
}

+(void)addItemToCart:(NSDictionary*)addedProduct isProductGrosir:(BOOL)isGrosir asManyAs:(int)quantity{
    if (NULL!=gInstance.usedCart) {
        NSArray *cartItem = [self retrieveShopCart];
        NSArray* images = (NSArray*)[addedProduct valueForKey:@"images"];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber* productId = [nf numberFromString:(NSString*)[addedProduct valueForKey:@"prd_id"]];
        Product* newItem = [[Product alloc]initWithID:productId andName:(NSString*)[addedProduct valueForKey:@"prd_name"] withImages:[NSMutableArray arrayWithArray:images] withPrice:(NSNumber*)[addedProduct valueForKey:@"prd_price"] andRetailPrice:(NSNumber*)[addedProduct valueForKey:@"prd_price"]];
        [newItem setCompleteData:[NSMutableDictionary dictionaryWithDictionary:addedProduct]];
        BOOL exist = false;
        
        //get the varID if retail product
        NSNumber *addedProductOptVarID;
        NSArray* selectedOptionValSorted;
        if (!isGrosir) {
            selectedOptionValSorted = [NSArray arrayWithArray:(NSArray*)[addedProduct valueForKey:product_option_key]];
            NSDictionary* stockInfo = [self getStockFromStockOption:[addedProduct valueForKey:@"stock"] usingOptionData:selectedOptionValSorted];
            if (stockInfo) {
                addedProductOptVarID = [nf numberFromString:(NSString*)[stockInfo valueForKey:@"var_id"]];
            }
        }
        
        for (M_Cart* cart in cartItem) {
            if ([cart.id_product intValue] == [newItem.ID intValue]) {
                if (isGrosir) {
                    exist = true;
                    [self increaseShopCartItemQuantity:cart asManyAs:quantity];
                    break;
                }else{
                    //NSNumber *productVarID = cart.var_id;
                    SBJsonParser *parser = [[SBJsonParser alloc] init];
                    NSArray *optionData = [parser objectWithString:cart.option error:nil];
                    exist = [self isThisOptionValue:optionData equalTo:selectedOptionValSorted];
                    //exist = ([productVarID intValue]==[addedProductOptVarID intValue]);
                    if (exist) {
                        [self increaseShopCartItemQuantityRetail:cart asManyAs:quantity];
                        break;
                    }

                }
            }
        }
        if (!exist) {
            if (isGrosir) {
                [self storeShopCart:newItem isProductGrosir:isGrosir
                         withOption:nil
                              andID:nil
                           asManyAs:quantity];
            }else{
                [self storeShopCart:newItem isProductGrosir:isGrosir
                         withOption:selectedOptionValSorted
                              andID:addedProductOptVarID
                           asManyAs:quantity];
            }
        }
        [gInstance.usedCart addNewProduct:newItem asManyAs:quantity];
        gInstance.shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.usedCart.totalItem intValue]];
    }
}


+(BOOL)insertAllFreeCartToLoggedInUser{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_owner==0"];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSNumber* loggedInUser = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [self retrieveUser];
    if (gInstance.loggedInUser!=nil) {
        loggedInUser = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    for (M_Cart * cart in cartItems) {
        cart.id_owner = loggedInUser;
    }
    return [_managedObjectContex save:nil];
    
}

+(void)addItemToWishlist:(NSDictionary*)addedProduct isProductGrosir:(BOOL)isGrosir{
    NSArray *storedWishList = [self retrieveWishList];
    NSArray* images = (NSArray*)[addedProduct valueForKey:@"images"];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* productId = [nf numberFromString:(NSString*)[addedProduct valueForKey:@"prd_id"]];
    Product* newItem = [[Product alloc]initWithID:productId andName:(NSString*)[addedProduct valueForKey:@"prd_name"] withImages:[NSMutableArray arrayWithArray:images] withPrice:(NSNumber*)[addedProduct valueForKey:@"prd_price"] andRetailPrice:(NSNumber*)[addedProduct valueForKey:@"prd_price"]];
    [newItem setCompleteData:[NSMutableDictionary dictionaryWithDictionary:addedProduct]];
    BOOL exist = false;
    for (M_Wishlist* storedItem in storedWishList) {
        if ([storedItem.id_product intValue] == [newItem.ID intValue]) {
            exist = true;
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: @"Produk sudah ada pada wishlist"
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
        }
    }
    if (!exist) {
        //if new item added to wishlist
        [gInstance.userWishList addNewProduct:newItem];
        gInstance.wishBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.userWishList.items count]];
        [self storeWishList:newItem isProductGrosir:isGrosir];
    }
    
    
}

+ (void) deleteAllObjects: (NSString *) entityDescription  {
    NSManagedObjectContext *_managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[_managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",entityDescription);
    }
    if (![_managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

+(BOOL)storeWishList:(Product*)newItem isProductGrosir:(BOOL)isGrosir;{
    int latestID = [self getLatestWishListId];
    latestID++;
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    M_Wishlist *_wishlistTable = (M_Wishlist*)[NSEntityDescription insertNewObjectForEntityForName:@"M_Wishlist" inManagedObjectContext:_managedObjectContex];
    [_wishlistTable setValue:[NSNumber numberWithInt:latestID] forKey:@"id"];
    [_wishlistTable setValue:newItem.ID forKey:@"id_product"];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    [_wishlistTable setValue:owner forKey:@"id_owner"];
    [_wishlistTable setValue:[NSNumber numberWithBool:isGrosir] forKey:@"is_grosir"];
    return [_managedObjectContex save:nil];
}

+(BOOL)storeShopCart:(Product*)newItem isProductGrosir:(BOOL)isGrosir
          withOption:(NSArray *)sortedOption
               andID:(NSNumber *)selectedVarID
            asManyAs:(int)quantity{
    int latestID = [self getLatestShopCartId];
    latestID++;
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    M_Cart *cartItem = (M_Cart*)[NSEntityDescription insertNewObjectForEntityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    [cartItem setValue:[NSNumber numberWithInt:latestID] forKey:@"id"];
    [cartItem setValue:newItem.ID forKey:@"id_product"];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    [cartItem setValue:owner forKey:@"id_owner"];
    [cartItem setValue:[NSNumber numberWithBool:isGrosir] forKey:@"is_grosir"];
    [cartItem setValue:[NSNumber numberWithInt:quantity] forKey:@"quantity"];
    
    if (sortedOption!=nil) {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sortedOption options:0 error:nil];
        NSString* variantData = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        [cartItem setValue:variantData forKey:@"option"];
        [cartItem setValue:selectedVarID forKey:@"var_id"];
    }

    return [_managedObjectContex save:nil];
}

+(int)getLatestWishListId{
    
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Wishlist" inManagedObjectContext:_managedObjectContex];
    
    [_fetchReq setEntity:entity];
    
    NSArray* wishes = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    int latestId = 0;
    for (M_Wishlist* wish in wishes) {
        if(wish != nil)
        {
            latestId  = [wish.id intValue];
        }
    }
    return latestId;
}

+(int)getLatestShopCartId{
    
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    
    [_fetchReq setEntity:entity];
    
    NSArray* carts = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    int latestId = 0;
    for (M_Cart* cart in carts) {
        if(cart != nil)
        {
            latestId  = [cart.id intValue];
        }
    }
    return latestId;
}

//return array of M_Wishlist
+(NSArray*)retrieveWishList{
    NSMutableArray *result = [NSMutableArray array];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Wishlist" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [self retrieveUser];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_owner==%@",owner];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* _wishLists = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    for (M_Wishlist * wish in _wishLists) {
        if(wish != nil)
        {
            [result addObject:wish];
        }
    }
    
    return result;
}

//return array of M_Cart
+(NSArray*)retrieveShopCart{
    NSMutableArray *result = [NSMutableArray array];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [self retrieveUser];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_owner==%@",owner];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    for (M_Cart * cart in cartItems) {
        if(cart != nil)
        {
            [result addObject:cart];
        }
    }
    
    
    return result;
}

+(NSArray*)retrieveShopCartDistinctByProductID{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [self retrieveUser];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_owner==%@",owner];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    NSArray* distinctPrdID = [cartItems valueForKeyPath:@"@distinctUnionOfObjects.id_product"];
    NSMutableArray* distinctResult = [NSMutableArray array];
    for (NSNumber* prdID in distinctPrdID) {
        for (M_Cart * cart in cartItems) {
            if ([cart.id_product intValue]==[prdID intValue]) {
                [distinctResult addObject:cart];
                break;
            }
        }
    }
    
    return distinctResult;
}

+(BOOL)increaseShopCartItemQuantity:(M_Cart*)newItem asManyAs:(int)quantity{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(id_owner==%@) AND (id_product==%@)",owner,newItem.id_product];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    if (cartItems.count>0) {
        M_Cart * cart = (M_Cart*)[cartItems objectAtIndex:0];
        cart.quantity = [NSNumber numberWithInt:[cart.quantity intValue]+quantity];
        return [_managedObjectContex save:nil];
    }
    
    return false;
}

+(BOOL)increaseShopCartItemQuantityRetail:(M_Cart*)newItem asManyAs:(int)quantity{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(id_owner==%@) AND (id_product==%@) AND (var_id==%@)",owner,newItem.id_product,newItem.var_id];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    if (cartItems.count>0) {
        M_Cart * cart = (M_Cart*)[cartItems objectAtIndex:0];
        cart.quantity = [NSNumber numberWithInt:[cart.quantity intValue]+quantity];
        return [_managedObjectContex save:nil];
    }
    
    return false;
}


+(BOOL)updateCartItem:(Product*)item withQuantity:(NSNumber*)newQuantity{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(id_owner==%@) AND (id_product==%@)",owner,item.ID];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    if (cartItems.count>0) {
        M_Cart * cart = (M_Cart*)[cartItems objectAtIndex:0];
        cart.quantity = newQuantity;
        return [_managedObjectContex save:nil];
    }
    
    return false;
}

+(NSMutableArray*)retrieveImagesWithProductId:(NSNumber*)productId{
    NSMutableArray *result = [NSMutableArray array];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Images" inManagedObjectContext:_managedObjectContex];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id==%@",productId];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* _images = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    for (M_Shop * image in _images) {
        if(image != nil)
        {
            [result addObject:image.image];
        }
    }
    
    return result;
}

+(BOOL)deleteWishListOnIndex:(int)index{
    //delete on persistent store
    Product* deletedWishList = [gInstance.userWishList.items objectAtIndex:index];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Wishlist" inManagedObjectContext:_managedObjectContex];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_product==%@",deletedWishList.ID];
    
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* _wishLists = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    M_Wishlist * wish = [_wishLists objectAtIndex:0];
    [_managedObjectContex deleteObject:wish];
    if ([_managedObjectContex save:nil]) {
        [gInstance.userWishList.items removeObjectAtIndex:index];
        gInstance.wishBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.userWishList.items count]];
        return true;
    }
    return false;
}

+(BOOL)deleteShopCartOnIndex:(int)index{
    //delete on persistent store
    NSDictionary* productData = [gInstance.usedCart.items objectAtIndex:index];
    Product* deletedShopCart = [productData valueForKey:productKey];
    NSDictionary* productRawData = deletedShopCart.completeData;
    BOOL isGrosirProduct = [[productRawData valueForKey:@"is_grosir"] boolValue];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSPredicate* predicate;
    if (isGrosirProduct) {
        predicate = [NSPredicate predicateWithFormat:@"id_product==%@",deletedShopCart.ID];
    }else{
        //find the var_id
        NSDictionary* stockInfo = [self getStockFromStockOption:[productRawData valueForKey:@"stock"] usingOptionData:[productRawData valueForKey:product_option_key]];
        NSNumber* varID;
        if (stockInfo) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            varID = [nf numberFromString:[stockInfo valueForKey:@"var_id"]];
        }
        predicate = [NSPredicate predicateWithFormat:@"id_product==%@ AND var_id==%@",deletedShopCart.ID,varID];
    }
    
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    M_Cart * cartItem = [cartItems objectAtIndex:0];
    [_managedObjectContex deleteObject:cartItem];
    if ([_managedObjectContex save:nil]) {
        //[gInstance.usedCart.items removeObjectAtIndex:index];
        [gInstance.usedCart removeItemAtIndex:index];
        gInstance.shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.usedCart.totalItem intValue]];
        return true;
    }
    return false;
}

+(NSString*)convertDictionaryToString:(NSDictionary*)dict{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    if (jsonData!=nil) {
        NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return @"";
}
+(NSDictionary*)convertStringToDictionary:(NSString*)str{
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return myDictionary;
}

+(BOOL)saveUserWithThisData:(NSDictionary*)userData{
    [self deleteAllObjects:@"M_User"];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    M_User *_user = (M_User*)[NSEntityDescription insertNewObjectForEntityForName:@"M_User" inManagedObjectContext:_managedObjectContex];
    _user.id_user = [[userData objectForKey:@"id"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"id"];
    _user.username = [[userData objectForKey:@"username"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"username"];
    _user.email = [[userData objectForKey:@"email"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"email"];
    _user.name = [[userData objectForKey:@"first_name"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"first_name"];
    _user.image = [[userData objectForKey:@"user_image"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"user_image"];
    NSDate *birthdate = [NSDate dateWithTimeIntervalSince1970:[(NSString*)[userData objectForKey:@"birthdate"] doubleValue]];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:date_format];
    _user.birthdate = birthdate==nil?@"":[format stringFromDate:birthdate];
    _user.gender = (NSNumber*)[userData objectForKey:@"gender"];
    _user.phone = [[userData objectForKey:@"phone"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"phone"];
    _user.phone_other = [[userData objectForKey:@"other_phone"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"other_phone"];
    _user.token = [[userData objectForKey:@"token"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"token"];
    _user.role = [[userData objectForKey:@"user_role"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"user_role"];
    
    //all data somehow prefer to be stored in case something wanted
    _user.raw_data = [self convertDictionaryToString:userData];
    return [_managedObjectContex save:nil];
}

+(BOOL)saveDeviceWithThisData:(NSDictionary*)deviceToken{
    [self deleteAllObjects:@"M_Device"];
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    M_Device *_device = (M_Device*)[NSEntityDescription insertNewObjectForEntityForName:@"M_Device" inManagedObjectContext:_managedObjectContex];
    _device.token = [[deviceToken objectForKey:@"token"]isEqual:[NSNull null]]?@"":[deviceToken objectForKey:@"token"];
    return [_managedObjectContex save:nil];
}

+(BOOL)updateUserWithThisData:(NSDictionary*)userData{
    [self retrieveUser];
    if (gInstance.loggedInUser!=nil) {
        NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
        NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_User" inManagedObjectContext:_managedObjectContex];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_user==%@",gInstance.loggedInUser.id_user];
        [_fetchReq setEntity:entity];
        [_fetchReq setPredicate:predicate];
        
        NSArray* users = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
        if ([users count]>0) {
            M_User* _user = [users objectAtIndex:0];
            _user.email = [[userData objectForKey:@"email"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"email"];
            _user.name = [[userData objectForKey:@"first_name"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"first_name"];
            _user.image = [[userData objectForKey:@"user_image"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"user_image"];
            NSDate *birthdate = [NSDate dateWithTimeIntervalSince1970:[(NSString*)[userData objectForKey:@"birthdate"] doubleValue]];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:date_format];
            _user.birthdate = birthdate==nil?@"":[format stringFromDate:birthdate];
            _user.gender = (NSNumber*)[userData objectForKey:@"gender"];
            _user.phone = [[userData objectForKey:@"phone"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"phone"];
            _user.phone_other = [[userData objectForKey:@"other_phone"]isEqual:[NSNull null]]?@"":[userData objectForKey:@"other_phone"];
            //all data somehow prefer to be stored in case something wanted
            _user.raw_data = [self convertDictionaryToString:userData];
            return [_managedObjectContex save:nil];
        }else{
            return false;
        }
    }else{
        return  false;
    }
}

+(BOOL)retrieveUser{
    
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_User" inManagedObjectContext:_managedObjectContex];
    
    [_fetchReq setEntity:entity];
    
    NSArray* _users = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    if ([_users count]>0) {
        M_User * user = [_users objectAtIndex:0];
        if(user != nil)
        {
            gInstance.loggedInUser = user;
            return YES;
        }
    }
    gInstance.loggedInUser = nil;
    return NO;
}

+(BOOL)retrieveDevice{
    
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Device" inManagedObjectContext:_managedObjectContex];
    
    [_fetchReq setEntity:entity];
    
    NSArray* _devices = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    if ([_devices count]>0) {
        M_Device * device = [_devices objectAtIndex:0];
        if(device != nil)
        {
            gInstance.myDevice = device;
            return YES;
        }
    }
    gInstance.myDevice = nil;
    return NO;
}

+(M_Cart*)getCartDataAboutThisProduct:(Product*)myProduct{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Cart" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(id_owner==%@) AND (id_product==%@)",owner,myProduct.ID];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* cartItems = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    for (M_Cart * cart in cartItems) {
        if(cart != nil)
        {
            return cart;
        }
    }
    return nil;
}

+(M_Wishlist*)getWishDataAboutThisProduct:(Product*)myProduct{
    NSManagedObjectContext *_managedObjectContex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContex;
    NSFetchRequest* _fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"M_Wishlist" inManagedObjectContext:_managedObjectContex];
    NSNumber* owner = [NSNumber numberWithInt:0];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (gInstance.loggedInUser!=nil) {
        owner = [nf numberFromString:gInstance.loggedInUser.id_user];
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(id_owner==%@) AND (id_product==%@)",owner,myProduct.ID];
    [_fetchReq setEntity:entity];
    [_fetchReq setPredicate:predicate];
    
    NSArray* wishlists = [_managedObjectContex executeFetchRequest:_fetchReq error:nil];
    for (M_Wishlist * wish in wishlists) {
        if(wish != nil)
        {
            return wish;
        }
    }
    return nil;
}

+(void)deleteUser{
    [self deleteAllObjects:@"M_User"];
    gInstance.loggedInUser = nil;
    gInstance.isLogin = false;
}

+(void)enableWishlistButton:(BOOL)enable{
    gInstance.enableWishListBtn = enable;
}

+(void)enableCartButton:(BOOL)enable{
    gInstance.enableShopCartBtn = enable;
}

+ (void)removeFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (!success) {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

+(void)insertThisProductToStockKeeper:(NSString*)prdSKU withStock:(NSNumber*)numberOfStock andStockID:(NSNumber*)stockID{
    if (!numberOfStock) {
        numberOfStock = [NSNumber numberWithInt:0];
    }
    if (!stockID) {
        stockID = [NSNumber numberWithInt:0];
    }
    NSArray *filteredStock = [gInstance.stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",prdSKU,stockID]];
    if (filteredStock.count>0) {
        //stock exist, modify
        NSMutableDictionary *existingStock = (NSMutableDictionary*)[filteredStock objectAtIndex:0];
        NSNumber *stockValue = [existingStock valueForKey:stock_qty_key];
        if ([stockValue intValue] != [numberOfStock intValue]) {
            [existingStock setValue:numberOfStock forKey:stock_qty_key];
        }
    }else{
        //new stock keeper
        NSMutableDictionary* stock = [[NSMutableDictionary alloc] initWithObjectsAndKeys:prdSKU,stock_prd_sku_key,stockID,stock_qty_id_key,numberOfStock,stock_qty_key, nil];
        [gInstance.stockKeeper addObject:stock];
    }
}

+(int)getCartItemIndexForThisProduct:(Product*)_product{
    int selectedIndex = -1;
    for (int i=0; i<gInstance.usedCart.items.count; i++) {
        if ([((Product*)[(NSDictionary*)[gInstance.usedCart.items objectAtIndex:i] valueForKey:productKey]).ID intValue] == [_product.ID intValue]) {
            selectedIndex = i;
            break;
        }
    }
    return selectedIndex;
}

+(int)getCartItemIndexForThisProduct:(Product*)_product andOption:(NSArray*)optionData{
    int selectedIndex = -1;
    for (int i=0; i<gInstance.usedCart.items.count; i++) {
        Product* checkedProduct = ((Product*)[(NSDictionary*)[gInstance.usedCart.items objectAtIndex:i] valueForKey:productKey]);
        if ([checkedProduct.ID intValue] == [_product.ID intValue]) {
            //check the option
            NSArray* productOption = [checkedProduct.completeData valueForKey:product_option_key];
            if ([self isThisOptionValue:productOption equalTo:optionData]) {
                selectedIndex = i;
                break;
            }
        }
    }
    return selectedIndex;
}

+(void)processAPIRequestResult:(NSString*)responseString withRequestCode:(int)requestCode{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (requestCode) {
        case getTopProduct:
            if (success) {
                gInstance.topProduct = [NSMutableArray array];
                gInstance.isTopProductRetail = [(NSNumber*)[jsonDictionary objectForKey:@"is_retail"]boolValue];
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* productData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [datum keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [productData setValue:[datum objectForKey:key] forKey:key];
                    }
                    [gInstance.topProduct addObject:productData];
                }
            }else{
                //error
                NSLog(@"error on request for getTopProduct");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getTopProductURL];
            }
            break;
        case getTopSeller:
            if (success) {
                gInstance.topSeller = [NSMutableArray array];
                
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* sellerData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [datum keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [sellerData setValue:[datum objectForKey:key] forKey:key];
                    }
                    [gInstance.topSeller addObject:sellerData];
                }
            }else{
                //error
                NSLog(@"error on request for getTopSeller");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getTopSellerURL];
            }
            break;
        case getAllCategory:
            if (success) {
                gInstance.allCategory = [NSMutableArray array];
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* categoryData = [[NSMutableDictionary alloc] init];
                    [categoryData setValue:[[datum objectForKey:@"cat_id"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"cat_id"]  forKey:@"cat_id"];
                    [categoryData setValue:[[datum objectForKey:@"parent_id"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"parent_id"]  forKey:@"parent_id"];
                    [categoryData setValue:[[datum objectForKey:@"cat_type"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"cat_type"]  forKey:@"cat_type"];
                    [categoryData setValue:[[datum objectForKey:@"slug"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"slug"]  forKey:@"slug"];
                    [categoryData setValue:[[datum objectForKey:@"cat_name"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"cat_name"]  forKey:@"cat_name"];
                    [categoryData setValue:[[datum objectForKey:@"cat_status"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"cat_status"]  forKey:@"cat_status"];
                    [categoryData setValue:[[datum objectForKey:@"brand_agent_id"] isEqual:[NSNull null]]? @"": [datum objectForKey:@"brand_agent_id"]  forKey:@"brand_agent_id"];
                    [gInstance.allCategory addObject:categoryData];
                }
            }else{
                //error
                NSLog(@"error on request for getAllCategory");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getAllCategoryURL];
            }
            break;
        case getAllStore:
            if (success) {
                gInstance.allStore = [NSMutableArray array];
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* storeData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [datum keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [storeData setValue:[datum objectForKey:key] forKey:key];
                    }
                    [gInstance.allStore addObject:storeData];
                }
            }else{
                //error
                NSLog(@"error on request for getAllStore");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getAllStoreURL];
            }
            break;
        case getAllAgent:
            if (success) {
                gInstance.allAgent = [NSMutableArray array];
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* agentData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [datum keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [agentData setValue:[datum objectForKey:key] forKey:key];
                    }
                    [gInstance.allAgent addObject:agentData];
                }
            }else{
                //error
                NSLog(@"error on request for getAllAgent");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getAllAgentURL];
            }
            break;
        case getAllCity:
            if (success) {
                gInstance.allCity = [NSMutableArray array];
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* cityData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [datum keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [cityData setValue:[datum objectForKey:key] forKey:key];
                    }
                    [gInstance.allCity addObject:cityData];
                }
            }else{
                //error
                NSLog(@"error on request for getAllCity");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getAllCityURL];
            }
            break;
        case getAllAccount:
            if (success) {
                gInstance.allAccount = [NSMutableArray array];
                NSArray* data = (NSArray *)[jsonDictionary objectForKey:@"data"];
                for (int i = 0; i<data.count; i++) {
                    NSDictionary* datum = (NSDictionary*)[data objectAtIndex:i];
                    NSMutableDictionary* accountData = [[NSMutableDictionary alloc] init];
                    NSEnumerator *enumerator = [datum keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) {
                        [accountData setValue:[datum objectForKey:key] forKey:key];
                    }
                    [gInstance.allAccount addObject:accountData];
                }
            }else{
                //error
                NSLog(@"error on request for getAllAccount");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getAllAccountURL];
            }
            break;
        case getUserProfile:
            if (success) {
                NSDictionary* data = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                
                NSNumber*_gender = [nf numberFromString:[data objectForKey:@"gender"]];
                if (_gender==nil) {
                    _gender = [NSNumber numberWithInt:0];
                }
                NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
                NSEnumerator *enumerator = [data keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    if ([(NSString*)key isEqualToString:@"gender"]) {
                        [userData setValue:_gender forKey:@"gender"];
                    }else{
                        [userData setValue:[data objectForKey:key] forKey:key];
                    }
                }
                [DataSingleton updateUserWithThisData:userData];
            }else{
                //error
                NSLog(@"error on request for getUserProfile");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getuserProfileURL];
            }
            break;
        case getProductShopCart:
            if (success) {
                NSDictionary* datum = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
                NSMutableDictionary* productData = [[NSMutableDictionary alloc] init];
                NSEnumerator *enumerator = [datum keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    [productData setValue:[datum objectForKey:key] forKey:key];
                }
                NSString* productSKU = [productData valueForKey:@"prd_SKU"];
                BOOL isGrosirProduct = [(NSNumber*)[productData valueForKey:@"is_grosir"]boolValue];
                NSNumber* productStock;
                NSNumber* productStockID;
                if (isGrosirProduct) {
                    //produk grosir
                    productStock = [[productData valueForKey:@"stock"] isEqual:[NSNull null]]? [NSNumber numberWithInt:0]:[productData valueForKey:@"stock"];
                    productStockID = [[productData valueForKey:@"stock_id"] isEqual:[NSNull null]]? [NSNumber numberWithInt:0]:[productData valueForKey:@"stock_id"];
                }
                if (!productStock) {
                    productStock = [NSNumber numberWithInt:0];
                }
                if (!productStockID) {
                    productStockID = [NSNumber numberWithInt:0];
                }
                
                NSArray* images = (NSArray*)[productData valueForKey:@"images"];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber* productId = [nf numberFromString:(NSString*)[productData valueForKey:@"prd_id"]];
                NSArray* cartItems = [DataSingleton retrieveShopCart];
                for (int x=0;x<cartItems.count;x++) {
                    M_Cart* cart = [cartItems objectAtIndex:x];
                    BOOL productMatch = false;
                    if ([cart.id_product intValue]==[productId intValue]) {
                        if (![cart.is_grosir boolValue]) {
                            //retail
                            //generate product_option_key and product_option_complete_key
                            SBJsonParser *parser = [[SBJsonParser alloc] init];
                            NSArray *productOptions = [NSArray arrayWithArray:[parser objectWithString:cart.option error:nil]];
                            NSMutableArray* optionValueHolder = [productOptions mutableCopy];
                            NSMutableArray* optionValueComplete = [NSMutableArray array];
                            
                            NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productData valueForKey:@"stock"] usingOptionData:optionValueHolder];
                            
                            if (stockInfo) {
                                productStock = [stockInfo valueForKey:@"stock"];
                                productStockID = [stockInfo valueForKey:@"stock_id"];
                            }
                            
                            NSArray *optionProduct = [productData valueForKey:@"option"];
                            //check (iterate) into every single product variant option
                            int productOptionsIndex = 0;
                            for (NSDictionary* optionProductData in optionProduct) {
                                NSArray* optionValues = [optionProductData valueForKey:@"opt_values"];
                                //check (iterate) into option values of currently checked single product variant option
                                for (NSDictionary* optionValuesData in optionValues) {
                                    //if get matched optionvalues var id, get the option values data, stop the iteration
                                    NSNumber* checkedOptValID = [nf numberFromString:(NSString*)[optionValuesData valueForKey:@"opt_val_id"]];
                                    if ([checkedOptValID intValue]==[(NSNumber*)[productOptions objectAtIndex:productOptionsIndex] intValue]) {
                                        [optionValueComplete addObject:optionValuesData];
                                        break;
                                    }
                                }
                                productOptionsIndex++;
                            }
                            
                            Product* newItem = [[Product alloc]initWithID:productId andName:(NSString*)[productData valueForKey:@"prd_name"] withImages:[NSMutableArray arrayWithArray:images] withPrice:(NSNumber*)[productData valueForKey:@"prd_price"] andRetailPrice:(NSNumber*)[productData valueForKey:@"prd_price"]];
                            NSMutableDictionary *addedProductData = [NSMutableDictionary dictionaryWithDictionary:productData];
                            [addedProductData setValue:optionValueHolder forKey:product_option_key];
                            [addedProductData setValue:optionValueComplete forKey:product_option_complete_key];
                            [newItem setCompleteData:addedProductData];
                            [gInstance.usedCart addNewProduct:newItem asManyAs:[cart.quantity intValue]];
                            gInstance.shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.usedCart.totalItem intValue]];
                            
                            productStock = [NSNumber numberWithInt:([productStock intValue]-[cart.quantity intValue])];
                            if ([productStock intValue]<0) {
                                productStock = [NSNumber numberWithInt:0];
                            }
                            [DataSingleton insertThisProductToStockKeeper:productSKU withStock:productStock andStockID:productStockID];
                        }else{
                            Product* newItem = [[Product alloc]initWithID:productId andName:(NSString*)[productData valueForKey:@"prd_name"] withImages:[NSMutableArray arrayWithArray:images] withPrice:(NSNumber*)[productData valueForKey:@"prd_price"] andRetailPrice:(NSNumber*)[productData valueForKey:@"prd_price"]];
                            [newItem setCompleteData:productData];
                            [gInstance.usedCart addNewProduct:newItem asManyAs:[cart.quantity intValue]];
                            gInstance.shopBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",(int)[gInstance.usedCart.totalItem intValue]];
                            
                            productStock = [NSNumber numberWithInt:([productStock intValue]-[cart.quantity intValue])];
                            if ([productStock intValue]<0) {
                                productStock = [NSNumber numberWithInt:0];
                            }
                            [DataSingleton insertThisProductToStockKeeper:productSKU withStock:productStock andStockID:productStockID];
                            productMatch = true;
                        }
                        
                        
                        if (productMatch) {
                            break;
                        }
                    }
                    
                }
                
                
            }else{
                NSLog(@"error on request for getProductShopCart");
                [gInstance.errorNotificationMessage appendFormat:@"%@ or %@ (cart)\n",getProductGrosirURL,getProductURL];
            }
            break;
        case getUserMenu:
            if (success) {
                NSDictionary* data = (NSDictionary *)[jsonDictionary objectForKey:@"data"];
                gInstance.showShopMenu = [(NSNumber*)[data objectForKey:@"menu_toko"]boolValue];
                gInstance.showAgentMenu = [(NSNumber*)[data objectForKey:@"menu_agent"]boolValue];
                gInstance.showCategoryMenu = [(NSNumber*)[data objectForKey:@"menu_kategori"]boolValue];
                gInstance.showMyAccountMenu = [(NSNumber*)[data objectForKey:@"menu_akun_saya"]boolValue];
                gInstance.showRetailProduct = [(NSNumber*)[data objectForKey:@"cms_product_retail"]boolValue];
                gInstance.showGrosirProduct = [(NSNumber*)[data objectForKey:@"cms_product_grosir"]boolValue];
                gInstance.showSalesOrder = [(NSNumber*)[data objectForKey:@"cms_sales_order"]boolValue];
                gInstance.showSalesRetur = [(NSNumber*)[data objectForKey:@"cms_sales_retur"]boolValue];
                gInstance.menuCMSProduct = [(NSNumber*)[data objectForKey:@"cms_product_retail"]boolValue];
                gInstance.menuCMSProductGrosir = [(NSNumber*)[data objectForKey:@"cms_product_grosir"]boolValue];
                gInstance.menuTambahProduct = [(NSNumber*)[data objectForKey:@"cms_product_retail_add"]boolValue];
                gInstance.menuTambahProductGrosir = [(NSNumber*)[data objectForKey:@"cms_product_grosir_add"]boolValue];
            }else{
                NSLog(@"error on request for getUserMenu");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getUserMenuURL];
            }
            break;
        case getMessageHelper:
            if ([jsonDictionary objectForKey:@"data"]) {
                gInstance.messageCollection = (NSDictionary *)[jsonDictionary objectForKey:@"data"];
            }else{
                //error
                NSLog(@"error on request for getMessageHelper");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getMessageHelperURL];
            }
            break;
        case getCategoryData:
            if ([jsonDictionary objectForKey:@"data"]) {
                gInstance.categoryData = [NSMutableArray arrayWithArray:(NSArray *)[jsonDictionary objectForKey:@"data"]];
            }else{
                //error
                NSLog(@"error on request for getCategoryData");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getCategoryDataURL];
            }
            break;
        case getAllBrand:
            if ([jsonDictionary objectForKey:@"data"]) {
                gInstance.allBrand = [NSMutableArray arrayWithArray:(NSArray *)[jsonDictionary objectForKey:@"data"]];
            }else{
                //error
                NSLog(@"error on request for getAllBrand");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getAllBrandURL];
            }
            break;
        case getOrderStatus:
            if ([jsonDictionary objectForKey:@"data"]) {
                gInstance.allOrderStatus = [NSMutableArray arrayWithArray:(NSArray *)[jsonDictionary objectForKey:@"data"]];
            }
            break;
        case getReturStatus:
            if ([jsonDictionary objectForKey:@"data"]) {
                gInstance.allReturStatus = [NSMutableArray arrayWithArray:(NSArray *)[jsonDictionary objectForKey:@"data"]];
            }else{
                //error
                NSLog(@"error on request for getReturStatus");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getReturStatusURL];
            }
            break;
        case getFooterContent1:
            if (success) {
                if ([jsonDictionary objectForKey:@"data"]) {
                    gInstance.footer1MenuList = [NSMutableArray arrayWithArray:(NSArray *)[jsonDictionary objectForKey:@"data"]];
                }
            }else{
                NSLog(@"error on request for getFooterContent1");
                [gInstance.errorNotificationMessage appendFormat:@"%@ - f_layanan\n",getFooterContentURL];
            }
            break;
        case getFooterContent2:
            if (success) {
                if ([jsonDictionary objectForKey:@"data"]) {
                    gInstance.footer2MenuList = [NSMutableArray arrayWithArray:(NSArray *)[jsonDictionary objectForKey:@"data"]];
                }
            }else{
                NSLog(@"error on request for getFooterContent2");
                [gInstance.errorNotificationMessage appendFormat:@"%@ - f_tentangy2\n",getFooterContentURL];
            }
            break;
        case getVideoHome:
            if ([jsonDictionary objectForKey:@"data"]) {
                gInstance.homeVideoUrl = [jsonDictionary objectForKey:@"data"];
            }else{
                NSLog(@"error on request for getVideoHome");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getVideoHomeURL];
            }
            break;
        case getSlideShowPromo:
            if ([[jsonDictionary objectForKey:@"data"] objectForKey:@"slide_show"]) {
                gInstance.promoList = [NSMutableArray arrayWithArray:(NSArray *)[[jsonDictionary objectForKey:@"data"] objectForKey:@"slide_show"]];
            }
            if([[jsonDictionary objectForKey:@"data"] objectForKey:@"time_slider"]){
                gInstance.sliderTime = [[jsonDictionary objectForKey:@"data"] valueForKey:@"time_slider"];
            }
            break;
        case getUserMenuTree:
            if (success) {
                NSDictionary* responseData = [jsonDictionary objectForKey:@"data"];
                [self setUserMenuTree:(NSArray *)[responseData objectForKey:@"menu_tree"]];
                gInstance.userSellerIDs = [NSArray arrayWithArray:[responseData objectForKey:@"seller_ids"]];
            }else{
                NSLog(@"error on request for getUserMenuTree");
                [gInstance.errorNotificationMessage appendFormat:@"%@\n",getUserMenuTreeURL];
            }
            break;
        default:
            break;
    }
}

+(void)setUserMenuTree:(NSArray*)menuTree{
    gInstance.userMenuTree = [NSArray arrayWithArray:menuTree];
    for (NSDictionary *genderNode in [DataSingleton instance].userMenuTree) {
        if ([[genderNode valueForKey:@"id"]isEqualToString:@"P"]) {
            [DataSingleton instance].maleData = [DataSingleton createNTree:genderNode];
        }else{
            [DataSingleton instance].femaleData = [DataSingleton createNTree:genderNode];
        }
        
    }
}

+(NSDictionary*)getStockFromStockOption:(NSArray*)optionStock usingOptionData:(NSArray*)optionReference{
    if (optionReference.count==0) {
        return nil;
    }
    for (NSDictionary* optionStockData in optionStock) {
        NSArray *stockCombination = (NSArray*)[optionStockData valueForKey:@"array_opt_val_id"];
        NSMutableArray *stockDataSorted = [NSMutableArray array];
        for (NSDictionary* stockCombinationData in stockCombination) {
            NSNumber* stockVal = (NSNumber*)[stockCombinationData valueForKey:@"opt_val_id"];
            [stockDataSorted addObject:stockVal];
        }
        if ([self isThisOptionValue:stockDataSorted equalTo:optionReference]) {
            return optionStockData;
        }
    }
    return nil;
}


+(void)fetchInitiallData:(ASINetworkQueue*)networkQueue{
    
    NSMutableArray* urlStringsToRequest = [NSMutableArray array];
    NSDictionary *urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%@%@",y2BaseURL,getTopProductURL], @"url",
                                [NSNumber numberWithInt:getTopProduct],@"tag",
                                nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getTopSellerURL], @"url",
                  [NSNumber numberWithInt:getTopSeller],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllCategoryURL], @"url",
                  [NSNumber numberWithInt:getAllCategory],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllStoreURL], @"url",
                  [NSNumber numberWithInt:getAllStore],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllAgentURL], @"url",
                  [NSNumber numberWithInt:getAllAgent],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllCityURL], @"url",
                  [NSNumber numberWithInt:getAllCity],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getUserMenuURL], @"url",
                  [NSNumber numberWithInt:getUserMenu],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getMessageHelperURL], @"url",
                  [NSNumber numberWithInt:getMessageHelper],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getOrderStatusURL], @"url",
                  [NSNumber numberWithInt:getOrderStatus],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getReturStatusURL], @"url",
                  [NSNumber numberWithInt:getReturStatus],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    [self retrieveUser];
    if (gInstance.loggedInUser!=NULL) {
        urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                      [NSString stringWithFormat:@"%@%@",y2BaseURL,getuserProfileURL], @"url",
                      [NSNumber numberWithInt:getUserProfile],@"tag",
                      nil];
        [urlStringsToRequest addObject:urlToFetch];
    }
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getAllBrandURL], @"url",
                  [NSNumber numberWithInt:getAllBrand],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getFooterMenuURL], @"url",
                  [NSNumber numberWithInt:getFooterContent1],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getFooterMenuURL], @"url",
                  [NSNumber numberWithInt:getFooterContent2],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getVideoHomeURL], @"url",
                  [NSNumber numberWithInt:getVideoHome],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    urlToFetch = [[NSDictionary alloc]initWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@%@",y2BaseURL,getSlideShowPromoURL], @"url",
                  [NSNumber numberWithInt:getSlideShowPromo],@"tag",
                  nil];
    [urlStringsToRequest addObject:urlToFetch];
    
    
    for (NSDictionary* _urlData in urlStringsToRequest) {
        NSString* _url = [_urlData valueForKey:@"url"];
        int tag = [(NSNumber*)[_urlData valueForKey:@"tag"] intValue];
        NSURL *url = [NSURL URLWithString:_url];
        
        if (tag==getTopProduct) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* user_id = @"-1";
            if (gInstance.loggedInUser!=NULL) {
                user_id = gInstance.loggedInUser.id_user;
            }
            [request addPostValue:user_id forKey:@"user_id"];
            [networkQueue addOperation:request];
        } else if (tag==getTopSeller) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* user_id = @"-1";
            if (gInstance.loggedInUser!=NULL) {
                user_id = gInstance.loggedInUser.id_user;
            }
            [request addPostValue:user_id forKey:@"user_id"];
            [networkQueue addOperation:request];
        } else if (tag==getUserProfile) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* userID = gInstance.loggedInUser.id_user;
            [request addPostValue:userID forKey:@"user_id"];
            [networkQueue addOperation:request];
        }else if (tag==getUserMenu) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* userID = gInstance.loggedInUser==nil? @"-1":gInstance.loggedInUser.id_user;
            [request addPostValue:userID forKey:@"user_id"];
            [networkQueue addOperation:request];
        }else if (tag==getFooterContent1) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            [request addPostValue:@"f_layanan" forKey:@"category"];
            [networkQueue addOperation:request];
        }else if (tag==getFooterContent2) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            [request addPostValue:@"f_tentangy2" forKey:@"category"];
            [networkQueue addOperation:request];
        }else if (tag==getSlideShowPromo) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [request setRequestMethod:@"POST"];
            NSString* user_id = @"-1";
            if (gInstance.loggedInUser!=NULL) {
                user_id = gInstance.loggedInUser.id_user;
            }
            [request addPostValue:user_id forKey:@"user_id"];
            [networkQueue addOperation:request];
        }else{
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            
            [request setTag:tag];
            [request setTimeOutSeconds:60];
            [networkQueue addOperation:request];
        }
        
    }
    for (M_Cart* cart in [self retrieveShopCartDistinctByProductID]) {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",y2BaseURL,[cart.is_grosir boolValue]? getProductGrosirURL:getProductURL]]];
        
        [request setTag:getProductShopCart];
        [request setTimeOutSeconds:60];
        [request setRequestMethod:@"POST"];
        
        [request addPostValue:cart.id_product forKey:@"prd_id"];
        [networkQueue addOperation:request];
    }
}

+(NSDictionary*)getStoreByStoreId:(NSNumber*)storeId{
    NSDictionary *store = nil;
    
    if(storeId && gInstance.allStore){
        for (NSDictionary *singleStore in gInstance.allStore) {
            if(singleStore){
                NSNumber *singleStoreId = [singleStore valueForKey:@"id"];
                if([singleStoreId intValue] == [storeId intValue]){
                    store = singleStore;
                    break;
                }
            }
        }
    }
    
    return store;
}

+(NSDictionary*)getAgentByAgentId:(NSNumber*)agentId{
    NSDictionary *agent = nil;
    
    if(agentId && gInstance.allAgent){
        for (NSDictionary *singleAgent in gInstance.allAgent) {
            if(singleAgent){
                NSNumber *singleAgentId = [singleAgent valueForKey:@"id"];
                if([singleAgentId intValue] == [agentId intValue]){
                    agent = singleAgent;
                    break;
                }
            }
        }
    }
    
    return agent;
}

+(BOOL)deviceHasInternetConnection{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    return (internetStatus != NotReachable);
}

+(BOOL)isLoggedInUserOwnProductOwner:(NSNumber*)ownerID{
    if (gInstance.loggedInUser!=nil) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        for (NSString *sellerMember in gInstance.userSellerIDs) {
            NSNumber *sellerMemberNumber = [f numberFromString:sellerMember];
            if ([ownerID isEqualToNumber:sellerMemberNumber]) {
                return true;
            }
        }
    }
    
    return false;
}

@end
