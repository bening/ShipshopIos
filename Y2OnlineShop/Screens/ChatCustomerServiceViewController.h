//
//  ChatCustomerServiceViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/20/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface ChatCustomerServiceViewController : UIViewController<UITextFieldDelegate>
{
    int widthContentView;
    bool viewLiftedUp;
}
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
@property (strong, nonatomic) IBOutlet UITextField *chatBox;
- (IBAction)sendChat:(id)sender;

@end
