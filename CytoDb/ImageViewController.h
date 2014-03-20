//
//  ImageViewController.h
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageDisplay;
@property (weak, nonatomic) IBOutlet UITextView *textDisplay;

@property NSUInteger pageIndex;
@property NSString *descriptionText;
@property NSData *imageFile;

@end
