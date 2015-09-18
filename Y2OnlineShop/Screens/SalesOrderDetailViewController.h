//
//  SalesOrderDetailViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 1/29/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownTextField.h"
#import "DXPopover.h"
#import "VCDelegate.h"
#import "ASIFormDataRequest.h"
#import "UILabel+VerticalAlignment.h"

@interface SalesOrderDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ASIHTTPRequestDelegate>{
    int selectedStatusOrderIndex;
    NSNumber* selectedStatusOrderId;
    int widthContentView;
    NSMutableArray *transPaymentList;
    NSMutableArray *productList;
    NSMutableArray *sellerList;
    NSMutableArray *orderStatusList;
    NSMutableArray *orderStatusData;
    NSMutableArray *groupOfProduct;
    UITextField* activeTextField;
    BOOL shouldDismissPopover;
    BOOL popoverShown;
    BOOL didUpdateOrderStatus;
    NSDictionary* dataOrder;
    NSDictionary* statusDetailOrder;
    NSNumber* preSelectedStatusOrderId;
    UITextView *commentView;
    NSArray *updateStatusOrderBtnTopConstraintTemp;
    NSNumberFormatter *nf;
}
@property (nonatomic, strong) NSString* orderNumberString;
@property (nonatomic, assign)   id<VCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *rootContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *rootScroller;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pageTitleLeadingSpaceIpad;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pageTitleTopSpaceIpad;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleOrder;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleShipping;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleContactShipping;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleTransfer;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleContact;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleSummary;
@property (strong, nonatomic) IBOutlet UILabel *tableTitleOrderSummary;

@property (strong, nonatomic) IBOutlet UILabel *orderNumber;
@property (strong, nonatomic) IBOutlet UILabel *orderDate;
@property (strong, nonatomic) IBOutlet UILabel *orderStatus;
@property (strong, nonatomic) IBOutlet UILabel *noPaymentText;
@property (strong, nonatomic) IBOutlet UITableView *tableTransferPayment;
@property (strong, nonatomic) IBOutlet UILabel *totalTrans;
@property (strong, nonatomic) IBOutlet UITableView *tableSeller;

@property (strong, nonatomic) IBOutlet UILabel *shippingName;
@property (strong, nonatomic) IBOutlet UILabel *shippingAddress;
@property (strong, nonatomic) IBOutlet UILabel *shippingLocation;
@property (strong, nonatomic) IBOutlet UILabel *shippingMethod;
@property (strong, nonatomic) IBOutlet UILabel *shippingEmail;
@property (strong, nonatomic) IBOutlet UILabel *shippingPhone;

@property (strong, nonatomic) IBOutlet UITableView *tableProductList;
@property (strong, nonatomic) IBOutlet UIView *statusOrderForm;
@property (strong, nonatomic) IBOutlet UILabel *itemSummaryTotal;
@property (strong, nonatomic) IBOutlet DropDownTextField *statusOrder;
@property (strong, nonatomic) IBOutlet UIButton *statusOrderUpdateBtn;
@property (strong, nonatomic) IBOutlet UILabel *shippingCharge;
@property (strong, nonatomic) IBOutlet UILabel *shippingChargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtotal;
@property (strong, nonatomic) IBOutlet UILabel *grandTotal;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) DXPopover *popover;
@property (strong, nonatomic) IBOutlet UITableView *orderStatusTable;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *updateStatusOrderBtnTopConstraint;

- (IBAction)updateOrderStatus:(id)sender;

@end
