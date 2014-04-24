//
//  ImageViewController.h
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface ImageViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageDisplay;
@property (weak, nonatomic) IBOutlet UITextView *textDisplay;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollWidth;

@property NSUInteger pageIndex;
@property NSString *descriptionText;
@property NSData *imageFile;
@property NSString *imageURL;
@property NSString *thumbURL;
@property UIImage *pageImage;

@property UITapGestureRecognizer *singleTap;
@property UITapGestureRecognizer *doubleTap;


@end
