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

@synthesize imageScrollView = _imageScrollView;



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
    
    
    
    
   // UIImage *slideImage = [UIImage imageWithData:self.imageFile];
   // self.edgesForExtendedLayout = UIRectEdgeNone;
    //CGRect imageframe = CGRectMake(200, 10, 300, 360);
    self.imageDisplay.image= [UIImage imageWithData:_imageFile scale:1.0f];
    [self.imageScrollView setMaximumZoomScale:2.0f];
    [self.imageScrollView setMinimumZoomScale:1.0f];
    [self.imageScrollView setZoomScale:1.0f];
    self.imageDisplay.contentMode= UIViewContentModeScaleAspectFill;
   //[self.imageScrollView addSubview:self.imageDisplay];
   //self.imageDisplay.frame= (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=slideImage.size};

   //Setting up tap gesture
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    _doubleTap.numberOfTapsRequired = 2;
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    _singleTap.numberOfTapsRequired = 1;
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
  
    
    
   //Double tap enables Zoom
    [self.imageScrollView addGestureRecognizer:_doubleTap];
 
    
    
  //  self.navigationController.navigationBar.translucent = YES;
  //  self.wantsFullScreenLayout = YES;
    
    
    
    
    //2
   // self.imageScrollView.contentSize = slideImage.size;
    

    // 3
    
    
  /*  UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.imageScrollView addGestureRecognizer:twoFingerTapRecognizer];
    
   
    
   UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    
    [self.view addGestureRecognizer:singleTap];
  */
   
    //[self centerScrollViewContents];
 //  [self.imageDisplay addGestureRecognizer:modalTap];
  
}


-(void)viewWillAppear:(BOOL)animated
{
   
    [self.textDisplay setHidden:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
    [self autoRotateView:self.imageScrollView toInterfaceOrientation:self.interfaceOrientation];
    
}


-(void)toggleNavigationBar
{
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden];
        
    }
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
  
   // NSLog(@"Double tap detected");
    
    
    CGFloat minZoomScale = self.imageScrollView.minimumZoomScale;
    CGFloat maxZoomScale = self.imageScrollView.maximumZoomScale;
    CGFloat midZoomScale = minZoomScale + 0.5*(maxZoomScale - minZoomScale);
    
    
    if(self.imageScrollView.zoomScale > midZoomScale ){
    [self.imageScrollView setZoomScale:minZoomScale animated:YES];
    }
    else{
    [self.imageScrollView setZoomScale:maxZoomScale animated:YES];
    }
  /*
    // 1
    CGPoint pointInView = [recognizer locationInView:self.imageDisplay];
    
    // 2
    CGFloat newZoomScale = self.imageScrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.imageScrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.imageScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.imageScrollView zoomToRect:rectToZoomTo animated:YES];
   
   */
}

/*
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.imageScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.imageScrollView.minimumZoomScale);
    [self.imageScrollView setZoomScale:newZoomScale animated:YES];
}

*/


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    
  
    return self.imageDisplay;
}




- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
   
    
}


- (IBAction)unwindToImageViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}




-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   // [[self navigationController] setNavigationBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) animated:YES];
    [self.textDisplay setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    [self autoRotateView:self.imageScrollView toInterfaceOrientation:toInterfaceOrientation];
    
}


-(void)autoRotateView:(UIView *)viewToAutoRotate toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            viewToAutoRotate.transform = CGAffineTransformMakeRotation(M_PI_2); // 90 degress
            self.imageTopConstraint.constant = 0.0f;
            self.imageHeight.constant = 500.0f;
            self.imageWidth.constant = 280.0f;
            self.scrollHeight.constant = 500.0f;
            self.scrollWidth.constant = 280.0f;
            [self.view addGestureRecognizer:_singleTap];
            break;
 
        case UIInterfaceOrientationPortraitUpsideDown:
        default:
            viewToAutoRotate.transform = CGAffineTransformMakeRotation(M_PI); // 180 degrees
            self.imageTopConstraint.constant = 40.0f;
            self.imageHeight.constant = 360.0f;
            self.imageWidth.constant = 300.0f;
            self.scrollHeight.constant = 360.0f;
            self.scrollWidth.constant = 300.0f;
            [[self navigationController] setNavigationBarHidden:NO];

            break;
      
    }

}

@end
