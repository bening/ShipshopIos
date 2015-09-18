//
//  DetailViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 12/10/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import "DetailViewController.h"
#import "CommentTableViewCell.h"
#import "Constants.h"
#import "Product.h"
#import "DataSingleton.h"
#import "UIButton+CustomData.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"

#define btn_bg_color_default [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]
#define btn_bg_color_selected [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0]
#define btn_txt_color_default [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1.0]
#define btn_txt_color_selected [UIColor whiteColor]
#define view_binder_key @"view_binder"

#define confirm_send_review 24

static NSString * const CommentCellIdentifier = @"CommentCell";

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize productToDisplay, productName,priceLabel,stockLabel,brandName,ownerName,deskripsiText,viewDeskripsi,viewRincian,rincianText,viewBrand,brandText,viewKomentar,komentarTable,komentarLoader,viewInfoPengiriman,infoPengirimanText,commentRatingView,commentSendBtn,commentTextField,deskrpsiBtn,rincianBtn,brandBtn,komentarBtn,infoPengirimanBtn, buttonWrapper,rootScroller,rootWrapper,brandImage,isRetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    contentRincian = [NSMutableString string];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    productName.text = [productToDisplay valueForKey:@"prd_name"];
    NSNumber* appropriatePrice = [productToDisplay valueForKey:@"prd_price"];
    int price = [appropriatePrice intValue];
    NSNumberFormatter *commas = [NSNumberFormatter new];
    commas.numberStyle = NSNumberFormatterDecimalStyle;
    double incomeValue = (price / 1000.0);
    priceLabel.text = [NSString stringWithFormat:@"Rp %@",
                       [commas stringFromNumber:[NSNumber numberWithDouble:incomeValue * 1000]]];
    ownerName.text = [productToDisplay valueForKey:@"nama_toko"];
    brandName.text = [productToDisplay valueForKey:@"brand_name"];
    ownerName.font = FONT_ARSENAL_BOLD(17);
    NSNumber* stock = [NSNumber numberWithInt:0];
    NSString* productSKU = [productToDisplay valueForKey:@"prd_SKU"];
    NSNumber* stockID;
    BOOL isGrosirProduct = [(NSNumber*)[productToDisplay valueForKey:@"is_grosir"] boolValue];
    if (isGrosirProduct) {
        stockID = [productToDisplay valueForKey:@"stock_id"];
    }else{
        NSArray* selectedOptionProduct = (NSArray*)[productToDisplay valueForKey:product_option_key];
        NSDictionary* stockInfo = [DataSingleton getStockFromStockOption:[productToDisplay valueForKey:@"stock"] usingOptionData:selectedOptionProduct];
        
        stockID = [stockInfo valueForKey:@"stock_id"];
    }
    NSArray *filteredStock = [[DataSingleton instance].stockKeeper filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(stock_product_sku == %@ AND stock_qty_id == %@)",productSKU,stockID]];
    if (filteredStock.count > 0) {
        NSMutableDictionary *existingStock = (NSMutableDictionary*)[filteredStock objectAtIndex:0];
        stock = (NSNumber*)[existingStock valueForKey:stock_qty_key];
    }
    stockLabel.text = [NSString stringWithFormat:@"%d",[stock intValue]];
    [deskripsiText loadHTMLString:[productToDisplay valueForKey:@"prd_description"] baseURL:nil];
    
    deskripsiText.scrollView.bounces = NO;
    rincianText.scrollView.bounces = NO;
    brandText.scrollView.bounces = NO;
    
    comments = [productToDisplay valueForKey:@"user_review"];
    
    [komentarTable setDelegate:self];
    [komentarTable setDataSource:self];
    [komentarTable registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:CommentCellIdentifier];
    komentarTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, komentarTable.bounds.size.width, 0.01f)];
    commentRatingView.canEdit = YES;
    commentRatingView.maxRating = 5;
    commentRatingView.minAllowedRating = 0;
    commentRatingView.maxAllowedRating = 5;
    commentRatingView.rating = 0;
    infoPengirimanText.scrollView.bounces = NO;
    
    rincianText.delegate = self;
    brandText.delegate = self;
    infoPengirimanText.delegate = self;
    
//    NSString* brandImg = [NSString stringWithFormat:@"<a href=\"\" style=\"float: left; padding-right: 10px; display: inline-block;\"><img src=\"%@\" width=\"120\" height=\"100\"></a>",[productToDisplay valueForKey:@"brand_img"]];
//    NSMutableString* brandDescWrapper = [NSMutableString stringWithString:@"<div style=\"padding-left: 10px; display: block; overflow:hidden; float:left; width:80%;\">"];
//    NSString* brandDesc = [productToDisplay valueForKey:@"brand_description"];
//    [brandDescWrapper appendString:[NSString stringWithFormat:@"%@</div>",brandDesc]];
    
    NSString* brandHtml = [productToDisplay valueForKey:@"brand_description"];
    [brandText loadHTMLString:[NSString stringWithFormat:@"%@",brandHtml] baseURL:nil];
    
    if ([productToDisplay valueForKey:@"brand_img"]) {
        //[cell.productImg setImageWithURL:[NSURL URLWithString:_product.image] placeholderImage:nil];
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:COLOR_PINK_Y2];
        activityIndicator.center = brandImage.center;
        activityIndicator.hidesWhenStopped = YES;
        __weak UIImageView* thisImage = brandImage;
        [thisImage setImageWithURL:[productToDisplay valueForKey:@"brand_img"] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             if (!image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     thisImage.image = [UIImage imageNamed:@"icon_no_img.png"];
                 });
                 
                 NSLog(@"failed load image for product");
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activityIndicator removeFromSuperview];
             });
         }];
        [thisImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
    
    //style=\"background-color:lightgrey;\"
    [infoPengirimanText loadHTMLString:[NSString stringWithFormat:@"<p align=\"center\">%@</p>",[productToDisplay valueForKey:@"info_pengiriman"]] baseURL:nil];
    
    commentTextField.delegate = self;
    commentTextField.placeholder = @"Tulis komentar";
    commentTextField.placeholderTextColor =[UIColor lightGrayColor];
    
    buttonColl = [NSMutableArray array];
    for (UIButton* eachButton in buttonWrapper.subviews) {
        [buttonColl addObject:eachButton];
        [eachButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    //hide the view
    viewDeskripsi.hidden = YES;
    viewRincian.hidden = YES;
    viewBrand.hidden = YES;
    viewKomentar.hidden = YES;
    viewInfoPengiriman.hidden = YES;
    //binding view
    [deskrpsiBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:viewDeskripsi,view_binder_key, nil]];
    [rincianBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:viewRincian,view_binder_key, nil]];
    [brandBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:viewBrand,view_binder_key, nil]];
    [komentarBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:viewKomentar,view_binder_key, nil]];
    [infoPengirimanBtn setDataDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:viewInfoPengiriman,view_binder_key, nil]];
    
    [deskrpsiBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    if (!IS_IPAD) {
        UIView *mainView = self.view;
        
        // Set the constraints for the scroll view and the image view.
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(rootScroller, rootWrapper, mainView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rootScroller]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rootScroller]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rootWrapper]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rootWrapper]|" options:0 metrics: 0 views:viewsDictionary]];
        
        //hack to tie contentView width to the width of the screen
        [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rootWrapper(==mainView)]" options:0 metrics:0 views:viewsDictionary]];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)buttonSelected:(UIButton*)sender{
    sender.selected = YES;
    [sender setBackgroundColor:btn_bg_color_selected];
    ((UIView*)[[sender getDataDictionary] valueForKey:view_binder_key]).hidden = NO;
    
    NSMutableArray *btnCollTemp = [buttonColl mutableCopy];
    [btnCollTemp removeObject:sender];
    for (UIButton* eachBtn in btnCollTemp) {
        eachBtn.selected = NO;
        [eachBtn setBackgroundColor:btn_bg_color_default];
        ((UIView*)[[eachBtn getDataDictionary] valueForKey:view_binder_key]).hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if ([productToDisplay valueForKey:@"rincian_table"]) {
        contentRincian = [NSMutableString stringWithString:[productToDisplay valueForKey:@"rincian_table"]];
        [rincianText loadHTMLString:contentRincian baseURL:nil];
    }
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (viewLiftedUp) {
        [self animateViewUp];
    }
}

-(void)animateViewUp{
    int liftUp = 80;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 210;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 140;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 140;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftUp = 300;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftUp = 100;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftUp = 100;
        }
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame; frame.origin.y = -1*liftUp;
    [self.view setFrame:frame]; [UIView commitAnimations];
    viewLiftedUp =true;
}

-(void)animateViewDown{
    int liftDown = 45;
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        //potrait
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftDown = 45;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftDown = 43;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftDown = 43;
        }
        
    }else{
        //landscape
        if(IS_IPAD)
        {
            NSLog(@"IS_IPAD");
            liftDown = 45;
        }else if(IS_IPHONE_5)
        {
            NSLog(@"IS_IPHONE_5");
            liftDown = 32;
        }else{
            NSLog(@"~IS_IPHONE & ~IS_IPAD");
            liftDown = 32;
        }
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame; frame.origin.y = liftDown;
    [self.view setFrame:frame]; [UIView commitAnimations];
    viewLiftedUp = false;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self animateViewUp];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (viewLiftedUp) {
        [self animateViewDown];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSString *bodyStyle = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
//    [self.webView stringByEvaluatingJavaScriptFromString:bodyStyle];
    if (webView==rincianText) {
        NSLog(@"webView Rincian DidFinishLoad");
    }else if (webView==brandText){
        NSString *myText = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        NSLog(@"%@",myText);
    }else if (webView==infoPengirimanText) {
        NSLog(@"webView Info Pengiriman DidFinishLoad");
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //heightForRowAtIndexPath 1st, this will be called afterward
    //static NSString* simpleTableIdentifier = @"CommentCell";
    CommentTableViewCell *cell = (CommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier forIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = (int)row;
    NSDictionary* commentData = [comments objectAtIndex:row];
    cell.username.text = [commentData valueForKey:@"username"];
    cell.comment.text = [commentData valueForKey:@"content"];
    //cell.comment.preferredMaxLayoutWidth = CGRectGetWidth(komentarTable.bounds);
    cell.rating.canEdit = NO;
    cell.rating.maxRating = 5;
    cell.rating.minAllowedRating = 0;
    cell.rating.maxAllowedRating = 5;
    cell.rating.rating = [[commentData valueForKey:@"score"] intValue];
    if(row % 2 == 1){
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    
    
    //[cell setNeedsUpdateConstraints];
    //[cell updateConstraintsIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 95;
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CommentTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [komentarTable dequeueReusableCellWithIdentifier:CommentCellIdentifier];
    });
    
    NSUInteger row = [indexPath row];
    sizingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    sizingCell.tag = (int)row;
    NSDictionary* commentData = [comments objectAtIndex:row];
    sizingCell.username.text = [commentData valueForKey:@"username"];
    sizingCell.comment.text = [commentData valueForKey:@"content"];
    
    sizingCell.comment.preferredMaxLayoutWidth = CGRectGetWidth(komentarTable.bounds);
    sizingCell.rating.canEdit = NO;
    sizingCell.rating.maxRating = 5;
    sizingCell.rating.minAllowedRating = 0;
    sizingCell.rating.maxAllowedRating = 5;
    sizingCell.rating.rating = [[commentData valueForKey:@"score"] intValue];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //NSLog(@"height is %d",(int)size.height);
    return size.height; // Add 1.0f for the cell separator height
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    //    NSUInteger row = [indexPath row];
    //    NSLog(@"%lu",(unsigned long)row);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==confirm_send_review){
        if (buttonIndex==0) {
           
        }else{
            NSMutableDictionary *commentData = [NSMutableDictionary dictionary];
            
            [DataSingleton retrieveUser];
            [commentData setValue:[[DataSingleton instance].loggedInUser valueForKey:@"username"] forKey:@"username"];
            [commentData setValue:commentTextField.text forKey:@"content"];
            [commentData setValue:[NSNumber numberWithFloat:commentRatingView.rating] forKey:@"score"];
            
            [self sendReviewWithData:commentData];
        }
    }
    
}

- (IBAction)sendReview:(id)sender {
    [self.view endEditing:YES];
    if([[DataSingleton instance] isLogin]){
        if(commentTextField.text.length > 0){
            UIAlertView *confirmationDialog = [[UIAlertView alloc] initWithTitle:@"Konfirmasi"
                                                                         message:@"Kirim komentar anda sekarang?"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Tidak"
                                                               otherButtonTitles:@"Ya", nil];
            confirmationDialog.tag = confirm_send_review;
            [confirmationDialog show];
        } else{
            UIAlertView *errorView;
            
            errorView = [[UIAlertView alloc]
                         initWithTitle: title_error
                         message: @"Komentar harus diisi"
                         delegate: nil
                         cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
            
            [errorView show];
        }
    } else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Anda harus login terlebih dahulu"
                     delegate: nil
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
}

-(void) sendReviewWithData:(NSMutableDictionary*)commentData{
    if(commentData){
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
        } else{
            comment = commentData;
            
            [self showLoadingOverlay];
            
            NSString * myUrl = [NSString stringWithFormat:@"%@%@",y2BaseURL,saveUserReviewURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myUrl]];
            request.tag = saveUserReview;
            
            [request setRequestMethod:@"POST"];
            [DataSingleton retrieveUser];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
            [request addPostValue:[NSNumber numberWithBool:!isRetail] forKey:@"is_grosir"];
            [request addPostValue:[commentData valueForKey:@"content"] forKey:@"content"];
            [request addPostValue:[commentData valueForKey:@"score"] forKey:@"score"];
            [request addPostValue:[productToDisplay valueForKey:@"prd_id"] forKey:@"prd_id"];
            
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
    }
}

-(void) showLoadingOverlay{
    if(!progress){
        progress = [[MBProgressHUD alloc] initWithView:self.view];
        
        progress.dimBackground = YES;
        progress.labelText = @"Loading";
        [self.view addSubview:progress];
        
        [progress show:YES];
    }
}

-(void) hideLoadingOverlay{
    if(progress){
        [progress removeFromSuperview];
        progress = nil;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self hideLoadingOverlay];
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
    NSLog(@"finished");
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    if (request.tag==saveUserReview) {
        if (success) {
            [comments addObject:comment];
            [komentarTable reloadData];
            
            [self hideLoadingOverlay];
            
            UIAlertView *alert;
            
            alert = [[UIAlertView alloc]
                         initWithTitle: title_success
                         message: @"Sukses mengirim komentar"
                         delegate: self
                         cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
            
            [alert show];
            
            commentTextField.text = @"";
            commentRatingView.rating = 0;
        }else{
            [self hideLoadingOverlay];
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
}

@end
