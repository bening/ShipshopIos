//
//  WishListViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/24/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemCollection.h"
#import "CartViewController.h"
#import "AppDelegate.h"
#import "M_Wishlist.h"
#import "M_Product.h"
#import "M_Shop.h"
#import "M_Images.h"


@interface WishListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    int widthContentView;
    bool isEmpty;
    NSMutableArray *itemWish;
    NSMutableArray *itemName;
    NSMutableArray *itemPrice;
    NSMutableArray *itemId;
    NSMutableArray *itemImage;
    NSMutableArray *itemShop;
}
@property (strong, nonatomic) UISearchBar *searchBarRef;
@property (nonatomic) IBOutlet UIView *viewEmpty;
@property (nonatomic) IBOutlet UIView *viewColl;
@property (nonatomic) IBOutlet UICollectionView *collItem;


//@property (strong,nonatomic) WishListViewController * wishlistReference;

@end
