//
//  ReturViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/20/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReturViewController : UIViewController<UITextFieldDelegate>
{
    int widthContentView;
    bool viewLiftedUp;
}

@property (nonatomic) IBOutlet UITextField *nameTextfield;
@property (nonatomic) IBOutlet UITextField *noTelpTextfield;
@property (nonatomic) IBOutlet UITextField *emailTextfield;
@property (nonatomic) IBOutlet UITextField *orderTextfield;

@end
