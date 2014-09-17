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
#import "Features.h"
#import "CDBFeatureTableViewController.h"

#define IS_PAD  (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

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
    [self.navigationItem setLeftBarButtonItem:self.rootPopoverButtonItem animated:YES];
    
    
    // [self configureView];
	// Do any additional setup after loading the view.
    
    //calculate height delta for different aspect ratio screens
    [self getScaledDimensions:0.3f];
    
    
    
    
    //Prevent View from Going under navBar
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
  if(self.conditionID !=nil){
    
      //selectedCondition name was delegated in the segue in the slideViewController
      self.pageViewController.delegate = self;

    
    //The selected condition is now used in setting the title and fetchSlides
    Condition *condition = (Condition *)[self.managedObjectContext existingObjectWithID:self.conditionID error:nil];
   
    if (IS_PAD) {
 //   [self.navigationController setTitle:condition.conditionName];
  [self.navigationItem setTitle:condition.conditionName];
        
    }
    else
        [self setTitle: condition.conditionName];
      
  /*  Uncomment for custom nav bar title
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont boldSystemFontOfSize:16.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:condition.conditionName];
    self.navigationItem.titleView = label;
 */
      
    [self fetchSlides]; //This populated the self.slideArray
    [self fetchFeatures]; //This populated the self.featureArray
    
    //Make SegmentedControl Visible
    [self.segmentedControl setHidden:NO];

    _pageTitles = [[NSMutableArray alloc] init];
    _pageThumbURLs = [[NSMutableArray alloc] init];
    _pageImageURLs = [[NSMutableArray alloc] init];
    _pageTexts =  [[NSMutableArray alloc] init];
    
    for(Slide *slide in self.slideArray){
      
      [_pageTitles addObject:slide.slideName];
      [_pageThumbURLs addObject:slide.slideImagePath];
      [_pageTexts  addObject:slide.slideDescription];
      [_pageImageURLs addObject:slide.imageURL];
      //Add any other attribute that need to go into the page view controller
     }
    
    
    //Set nav bar color to transparent
   // self.navigationController.navigationBar.translucent = YES;
    
    
   // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
   
    //selectedCondition name was delegated in the segue in the slideViewController
    self.pageViewController.delegate = self;

    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    //Set the first page in the pageViewController using the method "viewControlleratIndex"
    ImageViewController *startingViewController = [self viewControllerAtIndex:0];
    
    // The pages need to be sent as an array even if it is only one page, so we pass it into an array
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
      
    //SlideViewController (self) Will Provide the necessary data for the pageViewController
    self.pageViewController.dataSource = self;
    self.pageViewController.view.frame = self.view.bounds;
      
  //**  [self addChildViewController:self.pageViewController];
    
    CDBFeatureTableViewController *featureTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"featuresViewController"];
    featureTableViewController.managedObjectContext=self.managedObjectContext;
    featureTableViewController.conditionID=self.conditionID;
   
  
  //*   [self.view insertSubview:self.pageViewController.view atIndex:0];
  //*   [self.pageViewController didMoveToParentViewController:self];
    
    self.segmentedViewControllers = [NSArray arrayWithObjects:self.pageViewController, featureTableViewController,nil];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self.segmentedControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    
    [self didChangeSegmentControl:self.segmentedControl];
      
      
      //Custom pageControl
      self.pageControl.numberOfPages = self.pageTitles.count;
      self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
      self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
      [self.view addSubview:_pageControl.viewForBaselineLayout];
      
      if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
          
         // self.pageControlPosition.constant = self.scaledImageHeight - 10.0f;
      }

      
   }
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [self.detailsViewButton setHidden:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
    
    
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
    
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat fractionOfView = 0.20f;
   
    UITableView *featureTable = [[UITableView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, 0)];
    [featureTable setDataSource:self];
    [featureTable setDelegate:self];
    [featureTable setBackgroundColor:[UIColor clearColor]];
    //remove extra section lines
    [featureTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    
    
    
    // [subview setTextContainerInset:UIEdgeInsetsMake(40, 20,40,20)];
    //bg tool bar starting position
    UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, 0)];
    bgToolbar.barStyle = UIBarStyleDefault;
    
    //Custom pulldownbutton
    UIView *pulldownButton = [[UIView alloc]initWithFrame:CGRectMake(140, screenHeight, 40, 6)];
    [pulldownButton.layer setCornerRadius:3.0f];
    [pulldownButton setBackgroundColor:[UIColor grayColor]];
    
    //[subview.superview insertSubview:bgToolbar belowSubview:subview];
    
    [bgToolbar setShadowImage:nil forToolbarPosition:UIBarPositionTop];
    [self.view addSubview:bgToolbar];
    //[self.view addSubview:subview];
    [self.view addSubview:featureTable];
    [self.view addSubview:pulldownButton];
    pulldownButton.tag=9;
    //subview.tag=99;
    featureTable.tag =99;
    bgToolbar.tag=999;
    
    
    
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         pulldownButton.frame = CGRectMake(screenWidth*0.5-20, screenHeight*fractionOfView +10, 40, 6);
                         bgToolbar.frame= CGRectMake(0, screenHeight*fractionOfView, screenWidth, screenHeight*(1.0-fractionOfView) );
                         featureTable.frame =CGRectMake(0, screenHeight*fractionOfView +20.0, screenWidth, screenHeight*(1.0-fractionOfView)-40);
                     }
                     completion:^(BOOL finished){
                         
                         UITapGestureRecognizer *tapToClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBottomToolBar)];
                         tapToClose.numberOfTapsRequired = 1;
                         
                         UISwipeGestureRecognizer *swipedown=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideBottomToolBar)];
                         
                         swipedown.direction=UISwipeGestureRecognizerDirectionDown;
                         
                         NSArray *gestures = [NSArray arrayWithObjects:tapToClose,swipedown, nil];
                         
                         [bgToolbar setGestureRecognizers:gestures];
                         [featureTable addGestureRecognizer:tapToClose];
                         [pulldownButton setGestureRecognizers:gestures];
                         
                         
                     }];
    
    self.showingSubview = YES;
    
    
    
}



-(UITableView *)featureTable
{
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
   // CGFloat fractionOfView = 0.20f;
    
    UITableView *featureTable = [[UITableView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, 0)];
    [featureTable setDataSource:self];
    [featureTable setDelegate:self];
    //[featureTable setBackgroundColor:[UIColor clearColor]];
    //remove extra section lines
    [featureTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
   
    return featureTable;
   
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
    
    
    imageViewController.imageURL = self.pageImageURLs[index];
    imageViewController.descriptionText = self.pageTexts[index];
    imageViewController.pageIndex = index;
    imageViewController.thumbURL = self.pageThumbURLs[index];
    imageViewController.heightDelta = self.heightDelta;
    imageViewController.screenWidth = self.screenWidth;
    imageViewController.screenHeight = self.screenHeight;
    imageViewController.padding = self.padding;
    imageViewController.scaledImageHeight = self.scaledImageHeight;
    imageViewController.scaledImageWidth = self.scaledImageWidth;
    
    return imageViewController;
}


//These are used for displaying the pageControl if commented out the pageControl wont Show
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

    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"slideName"
                                                                 ascending:YES];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    _slideArray=fetchedObjects; //This array will be used to populate the pages
    
}

-(void)fetchFeatures
{
    //Grab the context
    
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features"
                                              inManagedObjectContext:context];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"ANY condition == %@", self.conditionID];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"featureOrder"
                                                                     ascending:YES];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];


    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    _featureArray =fetchedObjects; //This array will be used to populate the pages
    
    
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

//UITABLEVIEW PROTOCOL METHODS
#pragma -mark
#pragma -Table View delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    
    NSInteger count = _featureArray.count;
    
    return count;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    Features *feature = [_featureArray objectAtIndex:section];
      return feature.featureName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
   
    
    cell.backgroundColor=[UIColor clearColor];
    Features *feature = [_featureArray objectAtIndex:indexPath.section];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.lineBreakMode= NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text = feature.featureDescription;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Features *feature = [_featureArray objectAtIndex:indexPath.section];
    NSString *cellText =feature.featureDescription;
    UIFont *cellFont = [UIFont systemFontOfSize:15.0f];
    
  
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:cellText
     attributes:@
     {
     NSFontAttributeName: cellFont
     }];
   
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height + 20;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //  view.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95f];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14.0f]];

}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    NSLog(@"In Rotation Delegate");
   
   /*
    // [[self navigationController] setNavigationBarHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) animated:YES];
    [self.detailsViewButton setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
   // [self autoRotateView:self.imageScrollView toInterfaceOrientation:toInterfaceOrientation];
    UIView *taggedButton = [self.view viewWithTag:9];
    UIView *taggedView = [self.view viewWithTag:99];
    UIView *taggedToolbar = [self.view viewWithTag:999];
    if(self.showingSubview){
    
        [taggedButton setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
        [taggedView setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
        [taggedToolbar setHidden:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    }

    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        //self.pageControlXPosition.constant = 122.0f;
        
        CGRect screenRect = [[UIScreen mainScreen]bounds];
        CGFloat screenHeight = screenRect.size.height;
        self.pageControlXPosition.constant = screenHeight - 446.0f;
        
    }
    else {
        self.pageControlXPosition.constant = -8.0f;
    }
    
  */
}



-(void)displayTutorial
{
    UIViewController *userguideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"slideTutorialViewController"];
    [userguideViewController.view setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5f]];
   //Add Tapgesture to the userguide
    UITapGestureRecognizer  *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dismissUserGuide)];
    
    
    singleTap.numberOfTapsRequired = 1;
    
    [self.view addSubview:userguideViewController.view];
    [userguideViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    userguideViewController.view.tag=9999;
    //[userguideViewController  didMoveToParentViewController:self];
    [userguideViewController.view addGestureRecognizer:singleTap];
    
}

-(void)dismissUserGuide
{
     UIView *taggedView = [self.view viewWithTag:9999];
    [UIView animateWithDuration:0.8f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                       
                         taggedView.alpha = 0.0f;
                   // taggedView.frame = CGRectMake(10, 531, 300, 0);// its final location
                       
                     }
                     completion:^(BOOL finished){
                        
                         [taggedView removeFromSuperview];
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial02"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                        
                     }];
    
}



#pragma mark- SplitViewController Delegate Methods

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Master";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.rootPopoverButtonItem = barButtonItem;
    self.masterPopoverController = pc;

}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
 
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.rootPopoverButtonItem = nil;
    self.masterPopoverController = nil;
 
}



#pragma mark -
#pragma mark Segment control

- (void)didChangeSegmentControl:(UISegmentedControl *)control {
    
    
    UIView *oldView = self.activeViewController.view;
    //NSLog(@"Showing view %@", [oldView class]);
    self.activeViewController = [self.segmentedViewControllers objectAtIndex:control.selectedSegmentIndex];
    UIView *currentView = self.activeViewController.view;
    
    [self addChildViewController:self.activeViewController];
    [self.view insertSubview:self.activeViewController.view atIndex:0];
    
    
    if([self.activeViewController isKindOfClass:[CDBFeatureTableViewController class]])
    {
        NSLog(@"Showing FeatureTableViewController");
        currentView.backgroundColor = [UIColor clearColor];
        [self.view sendSubviewToBack:oldView];
        UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:currentView.frame];
        bgToolbar.tag=338;
        bgToolbar.barStyle = UIBarStyleDefault;
        [currentView.superview insertSubview:bgToolbar belowSubview:currentView];
        
    }
    else
    {
        [oldView removeFromSuperview];
        UIView *taggedToolbar = [self.view viewWithTag:338];
        [taggedToolbar removeFromSuperview];
       // [self.view ]
    }
    
    

    [self.activeViewController didMoveToParentViewController:self];
   
}


#pragma -Calculate height delta in moving from a high aspect ratio screen to low AR screen

//Returns 0 if the screen ratio is 360:568 and 88 for 360:480 screen
//adj factor of 1 is ideal but makes the image too small so we use 0.3
-(void)getScaledDimensions:(CGFloat) adjFactor
{
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    self.screenWidth = fmin(screenRect.size.width,screenRect.size.height);
    self.screenHeight = fmax(screenRect.size.width,screenRect.size.height);
    self.padding = 10.0f*ceil(self.screenWidth*0.003f);
    
    
    //paddAdj is the height lost in a 320:480 screen from 320:568 screen
    // Thai is 568-480 = 88
    //This is important because the base calculation was using iphone 5 320:568 screen
    //Now since we lost 88 px  in height we need to reduce width by 88*300/360 = 88*0.833
    //Therefore padding will increase by 88 * 0.833/2 = 88 * 0.4167 = 37
    //37 is too large, so we only use 40% of the adjustment so 0.4167*0.3 = 11
    //Final adding is 10+11 = 21
    
    self.heightDelta = ceil((self.screenWidth-2.0f*self.padding)*1.892f) - self.screenHeight;
    
    CGFloat adjPadding = self.padding + ceil(self.heightDelta*0.4167*adjFactor) ;
    self.scaledImageWidth = self.screenWidth - adjPadding*2.0;
    self.scaledImageHeight= ceil(self.scaledImageWidth*1.20);
    
    //NSLog(@"H:%4.0f  W: %4.0f",self.screenHeight,self.screenWidth );
    
}


@end
