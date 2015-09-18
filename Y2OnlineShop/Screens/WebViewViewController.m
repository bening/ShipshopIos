//
//  WebViewViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 2/9/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "WebViewViewController.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
@interface WebViewViewController ()

@end

@implementation WebViewViewController
@synthesize titleMenu,idTautan,content,loadingWrapper,loadingOverlay,loading,searchBarGrosir,searchBarRetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1.0f];
    }
    
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,widthContentView,self.navigationController.navigationBar.frame.size.height)];
//    UIView* wrapper = [[UIView alloc]init];
//    wrapper.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    UIImageView *imageLogo = [[UIImageView alloc]
//                              initWithFrame:CGRectMake(0,0,3,44)];
//    imageLogo.contentMode = UIViewContentModeLeft;
//    imageLogo.clipsToBounds = NO;
//    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35,0,widthContentView-30,self.navigationController.navigationBar.frame.size.height)];
//    titleLabel.text = titleMenu;
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor = [UIColor whiteColor];
//    [wrapper addSubview:imageLogo];
//    [wrapper addSubview:titleLabel];
//    [contentView addSubview:wrapper];
//    // Center Horizontally
//    NSLayoutConstraint *centerXConstraint =
//    [NSLayoutConstraint constraintWithItem:wrapper
//                                 attribute:NSLayoutAttributeCenterX
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:contentView
//                                 attribute:NSLayoutAttributeCenterX
//                                multiplier:1.0
//                                  constant:0.0];
//    [contentView addConstraint:centerXConstraint];
//    
//    searchBarRetail = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
//    searchBarRetail.alpha=0;
//    searchBarRetail.transform = CGAffineTransformMakeScale(0,0);
//    [searchBarRetail setBackgroundColor:[UIColor clearColor]];
//    searchBarRetail.barTintColor=[UIColor clearColor];
//    searchBarRetail.placeholder = @"Cari Produk Retail...";
//    searchBarRetail.delegate= [DataSingleton instance];
//    searchBarRetail.tag = search_bar_retail;
//    
//    searchBarGrosir = [[UISearchBar alloc] initWithFrame:CGRectMake(135,0,440,self.navigationController.navigationBar.frame.size.height)];
//    searchBarGrosir.alpha=0;
//    searchBarGrosir.transform = CGAffineTransformMakeScale(0,0);
//    [searchBarGrosir setBackgroundColor:[UIColor clearColor]];
//    searchBarGrosir.barTintColor=[UIColor clearColor];
//    searchBarGrosir.placeholder = @"Cari Produk Grosir...";
//    searchBarGrosir.delegate= [DataSingleton instance];
//    searchBarGrosir.tag = search_bar_grosir;
//    
//    [contentView addSubview:searchBarRetail];
//    [contentView addSubview:searchBarGrosir];
//    
//    self.navigationItem.titleView = contentView;
//    
//    [DataSingleton instance].navigationController = self.navigationController;
//    [DataSingleton instance].searchBarRetail = searchBarRetail;
//    [DataSingleton instance].searchBarGrosir = searchBarGrosir;
//    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].wishBarButtonItem, [DataSingleton instance].shopBarButtonItem, [DataSingleton instance].searchBarProductRetail,[DataSingleton instance].searchBarProductGrosir, nil];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,widthContentView,self.navigationController.navigationBar.frame.size.height)];
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    UIImageView *imageLogo = [[UIImageView alloc] init];
    imageLogo.contentMode = UIViewContentModeScaleAspectFit;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [imageLogo sizeToFit];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
    titleLabel.text = titleMenu;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    searchBarRetail = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(contentView.frame),CGRectGetHeight(contentView.frame))];
    searchBarRetail.alpha=0;
    searchBarRetail.transform = CGAffineTransformMakeScale(0,0);
    [searchBarRetail setBackgroundColor:[UIColor clearColor]];
    searchBarRetail.barTintColor=[UIColor clearColor];
    searchBarRetail.placeholder = @"Cari Produk Retail...";
    searchBarRetail.delegate= [DataSingleton instance];
    searchBarRetail.tag = search_bar_retail;
    
    searchBarGrosir = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(contentView.frame),CGRectGetHeight(contentView.frame))];
    searchBarGrosir.alpha=0;
    searchBarGrosir.transform = CGAffineTransformMakeScale(0,0);
    [searchBarGrosir setBackgroundColor:[UIColor clearColor]];
    searchBarGrosir.barTintColor=[UIColor clearColor];
    searchBarGrosir.placeholder = @"Cari Produk Grosir...";
    searchBarGrosir.delegate= [DataSingleton instance];
    searchBarGrosir.tag = search_bar_grosir;
    
    searchBarRetail.translatesAutoresizingMaskIntoConstraints = NO;
    searchBarGrosir.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:searchBarRetail];
    [contentView addSubview:searchBarGrosir];
    
    float spaceLeftLogoToSuperview = 0.0;
    //    if (IS_IPAD) {
    //        spaceLeftLogoToSuperview = 10.0f;
    //    }else {
    //        spaceLeftLogoToSuperview = 5.0f;
    //    }
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(contentView,titleLabel,imageLogo,searchBarRetail,searchBarGrosir);
    //padding left constraint for imageLogo
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-constantSpace-[imageLogo]" options:0 metrics: @{@"constantSpace":@(spaceLeftLogoToSuperview)} views:viewsDictionary]];
    //height constraint in order to not exceed navigationBar height
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageLogo(<=constantHeight)]" options:0 metrics:@{@"constantHeight":@(self.navigationController.navigationBar.frame.size.height)} views:viewsDictionary]];
    
    NSLayoutConstraint *aspectRatioConstraint =[NSLayoutConstraint
                                                constraintWithItem:imageLogo
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:imageLogo
                                                attribute:NSLayoutAttributeWidth
                                                multiplier:CGRectGetHeight(imageLogo.frame)/CGRectGetWidth(imageLogo.frame) //Aspect ratio: height:width
                                                constant:0.0f];
    [contentView addConstraint:aspectRatioConstraint];
    
    //space constraint between imageLogo and titleLabel
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageLogo]-constantSpace-[titleLabel]-0-|" options:0 metrics: @{@"constantSpace":@(spaceLogoToTitle)} views:viewsDictionary]];
    
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageLogo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    //constraint for searchBar in order to extend its width to the fullest width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarRetail]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBarGrosir]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    //constraint for searchBar in order to extend its height to the height width of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarRetail]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBarGrosir]-0-|" options:0 metrics: 0 views:viewsDictionary]];
    
    self.navigationItem.titleView = contentView;
    
    [DataSingleton instance].navigationController = self.navigationController;
    [DataSingleton instance].searchBarRetail = searchBarRetail;
    [DataSingleton instance].searchBarGrosir = searchBarGrosir;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:[DataSingleton instance].wishBarButtonItem, [DataSingleton instance].shopBarButtonItem, [DataSingleton instance].searchBarProductRetail,[DataSingleton instance].searchBarProductGrosir, nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeComponent];
    [self getContentForThisPage];
}

- (void)initializeComponent{
    loadingWrapper.layer.cornerRadius = 10.0f;
}

- (void)shallShowLoadingOverlay:(BOOL)show{
    loadingOverlay.hidden = !show;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ASIHTTPRequest
#pragma mark - delegate

- (void)getContentForThisPage{
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
        [self shallShowLoadingOverlay:YES];
        NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,getFooterContentURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
        
        [request setRequestMethod:@"POST"];
        
        [request addPostValue:idTautan forKey:@"id_tautan"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self shallShowLoadingOverlay:NO];
    UIAlertView *errorView;
    
    errorView = [[UIAlertView alloc]
                 initWithTitle: title_error
                 message: message_request_failed
                 delegate: self
                 cancelButtonTitle: @"OK" otherButtonTitles: nil];
    
    [errorView show];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self shallShowLoadingOverlay:NO];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (success) {
        NSDictionary* resultData = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
        [content loadHTMLString:[resultData valueForKey:@"cat_content"] baseURL:nil];
    }else{
        NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: errorMessage
                     delegate: self
                     cancelButtonTitle: @"Close" otherButtonTitles: nil];
        [errorView setTag:0];
        [errorView show];
    }
}

@end
