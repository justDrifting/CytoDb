//
//  CDBOrganViewController.h
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBOrganViewController : UITableViewController <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {

    NSURLSession * _session;
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic,strong) NSMutableArray * organList;

@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (weak, nonatomic) IBOutlet UIProgressView *progressDisplay;

@property (nonatomic,strong) NSFetchedResultsController *frc;       //Fetch Results Controller For TableViewController
@property (strong,nonatomic) NSFetchedResultsController *searchFrc; //Fetch Results Controller For SearchDisplayController

- (IBAction)showAll:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *showAllButton;


@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@property BOOL loading;

@end
