//
//  DetailViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/10/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentTableViewCell.h"
#import "ASStarRatingView.h"
#import "SZTextView.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"

@interface DetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIWebViewDelegate, ASIHTTPRequestDelegate>{
    NSMutableString* contentRincian;
    NSMutableArray *comments;
    BOOL viewLiftedUp;
    NSMutableArray *buttonColl;
    NSMutableDictionary *comment;
    MBProgressHUD *progress;
}

@property (strong, nonatomic) NSDictionary* productToDisplay;

@property (strong, nonatomic) IBOutlet UIScrollView *rootScroller;
@property (strong, nonatomic) IBOutlet UIView *rootWrapper;
@property (strong, nonatomic) IBOutlet UILabel *ownerName;
@property (strong, nonatomic) IBOutlet UILabel *brandName;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *stockLabel;

@property (strong, nonatomic) IBOutlet UIView *viewDeskripsi;
@property (strong, nonatomic) IBOutlet UIWebView *deskripsiText;

@property (strong, nonatomic) IBOutlet UIView *viewRincian;
@property (strong, nonatomic) IBOutlet UIWebView *rincianText;

@property (strong, nonatomic) IBOutlet UIView *viewBrand;
@property (strong, nonatomic) IBOutlet UIWebView *brandText;
@property (strong, nonatomic) IBOutlet UIImageView *brandImage;

@property (strong, nonatomic) IBOutlet UIView *viewKomentar;
@property (strong, nonatomic) IBOutlet UITableView *komentarTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *komentarLoader;

@property (strong, nonatomic) IBOutlet UIView *viewInfoPengiriman;
@property (strong, nonatomic) IBOutlet UIWebView *infoPengirimanText;

@property (strong, nonatomic) IBOutlet SZTextView *commentTextField;
@property (strong, nonatomic) IBOutlet UIButton *commentSendBtn;
@property (strong, nonatomic) IBOutlet ASStarRatingView *commentRatingView;
@property (strong, nonatomic) IBOutlet UIButton *deskrpsiBtn;
@property (strong, nonatomic) IBOutlet UIButton *rincianBtn;
@property (strong, nonatomic) IBOutlet UIButton *brandBtn;
@property (strong, nonatomic) IBOutlet UIButton *komentarBtn;
@property (strong, nonatomic) IBOutlet UIButton *infoPengirimanBtn;
@property (strong, nonatomic) IBOutlet UIView *buttonWrapper;

@property bool isRetail;

@end
