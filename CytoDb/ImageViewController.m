//
//  ImageViewController.m
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "ImageViewController.h"
#import "CDBSlideViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

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
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    self.textDisplay.text = self.descriptionText;
    self.imageDisplay.image= [UIImage imageWithData:self.imageFile];
  
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
