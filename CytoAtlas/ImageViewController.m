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
#define IS_PAD  (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

@interface ImageViewController ()


@property (weak, nonatomic) IBOutlet UITextView *imageLoadingText;

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
    //Set Font to 0.8 of preffered font size
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    float fontSize = [userFont pointSize] * 0.8f;
    self.textDisplay.font = [UIFont fontWithDescriptor:userFont size:fontSize];
    self.textDisplay.text = self.descriptionText;
    
    //Listen for changes in font Size user preference
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
    
    
   
    //convert imageURL to thumbURL
     NSString *thumbURL = self.imageURL;
     thumbURL = [thumbURL stringByReplacingOccurrencesOfString:@"Images" withString:@"thumbnails"];
     thumbURL = [thumbURL stringByReplacingOccurrencesOfString:@"png" withString:@"jpg"];
    
    
    NSURL *iURL= [NSURL URLWithString: self.imageURL];
    
   // [self.imageDisplay setImageWithURL:[NSURL URLWithString:thumbURL]];
    
    [self.imageDisplay sd_setImageWithURL:[NSURL URLWithString:thumbURL]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                          
                          // Slowly download the larger version of the image
                          SDWebImageManager *manager = [SDWebImageManager sharedManager];
                          [manager downloadImageWithURL:iURL
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                          }
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url) {
                                             
                                             
                                             //If no image
                                             if(!image){
                                                 
                                                 [_imageLoadingText setText:[NSString stringWithFormat:@"%@\r%@", @"Image Unavailable",@"Check Internet Connection"]];
                                                 
                                             }
                                             else  self.imageDisplay.image = image;
                                             
                                         }];
                      }];
  
    
    
    
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
    
    //Single Tap on Image to hide nav bar (For iPhone only)
   // _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTextDisplay)];
    
    _singleTap.numberOfTapsRequired = 1;
  
    //Isolating Single Taps From DoubleTaps
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
  
    
    //Double tap enables Zoom
    [self.imageScrollView addGestureRecognizer:_doubleTap];
 
  
}



//Selector to check prefered font size update
- (void)preferredContentSizeChanged:(NSNotification *)notification {
    
    //Set Font to 0.8 of preffered font size
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    float fontSize = [userFont pointSize] * 0.8f;
    self.textDisplay.font = [UIFont fontWithDescriptor:userFont size:fontSize];
}


-(void)viewWillAppear:(BOOL)animated
{
   //Hide text Display in iPhone Landscape
    //[self.textDisplay setHidden:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
    
    [self autoRotateView:self.imageScrollView toInterfaceOrientation:self.interfaceOrientation];
    
}


-(void)toggleNavigationBar
{
    if(!IS_PAD){
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden];
        
        }
    }
}


-(void)toggleTextDisplay
{
    if(IS_PAD){
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
         //   [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden];
            if(![self.textDisplay isHidden]){
                [self.textDisplay setHidden:YES];
            }
            else{
                [self.textDisplay setHidden:NO];
            }
        }
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
    //Clear Cache if needed
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
}




-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   // [[self navigationController] setNavigationBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) animated:YES];
   
    //Hide text Display in iPhone Landscape
    //[self.textDisplay setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    
    //Show text Display in iPad Portrait
    [self.textDisplay setHidden:!(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))];
    
    [self autoRotateView:self.imageScrollView toInterfaceOrientation:toInterfaceOrientation];
    //[self.navigationController setNavigationBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    
      
}


-(void)autoRotateView:(UIView *)viewToAutoRotate toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
   
    // CGRect screenRect = [[UIScreen mainScreen]bounds];
   // CGFloat screenWidth = screenRect.size.width;
   // CGFloat screenHeight = screenRect.size.height;
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
           // viewToAutoRotate.transform = CGAffineTransformMakeRotation(-M_PI_2); // -90 degress
           // self.progressView.transform = CGAffineTransformMakeRotation(M_PI/2);
          //  self.imageTopConstraint.constant = 0.0f;
            self.imageHeight.constant = 660.0f;
            self.imageWidth.constant = 600.0f;
            self.scrollHeight.constant = 660.0f;
            self.scrollWidth.constant = 600.0f;
            if(IS_PAD) self.textBoxTopFromBottom.constant = 100.0f;
            [self.view addGestureRecognizer:_singleTap];
            
            break;
 
        case UIInterfaceOrientationPortraitUpsideDown:
        default:
          /*  viewToAutoRotate.transform = CGAffineTransformMakeRotation(0); // 0 degrees
            //self.progressView.transform = CGAffineTransformMakeRotation(0);
           // self.imageTopConstraint.constant = 40.0f;
            self.imageHeight.constant = 760.0f;
            self.imageWidth.constant = 700.0f;
            self.scrollHeight.constant = 760.0f;
            self.scrollWidth.constant = 700.0f;
            self.textBoxTopFromBottom.constant = 200.0f;
        //  [[self navigationController] setNavigationBarHidden:NO];
           */
            
            viewToAutoRotate.transform = CGAffineTransformMakeRotation(0); // 0 degrees
            //self.progressView.transform = CGAffineTransformMakeRotation(0);
            //self.textViewToScrollView.constant= 8.0f;
            self.imageWidth.constant = self.scaledImageWidth;
            self.imageHeight.constant = self.scaledImageHeight;
            self.scrollWidth.constant = self.imageWidth.constant;
            self.scrollHeight.constant = self.imageHeight.constant;
            //self.imageTopToTop.constant=64.0f;
            self.textDisplayHeight.constant= self.screenHeight-self.scaledImageHeight-64.0f-20.0f;
            //self.vertSpaceTextViewTopToView.constant = self.scaledImageHeight+64.0f+8.0f;
            [[self navigationController] setNavigationBarHidden:NO];
            
            break;
    }
  
}



#pragma -document path
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}





@end
