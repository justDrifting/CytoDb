//
//  CDBOrganViewController.h
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDBOrganViewController : UITableViewController <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> {

    NSURLSession * _session;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray * organList;

@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@end
