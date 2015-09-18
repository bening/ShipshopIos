//
//  CustomRightViewTextfield.h
//  Y2OnlineShop
//
//  Created by maverick on 1/28/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomRightViewTextfield : UITextField
@property int rightViewDistance;
- (void)useRightView:(id)rightView;

@end
