//
//  SlideViewController.h
//  CytoDb
//
//  Created by Bobby on 3/11/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"

@interface SlideViewController : UIViewController < UIPageViewControllerDataSource,UIPageViewControllerDelegate>


@property (strong,nonatomic)UIPageViewController *pageViewController;
@property (strong,nonatomic)NSMutableArray *pageTitles;
@property (strong,nonatomic)NSMutableArray *pageImages;
@property (strong,nonatomic)NSMutableArray *pageTexts;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSString *selectedConditionName;

@property (nonatomic,weak,readonly) NSArray *slideArray; //Container for the slides that will be presented

@end
