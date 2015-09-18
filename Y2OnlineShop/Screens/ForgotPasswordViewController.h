//
//  ForgotPasswordViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 2/6/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldValidator.h"

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate>{
    int widthContentView;
}
@property (strong, nonatomic) IBOutlet UILabel *pageTitle;
@property (strong, nonatomic) IBOutlet TextFieldValidator *emailField;
@property (strong, nonatomic) IBOutlet UILabel *responseLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;


- (IBAction)requestResetPassword:(id)sender;

@end
