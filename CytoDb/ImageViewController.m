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
    
    NSLog(@"Image %@ size is %lu",self.descriptionText,self.imageFile.length);
    self.imageDisplay.image= [UIImage imageWithData:_imageFile scale:1.0f];
    [self.imageScrollView setMaximumZoomScale:2.0f];
    [self.imageScrollView setMinimumZoomScale:1.0f];
     [self.imageScrollView setZoomScale:1.0f];
    //self.imageDisplay.frame= (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=slideImage.size};
    self.imageDisplay.contentMode= UIViewContentModeScaleAspectFill;
   //[self.imageScrollView addSubview:self.imageDisplay];
    
  
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.imageScrollView addGestureRecognizer:doubleTapRecognizer];

    
    //2
   // self.imageScrollView.contentSize = slideImage.size;
    

    // 3
    
    
  /*  UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.imageScrollView addGestureRecognizer:twoFingerTapRecognizer];
    
   */ 
    
 // UITapGestureRecognizer *modalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFullView)];
    
    
    //[self.imageDisplay addGestureRecognizer:modalTap];
  
   
    //[self centerScrollViewContents];
 //  [self.imageDisplay addGestureRecognizer:modalTap];
  
}


/*
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 4
    CGRect scrollViewFrame = self.imageScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.imageScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.imageScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.imageScrollView.minimumZoomScale = minScale;
    
    // 5
    self.imageScrollView.maximumZoomScale = 1.0f;
    self.imageScrollView.zoomScale = minScale;
    
    // 6
    [self centerScrollViewContents];

}
*/



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
    // The scroll view has zoomed, so you need to re-center the contents
   // [self centerScrollViewContents];
    //NSLog(@"mid ZoomScale is %f", self.imageScrollView.zoomScale);
    
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





@end
