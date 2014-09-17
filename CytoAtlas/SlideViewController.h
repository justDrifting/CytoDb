//
//  SlideViewController.h
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"
#import "UIImageView+WebCache.h"


@interface SlideViewController : UIViewController < UIPageViewControllerDataSource,UIPageViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,UISplitViewControllerDelegate>


@property (strong,nonatomic)UIPageViewController *pageViewController;
@property (strong,nonatomic)NSMutableArray *pageTitles;
@property (strong,nonatomic)NSMutableArray *pageThumbURLs;
@property (strong,nonatomic)NSMutableArray *pageImageURLs;
@property (strong,nonatomic)NSMutableArray *pageTexts;
@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic) NSString *selectedConditionName;
@property (nonatomic,strong) NSManagedObjectID          *conditionID;

@property (nonatomic,weak,readonly) NSArray             *slideArray; //Container for the slides that will be presented
//Need to change this to weak
@property (nonatomic,strong,readonly) NSArray             *featureArray; //Container for the slides that will be presented

@property (strong, nonatomic) IBOutlet UIPageControl      *pageControl;

@property (weak, nonatomic) IBOutlet UIButton             *detailsViewButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint   *pageControlXPosition;

@property (nonatomic, strong) IBOutlet UISegmentedControl * segmentedControl;
@property (nonatomic, strong) UIViewController            * activeViewController;
@property (nonatomic, strong) NSArray                     * segmentedViewControllers;


@property BOOL showingSubview;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;

@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property CGFloat heightDelta;
@property CGFloat padding;
@property CGFloat scaledImageWidth;
@property CGFloat scaledImageHeight;



//- (void)configureView;

//ScrollView for Features



@end
