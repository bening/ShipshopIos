//
//  CustomRightViewTextfield.m
//  Y2OnlineShop
//
//  Created by maverick on 1/28/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "CustomRightViewTextfield.h"

@implementation CustomRightViewTextfield
@synthesize rightViewDistance;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)useRightView:(id)rightView {
    
    self.clipsToBounds = YES;
    [self setRightViewMode:UITextFieldViewModeAlways];
    
    self.rightView = rightView;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= rightViewDistance;
    return textRect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
