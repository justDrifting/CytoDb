//
//  CDBAppDelegate.h
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBAppDelegate : UIResponder <UIApplicationDelegate, NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate>

{
    
    NSURLSession * _session;
    
    UIAlertView *statusAlert;
    
    
}


@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundSessionCompletionHandler)();


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, copy) void (^completionHandler)(UIBackgroundFetchResult fetchResult);
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic,strong) NSFetchedResultsController *frc;       //Fetch Results Controller For TableViewController

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
