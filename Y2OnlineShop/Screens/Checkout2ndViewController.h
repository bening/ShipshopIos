//
//  Checkout2ndViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/29/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13CheckBox.h"
#import "TextFieldValidator.h"
#import "DropDownTextField.h"
#import "DXPopover.h"

@interface Checkout2ndViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    int widthContentView;
    BOOL saveAccountInfo;
    UITextField* activeTextField;
    BOOL viewLiftedUp;
    NSDateFormatter *format;
    NSString *pngFilePath;
    int selectedAccount;
    NSString *validatorMsg;
    float accountTableWidth;
    BOOL keyboardIsShown;
}
@property (strong, nonatomic) NSString *orderNumber;
@property (strong, nonatomic) UISearchBar *searchBarRef;
@property (strong, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (strong, nonatomic) IBOutlet UIButton *transBtn;
@property (strong, nonatomic) IBOutlet UIButton *ccBtn;
@property (strong, nonatomic) IBOutlet UIView *viewTrans;
@property (strong, nonatomic) IBOutlet UIView *viewCC;
@property (strong, nonatomic) IBOutlet UIScrollView *transScroller;
@property (strong, nonatomic) IBOutlet UIScrollView *ccScroller;
@property (strong, nonatomic) IBOutlet M13Checkbox *saveAccountCheckBox;

@property (strong, nonatomic) IBOutlet DropDownTextField *destinationAcc;
@property (strong, nonatomic) IBOutlet TextFieldValidator *transferBank;
@property (strong, nonatomic) IBOutlet TextFieldValidator *transferAccount;
@property (strong, nonatomic) IBOutlet TextFieldValidator *transferName;
@property (strong, nonatomic) IBOutlet TextFieldValidator *transferDate;
@property (strong, nonatomic) IBOutlet UIButton *uploadBtn;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) DXPopover *popover;
@property (strong, nonatomic) IBOutlet UIView *uploadOptView;
@property (strong, nonatomic) IBOutlet UIImageView *transScript;
@property (strong, nonatomic) IBOutlet UIButton *selectPicBtn;
@property (strong, nonatomic) IBOutlet UIButton *takePicBtn;
@property (strong, nonatomic) IBOutlet UIView *datePickerLayout;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *datePickerToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *datePickerCancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *datePickerDoneBtn;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadingLabel;
@property (strong, nonatomic) IBOutlet UITableView *accountListTable;
@property (strong, nonatomic) IBOutlet UILabel *subTotalLabel;
@property (strong, nonatomic) IBOutlet UILabel *ongkosKirimLabel;
@property (strong, nonatomic) IBOutlet UILabel *discOngkosKirimLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroller;
@property (strong, nonatomic) IBOutlet UIView *wrapper;

- (IBAction)goBack:(id)sender;
- (IBAction)proceedToNextStep:(id)sender;
- (IBAction)uploadBtnSelected:(id)sender;
- (IBAction)selectPicture:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)dismissDatePicker:(id)sender;
- (IBAction)pickDate:(id)sender;

@end
