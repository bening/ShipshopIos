//
//  BlankPageViewController.h
//  Y2OnlineShop
//
//  Created by maverick on 12/8/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlankPageViewController : UIViewController{
    int widthContentView;
}
@property (strong, nonatomic) IBOutlet UIImageView *blankImage;
@property (strong, nonatomic) NSString* imageNamed;

@end
