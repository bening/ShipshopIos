//
//  ProfilePageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/17/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "TextFieldValidator.h"
#import "SZTextView.h"
#import "M_User.h"
#import "LeftMenuTVC.h"

@interface ProfilePageViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate, UITableViewDataSource,ASIHTTPRequestDelegate>{
    NSDateFormatter *format;
    NSString *validatorMessage;
    UIView* activeTextField;
    bool viewLiftedUp;
    int selectedGender;
    int selectedCity;
    NSMutableDictionary* allData;
    NSMutableArray *cityList;
    int widthContentView;
    
    UIGestureRecognizer *tapper;
}
@property (strong, nonatomic) M_User* myProfile;
@property (strong, nonatomic) LeftMenuTVC* leftMenuReference;

@property (strong, nonatomic) IBOutlet UIButton *infoAccBtn;
@property (strong, nonatomic) IBOutlet UIButton *dataAccBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *infoAccScroller;
@property (strong, nonatomic) IBOutlet UIScrollView *dataAccScroller;
@property (strong, nonatomic) IBOutlet UIView *infoAccount;
@property (strong, nonatomic) IBOutlet UIView *dataAccount;
@property (strong, nonatomic) IBOutlet TextFieldValidator *userName;
@property (strong, nonatomic) IBOutlet TextFieldValidator *password;
@property (strong, nonatomic) IBOutlet TextFieldValidator *userNewPassword;
@property (strong, nonatomic) IBOutlet TextFieldValidator *name;
@property (strong, nonatomic) IBOutlet TextFieldValidator *gender;
@property (strong, nonatomic) IBOutlet TextFieldValidator *birthdate;
@property (strong, nonatomic) IBOutlet TextFieldValidator *phone;
//@property (strong, nonatomic) IBOutlet TextFieldValidator *phoneOther;
@property (strong, nonatomic) IBOutlet SZTextView *address;
@property (strong, nonatomic) IBOutlet TextFieldValidator *city;
@property (strong, nonatomic) IBOutlet TextFieldValidator *email;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *changePassBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *datepickerLayout;
@property (strong, nonatomic) IBOutlet UIView *genderPickerLayout;
@property (strong, nonatomic) IBOutlet UIView *cityPickerLayout;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *datePickerToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneDatePicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelDatePicker;
@property (strong, nonatomic) IBOutlet UITableView *genderTable;
@property (strong, nonatomic) IBOutlet UITableView *cityTable;
@property (strong, nonatomic) IBOutlet UIToolbar *genderToolbar;
@property (strong, nonatomic) IBOutlet UIToolbar *cityToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelGenderPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleGenderPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneGenderPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelCityPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleCityPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneCityPicker;



- (IBAction)saveProfile:(id)sender;
- (IBAction)updatePassword:(id)sender;
- (IBAction)datepickerDismiss:(id)sender;
- (IBAction)datepickerDone:(id)sender;
- (IBAction)genderPickerDismiss:(id)sender;
- (IBAction)genderPickerDone:(id)sender;
- (IBAction)cityPickerDismiss:(id)sender;
- (IBAction)cityPickerDone:(id)sender;

@end
