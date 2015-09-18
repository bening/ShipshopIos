//
//  UIButton+CustomData.m
//  Y2OnlineShop
//
//  Created by maverick on 1/20/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "UIButton+CustomData.h"
#import <objc/objc.h>
#import <objc/runtime.h>

@implementation UIButton (CustomData)

-(void)setDataDictionary:(NSDictionary*)data{
    objc_setAssociatedObject(self,@"dataDictionary",data,OBJC_ASSOCIATION_RETAIN);
}

-(NSDictionary*)getDataDictionary{
    if (objc_getAssociatedObject(self, @"dataDictionary")==nil)
    {
        objc_setAssociatedObject(self,@"dataDictionary",[[NSNumber alloc] init],OBJC_ASSOCIATION_RETAIN);
    }
    return (NSDictionary *)objc_getAssociatedObject(self, @"dataDictionary");
}

@end
