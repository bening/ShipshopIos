//
//  SalesOrderViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 1/28/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownTextField.h"
#import "CustomRightViewTextfield.h"
#import "DXPopover.h"
#import "VCDelegate.h"

@interface SalesOrderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,VCDelegate>{
    int widthContentView;
    NSMutableArray *salesOrderList;
    NSMutableArray *orderStatusList;
    BOOL shouldDismissPopover;
    BOOL popoverShown;
    UITextField* activeTextField;
    NSDateFormatter *dateFormat;
    int indexOfSelecetedStatusOrder;
    int currentPage;
    NSString* selectedOrderNumber;
    NSNumber* selectedOrderStatusId;
    NSString* selectedDateAdded;
    NSString* selectedCustomer;
    BOOL refreshSalesOrderList;
    BOOL salesOrderListReachEnd;
}
@property (strong, nonatomic) IBOutlet UIView *rootWrapper;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet UITextField *orderNumber;
@property (strong, nonatomic) IBOutlet DropDownTextField *orderStatus;
@property (strong, nonatomic) IBOutlet CustomRightViewTextfield *dateAdded;
@property (strong, nonatomic) IBOutlet UITextField *customer;
@property (strong, nonatomic) IBOutlet UIButton *filterBtn;
@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (strong, nonatomic) IBOutlet UILabel *tableTitle;
@property (strong, nonatomic) IBOutlet UITableView *salesOrderTable;
@property (strong, nonatomic) DXPopover *popover;
@property (strong, nonatomic) IBOutlet UITableView *orderStatusTable;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *datePickerToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *datePickerCancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *datePickerDoneBtn;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;


- (IBAction)filterSalesOrder:(id)sender;
- (IBAction)dismissDatePicker:(id)sender;
- (IBAction)pickDatePicker:(id)sender;

@end
