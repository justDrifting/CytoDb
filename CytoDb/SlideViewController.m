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
    //The selected condition is now used in setting the title and fetchSlides
    [self setTitle: self.selectedConditionName];
    [self fetchSlides]; //This populated the self.slideArray
    
    //This is actually slide Name that appears below the image
    _pageTitles = [[NSMutableArray alloc] init];
    _pageImages = [[NSMutableArray alloc] init];
    _pageTexts =  [[NSMutableArray alloc] init];
    
    for(Slide *slide in self.slideArray){
      
      [_pageTitles addObject:slide.slideName];
      [_pageImages addObject:slide.slideImage];
      //Add any other attribute that need to go into the page view controller
        
     }
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewController"];
    
    //SlideViewController (self) Will Provide the necessary data for the pageViewController
    self.pageViewController.dataSource = self;
    
    //Set the first page in the pageViewController using the method "vieControlleratIndex"
    ImageViewController *startingViewController = [self viewControllerAtIndex:0];
    
    // The pages need to be sent as an array even if it is only one page, so we pass it into an array
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Change the size of page view controller **Not Sure why this was used
   // self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];


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
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController*) viewController).pageIndex;
    
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
    imageViewController.descriptionText = self.pageTitles[index];
    imageViewController.pageIndex = index;
    
    return imageViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.slideArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


#pragma -Get the slides based on the selected Condition

-(void)fetchSlides
{
    //Grab the context
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Slide"
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"ANY condition.conditionName == %@", self.selectedConditionName];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    self.slideArray=fetchedObjects; //This array will be used to populate the pages
    
}



@end
