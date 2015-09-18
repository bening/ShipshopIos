//
//  GrosirVariantItem.m
//  Y2OnlineShop
//
//  Created by maverick on 4/16/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "GrosirVariantItem.h"

@implementation GrosirVariantItem
@synthesize grosirVariant;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        // Initialization code
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, self.frame.size.width-40.0, 40)];
        self.value = [[UITextField alloc] initWithFrame:CGRectMake(20, 55, self.frame.size.width-40.0, 40)];
        self.value.userInteractionEnabled = YES;
        self.value.enabled = YES;
        self.value.layer.masksToBounds=YES;
        self.value.layer.borderColor=[[UIColor grayColor]CGColor];
        self.value.layer.borderWidth= 1.0f;
        self.value.layer.cornerRadius = 5.0f;
        
        self.name.text = @"slingdidiw";
                
        [self addSubview:self.name];
        [self addSubview:self.value];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andGrosirVariant:(NSDictionary*)variant{
    self = [self initWithFrame:frame];
    if(self){
        self.grosirVariant = variant;
        if(self.grosirVariant){
            
        }
        
    }
    
    return  self;
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
