//
//  Manager.m
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/6/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "Manager.h"

@implementation Manager

@synthesize isAgen, isSubAgen, isUser, isLogin;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static Manager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        isAgen = false;
        isSubAgen = false;
        isUser = false;
        isLogin = false;
    }
    return self;
}

//+ (void)setProduct
//{
//    NSMutableArray *imagesAtasan = [[NSMutableArray alloc]initWithObjects:@"atasan0.jpg",@"atasan1.jpg",@"atasan2.jpg",@"atasan3.jpg",@"atasan4.jpg",@"atasan5.jpg",@"atasan6.jpg",@"atasan7.jpg",@"atasan8.jpg",@"atasan9.jpg",@"atasan10.jpg",@"atasan11.jpg",@"atasan12.jpg",@"atasan13.jpg",@"atasan14.jpg",@"atasan15.jpg",@"atasan16.jpg",nil];
//    NSMutableArray *imagesBawahan = [[NSMutableArray alloc] initWithObjects:@"bawahan0.jpg", nil];
//    NSMutableArray *imagesMukenah = [[NSMutableArray alloc] initWithObjects:@"mukenah0.jpg",@"mukenah1.jpg",@"mukenah2.jpg", @"mukenah3.jpg",@"mukenah4.jpg",@"mukenah5.jpg", nil];
//    
//    float varPrice = 0.1;
//    
//    for (int i=0; i< [imagesAtasan count]; i++)
//    {
//        Product * _product = [[Product alloc] initWithID:[NSNumber numberWithInt:(int)[products count]+1] andName:[NSString stringWithFormat:@"Atasan %d",(int)[products count]+1] withImage:[UIImage imageNamed:[imagesAtasan objectAtIndex:i]] withPrice:[NSNumber numberWithInt:((i+1)*10000)+(varPrice*((i+1)*10000))] withPriceRetail:[NSNumber numberWithInt:((i+1)*10000)+(varPrice*((i+1)*10000))]];
//        
//        [products addObject:_product];
//        
//        [_product setImages:[NSMutableArray arrayWithObject:[imagesAtasan objectAtIndex:i]]];
//        for (int j=0; j< [imagesMukenah count]; j++) {
//            [_product.images addObject:[imagesMukenah objectAtIndex:j]];
//        }
//        
//        [products addObject:_product];
//    }
//    
//    for (int i=0; i< [imagesBawahan count]; i++) {
//        Product * _product = [[Product alloc] initWithID:[NSNumber numberWithInt:(int)[products count]+1] andName:[NSString stringWithFormat:@"Bawahan %d",(int)[products count]+1] withImage:[UIImage imageNamed:[imagesAtasan objectAtIndex:i]] withPrice:[NSNumber numberWithInt:((i+1)*10000)+(varPrice*((i+1)*10000))] withPriceRetail:[NSNumber numberWithInt:((i+1)*10000)+(varPrice*((i+1)*10000))]];
//        
//        [_product setImages:[NSMutableArray arrayWithObject:[imagesBawahan objectAtIndex:i]]];
//        for (int j=0; j< [imagesMukenah count]; j++) {
//            [_product.images addObject:[imagesMukenah objectAtIndex:j]];
//        }
//        
//        [products addObject:_product];
//    }
//    
//    for (int i=0; i< [imagesMukenah count]; i++) {
//        Product * _product = [[Product alloc] initWithID:[NSNumber numberWithInt:(int)[products count]+1] andName:[NSString stringWithFormat:@"Mukenah %d",(int)[products count]+1] withImage:[UIImage imageNamed:[imagesAtasan objectAtIndex:i]] withPrice:[NSNumber numberWithInt:((i+1)*10000)+(varPrice*((i+1)*10000))] withPriceRetail:[NSNumber numberWithInt:((i+1)*10000)+(varPrice*((i+1)*10000))]];
//        
//        [_product setImages:[NSMutableArray arrayWithObject:[imagesMukenah objectAtIndex:i]]];
//        for (int j=0; j< [imagesMukenah count]; j++) {
//            [_product.images addObject:[imagesMukenah objectAtIndex:j]];
//        }
//        
//        [products addObject:_product];
//    }
//}
//
//+ (Product*)getProduct:(int)index:
//{
//    Product* _product = (Product*)[products objectAtIndex:currentIndex];
//    
//    return _product;
//}

@end
