//
//  RegisterViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/1/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "TextFieldValidator.h"

@interface RegisterViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,ASIHTTPRequestDelegate>{
    NSDateFormatter *format;
    NSString *validatorMessage;
    UITextField* activeTextField;
    bool viewLiftedUp;
    int selectedGender;
    int widthContentView;
    UIGestureRecognizer *tapper;
    
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet TextFieldValidator *username;
@property (strong, nonatomic) IBOutlet TextFieldValidator *email;
@property (strong, nonatomic) IBOutlet TextFieldValidator *password;
@property (strong, nonatomic) IBOutlet TextFieldValidator *passwordConfirmation;
@property (strong, nonatomic) IBOutlet TextFieldValidator *name;
@property (strong, nonatomic) IBOutlet TextFieldValidator *gender;
@property (strong, nonatomic) IBOutlet TextFieldValidator *birthdate;
@property (strong, nonatomic) IBOutlet TextFieldValidator *phone;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *datepickerLayout;
@property (strong, nonatomic) IBOutlet UIView *genderPickerLayout;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *datePickerToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneDatePicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelDatePicker;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *genderToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelGenderPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleGenderPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneGenderPicker;
@property (strong, nonatomic) IBOutlet UIView *wrapper;


- (IBAction)registrationProcess:(id)sender;
- (IBAction)datepickerDismiss:(id)sender;
- (IBAction)datepickerDone:(id)sender;
- (IBAction)genderPickerDismiss:(id)sender;
- (IBAction)genderPickerDone:(id)sender;

@end
