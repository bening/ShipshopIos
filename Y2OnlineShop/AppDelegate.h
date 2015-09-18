//
//  AppDelegate.h
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/3/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "M_DB.h"
#import "ASINetworkQueue.h"

@class HomeViewController;
@class MainVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    
    NSManagedObjectContext *managedObjectContex;
    ASINetworkQueue *networkQueue;
    UIImageView *splashView;
}

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) HomeViewController *homeViewController;
@property (strong, nonatomic) MainVC *mainVC;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContex;

@end
