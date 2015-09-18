//
//  AppDelegate.m
//  Y2OnlineShop
//
//  Created by DIOS 4750 on 11/3/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "AppDelegate.h"

#import "HomeViewController.h"
#import "MainVC.h"
#import "DataSingleton.h"
#import "M_Category.h"
#import "Constants.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"



@implementation AppDelegate
@synthesize managedObjectContex;


-(NSManagedObjectContext *) managedObjectContex
{
    if(managedObjectContex == nil)
    {
        [self setUpCoreDataStack];
    }
    
    return managedObjectContex;
}

-(void)setUpCoreDataStack
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"y2.sqlite"];
    
    NSDictionary *options = @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete,
                              NSMigratePersistentStoresAutomaticallyOption:@YES};
    NSError *error = nil;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
    if (!store)
    {
        NSLog(@"Error adding persistent store. Error %@",error);
        
        NSError *deleteError = nil;
        if ([[NSFileManager defaultManager] removeItemAtURL:url error:&deleteError])
        {
            error = nil;
            store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
        }
        
        if (!store)
        {
            // Also inform the user...
            NSLog(@"Failed to create persistent store. Error %@. Delete error %@",error,deleteError);
            abort();
        }
    }
    
    managedObjectContex = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContex.persistentStoreCoordinator = psc;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application{
    NSLog(@"did finish launching");
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    NSString* deviceTokenString = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:deviceTokenString,@"token", nil];
    [DataSingleton saveDeviceWithThisData:deviceInfo];
    [DataSingleton retrieveUser];
    if ([DataSingleton instance].loggedInUser!=nil) {
        NSString* userID = [DataSingleton instance].loggedInUser.id_user;
        NSString* accessToken = [DataSingleton instance].loggedInUser.token;
        [self registerToken:deviceTokenString andUserID:userID andAccessToken:accessToken];
    }
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	//[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DataSingleton instance];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: @"notification"
                         message: @"You have notification"
                         delegate: self
                         cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [errorView setTag:0];
            [errorView show];
			//[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
    splashView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    
    if(IS_IPAD){
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            //Do what you want in Landscape Left
            splashView.image = !IS_RETINA ? [UIImage imageNamed:@"splash768x1024left"] : [UIImage imageNamed:@"splash2047x1536left"];
        }
        else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            //Do what you want in Landscape Right
            splashView.image = !IS_RETINA ? [UIImage imageNamed:@"splash768x1024right"] : [UIImage imageNamed:@"splash1536x2048right"];
        }
        else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
        {
            //Do what you want in Portrait
            splashView.image = !IS_RETINA ? [UIImage imageNamed:@"splash768x1024.png"] : [UIImage imageNamed:@"splash1536x2048"];
        }
        else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            //Do what you want in Portrait Upside Down
            splashView.image = !IS_RETINA ? [UIImage imageNamed:@"splash768x1024.png"] : [UIImage imageNamed:@"splash1536x2048"];
        }

    }
    
    
    splashView.contentMode = UIViewContentModeScaleAspectFill;
    splashView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.window addSubview:splashView];
    [self.window bringSubviewToFront:splashView];
    NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:splashView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.window//[UIScreen mainScreen]
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0];
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:splashView
                                attribute:NSLayoutAttributeWidth
                                relatedBy:0
                                toItem:self.window
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:splashView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.window
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:splashView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.window
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:splashView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.window
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    [self.window addConstraint:centerXConstraint];
    [self.window addConstraint:width];
    [self.window addConstraint:height];
    [self.window addConstraint:top];
    [self.window addConstraint:leading];
    
    [self.window makeKeyAndVisible];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus == NotReachable){
        [DataSingleton instance].networkError = true;
        NSLog(@"Queue finished");
        [splashView removeFromSuperview];
        self.mainVC = [[MainVC alloc] init];
        UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:self.mainVC];
        
        self.window.rootViewController = homeNav;
    }else{
        [DataSingleton instance].networkError = false;
        [self fetchData];
    }
    [DataSingleton retrieveUser];
    
    return YES;
}

-(void)fetchData{
    [networkQueue cancelAllOperations];
    networkQueue = [ASINetworkQueue queue];
    networkQueue.delegate = self;
    [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
	[networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
    [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
    [DataSingleton fetchInitiallData:networkQueue];
    [networkQueue go];
}

- (void)oneRequestFinished:(ASIHTTPRequest *)request
{
	// You could release the queue here if you wanted
	//if ([networkQueue requestsCount] == 0) {
        
		// Since this is a retained property, setting it to nil will release it
		// This is the safest way to handle releasing things - most of the time you only ever need to release in your accessors
		// And if you an Objective-C 2.0 property for the queue (as in this example) the accessor is generated automatically for you
		//networkQueue = nil;
	//}
    NSString *responseString = [request responseString];
    [DataSingleton processAPIRequestResult:responseString withRequestCode:request.tag];
	
	//... Handle success
	NSLog(@"Request finished");
}

- (void)oneRequestFailed:(ASIHTTPRequest *)request
{
    [DataSingleton instance].networkError = true;
    [networkQueue cancelAllOperations];
	// You could release the queue here if you wanted
//	if ([networkQueue requestsCount] == 0) {
//		networkQueue = nil;
//	}
	
	//... Handle failure
	NSLog(@"Request failed");
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	// You could release the queue here if you wanted
	if ([networkQueue requestsCount] == 0) {
		networkQueue = nil;
	}
	NSLog(@"Queue finished");
    if ([DataSingleton instance].showShopMenu) {
        //shop menu is visible/accessible
        [DataSingleton instance].topBrand = [[DataSingleton instance].allStore mutableCopy];
    }else{
        [DataSingleton instance].topBrand = [[DataSingleton instance].allAgent mutableCopy];
    }
    
    if ([DataSingleton instance].errorNotificationMessage.length>0) {
        [[DataSingleton instance].errorNotificationMessage insertString:[NSString stringWithFormat:@"There're some error occured on API (%@): \n",y2BaseURL] atIndex:0];
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: [DataSingleton instance].errorNotificationMessage
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
        [DataSingleton instance].errorNotificationMessage = [NSMutableString string];
    }

    self.mainVC = [[MainVC alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:self.mainVC];
    self.window.rootViewController = homeNav;
    [splashView removeFromSuperview];
    
    //[self.window makeKeyAndVisible];
}

- (void)registerToken:(NSString*)myToken andUserID:(NSString*)userID andAccessToken:(NSString*)accessToken
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus == NotReachable)
    {
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: message_connection_error
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }else
    {
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,registerDeviceTokenURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        request.tag = registerDeviceToken;
        [request setRequestMethod:@"POST"];
        
        [request addPostValue:userID forKey:@"user_id"];
        [request addPostValue:myToken forKey:@"device_token"];
        [request addPostValue:accessToken forKey:@"access_token"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (request.tag==registerDeviceToken) {
        NSLog(@"%@", request.error.description);
        
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: message_request_failed
                     delegate: self
                     cancelButtonTitle: @"OK" otherButtonTitles: nil];
        
        [errorView show];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
