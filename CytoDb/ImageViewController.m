//
//  ImageViewController.m
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "ImageViewController.h"
#import "CDBSlideViewController.h"
#import "fullViewController.h"

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
    
    UITapGestureRecognizer *modalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFullView)];
    
    [self.imageDisplay addGestureRecognizer:modalTap];
  
  
}


- (IBAction)unwindToImageViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

-(void)goToFullView
{
     [self performSegueWithIdentifier:@"fullViewSegue" sender:self];

}


/*
-(void)showModalView
{
    NSLog(@"I have been touched");
    
    if(!self.isLarge){
    
        self.isLarge =YES;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.fullSizeImageView = [[UIImageView alloc] init];
    self.fullSizeImageView.frame = CGRectMake(5, 5, self.view.frame.size.width -10, self.view.frame.size.height - 10);
    
    UIImage *imageToDisplay = [UIImage imageWithData:self.imageFile];
  
    
    self.fullSizeImageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.fullSizeImageView setContentMode:UIViewContentModeCenter];

    self.fullSizeImageView.image = imageToDisplay;
    
    //UITapGestureRecognizer *modalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalView)];
    
   // [imageView addGestureRecognizer:modalTap];
    
    //Add this image as a subview
    [self.view addSubview:self.fullSizeImageView];
        
    }
    else
    {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        
        [UIView animateWithDuration:0.25
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.fullSizeImageView.alpha = 0;
                         }completion:^(BOOL finished){
                             [self.fullSizeImageView removeFromSuperview];
                         }];
        
        self.isLarge =NO;
    }
    
    //[self presentViewController:modalViewController animated:YES completion:nil];
    
    

}

*/


/*
-(void)showModalView
{
    NSLog(@"I have been touched");
    
    if(!self.isLarge){
        
        self.isLarge =YES;
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        
        self.fullSizeImageView = [[UIImageView alloc] init];
        self.fullSizeImageView.frame = CGRectMake(5, 5, self.view.frame.size.width -10, self.view.frame.size.height - 10);
        
        UIImage *imageToDisplay = [UIImage imageWithData:self.imageFile];
        
        
        self.fullSizeImageView.contentMode=UIViewContentModeScaleAspectFill;
        [self.fullSizeImageView setContentMode:UIViewContentModeCenter];
        
        self.fullSizeImageView.image = imageToDisplay;
        
        //UITapGestureRecognizer *modalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalView)];
        
        // [imageView addGestureRecognizer:modalTap];
        
        //Add this image as a subview
        [self.view addSubview:self.fullSizeImageView];
        
    }
    else
    {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        
        [UIView animateWithDuration:0.25
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.fullSizeImageView.alpha = 0;
                         }completion:^(BOOL finished){
                             [self.fullSizeImageView removeFromSuperview];
                         }];
        
        self.isLarge =NO;
    }
    
    //[self presentViewController:modalViewController animated:YES completion:nil];
    
    
    
}*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier]isEqualToString:@"fullViewSegue"]){
        
        fullViewController *fullViewCont = (fullViewController *) segue.destinationViewController;
        fullViewCont.fullImage = [UIImage imageWithData:self.imageFile];
       
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}






-(void)dismissModalView
{
    
  //NSLog(@"I dismissmodalview");
 // [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
   [self.view removeFromSuperview];
}


@end
