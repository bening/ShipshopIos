//
//  GrosirVariantItem.h
//  Y2OnlineShop
//
//  Created by maverick on 4/16/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrosirVariantItem : UIView

@property (nonatomic, retain) NSDictionary *grosirVariant;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UITextField *value;

- (id)initWithFrame:(CGRect)frame andGrosirVariant:(NSDictionary*)variant;

@end
