//
//  AddNewProductViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 1/9/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldValidator.h"
#import "SZTextView.h"
#import "DropDownTextField.h"
#import "DXPopover.h"
#import "VCDelegate.h"
#import "ProductImageCell.h"
#import "ASINetworkQueue.h"

@interface AddNewProductViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,ASIProgressDelegate>{
    int widthContentView;
    UITextField* activeTextField;
    DXPopover *dropdownPopover;
    NSMutableArray* dropdownValues;
    NSMutableArray* brandValues;
    NSMutableArray* genderValues;
    NSMutableArray* categoryValues;
    NSMutableArray* photos;
    NSMutableArray* createdImages;
    BOOL submitEdit;
    BOOL addProductSuccessful;
    BOOL uploadImageSuccess;
    int numberOfProductImageUploaded;
    int selectedBrandIndex;
    int selectedGenderIndex;
    int selectedCategoryIndex;
    NSString *selectedGenderName;
    NSMutableDictionary* categoryDict;
    
    NSString* addedProductID;
    BOOL shouldDismissPopover;
    BOOL popoverShown;
    NSString* validatorMsg;
    NSArray *tempConstraint;
    NSMutableArray *viewVariantCollection;
    NSMutableArray *dataVariantCollection;
    NSMutableArray *variantDataList;
    int variantViewTag;
    NSArray *variantOptionData;
    NSArray *grosirVariants;
    NSMutableArray *optionKind;
    NSMutableArray *optionValues;
    BOOL refreshVariantView;
    NSMutableDictionary *variantKeyMapper;
    BOOL variantViewHasBeenInitialized;
    int sessionQueue;
    ASINetworkQueue* networkQueue;
    int variantIndexToDelete;
    BOOL isInit;
    BOOL isInitGrosirVariant;
    BOOL hasNotRequestForCategory;
    
    UIGestureRecognizer *tapper;
    
    NSMutableArray *imagesToUpload;
    NSMutableArray *imagesToDelete;
}

@property (nonatomic, assign)   id<VCDelegate> delegate;
@property (strong, nonatomic) NSDictionary* productData;
@property BOOL isRetailProduct;
@property (strong, nonatomic) IBOutlet UIView *uploadOptionView;
@property (strong, nonatomic) IBOutlet UIButton *takePicBtn;
@property (strong, nonatomic) IBOutlet UIButton *selectPicBtn;
@property (strong, nonatomic) IBOutlet UITableView *dropdownTableView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroller;
@property (strong, nonatomic) IBOutlet UIView *mainWrapper;
@property (strong, nonatomic) IBOutlet TextFieldValidator *name;
@property (strong, nonatomic) IBOutlet TextFieldValidator *sku;
@property (strong, nonatomic) IBOutlet TextFieldValidator *price;
@property (strong, nonatomic) IBOutlet UILabel *stockLabel;
@property (strong, nonatomic) IBOutlet TextFieldValidator *stock;
@property (strong, nonatomic) IBOutlet TextFieldValidator *weight;
@property (strong, nonatomic) IBOutlet SZTextView *description;
@property (strong, nonatomic) IBOutlet DropDownTextField *brand;
@property (strong, nonatomic) IBOutlet DropDownTextField *gender;
@property (strong, nonatomic) IBOutlet DropDownTextField *category;

@property (strong, nonatomic) IBOutlet UIButton *uploadImageBtn;
@property (strong, nonatomic) IBOutlet UILabel *noImageLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIView *loadingWrapper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIView *uploadingWrapper;
@property (strong, nonatomic) IBOutlet UIProgressView *uploadingProgress;
@property (strong, nonatomic) IBOutlet UILabel *uploadingPercentage;
@property (strong, nonatomic) IBOutlet UILabel *uploadingMessage;
@property (strong, nonatomic) IBOutlet UIView *variantView;
@property (strong, nonatomic) IBOutlet UIButton *addNewVariantBtn;
@property (strong, nonatomic) IBOutlet UILabel *addNewVariantLabel;

- (IBAction)getImageToUpload:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)selectImage:(id)sender;
- (IBAction)saveProduct:(id)sender;
- (IBAction)addNewVariant:(id)sender;

@end
