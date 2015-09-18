//
//  CustomerServiceViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 11/20/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingQuestionViewController.h"
#import "ChatCustomerServiceViewController.h"
#import "ReturViewController.h"

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface CustomerServiceViewController : UIViewController
{    
    int widthContentView;
}
@end
