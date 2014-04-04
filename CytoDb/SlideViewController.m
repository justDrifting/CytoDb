//
//  SlideViewController.m
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "SlideViewController.h"
#import "Organ.h"
#import "Condition.h"
#import "Slide.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface SlideViewController ()

@end

@implementation SlideViewController

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
    
    
	// Do any additional setup after loading the view.
    //selectedCondition name was delegated in the segue in the slideViewController
   
     self.pageViewController.delegate = self;
    
    //The selected condition is now used in setting the title and fetchSlides
    Condition *condition = (Condition *)[self.managedObjectContext existingObjectWithID:self.conditionID error:nil];
    [self setTitle: condition.conditionName];
    self.subviewText = condition.conditionDescription;
    [self fetchSlides]; //This populated the self.slideArray
    
   
    
    //This is actually slide Name that appears below the image
    _pageTitles = [[NSMutableArray alloc] init];
    _pageImages = [[NSMutableArray alloc] init];
    _pageImageURLs = [[NSMutableArray alloc] init];
    _pageTexts =  [[NSMutableArray alloc] init];
    
    for(Slide *slide in self.slideArray){
      
      [_pageTitles addObject:slide.slideName];
      [_pageImages addObject:slide.slideImage];
      [_pageTexts  addObject:slide.slideDescription];
      [_pageImageURLs addObject:[NSURL URLWithString:(slide.imageURL)]];
      //Add any other attribute that need to go into the page view controller
     }
    
    
    //Set nav bar color to transparent
    /* [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
   */
   self.navigationController.navigationBar.translucent = YES;
    
    
  //  [[self navigationController] setNavigationBarHidden:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) animated:YES];
    
    
   // Create page view controller
   // self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewController"];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
   
    //SlideViewController (self) Will Provide the necessary data for the pageViewController
    self.pageViewController.dataSource = self;
    
    
    
    //Set the first page in the pageViewController using the method "viewControlleratIndex"
    ImageViewController *startingViewController = [self viewControllerAtIndex:0];
    
    // The pages need to be sent as an array even if it is only one page, so we pass it into an array
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
   
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
   

    
    //Add Tapgesture to thetext field
     UITapGestureRecognizer  *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(toggleBottomToolBar)];
    singleTap.numberOfTapsRequired = 1;
    
    [self.view addSubview:_detailsViewButton];
    
    [_detailsViewButton addGestureRecognizer: singleTap];
 
    
 
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    //Custom pageControl
    self.pageControl.numberOfPages = self.pageTitles.count;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self.view addSubview:_pageControl.viewForBaselineLayout];


}


-(void)toggleBottomToolBar
{
    
    if (!self.showingSubview){
        [self showBottomToolBar];
    }
    else{
        [self hideBottomToolBar];
    }
    
}

-(void)showBottomToolBar
{
    UITextView *subview = [[UITextView alloc] initWithFrame:CGRectMake(10, 568, 300, 37)];
    subview.backgroundColor = [UIColor clearColor];
    subview.text = self.subviewText;
    
    [subview setTextColor:[UIColor blackColor]];
    [subview setFont:[UIFont systemFontOfSize:14]];
    // [subview setTextContainerInset:UIEdgeInsetsMake(40, 20,40,20)];
    [subview setEditable:NO];
    [subview setSelectable:NO];
    [subview setScrollEnabled:YES];
    UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 568, 320, 37)];
    bgToolbar.barStyle = UIBarStyleDefault;
    
    //Custom pulldownbutton
    UIView *pulldownButton = [[UIView alloc]initWithFrame:CGRectMake(140, 568, 40, 6)];
    [pulldownButton.layer setCornerRadius:3.0f];
    [pulldownButton setBackgroundColor:[UIColor grayColor]];
    
    //[subview.superview insertSubview:bgToolbar belowSubview:subview];
    
    [bgToolbar setShadowImage:nil forToolbarPosition:UIBarPositionTop];
    [self.view addSubview:bgToolbar];
    [self.view addSubview:subview];
    [self.view addSubview:pulldownButton];
    pulldownButton.tag=9;
    subview.tag=99;
    bgToolbar.tag=999;
    
    
    
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         pulldownButton.frame = CGRectMake(140, 400, 40, 6);
                         bgToolbar.frame= CGRectMake(0, 390, 320, 178);
                         subview.frame =CGRectMake(10, 412, 300, 129);
                     }
                     completion:^(BOOL finished){
                         
                         UITapGestureRecognizer *tapToClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBottomToolBar)];
                         tapToClose.numberOfTapsRequired = 1;
                         
                          UISwipeGestureRecognizer *swipedown=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideBottomToolBar)];
                          
                          swipedown.direction=UISwipeGestureRecognizerDirectionDown;
                         
                         NSArray *gestures = [NSArray arrayWithObjects:tapToClose,swipedown, nil];
                         
                         [bgToolbar setGestureRecognizers:gestures];
                         [subview addGestureRecognizer:tapToClose];
                         [pulldownButton setGestureRecognizers:gestures];
                         
                         
                         
                         
                     }];
    
    self.showingSubview = YES;
    
    

}

-(void)hideBottomToolBar
{
    UIView *taggedButton = [self.view viewWithTag:9];
    UIView *taggedView = [self.view viewWithTag:99];
    UIView *taggedToolbar = [self.view viewWithTag:999];
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         taggedButton.frame = CGRectMake(140, 568, 40, 8);
                         taggedView.frame = CGRectMake(10, 531, 300, 0);// its final location
                         taggedToolbar.frame = CGRectMake(0, 568, 320, 0);
                     }
                     completion:^(BOOL finished){
                         [taggedButton removeFromSuperview];
                         [taggedView removeFromSuperview];
                         [taggedToolbar removeFromSuperview];
                     }];
    
    
    //taggedView = nil;
    self.showingSubview = NO;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController*) viewController).pageIndex;
   self.pageControl.currentPage = index;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController*) viewController).pageIndex;
    self.pageControl.currentPage = index;
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

 
- (ImageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ImageViewController *imageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageController"];
    
    imageViewController.imageFile = self.pageImages[index];
    imageViewController.imageURL = self.pageImageURLs[index];
    imageViewController.descriptionText = self.pageTexts[index];
    imageViewController.pageIndex = index;
    
    return imageViewController;
}


//These are used for displaying the pageControl if commented out the pageControlWont Show
/*
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.slideArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
*/

#pragma -Get the slides based on the selected Condition

-(void)fetchSlides
{
    //Grab the context
    
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Slide"
                                              inManagedObjectContext:context];
   
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"ANY condition == %@", self.conditionID];

    
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    _slideArray=fetchedObjects; //This array will be used to populate the pages
    
}


#pragma -mark
#pragma - Custom textView
- (CGFloat)textViewHeightForText:(NSString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}



@end
