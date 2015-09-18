//
//  WebViewViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 2/9/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController{
    int widthContentView;
}

@property (strong, nonatomic) NSString* titleMenu;
@property (strong, nonatomic) NSString* idTautan;
@property (strong, nonatomic) UISearchBar *searchBarRetail;
@property (strong, nonatomic) UISearchBar *searchBarGrosir;
@property (strong, nonatomic) IBOutlet UIWebView *content;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@end
