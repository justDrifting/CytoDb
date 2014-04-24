//
//  ImageViewController.m
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "ImageViewController.h"
#import "CDBSlideViewController.h"
#import "UIImageView+WebCache.h"
#import "Features.h"

#define TMP NSTemporaryDirectory()

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
    
    
  
   
   //Filepath for the thumbnail
    NSString *filepath = [self documentsPathForFileName:self.thumbURL];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    UIImage *placeholderImage = [UIImage imageWithData:data];
  
    
    if(placeholderImage ==nil){
        
        placeholderImage = [UIImage imageNamed:@"placeholder.png"];
        NSLog(@"no image yet");
    }
    
    
    
   [self.imageDisplay setImageWithURL:[NSURL URLWithString: self.imageURL]
                      placeholderImage:placeholderImage];
    
    
    // CHECK IF HAVE SHOWN SETTINGS
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    BOOL hasShownSettings = [ud boolForKey: @"hasShownGuide"];
    
    // SHOW SETTINGS VIEW
    if (!hasShownSettings) {
        
        //[self showUserAgreement];
        // SAVE THAT WE HAVE SHOWN SETTINGS PAGE
        [ud setBool: YES forKey: @"hasShownSettings"];
        
    }

    
    [self.imageScrollView setMaximumZoomScale:2.0f];
    [self.imageScrollView setMinimumZoomScale:1.0f];
    [self.imageScrollView setZoomScale:1.0f];
    self.imageDisplay.contentMode= UIViewContentModeScaleAspectFill;
   

   //Setting up tap gesture
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    _doubleTap.numberOfTapsRequired = 2;
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    _singleTap.numberOfTapsRequired = 1;
  
    //Isolating Single Taps From DoubleTaps
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
  
    
    //Double tap enables Zoom
    [self.imageScrollView addGestureRecognizer:_doubleTap];
 
    
   

  
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
    
   // [[self.parentViewController.view viewWithTag:99 ] removeFromSuperview];
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
    //Clear Cache if needed
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
}




-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   // [[self navigationController] setNavigationBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) animated:YES];
    [self.textDisplay setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    [self autoRotateView:self.imageScrollView toInterfaceOrientation:toInterfaceOrientation];
    [self.navigationController setNavigationBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    
      
}


-(void)autoRotateView:(UIView *)viewToAutoRotate toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            viewToAutoRotate.transform = CGAffineTransformMakeRotation(-M_PI_2); // -90 degress
            self.imageTopConstraint.constant = 0.0f;
            self.imageHeight.constant = 500.0f;
            self.imageWidth.constant = 280.0f;
            self.scrollHeight.constant = 500.0f;
            self.scrollWidth.constant = 280.0f;
            [self.view addGestureRecognizer:_singleTap];
            
            break;
 
        case UIInterfaceOrientationPortraitUpsideDown:
        default:
            viewToAutoRotate.transform = CGAffineTransformMakeRotation(0); // 0 degrees
            self.imageTopConstraint.constant = 40.0f;
            self.imageHeight.constant = 360.0f;
            self.imageWidth.constant = 300.0f;
            self.scrollHeight.constant = 360.0f;
            self.scrollWidth.constant = 300.0f;
            [[self navigationController] setNavigationBarHidden:NO];

            break;
    }

}
/*

- (void) getCachedImage: (NSURL *) imageURL
{
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [imageURL absoluteString];
    
    
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    UIImage *image;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        NSLog(@"image is in Cache");
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    else
    {
        // get a new one
        NSLog(@"Need to get image %@ from URL",filename);
        [self cacheImage: imageURL];
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
    self.imageDisplay.image= image;
    //return image;
    
}


- (void) cacheImage: (NSURL *) imageURL
{
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [imageURL absoluteString];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
        
        // Fetch image
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
            UIImage *image = [[UIImage alloc] initWithData: imageData];
            
        
                // STORE IN FILESYSTEM
               // NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
               // NSString *file = [cachesDirectory stringByAppendingPathComponent:[self.imageURL absoluteString]];
                //[imageData writeToFile:file atomically:YES];
                [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
                // STORE IN MEMORY
               // [memoryCache setObject:imageData forKey:[self.imageURL absoluteString]];
                
                //Main Dispatch Task to decompressData
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    
                      self.imageDisplay.image= [UIImage imageWithData:imageData];
                }); //End Inner Block
            
        });//End GCD Block
    }

}
*/


#pragma -document path
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}





@end
