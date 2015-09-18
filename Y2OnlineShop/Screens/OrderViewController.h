//
//  OrderViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 1/7/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTableViewCell.h"
#import "VCDelegate.h"
#import "ASINetworkQueue.h"

@interface OrderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,VCDelegate>{
    int widthContentView;
    NSMutableArray *orderList;
    NSMutableArray *orderListFiltered;
    NSDateFormatter *orderDateFormat;
    BOOL isFiltered;
    NSDictionary *orderInfo;
    ASINetworkQueue *networkQueue;
}
@property (strong, nonatomic) UISearchBar *searchBarRef;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UITableView *orderTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIImageView *emptyOrderImage;

@end
