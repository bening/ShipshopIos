//
//  UIButton+CustomData.h
//  Y2OnlineShop
//
//  Created by maverick on 1/20/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (CustomData)

- (void)setDataDictionary:(NSDictionary*)data;
- (NSDictionary*)getDataDictionary;
@end
