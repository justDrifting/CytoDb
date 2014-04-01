//
//  CDBSlideViewController.h
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CDBSlideViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate>


@property (nonatomic) NSString *selectedRowName;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *conditionArray;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (strong,nonatomic) NSFetchedResultsController *searchFrc;

@property (nonatomic) BOOL searchIsActive;

@end
