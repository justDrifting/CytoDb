//
//  CDBFeatureTableViewController.h
//  CytoAtlas
//
//  Created by Bobby on 9/8/14.
//  Copyright (c) 2014 proqms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBFeatureTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSManagedObjectID *conditionID;

@property (nonatomic,strong,readonly) NSArray *featureArray; //Container for the slides that will be presented


@end
