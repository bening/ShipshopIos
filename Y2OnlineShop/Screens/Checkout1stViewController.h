//
//  Checkout1stViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/24/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"
#import "TextFieldValidator.h"
#import "SZTextView.h"
#import "DXPopover.h"

@interface Checkout1stViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate>{
    bool viewLiftedUp;
    UITextField* activeTextField;
    NSMutableArray *cityList;
    int selectedCity;
    int widthContentView;
    NSString *orderNumber;
}
@property BOOL isRetail;
@property (strong, nonatomic) UISearchBar *searchBarRef;
@property (strong, nonatomic) IBOutlet M13Checkbox *titipToko;
@property (strong, nonatomic) IBOutlet TextFieldValidator *tokoName;
@property (strong, nonatomic) IBOutlet UIButton *helpBtn;
@property (strong, nonatomic) IBOutlet M13Checkbox *y2Pool;
@property (strong, nonatomic) IBOutlet M13Checkbox *myAddress;
@property (strong, nonatomic) IBOutlet M13Checkbox *otherAddress;
@property (strong, nonatomic) IBOutlet UIView *cityPickerLayout;
@property (strong, nonatomic) IBOutlet UITableView *cityTable;
@property (strong, nonatomic) IBOutlet UIToolbar *cityPickerToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelCityPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleCityPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneCityPicker;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
- (IBAction)dismissCityPicker:(id)sender;
- (IBAction)pickCity:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *prevBtn;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) IBOutlet UIView *addressLayout;
@property (strong, nonatomic) IBOutlet TextFieldValidator *name;
@property (strong, nonatomic) IBOutlet TextFieldValidator *phone;
@property (strong, nonatomic) IBOutlet TextFieldValidator *city;
@property (strong, nonatomic) IBOutlet TextFieldValidator *fee;
@property (strong, nonatomic) IBOutlet SZTextView *address;
@property (strong, nonatomic) IBOutlet UITextView *helpMsgTextView;
@property (nonatomic, strong) DXPopover *popover;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroller;
@property (strong, nonatomic) IBOutlet UIView *wrapper;
@property (strong, nonatomic) IBOutlet UILabel *metodePengirimanLabel;
@property (strong, nonatomic) IBOutlet UIView *metodePengirimanWrapper;
@property (strong, nonatomic) IBOutlet UILabel *alamatPengirimanLabel;
@property (strong, nonatomic) IBOutlet UILabel *dataPengirimanLabel;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet TextFieldValidator *expedisi;

- (IBAction)goBack:(id)sender;
- (IBAction)goToNextStep:(id)sender;
- (IBAction)showHelpPopup:(id)sender;

@end
