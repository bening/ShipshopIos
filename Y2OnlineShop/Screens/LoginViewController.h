//
//  LoginViewController.h
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/4/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "CustomRightViewTextfield.h"
@class LeftMenuTVC;

@interface LoginViewController : UIViewController <UITextFieldDelegate>{
    bool userNameTyped;
    bool passwordTyped;
    bool viewLiftedUp;
    int widthContentView;
    UITextField *activeTextField;
    
    UIGestureRecognizer *tapper;
}

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong,nonatomic) LeftMenuTVC * leftMenuReference;
@property (strong, nonatomic) IBOutlet CustomRightViewTextfield *username;
@property (strong, nonatomic) IBOutlet CustomRightViewTextfield *password;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIButton *forgotPassBtn;

- (IBAction)buttonLoginTapped:(UIButton *)sender;
- (IBAction)userNameChanged:(id)sender;
- (IBAction)passwordChanged:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
