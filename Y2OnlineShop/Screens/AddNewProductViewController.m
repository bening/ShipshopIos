//
//  AddNewProductViewController.m
//  Y2OnlineShop
//
//  Created by maverick on 1/9/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "AddNewProductViewController.h"
#import "Constants.h"
#import "DataSingleton.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomRightViewTextfield.h"
#import "GrosirVariantItem.h"
#define brand_dropdown 1
#define gender_dropdown 2
#define category_dropdown 3
#define option_dropdown 4
#define loading_overlay 1
#define uploading_overlay 2
#define min_image_product 1
#define stock_field 999
#define queue_none 0
#define queue_add_image 1
#define queue_update_image 2

#define deleteAlert 17

static NSString * const ProductImageCellIdentifier = @"ProductImageCell";

@interface AddNewProductViewController ()

@end

@implementation AddNewProductViewController
@synthesize mainScroller,mainWrapper,name,sku,price,stock,weight,description,brand,gender,category,uploadImageBtn,noImageLabel,dropdownTableView,uploadOptionView,saveBtn,collectionView,productData,loadingOverlay,loadingWrapper,loading,uploadingWrapper,uploadingProgress,uploadingPercentage,variantView,isRetailProduct,addNewVariantBtn,addNewVariantLabel,stockLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        widthContentView = 175;
        if (IS_IPAD) {
            widthContentView = (widthContentView*4)-80;
        }
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
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,widthContentView,self.navigationController.navigationBar.frame.size.height)];
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    UIImageView *imageLogo = [[UIImageView alloc] init];
    imageLogo.contentMode = UIViewContentModeScaleAspectFit;
    imageLogo.image = [UIImage imageNamed:@"logo_header.png"];
    [imageLogo sizeToFit];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageLogo.frame)+spaceLogoToTitle,0,0,0)];
    titleLabel.text = productData ? @"Edit Produk" : @"Tambah Produk";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    imageLogo.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageLogo];
    [contentView addSubview:titleLabel];
    
    float spaceLeftLogoToSuperview = 0.0;
//    if (IS_IPAD) {
//        spaceLeftLogoToSuperview = 10.0f;
//    }else {
//        spaceLeftLogoToSuperview = 5.0f;
//    }
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(contentView,titleLabel,imageLogo);
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
    
    self.navigationItem.titleView = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeData];
    [self initializeComponent];
    if (productData!=nil) {
        isInitGrosirVariant = YES;
        [self populateField];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    /**
     variant view config
     */
//    if (isRetailProduct && !variantViewHasBeenInitialized) {
//        if(productData){
//            refreshVariantView = false;
//        }
//        
//        [self requestOptionValueForCatID];
//    }
    if (isInit && hasNotRequestForCategory) {
        hasNotRequestForCategory = YES;
        selectedGenderName = [(NSDictionary*)[[DataSingleton instance].categoryData objectAtIndex:selectedGenderIndex] valueForKey:@"gender"];
        [self requestForCategory];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if(_delegate && [_delegate respondsToSelector:@selector(addNewProduct:)])
        {
            [_delegate addNewProduct:addProductSuccessful];
        }
        
        if (submitEdit) {
            if(_delegate && [_delegate respondsToSelector:@selector(submitEditedProduct:)])
            {
                [_delegate submitEditedProduct:true];
            }
        }
    }
    [super viewWillDisappear:animated];
}

- (void)initializeComponent{
    for (id subview in mainWrapper.subviews) {
        [self border:subview];
    }
    for (id subview in uploadOptionView.subviews) {
        ((UIButton*)subview).layer.cornerRadius=5.0f;
        ((UIButton*)subview).titleLabel.font = FONT_ARSENAL(18);
    }
    uploadImageBtn.layer.cornerRadius = 5.0f;
    uploadImageBtn.titleLabel.font = FONT_ARSENAL_BOLD(18);
    saveBtn.layer.cornerRadius = 5.0f;
    saveBtn.titleLabel.font = FONT_ARSENAL_BOLD(18);
    dropdownPopover = [DXPopover new];
    dropdownPopover.maskType = DXPopoverMaskTypeNone;
    //dropdownPopover.backgroundColor = [UIColor lightGrayColor];
    dropdownTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240.0, 265.0) style:UITableViewStylePlain];
    dropdownTableView.backgroundColor = [UIColor lightGrayColor];
    dropdownTableView.delegate = self;
    dropdownTableView.dataSource = self;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    //[collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"imageCell"];
    [collectionView registerNib:[UINib nibWithNibName:@"ProductImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:ProductImageCellIdentifier];
    loadingWrapper.layer.cornerRadius = 10.0f;
    uploadingWrapper.layer.cornerRadius = 10.0f;
    addNewVariantBtn.layer.cornerRadius = 5.0f;
    
    if (brandValues.count>selectedBrandIndex) {
        brand.text = [NSString stringWithFormat:@"%@",[brandValues objectAtIndex:selectedBrandIndex]];
    }
    
    if (genderValues.count>selectedGenderIndex) {
        gender.text = [NSString stringWithFormat:@"%@",[genderValues objectAtIndex:selectedGenderIndex]];
    }
    
//    if (categoryValues.count>selectedCategoryIndex) {
//        category.text = [NSString stringWithFormat:@"%@",[categoryValues objectAtIndex:selectedCategoryIndex]];
//    }
    
    loadingOverlay.hidden = YES;
    loadingWrapper.hidden = YES;
    uploadingWrapper.hidden = YES;
    [uploadingProgress setProgress:0];
    uploadingPercentage.text = @"0%";
    //[name addRegx:regex_product_name withMsg:@"Nama hanya dapat diisi dengan huruf"];
    name.isMandatory = YES;
    //[sku addRegx:regex_sku withMsg:@"SKU minimal terdiri dari 1 karakter"];
    sku.isMandatory = NO;
    [price addRegx:regex_value withMsg:@"Input harga dengan benar"];
    price.isMandatory = YES;
    if (isRetailProduct) {
        stock.isMandatory = NO;
        stock.hidden = YES;
        stockLabel.hidden = YES;
    }else{
        [stock addRegx:regex_value withMsg:@"Input stok barang dengan benar"];
        stock.isMandatory = YES;
    }
    
//    [weight addRegx:regex_value withMsg:@"Input bobot barang dengan benar"];
    weight.isMandatory = YES;
    
    UIView *mainView = self.view;
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(mainScroller, mainWrapper, mainView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainScroller]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainScroller]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainWrapper]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainWrapper]-100-|" options:0 metrics: 0 views:viewsDictionary]];
    
    //hack to tie contentView width to the width of the screen
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainWrapper(==mainView)]" options:0 metrics:0 views:viewsDictionary]];
    
    if(productData){
        if(isRetailProduct){
            if(![DataSingleton instance].menuTambahProduct){
                [gender setEnabled:false];
                [category setEnabled:false];
                
                [gender setBackgroundColor:
                 [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];
                
                [category setBackgroundColor:
                 [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];

            }
        } else{
            if(![DataSingleton instance].menuTambahProductGrosir){
                [gender setEnabled:false];
                [category setEnabled:false];
                
                [gender setBackgroundColor:
                 [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];
                
                [category setBackgroundColor:
                 [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];

            }
        }
    }
    
    if(productData != nil && isRetailProduct){
        [gender setEnabled:false];
        [category setEnabled:false];
        
        [gender setBackgroundColor:
            [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];
        
        [category setBackgroundColor:
            [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];
    }
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    if(!IS_IPAD){
        noImageLabel.hidden = YES;
    }
    
    if(!isRetailProduct){
        addNewVariantBtn.hidden = YES;
    }
}

- (void)initializeData{
    variantViewHasBeenInitialized = NO;
    addProductSuccessful = false;
    submitEdit = false;
    uploadImageSuccess = true;
    refreshVariantView = true;
    numberOfProductImageUploaded = 0;
    variantKeyMapper = nil;
    variantViewTag = 0;
    dropdownValues = [NSMutableArray array];
    photos = [NSMutableArray array];
    brandValues = [NSMutableArray array];
    genderValues = [NSMutableArray array];
    categoryValues = [NSMutableArray array];
    viewVariantCollection = [NSMutableArray array];
    dataVariantCollection = [NSMutableArray array];
    variantDataList = [NSMutableArray array];
    selectedBrandIndex = 0;
    selectedGenderIndex = 0;
    selectedCategoryIndex = 0;
    
    for (NSDictionary* brandData in [DataSingleton instance].allBrand) {
        [brandValues addObject:[brandData valueForKey:@"brand_name"]];
    }
    for (NSDictionary* catData in [DataSingleton instance].categoryData) {
        [genderValues addObject:[catData valueForKey:@"gender"]];
    }
    
    categoryDict = [NSMutableDictionary dictionary];
    categoryValues = [NSMutableArray array];
    if ([DataSingleton instance].categoryData.count>0 && selectedGenderIndex<[DataSingleton instance].categoryData.count) {
        selectedGenderName = [(NSDictionary*)[[DataSingleton instance].categoryData objectAtIndex:selectedGenderIndex] valueForKey:@"gender"];
        isInit = YES;
    }
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    sessionQueue = queue_none;
    
    imagesToUpload = [NSMutableArray array];
    imagesToDelete = [NSMutableArray array];
}

- (void)populateField{
    [self shallShowLoadingOverlay:YES forAction:loading_overlay];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Call your function or whatever work that needs to be done
        //Code in this part is run on a background thread
        NSDictionary* brandInfo = [productData valueForKey:@"brand_data"];
        NSNumber* brandDataID = [brandInfo valueForKey:@"brand_id"];
        for (int i = 0; i<[DataSingleton instance].allBrand.count; i++) {
            NSDictionary* singleBrand = [[DataSingleton instance].allBrand objectAtIndex:i];
            NSNumber* singleBrandID = [singleBrand valueForKey:@"brand_id"];
            if ([brandDataID intValue]==[singleBrandID intValue]) {
                selectedBrandIndex = i;
                break;
            }
        }
        
        NSDictionary* categoryInfo = [productData valueForKey:@"cat_data"];
        NSString* catTypeInfo = [[categoryInfo valueForKey:@"cat_type"] isEqualToString:@"P"]?@"Pria":@"Wanita";

        for (int i = 0; i<[DataSingleton instance].categoryData.count; i++) {
            NSDictionary* singleCategoryData = [[DataSingleton instance].categoryData objectAtIndex:i];
            NSString* genderInfo = [singleCategoryData valueForKey:@"gender"];
            if ([genderInfo isEqualToString:catTypeInfo]) {
                selectedGenderIndex = i;
                break;
            }
        }
       
        addedProductID = [productData valueForKey:@"prd_id"];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            name.text = [productData valueForKey:@"prd_name"];
            sku.text = [productData valueForKey:@"prd_SKU"];
            NSNumber *itemPrice = [productData valueForKey:@"prd_price"];
            int productPrice = [itemPrice intValue];
            NSNumberFormatter *commas = [NSNumberFormatter new];
            commas.numberStyle = NSNumberFormatterDecimalStyle;
            double formattedItemPrice = (productPrice / 1000.0);
            price.text = [productData valueForKey:@"prd_price"];
            [NSString stringWithFormat:@"%@",
                          [commas stringFromNumber:[NSNumber numberWithDouble:formattedItemPrice * 1000]]];
//            stock.text = [productData valueForKey:@"stock"];
            stock.text = [NSString stringWithFormat:@"%@", [productData valueForKey:@"stock"]];
            weight.text = [NSString stringWithFormat:@"%@",[productData valueForKey:@"prd_weight"]];
            
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[[productData valueForKey:@"prd_description"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            description.attributedText = attrStr;
            
            brand.text = [NSString stringWithFormat:@"%@",[brandValues objectAtIndex:selectedBrandIndex]];
            gender.text = [NSString stringWithFormat:@"%@",[genderValues objectAtIndex:selectedGenderIndex]];
            //category.text = [NSString stringWithFormat:@"%@",[categoryValues objectAtIndex:selectedCategoryIndex]];
            
            /*images*/
            NSArray *images = (NSArray*)[productData valueForKey:@"images"];
            SDWebImageManager *manager;
            for (NSDictionary* imageInfo in images) {
                manager = [SDWebImageManager sharedManager];
                [manager downloadWithURL:[imageInfo valueForKey:@"img_url"]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize)
                 {
                     // progression tracking code
                 }
                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                 {
                     if (image)
                     {
                         // do something with image
                         NSMutableDictionary * imageData = [NSMutableDictionary dictionary];
                         [imageData setObject:image forKey:@"image"];
                         [imageData setObject:[imageInfo valueForKey:@"img_id"] forKey:@"img_id"];
//                         if(isRetailProduct){
//                             [imageData setObject:[imageInfo valueForKey:@"img_color"] forKey:@"color"];
//                             [imageData setObject:[NSNumber numberWithBool:NO] forKey:@"editable_color"];
//                         }
                         [imageData setObject:[imageInfo valueForKey:@"img_color"] forKey:@"color"];
                         [imageData setObject:[NSNumber numberWithBool:NO] forKey:@"editable_color"];
                         
                         [photos addObject:imageData];
                         noImageLabel.hidden = YES;
                         [uploadImageBtn setTitle:@"Tambah Gambar" forState:UIControlStateNormal];
                         [collectionView reloadData];
                     }
                 }];

            }
            
            if(isRetailProduct){
                variantView.hidden = NO;
                NSMutableDictionary *variants = [productData valueForKey:@"variant"];
                for (NSDictionary* variant in variants) {
                    [self addExistingVariantOptionWithData:variant];
                }
            } else{
                addNewVariantBtn.hidden = YES;
                if([productData objectForKey:@"options"]){
                    [self setGrosirVariantsWithData:[productData valueForKey:@"options"]];
                }
            }
            
            [self shallShowLoadingOverlay:NO forAction:0];
            
        });
    });
}

- (void)shallShowLoadingOverlay:(BOOL)show forAction:(int)overlayType{
    if (show) {
        switch (overlayType) {
            case loading_overlay:
                loadingWrapper.hidden = NO;
                uploadingWrapper.hidden = YES;
                break;
            case uploading_overlay:
                loadingWrapper.hidden = YES;
                uploadingWrapper.hidden = NO;
                break;
            default:
                break;
        }
    }
    loadingOverlay.hidden = !show;
    
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    //[self checkForCollectionPhotoDimension];
}

- (void)checkForCollectionPhotoDimension{
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGSize photoCollSize = collectionView.collectionViewLayout.collectionViewContentSize;
    
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    //mainScroller.contentSize = screenBounds.size;
    CGSize mainScrollerSize = mainScroller.contentSize;
    
    NSLog(@"photo coll size: width => %d, height => %d",(int)photoCollSize.width,(int)photoCollSize.height);
    NSLog(@"mainScrollerSize: width => %d, height => %d",(int)mainScrollerSize.width,(int)mainScrollerSize.height);
    NSLog(@"screen size: width => %d, height => %d",(int)screenBounds.size.width,(int)screenBounds.size.height);
    
}

-(void)border:(id)sender{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, ((UIView*)sender).frame.size.height)];
    if ([sender isKindOfClass:[UITextField class]]) {
        ((UITextField*)sender).layer.cornerRadius=5.0f;
        ((UITextField*)sender).layer.masksToBounds=YES;
        ((UITextField*)sender).layer.borderColor=[[UIColor grayColor]CGColor];
        ((UITextField*)sender).layer.borderWidth= 1.0f;
        ((UITextField*)sender).leftView = paddingView;
        ((UITextField*)sender).leftViewMode = UITextFieldViewModeAlways;
    }else if ([sender isKindOfClass:[UITextView class]]) {
        ((UITextView*)sender).layer.cornerRadius=5.0f;
        ((UITextView*)sender).layer.masksToBounds=YES;
        ((UITextView*)sender).layer.borderColor=[[UIColor grayColor]CGColor];
        ((UITextView*)sender).layer.borderWidth= 1.0f;
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==brand) {
        [activeTextField resignFirstResponder];
        [description resignFirstResponder];
        [self showOptionListFor:brand_dropdown withTextFieldRef:brand];
        activeTextField = textField;
        if (!shouldDismissPopover) {
            [self updateDropDownPopover];
            [self showDropDownInside:mainWrapper];
        }else{
            [self hideDropDown];
        }
        return NO;
    }else if (textField==gender) {
        [activeTextField resignFirstResponder];
        [description resignFirstResponder];
        [self showOptionListFor:gender_dropdown withTextFieldRef:gender];
        activeTextField = textField;
        if (!shouldDismissPopover) {
            [self updateDropDownPopover];
            [self showDropDownInside:mainWrapper];
        }else{
            [self hideDropDown];
        }
        return NO;
    }else if (textField==category) {
        if (categoryValues.count>0) {
            [activeTextField resignFirstResponder];
            [description resignFirstResponder];
            [self showOptionListFor:category_dropdown withTextFieldRef:category];
            activeTextField = textField;
            if (!shouldDismissPopover) {
                [self updateDropDownPopover];
                [self showDropDownInside:mainWrapper];
            }else{
                [self hideDropDown];
            }
        }
        
        
        return NO;
    }else{
        if (textField.tag>0 && textField.tag<stock_field) {
            [activeTextField resignFirstResponder];
            [description resignFirstResponder];
            [self showOptionListFor:option_dropdown withTextFieldRef:textField];
            activeTextField = textField;
            if (!shouldDismissPopover) {
                [self updateDropDownPopover];
                UIView *textfieldWrapper = [textField superview];
                UIView *superWrapper = [[textField superview] superview];
                CGRect helperFrame = textfieldWrapper.frame;
                helperFrame.origin = CGPointMake(helperFrame.origin.x, CGRectGetMinY(superWrapper.frame)+helperFrame.origin.y);
                UIView *helperView = [[UIView alloc] initWithFrame:helperFrame];
                [self showDropDownInside:helperView];
            }else{
                [self hideDropDown];
            }
            return NO;
        }else{
            activeTextField = textField;
            if (popoverShown) {
                [self hideDropDown];
            }
            return YES;
        }
        
    }
    
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (popoverShown) {
        [self hideDropDown];
    }
    return YES;
}

- (void)showOptionListFor:(int)thisOptionKind withTextFieldRef:(UITextField*)referenceTextField{
    switch (thisOptionKind) {
        case brand_dropdown:
            if (activeTextField!=brand) {
                dropdownValues = [brandValues mutableCopy];
                [dropdownTableView reloadData];
                [dropdownTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                shouldDismissPopover = false;
            }else{
                shouldDismissPopover = !shouldDismissPopover;
            }
            break;
        case gender_dropdown:
            if (activeTextField!=gender) {
                dropdownValues = [genderValues mutableCopy];
                [dropdownTableView reloadData];
                [dropdownTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                shouldDismissPopover = false;
            }else{
                shouldDismissPopover = !shouldDismissPopover;
            }
            break;
        case category_dropdown:
            if (activeTextField!=category) {
                dropdownValues = [categoryValues mutableCopy];
                [dropdownTableView reloadData];
                [dropdownTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                shouldDismissPopover = false;
            }else{
                shouldDismissPopover = !shouldDismissPopover;
            }
            break;
        case option_dropdown:
            if (activeTextField!=referenceTextField) {
                int index = (int)referenceTextField.tag-1;
                //NSDictionary* variantOptionInfo = [variantOptionData objectAtIndex:index];
                NSMutableArray* optionValue = [optionValues objectAtIndex:index];
                dropdownValues = [NSMutableArray array];
                for (NSDictionary* optionValueInfo in optionValue) {
                    [dropdownValues addObject:[optionValueInfo valueForKey:@"opt_val_name"]];
                }
                [dropdownTableView reloadData];
                [dropdownTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                shouldDismissPopover = false;
            }else{
                shouldDismissPopover = !shouldDismissPopover;
            }
            break;
        default:
            break;
    }
}

- (void)showDropDownInside:(UIView*)wrapper{
    CGPoint showPoint = CGPointMake(CGRectGetMinX(wrapper.frame)+CGRectGetMidX(activeTextField.frame), CGRectGetMinY(wrapper.frame)+CGRectGetMaxY(activeTextField.frame));
    dropdownPopover.maskType = DXPopoverMaskTypeNotExist;
    [dropdownPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionDown withContentView:dropdownTableView inView:mainScroller];
    [dropdownTableView flashScrollIndicators];
    popoverShown = true;
}

- (void)hideDropDown{
    CGPoint showPoint = CGPointMake(-500, -500);
    dropdownPopover.maskType = DXPopoverMaskTypeNotExist;
    [dropdownPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionUp withContentView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] inView:mainScroller];
    popoverShown = false;
}

-(void)updateDropDownPopover{
    if (dropdownValues.count>5) {
        [dropdownTableView setFrame:CGRectMake(0, 0, 240.0, 120.0+80.0)];
    }else{
        [dropdownTableView setFrame:CGRectMake(0, 0, 240.0, 44.0*dropdownValues.count)];
    }
    [dropdownPopover setFrame:dropdownTableView.bounds];
}

- (IBAction)saveProduct:(id)sender {
    if (popoverShown) {
        [self hideDropDown];
    }
    if ([self validateForm]) {
        if (isRetailProduct) {
            if (viewVariantCollection.count>0) {
                dataVariantCollection = [NSMutableArray arrayWithArray:[self generateVariantData]];
                if (dataVariantCollection.count!=viewVariantCollection.count) {
                    validatorMsg = @"Harap isi stok barang dengan benar untuk setiap varian.";
                    UIAlertView *errorView;
                    
                    errorView = [[UIAlertView alloc]
                                 initWithTitle: title_error
                                 message: validatorMsg.length>0?validatorMsg:@"Harap isi data dengan benar"
                                 delegate: self
                                 cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
                    
                    [errorView show];
                }else{
                    if (productData!=nil){
                        [self addProductRetailToServerEditMode:true];
                    }else{
                        [self addProductRetailToServerEditMode:false];
                    }
                    
                }
            }else{
                //variant empty
                validatorMsg = @"Tidak ada data varian, produk retail membutuhkan data varian.";
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_error
                             message: validatorMsg.length>0?validatorMsg:@"Harap isi data dengan benar"
                             delegate: self
                             cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
                
                [errorView show];
            }
            
            
        }else{
            if (productData!=nil){
                [self addProductToServerEditMode:true];
            }else{
                [self addProductToServerEditMode:false];
            }
        }
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: validatorMsg.length>0?validatorMsg:@"Harap isi data dengan benar"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
    }
    
}

- (IBAction)addNewVariant:(id)sender {
    [activeTextField resignFirstResponder];
    [description resignFirstResponder];
    [self addNewVariantOption:YES];
}

- (BOOL)validateForm{
    BOOL valid = true;
    valid &= [name validate];
    valid &= [sku validate];
    valid &= [price validate];
    valid &= [stock validate];
    valid &= [weight validate];
    validatorMsg = @"";
    if (valid) {
        if (description.text.length==0) {
            validatorMsg = @"Harap isi deskripsi produk";
            valid &= false;
        }
    }
    if (valid) {
        //check image product
        if (photos.count<min_image_product) {
            validatorMsg = [NSString stringWithFormat:@"Produk harus memiliki paling sedikit, %d gambar",min_image_product];
            valid &= false;
        }
        
        if (valid){
            for (NSDictionary *imageData in photos) {
                if([imageData objectForKey:@"color"] && ([imageData objectForKey:@"color"] != [NSNull null])){
                    if(((NSString*)[imageData objectForKey:@"color"]).length == 0){
                        valid &= false;
                        validatorMsg = @"Setiap warna pada gambar harus diisi";
                        break;
                    } else if(((NSString*)[imageData objectForKey:@"color"]).length > 50){
                        valid &= false;
                        validatorMsg = @"Setiap warna pada gambar tidak boleh diisi lebih dari 50 karakter";
                        break;
                    }
                } else{
                    valid &= false;
                    validatorMsg = @"Setiap warna pada gambar harus diisi";
                    break;
                }
            }
        }
    }
    if(valid && !isRetailProduct){
        if(grosirVariants){
            for (NSDictionary *variant in grosirVariants) {
                if(variant){
                    if([variant objectForKey:@"value"] && ([variant objectForKey:@"value"] != [NSNull null])){
                        if(((NSString*)[variant objectForKey:@"value"]).length == 0){
                            valid &= false;
                            validatorMsg = @"Setiap variant tidak boleh diisi lebih dari 50 karakter";
                            break;
                        } else{
                            if(((NSString*)[variant objectForKey:@"value"]).length > 50){
                                valid &= false;
                                validatorMsg = @"Setiap variant harus diisi";
                                break;
                            }
                        }
                    } else{
                        valid &= false;
                        validatorMsg = @"Setiap variant harus diisi";
                        break;
                    }
                }
            }
        }
    }
    
    return  valid;
}

-(void) updateVariantIndex{
    int counter = 0;
    for (UIView* variantWrapper in viewVariantCollection) {
        for (int x=0; x<variantWrapper.subviews.count; x++) {
            id subview = [variantWrapper.subviews objectAtIndex:x];
            if ([subview isKindOfClass:[UIButton class]]) {
                [subview setTag:counter];
            }
        }
        [variantWrapper setTag:counter];
        counter++;
    }
}

- (NSArray*)generateVariantData{
    NSMutableArray* variantDataResult = [NSMutableArray array];
    for (UIView* variantWrapper in viewVariantCollection) {
        UITextField* stockField = (UITextField*)[variantWrapper viewWithTag:stock_field];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *stockValue = [nf numberFromString:stockField.text];
        BOOL stockValid = stockValue!=nil;
        if (stockValid) {
            NSMutableDictionary *variantCollectionDictionary = [NSMutableDictionary dictionary];
            NSMutableArray *optionCollection = [NSMutableArray array];
            for (int i=0; i<optionKind.count; i++) {
                NSMutableArray* optionValue = [optionValues objectAtIndex:i];
                int selectedIndex = 0;
                UITextField *dropDownField;// = (UITextField*)[variantWrapper viewWithTag:(i+1)];
                for (int x=0; x<variantWrapper.subviews.count; x++) {
                    id subview = [variantWrapper.subviews objectAtIndex:x];
                    if ([subview isKindOfClass:[UITextField class]]) {
                        if (((UITextField*)subview).tag==i+1) {
                            dropDownField = (UITextField*)subview;
                            break;
                        }
                    }
                }
                for (int j=0; j<optionValue.count; j++) {
                    NSDictionary* optionValueInfo = [optionValue objectAtIndex:j];
                    if ([(NSString*)[optionValueInfo valueForKey:@"opt_val_name"] isEqualToString:dropDownField.text]) {
                        selectedIndex = j;
                        break;
                    }
                }
                
                NSDictionary* selectedOptionValueData = [optionValue objectAtIndex:selectedIndex];
                NSMutableDictionary *subHelper = [NSMutableDictionary dictionary];
                [subHelper setValue:[selectedOptionValueData valueForKey:@"opt_id"] forKey:@"opt_id"];
                [subHelper setValue:[selectedOptionValueData valueForKey:@"opt_val_id"] forKey:@"opt_val_id"];
                [optionCollection addObject:subHelper];
            }
            [variantCollectionDictionary setValue:optionCollection forKey:@"opt"];
            [variantCollectionDictionary setValue:stockValue forKey:@"stock"];
            [variantDataResult addObject:variantCollectionDictionary];
        }
    }
    
    return variantDataResult;
}

- (NSArray*)generateNewVariantList{
    NSMutableArray* variantDataResult = [NSMutableArray array];
    int counter = 0;
    for (UIView* variantWrapper in viewVariantCollection) {
        NSDictionary *variantData = [variantDataList objectAtIndex:counter];
        if(variantData){
            if([variantData valueForKeyPath:@"opt"]){
                UITextField* stockField = (UITextField*)[variantWrapper viewWithTag:stock_field];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *stockValue = [nf numberFromString:stockField.text];
                BOOL stockValid = stockValue!=nil;
                if (stockValid) {
                    NSMutableDictionary *variantCollectionDictionary = [NSMutableDictionary dictionary];
                    NSMutableArray *optionCollection = [NSMutableArray array];
                    for (int i=0; i<optionKind.count; i++) {
                        NSMutableArray* optionValue = [optionValues objectAtIndex:i];
                        int selectedIndex = 0;
                        UITextField *dropDownField;// = (UITextField*)[variantWrapper viewWithTag:(i+1)];
                        for (int x=0; x<variantWrapper.subviews.count; x++) {
                            id subview = [variantWrapper.subviews objectAtIndex:x];
                            if ([subview isKindOfClass:[UITextField class]]) {
                                if (((UITextField*)subview).tag==i+1) {
                                    dropDownField = (UITextField*)subview;
                                    break;
                                }
                            }
                        }
                        for (int j=0; j<optionValue.count; j++) {
                            NSDictionary* optionValueInfo = [optionValue objectAtIndex:j];
                            if ([(NSString*)[optionValueInfo valueForKey:@"opt_val_name"] isEqualToString:dropDownField.text]) {
                                selectedIndex = j;
                                break;
                            }
                        }
                        
                        NSDictionary* selectedOptionValueData = [optionValue objectAtIndex:selectedIndex];
                        NSMutableDictionary *subHelper = [NSMutableDictionary dictionary];
                        [subHelper setValue:[selectedOptionValueData valueForKey:@"opt_id"] forKey:@"opt_id"];
                        [subHelper setValue:[selectedOptionValueData valueForKey:@"opt_val_id"] forKey:@"opt_val_id"];
                        [optionCollection addObject:subHelper];
                    }
                    [variantCollectionDictionary setValue:optionCollection forKey:@"opt"];
                    [variantCollectionDictionary setValue:stockValue forKey:@"stock"];
                    [variantDataResult addObject:variantCollectionDictionary];
                }
            }
        }
        counter++;
    }
    return variantDataResult;
}

-(NSArray*) generateExistingVariants{
    NSMutableArray* existingVariantList = [NSMutableArray array];
    int counter = 0;
    for (UIView* variantWrapper in viewVariantCollection) {
        NSDictionary *variantData = [variantDataList objectAtIndex:counter];
        if(variantData){
            if([variantData valueForKey:@"var_id"]){
                UITextField* stockField = (UITextField*)[variantWrapper viewWithTag:stock_field];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *stockValue = [nf numberFromString:stockField.text];
                NSMutableDictionary *existingVariant = [NSMutableDictionary dictionary];
                [existingVariant setValue:stockValue forKey:@"stock"];
                [existingVariant setValue:[variantData valueForKey:@"var_id"] forKeyPath:@"var_id"];
                [existingVariantList addObject:existingVariant];
            }
        }
        counter++;
    }
    return existingVariantList;
}

-(NSArray*) generateOptionsDataFromGrosirOptions:(NSArray*)grosirOptions{
    NSMutableArray *options = [NSMutableArray array];
    
    if(grosirOptions){
        for (NSDictionary *option in grosirOptions) {
            NSMutableDictionary *grosirOption = [NSMutableDictionary dictionary];
            [grosirOption setValue:[option valueForKey:@"opt_id"] forKey:@"opt_id"];
            [grosirOption setValue:[option valueForKey:@"value"] forKey:@"opt_value"];
            [options addObject:grosirOption];
        }
    }
    
    return options;
}

- (void)addNewVariantOption:(BOOL)scrollTo{
    UIView *prevView = nil;
    NSMutableDictionary *variantCollectionDictionary = [NSMutableDictionary dictionary];
    if (variantView.subviews.count>2) {
        prevView = [variantView.subviews objectAtIndex:variantView.subviews.count-1];
    }
    variantViewTag = variantDataList.count;
    int posY = prevView==nil?46:CGRectGetMaxY(prevView.frame);
    posY += 20;
    UIView * variantWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, posY, variantView.frame.size.width, 200)];
    [variantWrapper setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5]];
    variantWrapper.layer.cornerRadius = 9.0f;

    variantWrapper.translatesAutoresizingMaskIntoConstraints = NO;
//    NSMutableArray *optionKind = [NSMutableArray arrayWithObjects:@"Ukuran",@"Bahan",@"Bentuk", nil];
    
    optionKind = [NSMutableArray array];
    optionValues = [NSMutableArray array];

    for (NSDictionary* variantOptionInfo in variantOptionData) {
        [optionKind addObject:[variantOptionInfo valueForKey:@"opt_name"]];
        [optionValues addObject:[variantOptionInfo valueForKey:@"opt_values"]];
    }
//    NSArray *ukuranValues = [NSArray arrayWithObjects:@"XL",@"L",@"M",@"S", nil];
//    NSArray *bahanValues = [NSArray arrayWithObjects:@"Katun",@"Jeans",@"Denim",@"Kaos", nil];
//    NSArray *bentukValues = [NSArray arrayWithObjects:@"Persegi",@"Kotak",@"Rectangle",@"Segi empat", nil];
//    NSArray *optionValues = [NSArray arrayWithObjects:ukuranValues,bahanValues,bentukValues, nil];
    int height = 0;
    int y = 20;
    NSMutableArray *optionCollection = [NSMutableArray array];
    for (int i=0; i<optionKind.count; i++) {
        NSString* optionName = [optionKind objectAtIndex:i];
        if (optionName && [optionName length]>0) {
            optionName = [optionName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                             withString:[[optionName substringToIndex:1] capitalizedString]];
        }
        NSMutableArray* optionValue = [optionValues objectAtIndex:i] ;
        int selectedIndex = 0;
        NSDictionary* selectedOptionValueData = [optionValue objectAtIndex:selectedIndex];
        NSString* valueName = [selectedOptionValueData valueForKey:@"opt_val_name"];
        
        NSMutableDictionary *subHelper = [NSMutableDictionary dictionary];
        [subHelper setValue:[selectedOptionValueData valueForKey:@"opt_id"] forKey:@"opt_id"];
        [subHelper setValue:[selectedOptionValueData valueForKey:@"opt_val_id"] forKey:@"opt_val_id"];
        [optionCollection addObject:subHelper];
        //Does the string live in memory and it has atleast one letter?
        if (valueName && [valueName length]>0) {
            //Yes. It is
            valueName = [valueName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                           withString:[[valueName substringToIndex:1] capitalizedString]];
        }
        UILabel* optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 230.0, 21)];
        height += 25;
        y += 25;
        CustomRightViewTextfield *variantText = [[CustomRightViewTextfield alloc] initWithFrame:CGRectMake(20, y, variantWrapper.frame.size.width-40.0, 40)];
        height += 40;
        variantText.tag = i+1;
        variantText.delegate = self;
        variantText.layer.masksToBounds=YES;
        variantText.layer.borderColor=[[UIColor grayColor]CGColor];
        variantText.layer.borderWidth= 1.0f;
        variantText.layer.cornerRadius = 5.0f;
        [variantText setBackgroundColor:[UIColor whiteColor]];
        
        //create padding left
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, variantText.frame.size.height)];
        variantText.leftView = paddingView;
        variantText.leftViewMode = UITextFieldViewModeAlways;
        //create dropdown icon
        variantText.rightViewDistance = 10;
        [variantText useRightView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-01-16.png"]]];
        variantText.placeholder = [NSString stringWithFormat:@"Pilih %@",optionName];
        variantText.translatesAutoresizingMaskIntoConstraints = NO;
        
        optionNameLabel.text = optionName;
        variantText.text = valueName;
        [variantWrapper addSubview:optionNameLabel];
        [variantWrapper addSubview:variantText];
        y += 55;
        height += 20;
        
        NSDictionary *variantTextConstraintDictionary = NSDictionaryOfVariableBindings(variantWrapper,variantText);
        [variantWrapper addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[variantText]-10-|"
                                                 options:0
                                                 metrics:0
                                                   views:variantTextConstraintDictionary]];
        
        [variantWrapper addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantText(==constantHeight)]"
                                                 options:0
                                                 metrics:@{@"constantHeight":@(40)}
                                                   views:variantTextConstraintDictionary]];
        
    }
    UILabel* stockLabelVariant = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 230.0, 21)];
    stockLabelVariant.text = @"Stock";
    height += 25;
    y += 25;
    UITextField *stockTextField = [[UITextField alloc] init];
    [stockTextField setFrame:CGRectMake(20, y, 230.0, 40)];
    height += 40;
    
    stockTextField.delegate = self;
    stockTextField.layer.masksToBounds=YES;
    stockTextField.layer.borderColor=[[UIColor grayColor]CGColor];
    stockTextField.layer.borderWidth= 1.0f;
    stockTextField.layer.cornerRadius = 5.0f;
    [stockTextField setBackgroundColor:[UIColor whiteColor]];
    
    //create padding left
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, stockTextField.frame.size.height)];
    stockTextField.leftView = paddingView;
    stockTextField.leftViewMode = UITextFieldViewModeAlways;
    stockTextField.placeholder = [NSString stringWithFormat:@"Stock barang"];
    [stockTextField setKeyboardType:UIKeyboardTypeNumberPad];
    stockTextField.tag= stock_field;
    //stockTextField.text = [NSString stringWithFormat:@"%d",variantViewTag];
    [variantCollectionDictionary setValue:optionCollection forKey:@"opt"];
    [variantCollectionDictionary setValue:[NSNumber numberWithInt:0] forKey:@"stock"];
    
    [variantWrapper addSubview:stockLabelVariant];
    [variantWrapper addSubview:stockTextField];
    height += 60;
    y += 60;
    
    //set cancel button
    int buttonHeight = 35.0;
    int buttonWidth = 80.0;
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, y, buttonWidth, buttonHeight)];
    [cancelBtn setTitle:@"Hapus" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = FONT_ARSENAL(17);
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    cancelBtn.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0];
    cancelBtn.translatesAutoresizingMaskIntoConstraints= NO;
    cancelBtn.tag = variantViewTag;
    //set selector here
    [cancelBtn addTarget:self
                       action:@selector(deleteVariantView:)
             forControlEvents:UIControlEventTouchUpInside];
    [variantWrapper addSubview:cancelBtn];
    height += 30;
    
    NSDictionary* viewsDictionaryCancelBtn = NSDictionaryOfVariableBindings(cancelBtn);
    //set height constraint
    [variantWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelBtn(==constantHeight)]" options:0 metrics:@{@"constantHeight":@(buttonHeight)} views:viewsDictionaryCancelBtn]];
    //set width constraint
    [variantWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancelBtn(==constantWidth)]" options:0 metrics:@{@"constantWidth":@(buttonWidth)} views:viewsDictionaryCancelBtn]];
    [variantWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelBtn]-20-|" options:0 metrics: 0 views:viewsDictionaryCancelBtn]];
    NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:cancelBtn
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:variantWrapper
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0];
    
    [variantWrapper addConstraint:centerXConstraint];
    variantWrapper.tag = cancelBtn.tag;
    [variantView addSubview:variantWrapper];
    NSDictionary* viewsDictionary;
    if (prevView) {
        viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,prevView,addNewVariantBtn);
        //set height constraint
        [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper(==constantHeight)]" options:0 metrics:@{@"constantHeight":@(height)} views:viewsDictionary]];
        
        //set dynamic width constraint, x-pos constraint
        [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[variantWrapper]-0-|" options:0 metrics: 0 views:viewsDictionary]];
        //set y-post constraint
        [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prevView]-20-[variantWrapper]" options:0 metrics: 0 views:viewsDictionary]];
        [variantView removeConstraints:tempConstraint];
        //set variantView to wrap variantWrapper
        tempConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper]-20-|" options:0 metrics: 0 views:viewsDictionary];
        [variantView addConstraints:tempConstraint];
        
        
    }else{
        viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,addNewVariantBtn);
        //set height constraint
        [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper(==constantHeight)]" options:0 metrics:@{@"constantHeight":@(height)} views:viewsDictionary]];
        
        //set dynamic width constraint, x-pos constraint
        [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[variantWrapper]-0-|" options:0 metrics: 0 views:viewsDictionary]];
        //set y-post constraint
        [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[addNewVariantBtn]-20-[variantWrapper]" options:0 metrics: 0 views:viewsDictionary]];
        //set variantView to wrap variantWrapper
        tempConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper]-20-|" options:0 metrics: 0 views:viewsDictionary];
        [variantView addConstraints:tempConstraint];
    }
    if (scrollTo) {
        CGPoint offsetPoint = CGPointMake(0, CGRectGetMinY(variantView.frame)+CGRectGetMinY(variantWrapper.frame)-100.0);
        [UIView animateWithDuration:0.2 animations:^{
            [mainScroller setContentOffset:offsetPoint animated: NO];
        } completion:^(BOOL finished) {
            [stockTextField becomeFirstResponder];
        }];
        //[mainScroller setContentOffset:offsetPoint animated:YES];
        
    }
    
    [viewVariantCollection addObject:variantWrapper];
    [dataVariantCollection addObject:variantCollectionDictionary];
    [variantDataList addObject:variantCollectionDictionary];
}

- (void)addExistingVariantOptionWithData:(NSDictionary*)variantData{
    if(variantData){
        UIView *prevView = nil;
        NSMutableDictionary *variantCollectionDictionary = [NSMutableDictionary dictionary];
        if (variantView.subviews.count>2) {
            prevView = [variantView.subviews objectAtIndex:variantView.subviews.count-1];
        }
        variantViewTag = variantDataList.count;
        int posY = prevView==nil?46:CGRectGetMaxY(prevView.frame);
        posY += 20;
        UIView * variantWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, posY, variantView.frame.size.width, 200)];
        [variantWrapper setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5]];
        variantWrapper.layer.cornerRadius = 9.0f;
        
        variantWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        
        int height = 0;
        int y = 20;
        
        NSNumber *stockNumber = [variantData valueForKey:@"stock"];
        
        NSArray *variantOptionArray = [variantData valueForKey:@"variant_option"];
        
        for (NSDictionary *option in variantOptionArray) {
//            NSMutableDictionary *variantOptions = [variantData valueForKey:@"variant_option"];
            NSString* optionName = @"";
            NSString* valueName = @"";
//            for (NSDictionary *option in variantOptions) {
                optionName = [option valueForKey:@"opt_name"];
                valueName = [option valueForKey:@"opt_val_name"];
//            }
            
            if (optionName && [optionName length]>0) {
                optionName = [optionName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                 withString:[[optionName substringToIndex:1] capitalizedString]];
            }
            
            //Does the string live in memory and it has atleast one letter?
            if (valueName && [valueName length]>0) {
                //Yes. It is
                valueName = [valueName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                               withString:[[valueName substringToIndex:1] capitalizedString]];
            }
            UILabel* optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 230.0, 21)];
            height += 25;
            y += 25;
            CustomRightViewTextfield *variantText = [[CustomRightViewTextfield alloc] initWithFrame:CGRectMake(20, y, variantWrapper.frame.size.width-40.0, 40)];
            height += 40;
            variantText.tag = 1;
            variantText.delegate = self;
            variantText.layer.masksToBounds=YES;
            variantText.layer.borderColor=[[UIColor grayColor]CGColor];
            variantText.layer.borderWidth= 1.0f;
            variantText.layer.cornerRadius = 5.0f;
            [variantText setBackgroundColor:[UIColor whiteColor]];
            //create padding left
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, variantText.frame.size.height)];
            variantText.leftView = paddingView;
            variantText.leftViewMode = UITextFieldViewModeAlways;
            //create dropdown icon
            variantText.rightViewDistance = 10;
            [variantText useRightView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-01-16.png"]]];
            variantText.placeholder = [NSString stringWithFormat:@"Pilih %@",optionName];
            [variantText setEnabled:false];
            [variantText setBackgroundColor:[UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.5]];
            variantText.translatesAutoresizingMaskIntoConstraints = NO;
            
            optionNameLabel.text = optionName;
            variantText.text = valueName;
            [variantWrapper addSubview:optionNameLabel];
            [variantWrapper addSubview:variantText];
            y += 55;
            height += 20;
            
            NSDictionary *variantTextConstraintDictionary = NSDictionaryOfVariableBindings(variantWrapper,variantText);
            [variantWrapper addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[variantText]-10-|"
                                                     options:0
                                                     metrics:0
                                                       views:variantTextConstraintDictionary]];
            
            [variantWrapper addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantText(==constantHeight)]"
                                                     options:0
                                                     metrics:@{@"constantHeight":@(40)}
                                                       views:variantTextConstraintDictionary]];
        }
        
        UILabel* stockLabelVariant = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 230.0, 21)];
        stockLabelVariant.text = @"Stock";
        height += 25;
        y += 25;
        UITextField *stockTextField = [[UITextField alloc] init];
        [stockTextField setFrame:CGRectMake(20, y, 230.0, 40)];
        height += 40;
        
        stockTextField.delegate = self;
        stockTextField.layer.masksToBounds=YES;
        stockTextField.layer.borderColor=[[UIColor grayColor]CGColor];
        stockTextField.layer.borderWidth= 1.0f;
        stockTextField.layer.cornerRadius = 5.0f;
        stockTextField.text = [NSString stringWithFormat:@"%@", stockNumber];
        [stockTextField setBackgroundColor:[UIColor whiteColor]];
        
        //create padding left
        UIView *paddingViewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, stockTextField.frame.size.height)];
        stockTextField.leftView = paddingViewLeft;
        stockTextField.leftViewMode = UITextFieldViewModeAlways;
        stockTextField.placeholder = [NSString stringWithFormat:@"Stock barang"];
        [stockTextField setKeyboardType:UIKeyboardTypeNumberPad];
        stockTextField.tag= stock_field;
        
        [variantCollectionDictionary setValue:stockNumber forKey:@"stock"];
        
        [variantWrapper addSubview:stockLabelVariant];
        [variantWrapper addSubview:stockTextField];
        height += 60;
        y += 60;
        
        //set cancel button
        int buttonHeight = 35.0;
        int buttonWidth = 80.0;
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, y, buttonWidth, buttonHeight)];
        [cancelBtn setTitle:@"Hapus" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = FONT_ARSENAL(17);
        cancelBtn.titleLabel.textColor = [UIColor whiteColor];
        cancelBtn.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0];
        cancelBtn.translatesAutoresizingMaskIntoConstraints= NO;
        cancelBtn.tag = variantViewTag;
        //set selector here
        [cancelBtn addTarget:self
                      action:@selector(deleteVariantView:)
            forControlEvents:UIControlEventTouchUpInside];
        [variantWrapper addSubview:cancelBtn];
        height += 30;
        
        NSDictionary* viewsDictionaryCancelBtn = NSDictionaryOfVariableBindings(cancelBtn);
        //set height constraint
        [variantWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelBtn(==constantHeight)]" options:0 metrics:@{@"constantHeight":@(buttonHeight)} views:viewsDictionaryCancelBtn]];
        //set width constraint
        [variantWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancelBtn(==constantWidth)]" options:0 metrics:@{@"constantWidth":@(buttonWidth)} views:viewsDictionaryCancelBtn]];
        [variantWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelBtn]-20-|" options:0 metrics: 0 views:viewsDictionaryCancelBtn]];
        NSLayoutConstraint *centerXConstraint =
        [NSLayoutConstraint constraintWithItem:cancelBtn
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:variantWrapper
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0.0];
        
        [variantWrapper addConstraint:centerXConstraint];
        variantWrapper.tag = cancelBtn.tag;
        [variantView addSubview:variantWrapper];
        NSDictionary* viewsDictionary;
        if (prevView) {
            viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,prevView,addNewVariantBtn);
            //set height constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper(==constantHeight)]" options:0 metrics:@{@"constantHeight":@(height)} views:viewsDictionary]];
            
            //set dynamic width constraint, x-pos constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[variantWrapper]-0-|" options:0 metrics: 0 views:viewsDictionary]];
            //set y-post constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prevView]-20-[variantWrapper]" options:0 metrics: 0 views:viewsDictionary]];
            [variantView removeConstraints:tempConstraint];
            //set variantView to wrap variantWrapper
            tempConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper]-20-|" options:0 metrics: 0 views:viewsDictionary];
            [variantView addConstraints:tempConstraint];
            
            
        }else{
            viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,addNewVariantBtn);
            //set height constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper(==constantHeight)]" options:0 metrics:@{@"constantHeight":@(height)} views:viewsDictionary]];
            
            //set dynamic width constraint, x-pos constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[variantWrapper]-0-|" options:0 metrics: 0 views:viewsDictionary]];
            //set y-post constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[addNewVariantBtn]-20-[variantWrapper]" options:0 metrics: 0 views:viewsDictionary]];
            //set variantView to wrap variantWrapper
            tempConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper]-20-|" options:0 metrics: 0 views:viewsDictionary];
            [variantView addConstraints:tempConstraint];
        }
        
        [viewVariantCollection addObject:variantWrapper];
        [dataVariantCollection addObject:variantData];
        [variantDataList addObject:variantData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ASIHTTPRequest

- (void)addProductToServerEditMode:(BOOL)editMode
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
        [self shallShowLoadingOverlay:YES forAction:loading_overlay];
        NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,addProductGrosirURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
        request.tag = addProductGrosir;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        if (editMode) {
            [request addPostValue:[productData valueForKey:@"prd_id"] forKey:@"prd_id"];
            request.tag= editProductGrosir;
        }
        if (sku.text.length>0) {
            [request addPostValue:sku.text forKey:@"sku"];
        }
        
        [request addPostValue:name.text forKey:@"name"];
        NSDictionary* selectedBrand = [[DataSingleton instance].allBrand objectAtIndex:selectedBrandIndex];
        [request addPostValue:[selectedBrand valueForKey:@"brand_id"] forKey:@"brand"];
       
        NSMutableArray *catForGender = (NSMutableArray*)[categoryDict objectForKey:selectedGenderName];
        NSDictionary* selectedCategory = [catForGender objectAtIndex:selectedCategoryIndex];
        [request addPostValue:[selectedCategory valueForKey:@"cat_id"] forKey:@"cat_id"];
        [request addPostValue:price.text forKey:@"price"];
        [request addPostValue:description.text forKey:@"description"];
        [request addPostValue:weight.text forKey:@"weight"];
        [request addPostValue:stock.text forKey:@"stock"];
        [request addPostValue:[NSNumber numberWithBool:true] forKey:@"is_grosir"];
        
        if(grosirVariants){
            NSMutableArray *options = [NSMutableArray arrayWithArray:[self generateOptionsDataFromGrosirOptions:grosirVariants]];
            
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:options options:0 error:nil];
            NSString* dataString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            [request addPostValue:dataString forKey:@"options"];
        }
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)addProductRetailToServerEditMode:(BOOL)editMode
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
        [self shallShowLoadingOverlay:YES forAction:loading_overlay];
        NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,addProductRetailURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
        request.tag = addProductRetail;
        [request setRequestMethod:@"POST"];
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        if (editMode) {
            [request addPostValue:[productData valueForKey:@"prd_id"] forKey:@"prd_id"];
            request.tag= editProductRetail;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self generateExistingVariants] options:0 error:nil];
            NSString* dataString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            [request addPostValue:dataString forKey:@"variant_stock_update"];
        } else{
            [request addPostValue:@"[]" forKey:@"variant_stock_update"];
        }
        
        if (sku.text.length>0) {
            [request addPostValue:sku.text forKey:@"sku"];
        }
        
        [request addPostValue:name.text forKey:@"name"];
        NSDictionary* selectedBrand = [[DataSingleton instance].allBrand objectAtIndex:selectedBrandIndex];
        [request addPostValue:[selectedBrand valueForKey:@"brand_id"] forKey:@"brand_id"];
        NSMutableArray *catForGender = (NSMutableArray*)[categoryDict objectForKey:selectedGenderName];
        NSDictionary* selectedCategory = [catForGender objectAtIndex:selectedCategoryIndex];
        [request addPostValue:[selectedCategory valueForKey:@"cat_id"] forKey:@"cat_id"];
        [request addPostValue:price.text forKey:@"price"];
        [request addPostValue:description.text forKey:@"description"];
        [request addPostValue:weight.text forKey:@"weight"];
        [request addPostValue:[NSNumber numberWithBool:false] forKey:@"is_grosir"];
        
        dataVariantCollection = [NSMutableArray arrayWithArray:[self generateNewVariantList]];
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataVariantCollection options:0 error:nil];
        NSString* dataString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        [request addPostValue:dataString forKey:@"variant"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestOptionValueForCatID
{
    if (!variantViewHasBeenInitialized) {
        variantViewHasBeenInitialized = true;
    }
    if (refreshVariantView) {
        refreshVariantView = false;
        [self clearVariantView];
    }
    NSDictionary* selectedCatData = [[DataSingleton instance].categoryData objectAtIndex:selectedGenderIndex];
    NSMutableArray *catForGender = (NSMutableArray*)[categoryDict objectForKey:selectedGenderName];
    NSDictionary* selectedCategory = [catForGender objectAtIndex:selectedCategoryIndex];

    NSString *catIDString = [selectedCategory valueForKey:@"cat_id"];
    BOOL dataExist = false;
    if (variantKeyMapper!=nil) {
        if ([variantKeyMapper valueForKey:catIDString]) {
            variantOptionData = [NSArray arrayWithArray:[variantKeyMapper valueForKey:catIDString]];
            variantView.hidden = NO;
            [addNewVariantBtn setEnabled:YES];
            dataExist = true;
        }
    }
    if (dataExist) {
        if (refreshVariantView) {
            refreshVariantView = false;
            [self clearVariantView];
        }
        [self addNewVariantOption:NO];
        
    }else{
        NSNumberFormatter *nf = [[NSNumberFormatter alloc]init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *catID = [nf numberFromString:catIDString];
        
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
            [self shallShowLoadingOverlay:YES forAction:loading_overlay];
            NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,getOptionValuesURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = getOptionValues;
            [request setRequestMethod:@"POST"];
            
            [request addPostValue:catID forKey:@"cat_id"];
            [request addPostValue:[NSNumber numberWithBool:false] forKey:@"is_grosir"];
            
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
    }
    
}

- (void)addProductImageToServerIsGrosir:(BOOL)isGrosirProduct
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
        [self shallShowLoadingOverlay:YES forAction:uploading_overlay];
        networkQueue = [ASINetworkQueue queue];
        [networkQueue setMaxConcurrentOperationCount:1];
        networkQueue.delegate = self;
        [networkQueue setUploadProgressDelegate:self];
        [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
        [networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
        [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        [self makeQueueForAddNewImageIsGrosir:isGrosirProduct];
        sessionQueue = queue_add_image;
        [networkQueue go];
    }
    
}

- (void)updateProductImageToServerIsGrosir:(BOOL)isGrosirProduct
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
        BOOL needToAdd = [self haveImageToUpload];
        if (needToAdd) {
            [self shallShowLoadingOverlay:YES forAction:uploading_overlay];
        }else{
            [self shallShowLoadingOverlay:YES forAction:loading_overlay];
        }
        networkQueue = [ASINetworkQueue queue];
        [networkQueue setMaxConcurrentOperationCount:1];
        networkQueue.delegate = self;
        [networkQueue setUploadProgressDelegate:self];
        [networkQueue setRequestDidFinishSelector:@selector(oneRequestFinished:)];
        [networkQueue setRequestDidFailSelector:@selector(oneRequestFailed:)];
        [networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        
        if(imagesToDelete.count > 0){
            [self makeQueueForDeleteOldImageIsGrosir:isGrosirProduct];
        }
        
        if (needToAdd) {
            [self makeQueueForAddNewImageIsGrosir:isGrosirProduct];
        } else{
            if(imagesToDelete.count == 0){
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_success
                             message: @"Produk berhasil diedit"
                             delegate: self
                             cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
                
                [errorView show];
                
                [self.navigationController popViewControllerAnimated:TRUE];
            }
        }

        sessionQueue = queue_update_image;
        [networkQueue go];
    }
}

- (void)makeQueueForDeleteOldImageIsGrosir:(BOOL)isGrosirProduct{
    NSArray *oldImages = (NSArray*)[productData valueForKey:@"images"];
    oldImages = imagesToDelete;
    for (NSDictionary* imageInfo in oldImages) {
        NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,deleteImageProductURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
        request.tag = deleteProductImage;
        [request setRequestMethod:@"POST"];
        
        [DataSingleton retrieveUser];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
        [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
        
        [request addPostValue:[imageInfo valueForKey:@"img_id"] forKey:@"image_id"];
        [request addPostValue:[NSNumber numberWithBool:isGrosirProduct] forKey:@"is_grosir"];
        
        [request setTimeOutSeconds:60];
        [networkQueue addOperation:request];
    }
}

- (void)makeQueueForAddNewImageIsGrosir:(BOOL)isGrosirProduct{
    createdImages = [NSMutableArray array];
    for (NSDictionary* imageData in photos) {
        if(![imageData valueForKey:@"img_id"]){
            NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,addImageProductURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = addProductImage;
            [request setRequestMethod:@"POST"];
            
            [DataSingleton retrieveUser];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
            
            [request addPostValue:addedProductID forKey:@"prd_id"];
            [request addPostValue:[NSNumber numberWithBool:isGrosirProduct] forKey:@"is_grosir"];
//            if(isRetailProduct){
//                [request addPostValue:[imageData objectForKey:@"color"] forKey:@"color"];
//            }
            [request addPostValue:[imageData objectForKey:@"color"] forKey:@"color"];
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
            NSString* pngFilePath = [NSString stringWithFormat:@"%@/%d.png",docDir,(int)timeStamp];
            
            //delete existing file
            [DataSingleton removeFile:pngFilePath];
            //write file
            UIImage* productImage = [imageData objectForKey:@"image"];
            NSData *imageDataRepresentation = UIImagePNGRepresentation(productImage);
            //NSString* base64Image = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:0];
            //NSData *data = [NSData dataFromBase64String:[DataSingleton instance].outletImage64Encoding];
            [imageDataRepresentation writeToFile:pngFilePath atomically:YES];
            
            [createdImages addObject:pngFilePath];
            
            //        NSURL *_path = [NSURL URLWithString:pngFilePath];
            //        NSString* imagePath = [_path path];
            //        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
            if (imageDataRepresentation.length >0) {
                [request setData:imageDataRepresentation withFileName:[NSString stringWithFormat:@"%d.png",(int)timeStamp] andContentType:@"image/png" forKey:@"img_name"];
            }
            
            //[request setDelegate:self];
            [request setTimeOutSeconds:60];
            [networkQueue addOperation:request];
        }
    }
}

- (void)requestForCategory
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
        [self shallShowLoadingOverlay:YES forAction:loading_overlay];
        NSMutableString* composedUrl = [NSMutableString stringWithFormat:@"%@%@?gender_id=%@&prd_type=%@&owner_id=%@",y2BaseURL,getProductCategoryURL,[selectedGenderName isEqualToString:@"Pria"]?@"P":@"W",isRetailProduct?@"RT":@"GR",[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@""];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:composedUrl]];
        request.tag = getProductCategory;
        [request setRequestMethod:@"GET"];
        
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request startAsynchronous];
        [request setUseSessionPersistence:YES];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", request.error.description);
    [self shallShowLoadingOverlay:NO forAction:0];
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
    [self shallShowLoadingOverlay:NO forAction:0];
    NSString *responseString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableDictionary *jsonDictionary = [parser objectWithString:responseString error:nil];
    BOOL success = [(NSNumber*)[jsonDictionary objectForKey:@"status"]boolValue];
    switch (request.tag) {
        case addProductGrosir:
            if (success) {
                addProductSuccessful = true;
                if ([self haveImageToUpload]) {
                    NSDictionary* resultData = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
                    addedProductID = [resultData valueForKey:@"prd_id"];
                    
                    //upload image
                    [self addProductImageToServerIsGrosir:true];
                }else{
                    UIAlertView *errorView;
                    
                    errorView = [[UIAlertView alloc]
                                 initWithTitle: title_success
                                 message: @"Produk berhasil ditambahkan"
                                 delegate: self
                                 cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
                    
                    [errorView show];
                    
                    [self.navigationController popViewControllerAnimated:TRUE];
                }
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
            break;
        case editProductGrosir:
            if (success) {
                addProductSuccessful = true;
                //update image
                [self updateProductImageToServerIsGrosir:true];
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
            break;
        case addProductRetail:
            if (success) {
                addProductSuccessful = true;
                if ([self haveImageToUpload]) {
                    NSDictionary* resultData = (NSDictionary*)[jsonDictionary objectForKey:@"data"];
                    addedProductID = [resultData valueForKey:@"prd_id"];
                    //upload image
                    
                    [self addProductImageToServerIsGrosir:false];
                }else{
                    UIAlertView *errorView;
                    
                    errorView = [[UIAlertView alloc]
                                 initWithTitle: title_success
                                 message: @"Produk berhasil ditambahkan"
                                 delegate: self
                                 cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
                    
                    [errorView show];
                    
                    [self.navigationController popViewControllerAnimated:TRUE];
                    
                }
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
            break;
        case editProductRetail:
            if (success) {
                //upload image
                addProductSuccessful = true;
                [self updateProductImageToServerIsGrosir:false];
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
            break;
        case getOptionValues:
            if (success) {
                NSArray* resultData = (NSArray*)[jsonDictionary objectForKey:@"data"];
                variantOptionData = [NSArray arrayWithArray:resultData];
                NSDictionary* optionData = [variantOptionData objectAtIndex:0];
                NSString* catID = [optionData valueForKey:@"cat_id"];
                if (variantKeyMapper==nil) {
                    variantKeyMapper = [NSMutableDictionary dictionary];
                }
                [variantKeyMapper setValue:[variantOptionData mutableCopy] forKey:catID];
                variantView.hidden = NO;
                if(!productData){
                    [self addNewVariantOption:NO];
                }
                
                [addNewVariantBtn setEnabled:YES];
            }else{
                //failed to get option values
                NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
                UIAlertView *errorView;
                
                errorView = [[UIAlertView alloc]
                             initWithTitle: title_error
                             message: errorMessage
                             delegate: self
                             cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [errorView setTag:0];
                [errorView show];
                variantView.hidden = YES;
                [addNewVariantBtn setEnabled:NO];
            }
            break;
        case deleteVariant:
        {
            if(success){
                [self deleteVariantViewAt:variantIndexToDelete];
            } else{
                NSString* errorMessage = [jsonDictionary objectForKey:@"message"];
                errorMessage = [NSString stringWithFormat:@"%@%@", @"Gagal menghapus varian.", errorMessage];
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
            break;
        case getProductCategory:
            if (success) {
                NSArray* catList = [NSArray arrayWithArray:(NSArray*)[jsonDictionary objectForKey:@"data"]];
                [categoryDict setObject:catList forKey:selectedGenderName];
                for (NSDictionary* catGender in catList) {
                    [categoryValues addObject:[catGender valueForKey:@"path"]];
                }
                [self setDefaultCategory];
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
        default:
            break;
    }
    
}

- (void)oneRequestFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    NSLog(@"response string : %@", responseString);
    if (request.tag==addProductImage) {
        numberOfProductImageUploaded++;
        uploadImageSuccess &= true;
    }
}

- (void)oneRequestFailed:(ASIHTTPRequest *)request
{
	//... Handle failure
    if (request.tag == addProductImage) {
        uploadImageSuccess &= false;
    }
	NSLog(@"Request failed");
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	// You could release the queue here if you wanted
	if ([queue requestsCount] == 0) {
		queue = nil;
	}
    [self shallShowLoadingOverlay:NO forAction:0];
    for (NSString* pngFilePath in createdImages) {
        //delete craeted image
        [DataSingleton removeFile:pngFilePath];
    }
    if (uploadImageSuccess) {
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_success
                     message: sessionQueue==queue_add_image?@"Produk berhasil ditambahkan":@"Produk berhasil diedit"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
        
        [self.navigationController popViewControllerAnimated:TRUE];
    }else{
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Gagal mengunggah gambar produk"
                     delegate: self
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [errorView show];
        NSLog(@"Queue finished");
    }
    sessionQueue = queue_none;
}

- (void)setProgress:(float)progress
{
    [uploadingProgress setProgress:progress];
    [uploadingPercentage setText:[NSString stringWithFormat:@"%d%%",(int)(progress*100)]];
}

#pragma mark - UITableView
#pragma mark - datasource

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dropdownValues.count;
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    int row = (int)indexPath.row;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[dropdownValues objectAtIndex:row]];
    cell.tag = row;
//    if (cell.tag==selectedAccount) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }else{
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [dropdownTableView cellForRowAtIndexPath:indexPath];
    int _row = (int)cell.tag;
    NSString* selectedValue = [dropdownValues objectAtIndex:_row];
    if (activeTextField!=nil) {
        activeTextField.text = [NSString stringWithFormat:@"%@",selectedValue];
        if (activeTextField==brand) {
            selectedBrandIndex = _row;
        }else if (activeTextField==gender) {
            if (selectedGenderIndex!=_row) {
                //gender changed
                //repopulate category
                selectedGenderIndex = _row;
                categoryValues = [NSMutableArray array];
                if(selectedGenderIndex >= 0){
                    selectedGenderName = [(NSDictionary*)[[DataSingleton instance].categoryData objectAtIndex:selectedGenderIndex] valueForKey:@"gender"];
                    NSMutableArray *catForGender = (NSMutableArray*)[categoryDict objectForKey:selectedGenderName];
                    
                    if (!catForGender) {
                        //category unavailable yet, request for it
                        [self requestForCategory];
                    }else{
                        for (NSDictionary* catGender in catForGender) {
                            [categoryValues addObject:[catGender valueForKey:@"path"]];
                        }
                        [self setDefaultCategory];
                    }
                    
                }
                
            }
            
        }else if (activeTextField==category){
            selectedCategoryIndex = _row;
            if (isRetailProduct) {
                refreshVariantView = true;
                [self requestOptionValueForCatID];
            } else{
                [self createVariantViewGrosir];
            }
        }
    }
    shouldDismissPopover = true;
    [self hideDropDown];
    
    [_tableView reloadData];
}

#pragma mark - UICollectionView
#pragma mark - datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return photos.count;
}

- (ProductImageCell*)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ProductImageCell* imageCell = [_collectionView dequeueReusableCellWithReuseIdentifier:ProductImageCellIdentifier forIndexPath:indexPath];
    int row = (int)[indexPath row];
    
    NSMutableDictionary *imageData = [photos objectAtIndex:row];
    UIImage *singleImage = [imageData objectForKey:@"image"];
    
    if (singleImage) {
        [imageCell.image setImage:singleImage];
    }
    imageCell.closeBtn.tag =row;
    [imageCell.closeBtn addTarget:self action:@selector(deleteProductImageAtIndex:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *color = [imageData objectForKey:@"color"];
    imageCell.color.text = [color isEqual:[NSNull null]]?@"":color;
    imageCell.color.hidden = NO;
    NSNumber *editable = [imageData objectForKey:@"editable_color"];
    if([editable boolValue]){
        imageCell.color.enabled = YES;
    } else{
        imageCell.color.enabled = NO;
    }
    [imageCell.color addTarget:self action:@selector(handleTextEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    imageCell.color.tag = row;
    
    return imageCell;
}

-(void)deleteProductImageAtIndex:(id)sender{
    int index = (int)((UIButton*)sender).tag;
    
    NSDictionary *imageToDelete = [photos objectAtIndex:index];
    if([imageToDelete valueForKey:@"img_id"]){
        [imagesToDelete addObject:imageToDelete];
    }
    
    [photos removeObjectAtIndex:index];
    [collectionView reloadData];
    if (photos.count==0) {
        if(IS_IPAD)
        noImageLabel.hidden = NO;
        [uploadImageBtn setTitle:@"Upload Gambar" forState:UIControlStateNormal];
    }
}

- (void)setDefaultCategory{
    selectedCategoryIndex = 0;
    category.text = [NSString stringWithFormat:@"%@",[categoryValues objectAtIndex:selectedCategoryIndex]];
    //change selected category index
    if (isRetailProduct && !variantViewHasBeenInitialized) {
        if(productData){
            refreshVariantView = false;
        }
        
        [self requestOptionValueForCatID];
    }else
    if (isRetailProduct) {
        refreshVariantView = true;
        [self requestOptionValueForCatID];
    }else{
        [self createVariantViewGrosir];
    }
}

- (void)createVariantViewGrosir{
    if(!isInitGrosirVariant){
        NSMutableArray *catForGender = (NSMutableArray*)[categoryDict objectForKey:selectedGenderName];
        NSDictionary* catInfo = [catForGender objectAtIndex:selectedCategoryIndex];
        NSArray* variants = [catInfo valueForKey:@"option"];
        
        [self setGrosirVariantsWithData:variants];
    } else{
        isInitGrosirVariant = NO;
    }
}

-(void) setGrosirVariantsWithData:(NSArray*)variants{
    [self clearGrosirVariant];
    
    if(variants && variants.count > 0){
        grosirVariants = variants;
        
        UIView *prevView = nil;
        if (variantView.subviews.count>2) {
            prevView = [variantView.subviews objectAtIndex:variantView.subviews.count-1];
        }
        variantViewTag = variantDataList.count;
        int posY = prevView==nil?46:CGRectGetMaxY(prevView.frame);
        posY += 20;
        
        UIView * variantWrapper = [[UIView alloc]
                                   initWithFrame:CGRectMake(0, posY, variantView.frame.size.width, 200)];
        [variantWrapper
            setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5]];
        variantWrapper.layer.cornerRadius = 9.0f;
        
        variantWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        
        int height = 0;
        int y = 20;
        
        int index = 0;
        for (NSDictionary* variant in variants) {
            UILabel* optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 230.0, 21)];
            height += 25;
            y += 25;
            [optionNameLabel setText:[variant valueForKey:@"opt_name"]];
            
            CustomRightViewTextfield *variantText = [[CustomRightViewTextfield alloc]
                                                        initWithFrame:CGRectMake(20,
                                                                                 y,
                                                                                 variantWrapper.frame.size.width-40.0,
                                                                                 40)];
            
            height += 40;
            variantText.layer.masksToBounds=YES;
            variantText.layer.borderColor=[[UIColor grayColor]CGColor];
            variantText.layer.borderWidth= 1.0f;
            variantText.layer.cornerRadius = 5.0f;
            [variantText setBackgroundColor:[UIColor whiteColor]];
            
            //create padding left
            UIView *paddingView = [[UIView alloc]
                                   initWithFrame:CGRectMake(0, 0, 5, variantText.frame.size.height)];
            
            variantText.leftView = paddingView;
            variantText.leftViewMode = UITextFieldViewModeAlways;
            if([variant objectForKey:@"value"]){
                variantText.text = [variant valueForKey:@"value"];
            }
            
            variantText.translatesAutoresizingMaskIntoConstraints = NO;
            variantText.tag = index;
            
            [variantText addTarget:self action:@selector(handleEndEditingGrosirVariantValue:) forControlEvents:UIControlEventEditingDidEnd];
            
            [variantWrapper addSubview:optionNameLabel];
            [variantWrapper addSubview:variantText];
            y += 55;
            height += 20;
            
            NSDictionary *variantTextConstraintDictionary = NSDictionaryOfVariableBindings(variantWrapper,variantText);
            [variantWrapper addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[variantText]-10-|"
                                                     options:0
                                                     metrics:0
                                                       views:variantTextConstraintDictionary]];
            
            [variantWrapper addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantText(==constantHeight)]"
                                                     options:0
                                                     metrics:@{@"constantHeight":@(40)}
                                                       views:variantTextConstraintDictionary]];
            
            index++;
        }
        height += 25;
        
        [variantView addSubview:variantWrapper];
        
        NSDictionary* viewsDictionary;
        if (prevView) {
            viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,prevView,addNewVariantBtn);
            //set height constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper(==constantHeight)]"
                                                                                options:0
                                                                                metrics:@{@"constantHeight":@(height)}
                                                                                views:viewsDictionary]];
            
            //set dynamic width constraint, x-pos constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[variantWrapper]-0-|"
                                                                                options:0
                                                                                metrics: 0
                                                                                views:viewsDictionary]];
            //set y-post constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prevView]-20-[variantWrapper]"
                                                                                options:0
                                                                                metrics: 0
                                                                                views:viewsDictionary]];
            [variantView removeConstraints:tempConstraint];
            //set variantView to wrap variantWrapper
            tempConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[variantWrapper]-20-|"
                                                                     options:0
                                                                     metrics: 0
                                                                     views:viewsDictionary];
            [variantView addConstraints:tempConstraint];
            
            
        }else{
            viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,addNewVariantBtn);
            //set height constraint
            [variantView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:[variantWrapper(==constantHeight)]"
                                         options:0
                                         metrics:@{@"constantHeight":@(height)}
                                         views:viewsDictionary]];
            
            //set dynamic width constraint, x-pos constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[variantWrapper]-0-|"
                                                                                options:0
                                                                                metrics: 0
                                                                                views:viewsDictionary]];
            //set y-post constraint
            [variantView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:[addNewVariantBtn]-20-[variantWrapper]"
                                         options:0
                                         metrics: 0
                                         views:viewsDictionary]];
            
            //set variantView to wrap variantWrapper
            tempConstraint = [NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[variantWrapper]-20-|"
                              options:0
                              metrics: 0
                              views:viewsDictionary];
            
            [variantView addConstraints:tempConstraint];
        }
    }
}

- (void)clearGrosirVariant{
    for (id subview in variantView.subviews) {
        if (subview!=addNewVariantLabel && subview!=addNewVariantBtn) {
            [subview removeFromSuperview];
        }
    }
    grosirVariants = nil;
}

#pragma mark - imagePickerController
#pragma mark - get product picture

- (IBAction)getImageToUpload:(id)sender {
    [activeTextField resignFirstResponder];
    [description resignFirstResponder];
    [dropdownPopover dismiss];
    [dropdownPopover setFrame:uploadOptionView.bounds];
    dropdownPopover.maskType = DXPopoverMaskTypeNone;
    CGPoint showPoint = CGPointMake(CGRectGetMaxX(uploadImageBtn.frame)-20, CGRectGetMaxY(uploadImageBtn.frame));
    [dropdownPopover showAtPoint:showPoint popoverPostion:DXPopoverPositionDown withContentView:uploadOptionView inView:mainScroller];
}

- (IBAction)takePicture:(id)sender {
    [dropdownPopover dismiss];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:title_error
                                                              message:@"Perangkat tidak didukung kamera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)selectImage:(id)sender {
    [dropdownPopover dismiss];
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    [imgPicker setDelegate:self];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setAllowsEditing:YES];
    [imgPicker setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:imgPicker animated:YES completion:NULL];
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return YES;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    noImageLabel.hidden = YES;
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //productImage.image = chosenImage;
    //UIImageView* selectedImage = [[UIImageView alloc] initWithImage:chosenImage];
    
    NSMutableDictionary * imageData = [NSMutableDictionary dictionary];
    [imageData setObject:chosenImage forKey:@"image"];
    [imageData setObject:@"" forKey:@"color"];
    [imageData setObject:[NSNumber numberWithBool:YES] forKey:@"editable_color"];
    
    [photos addObject:imageData];
    [imagesToUpload addObject:imageData];
    
    [uploadImageBtn setTitle:@"Tambah Gambar" forState:UIControlStateNormal];
    [collectionView reloadData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)deleteVariantView:(id)sender{
    if (viewVariantCollection.count>1) {
        variantIndexToDelete = ((UIButton*)sender).tag;
        
        UIAlertView *deleteConfirmation = [[UIAlertView alloc] initWithTitle:@"Konfirmasi"
                                                                     message:@"Anda yakin ingin menghapus varian ini?"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Tidak"
                                                           otherButtonTitles:@"Ya", nil];
        deleteConfirmation.tag = deleteAlert;
        [deleteConfirmation show];
    }
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==deleteAlert){
        if (buttonIndex==0) {
            NSLog(@"delete produk: tidak");
        }else{
            NSLog(@"delete produk: ya");
            NSDictionary *variantToDelete = [variantDataList objectAtIndex:variantIndexToDelete];
            if([variantToDelete valueForKey:@"var_id"]){
                //server variant
                [self deleteServerVariantWithVariantId:[variantToDelete valueForKey:@"var_id"]];
            } else{
                //new variant
                [self deleteVariantViewAt:variantIndexToDelete];
            }
        }
    }
    
}

-(void)deleteServerVariantWithVariantId:(NSString*)variantId{
    if(variantId){
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
            [self shallShowLoadingOverlay:YES forAction:loading_overlay];
            NSString * myURL = [NSString stringWithFormat:@"%@%@",y2BaseURL,deleteVariantURL];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:myURL]];
            request.tag = deleteVariant;
            [request setRequestMethod:@"POST"];
            [DataSingleton retrieveUser];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.id_user:@"" forKey:@"user_id"];
            [request addPostValue:[DataSingleton instance].loggedInUser!=nil?[DataSingleton instance].loggedInUser.token:@"" forKey:@"access_token"];
            [request addPostValue:variantId forKey:@"var_id"];
            [request setDelegate:self];
            [request setTimeOutSeconds:60];
            [request startAsynchronous];
            [request setUseSessionPersistence:YES];
        }
    } else{
        UIAlertView *alert;
        
        alert = [[UIAlertView alloc]
                     initWithTitle: title_error
                     message: @"Gagal menghapus varian"
                     delegate: nil
                     cancelButtonTitle: @"Tutup" otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)deleteVariantViewAt:(int)index{
    if (viewVariantCollection.count>1) {
        UIView* variantWrapper;
        for (UIView* checkedView in variantView.subviews) {
            if (checkedView.tag==index) {
                variantWrapper = checkedView;
                break;
            }
        }
        int selectedVariantViewIndex = [variantView.subviews indexOfObject:variantWrapper];
        selectedVariantViewIndex -= 2;
        if (selectedVariantViewIndex==0) {
            //remove 1st variantView
            UIView * lowerView = [viewVariantCollection objectAtIndex:selectedVariantViewIndex+1];
            NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,lowerView,addNewVariantBtn);
            //set y-post constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[addNewVariantBtn]-20-[lowerView]" options:0 metrics: 0 views:viewsDictionary]];
        }else if (selectedVariantViewIndex==viewVariantCollection.count-1){
            //remove last variantView
            UIView * upperView = [viewVariantCollection objectAtIndex:selectedVariantViewIndex-1];
            NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,upperView,addNewVariantBtn);
            tempConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[upperView]-20-|" options:0 metrics: 0 views:viewsDictionary];
            [variantView addConstraints:tempConstraint];
        }else{
            //remove variantView in the middle
            UIView * upperView = [viewVariantCollection objectAtIndex:selectedVariantViewIndex-1];
            UIView * lowerView = [viewVariantCollection objectAtIndex:selectedVariantViewIndex+1];
            NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(variantWrapper,upperView,lowerView);
            //set y-post constraint
            [variantView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[upperView]-20-[lowerView]" options:0 metrics: 0 views:viewsDictionary]];
        }
        
        [variantView removeConstraints:variantWrapper.constraints];
        [variantWrapper removeFromSuperview];
        [viewVariantCollection removeObjectAtIndex:selectedVariantViewIndex];
        [dataVariantCollection removeObjectAtIndex:selectedVariantViewIndex];
        [variantDataList removeObjectAtIndex:selectedVariantViewIndex];
        
        UIAlertView *alert;
        
        alert = [[UIAlertView alloc]
                     initWithTitle: title_success
                     message: @"Varian berhasil dihapus"
                     delegate: nil
                     cancelButtonTitle: @"Close" otherButtonTitles: nil];
        [alert setTag:0];
        [alert show];
        addProductSuccessful = YES;
        
        [self updateVariantIndex];
    }
}

- (void)clearVariantView{
    for (id subview in variantView.subviews) {
        if (subview!=addNewVariantLabel && subview!=addNewVariantBtn) {
            [subview removeFromSuperview];
        }
    }
    viewVariantCollection = [NSMutableArray array];
    dataVariantCollection = [NSMutableArray array];
    variantDataList = [NSMutableArray array];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
    if(popoverShown){
        [self hideDropDown];
    }
}

- (void)handleTextEndEditing:(UITextField*) sender{
    if(sender){
        int row = sender.tag;
        [[photos objectAtIndex:row] setObject:sender.text forKey:@"color"];
    }
}

- (void)handleEndEditingGrosirVariantValue:(UITextField*) sender{
    if(sender){
        int row = sender.tag;
        if(grosirVariants && grosirVariants.count > row){
            [[grosirVariants objectAtIndex:row] setObject:sender.text forKey:@"value"];
        }
    }
}

-(BOOL)haveImageToUpload{
    BOOL have = NO;
    
    if(photos){
        if(photos.count > 0){
            for (NSDictionary *photo in photos) {
                if(![photo valueForKey:@"img_id"]){
                    have = YES;
                    break;
                }
            }
        }
    }
    
    return have;
}

@end
