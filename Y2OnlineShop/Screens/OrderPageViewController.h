//
//  OrderPageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/23/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderItemCell.h"
#import "VCDelegate.h"
#import "RWLabel.h"

@interface OrderPageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>{
    int widthContentView;
    NSMutableArray *orderItemList;
    NSMutableArray *orderItemListFiltered;
    BOOL isFiltered;
    BOOL hasConfirmShipping;
    NSDictionary* orderData;
}
@property (nonatomic, assign)   id<VCDelegate> delegate;
@property (strong, nonatomic) UISearchBar *searchBarRef;
@property (strong, nonatomic) NSString *orderNumber;
@property (strong, nonatomic) NSString *orderStatus;
@property (strong, nonatomic) NSNumber *orderCode;
@property BOOL needConfirmation;
@property (strong, nonatomic) IBOutlet UITableView *orderItemTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic) IBOutlet UILabel *shippingService;
@property (strong, nonatomic) IBOutlet UILabel *orderStatusLabel;

@property (strong, nonatomic) IBOutlet UIView *infoPengiriman;
@property (strong, nonatomic) IBOutlet RWLabel *ipNama;
@property (strong, nonatomic) IBOutlet RWLabel *ipPhone;
@property (strong, nonatomic) IBOutlet RWLabel *ipAddress;
@property (strong, nonatomic) IBOutlet RWLabel *ipFee;


- (IBAction)confirmOrderArrival:(id)sender;

@end
