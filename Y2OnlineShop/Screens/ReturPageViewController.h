//
//  ReturPageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 2/5/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownTextField.h"
#import "CustomRightViewTextfield.h"
#import "DXPopover.h"
#import "VCDelegate.h"

@interface ReturPageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,VCDelegate>{
    int widthContentView;
    NSMutableArray *returList;
    NSMutableArray *returStatusList;
    BOOL shouldDismissPopover;
    BOOL popoverShown;
    UITextField* activeTextField;
    NSDateFormatter *dateFormat;
    int indexOfSelecetedStatusRetur;
    int currentPage;
    NSString* selectedOrderNumber;
    NSNumber* selectedReturStatusId;
    NSString* selectedDateAdded;
    NSString* selectedCustomer;
    BOOL refreshReturList;
    BOOL returListReachEnd;
}

@property (strong, nonatomic) IBOutlet UIView *rootWrapper;
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet UITextField *orderNumber;
@property (strong, nonatomic) IBOutlet DropDownTextField *returStatus;
@property (strong, nonatomic) IBOutlet CustomRightViewTextfield *dateAdded;
@property (strong, nonatomic) IBOutlet UITextField *customer;
@property (strong, nonatomic) IBOutlet UIButton *filterBtn;
@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (strong, nonatomic) IBOutlet UILabel *tableTitle;
@property (strong, nonatomic) IBOutlet UITableView *tableRetur;
@property (strong, nonatomic) DXPopover *popover;
@property (strong, nonatomic) IBOutlet UITableView *returStatusTable;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *datePickerToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *datePickerCancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *datePickerDoneBtn;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;


- (IBAction)filterReturList:(id)sender;
- (IBAction)dismissDatePicker:(id)sender;
- (IBAction)pickDatePicker:(id)sender;

@end
