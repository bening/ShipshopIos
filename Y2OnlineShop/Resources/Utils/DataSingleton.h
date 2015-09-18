//
//  DataSingleton.h
//  Y2OnlineShop
//
//  Created by maverick on 11/26/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wishlist.h"
#import "AppDelegate.h"
#import "Cart.h"
#import "BBBadgeBarButtonItem.h"
#import "M_Category.h"
#import "M_Cart.h"
#import "M_Product.h"
#import "M_User.h"
#import "M_Wishlist.h"
#import "M_Device.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"

@interface DataSingleton : NSObject<UISearchBarDelegate>
{
}
@property bool networkError;
@property bool enableWishListBtn;
@property bool enableShopCartBtn;
@property bool isLogin;
@property bool showShopMenu;
@property bool showAgentMenu;
@property bool showCategoryMenu;
@property bool showMyAccountMenu;
@property bool isTopProductRetail;
@property bool showRetailProduct;
@property bool showGrosirProduct;
@property bool showSalesOrder;
@property bool showSalesRetur;
@property bool disableTouchOnLeftMenu;
@property bool menuCMSProductGrosir;
@property bool menuCMSProduct;
@property bool menuTambahProduct;
@property bool menuTambahProductGrosir;
@property (nonatomic,retain) NSNumber* wishCartStack;
@property (nonatomic,retain) UINavigationController *navigationController;
@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;
@property (nonatomic,retain) BBBadgeBarButtonItem* shopBarButtonItem;
@property (nonatomic,retain) BBBadgeBarButtonItem* wishBarButtonItem;
@property (nonatomic,retain) UIBarButtonItem* searchBarProductRetail;
@property (nonatomic,retain) UIBarButtonItem* searchBarProductGrosir;
@property (nonatomic,retain) Wishlist *userWishList;
@property (nonatomic,retain) M_User *loggedInUser;
@property (nonatomic,retain) Cart *usedCart;
@property (nonatomic,retain) NSMutableArray *cartCollection;
@property (nonatomic,retain) NSMutableArray *topBrand;
@property (nonatomic,retain) NSMutableArray *topProduct;
@property (nonatomic,retain) NSMutableArray *topSeller;
@property (nonatomic,retain) NSMutableArray *allStore;
@property (nonatomic,retain) NSMutableArray *allAgent;
@property (nonatomic,retain) NSMutableArray *allCategory;
@property (nonatomic,retain) NSMutableArray *allCity;
@property (nonatomic,retain) NSMutableArray *allAccount;
@property (nonatomic,retain) NSMutableArray *allBrand;
@property (nonatomic,retain) NSMutableArray *allOrderStatus;
@property (nonatomic,retain) NSMutableArray *allReturStatus;
@property (nonatomic,retain) NSMutableArray *stockKeeper;
@property (nonatomic,retain) NSMutableArray *footer1MenuList;
@property (nonatomic,retain) NSMutableArray *footer2MenuList;
@property (nonatomic,retain) NSMutableArray *footer3MenuList;
@property (nonatomic,retain) NSMutableArray *footer4MenuList;
@property (nonatomic,retain) NSMutableArray *promoList;
@property (nonatomic,retain) NSDictionary *messageCollection;
@property (nonatomic,retain) NSMutableArray *checkoutItems;
@property (nonatomic,retain) NSNumber *checkoutItemsIsRetail;
@property (nonatomic,retain) NSMutableArray *categoryData;
@property (nonatomic,retain) NSNumber *checkoutExpense;
@property (nonatomic,retain) NSMutableDictionary *paymentInfo;
@property (nonatomic,retain) NSString *homeVideoUrl;
@property (nonatomic,retain) NSMutableString *errorNotificationMessage;
@property (nonatomic,retain) M_Device *myDevice;
@property (nonatomic, retain) NSNumber *sliderTime;
@property (nonatomic, retain) NSString *menuDataString;
@property (nonatomic, retain) NSArray *userMenuTree;
@property (nonatomic, retain) NSMutableDictionary *maleData;
@property (nonatomic, retain) NSMutableDictionary *femaleData;
@property (nonatomic, retain) NSArray *userSellerIDs;

+ (DataSingleton *)instance;
+(void)checkDevice;
+(void)shopAction;
+(void)wishListAction;
+(BOOL)isThisOptionValue:(NSArray*)optionValue1 equalTo:(NSArray*)optionValue2;
+(void)addItemToCart:(NSDictionary*)addedProduct isProductGrosir:(BOOL)isGrosir asManyAs:(int)quantity;
+(BOOL)insertAllFreeCartToLoggedInUser;
+(void)addItemToWishlist:(NSDictionary*)addedProduct isProductGrosir:(BOOL)isGrosir;
+(void)deleteAllObjects:(NSString*)entityDescription;
+(BOOL)storeWishList:(Product*)newItem isProductGrosir:(BOOL)isGrosir;
+(BOOL)storeShopCart:(Product*)newItem
     isProductGrosir:(BOOL)isGrosir
          withOption:(NSArray*)sortedOption
               andID:(NSNumber*)selectedVarID
            asManyAs:(int)quantity;
+(NSArray*)retrieveWishList;
+(NSArray*)retrieveShopCart;
+(NSArray*)retrieveShopCartDistinctByProductID;
+(BOOL)increaseShopCartItemQuantity:(M_Cart*)newItem asManyAs:(int)quantity;
+(BOOL)increaseShopCartItemQuantityRetail:(M_Cart*)newItem asManyAs:(int)quantity;
+(BOOL)updateCartItem:(Product*)item withQuantity:(NSNumber*)newQuantity;
+(int)getLatestWishListId;
+(int)getLatestShopCartId;
+(BOOL)deleteWishListOnIndex:(int)index;
+(BOOL)deleteShopCartOnIndex:(int)index;
+(NSString*)convertDictionaryToString:(NSDictionary*)dict;
+(NSDictionary*)convertStringToDictionary:(NSString*)str;
+(BOOL)saveUserWithThisData:(NSDictionary*)userData;
+(BOOL)saveDeviceWithThisData:(NSDictionary*)deviceToken;
+(BOOL)updateUserWithThisData:(NSDictionary*)userData;
+(BOOL)retrieveUser;
+(BOOL)retrieveDevice;
+(M_Cart*)getCartDataAboutThisProduct:(Product*)myProduct;
+(M_Wishlist*)getWishDataAboutThisProduct:(Product*)myProduct;
+(void)deleteUser;
+(void)enableWishlistButton:(BOOL)enable;
+(void)enableCartButton:(BOOL)enable;
+(void)removeFile:(NSString *)filePath;
+(void)insertThisProductToStockKeeper:(NSString*)prdSKU withStock:(NSNumber*)numberOfStock andStockID:(NSNumber*)stockID;
+(int)getCartItemIndexForThisProduct:(Product*)_product;
+(int)getCartItemIndexForThisProduct:(Product*)_product andOption:(NSArray*)optionData;
+(void)processAPIRequestResult:(NSString*)responseString withRequestCode:(int)requestCode;
+(NSDictionary*)getStockFromStockOption:(NSArray*)optionStock usingOptionData:(NSArray*)optionReference;
+(void)hideSearchBar:(UISearchBar*)searchBarTarget;
+(void)showSearchBar:(UISearchBar*)searchBarTarget;
+(void)fetchInitiallData:(ASINetworkQueue*)networkQueue;
+(NSDictionary*)getStoreByStoreId:(NSNumber*)storeId;
+(NSDictionary*)getAgentByAgentId:(NSNumber*)agentId;
+(NSMutableDictionary*)createNTree:(NSDictionary*)parent;
+(void)setUserMenuTree:(NSArray*)menuTree;
+(BOOL)deviceHasInternetConnection;
+(BOOL)isLoggedInUserOwnProductOwner:(NSNumber*)ownerID;

@end
