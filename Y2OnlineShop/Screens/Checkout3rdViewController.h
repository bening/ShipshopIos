//
//  Checkout3rdViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/29/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Checkout3rdViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *thanksText;
@property (strong, nonatomic) IBOutlet UILabel *messageText;
@property (strong, nonatomic) IBOutlet UIView *messageBox;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeBtn;
- (IBAction)backToHome:(id)sender;

@end
