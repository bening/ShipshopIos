//
//  ReturDetailViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXPopover.h"
#import "VCDelegate.h"
#import "ASIFormDataRequest.h"

@interface ReturDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ASIHTTPRequestDelegate>{
    int selectedStatusReturIndex;
    NSNumber* selectedStatusReturId;
    int widthContentView;
    NSMutableArray *returDetailList;
    UITextField* activeTextField;
    BOOL shouldDismissPopover;
    BOOL popoverShown;
    BOOL didUpdateReturStatus;
    NSDictionary* returData;
    //NSDictionary* dataOrder;
    //NSDictionary* statusDetailOrder;
}

@property (nonatomic, assign) NSString* orderNumberString;
@property (nonatomic, assign) NSString* returStatusString;
@property (nonatomic, assign)   id<VCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *rootContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *rootScroller;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleOrder;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleShipping;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleContact;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleReturList;

@property (strong, nonatomic) IBOutlet UILabel *orderNumber;
@property (strong, nonatomic) IBOutlet UILabel *orderDate;
@property (strong, nonatomic) IBOutlet UILabel *returStatus;
@property (strong, nonatomic) IBOutlet UITableView *tableReturDetail;

@property (strong, nonatomic) IBOutlet UILabel *shippingName;
@property (strong, nonatomic) IBOutlet UILabel *shippingAddress;
@property (strong, nonatomic) IBOutlet UILabel *shippingMethod;
@property (strong, nonatomic) IBOutlet UILabel *shippingEmail;
@property (strong, nonatomic) IBOutlet UILabel *shippingPhone;

@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@end
