//
//  DropDownTextField.m
//  Y2OnlineShop
//
//  Created by maverick on 1/9/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "DropDownTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation DropDownTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        
        self.clipsToBounds = YES;
        [self setRightViewMode:UITextFieldViewModeAlways];
        
        self.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-01-16.png"]];
    }
    
    return self;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= 10;
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
