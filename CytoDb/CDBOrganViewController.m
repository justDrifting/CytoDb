//
//  CDBOrganViewController.m
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "CDBOrganViewController.h"
#import "CDBSlideViewController.h"
#import "SlideViewController.h"
#import "Organ.h"
#import "Condition.h"
#import "Slide.h"



//#define dataURLString @"http://localhost/json.php"
#define dataURLString @"http://proqms.info/json.php"

@interface CDBOrganViewController ()


@end

@implementation CDBOrganViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

   // Uncomment to clean up table entry
  //[self removeAllObjects];
    
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource=self;
    self.searchDisplayController.searchResultsDelegate=self;

   
    [self fetchOrgans];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self
                action:@selector(refreshView:)
    forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
   
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrganCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil && tableView != self.tableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    //if search display is active
    if(self.searchDisplayController.active){
        
        Condition *condition= [[self searchFrc] objectAtIndexPath:indexPath];
        cell.textLabel.text= [condition valueForKey:@"conditionName"];
    }
    else{
        Organ *organ= [[self frc] objectAtIndexPath:indexPath];
        cell.textLabel.text = [organ valueForKey:@"organName"];
    }

    
     return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(self.searchDisplayController.active){
        if ([[[self fetchedResultsControllerForTableView:tableView] sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
            return [sectionInfo name];
        } else return nil;
    }else return nil;
}



#pragma mark -
#pragma Critical Search Helper method

//This is a critical helper method for the search function.
//It shows which FRC (Table or Search) is being used by the tableView
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.frc : self.searchFrc;
}


#pragma mark -Refresh table
-(void) refreshView: (UIRefreshControl *)refresh
{
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    //Custom refresh logic
    
    //pull data from URL
    [self retrieveData];
    
    //....After Refresh.....
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
    
}



#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!self.searchDisplayController.active){
        
        UITableViewCell *sender = [self.tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"pushToConditions" sender:sender];
    }
    else{
        UITableViewCell *sender = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"pushToSlides" sender:sender];
    }

}



// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Pass the selected object to the new view controller.
    
  
    if([[segue identifier]isEqualToString:@"pushToConditions"])
    {
        
        // Get the new view controller using [segue destinationViewController].
        CDBSlideViewController *destinationController = (CDBSlideViewController *)segue.destinationViewController;
      
        //get indexPath for the  selected Row
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        
        Organ *organ= [[self frc] objectAtIndexPath:indexPath];
        destinationController.selectedRowName=[organ valueForKey:@"organName"];
        destinationController.managedObjectContext=self.managedObjectContext;
        
    }
    
    if([[segue identifier]isEqualToString:@"pushToSlides"])
    {
        // Get the new view controller using [segue destinationViewController].
        SlideViewController *slideViewController =(SlideViewController *)segue.destinationViewController;
        
        //get indexPath for the  selected Row
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        
        Condition *condition= [[self searchFrc] objectAtIndexPath:indexPath];
        slideViewController.selectedConditionName =[condition valueForKey:@"conditionName"];
        slideViewController.conditionID =[condition objectID];
        slideViewController.managedObjectContext=self.managedObjectContext;
    }
    
}


#pragma mark - CoreData CRUD Methods
#pragma -insertSlide

-(void)inserNewSlide:(NSDictionary *)jsonDictionary
{
 
    //Grab the context
    NSManagedObjectContext *context = [self managedObjectContext ];
    
    //Is the Slide duplicate?
    BOOL duplicateSlide = [self duplicateSlideForSlideName:[jsonDictionary objectForKey:@"slideName"]
                                                ForContext:context];
    
    if(!duplicateSlide){  //If Slide is not duplicate
        
        //CreateSlide
        Slide *slide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide"
                                                 inManagedObjectContext:context];
    
        slide.slideName = [jsonDictionary objectForKey:@"slideName"];
        //slide.slideOrder= [jsonDictionary objectForKey:@"slideOrder"];
        slide.slideDescription=[jsonDictionary objectForKey:@"slideDescription"];
        //slide.slideMag = [jsonDictionary objectForKey:@"slideMag"];
        slide.imageURL= [jsonDictionary objectForKey:@"imageURL"];

        //Fetch or Create the Condition entity
        NSManagedObjectID *conditionID =
        [self fetchOrCreateConditionIDForConditionName:[jsonDictionary objectForKey:@"conditionName"]
                              ConditionDiffertialGroup:[jsonDictionary objectForKey:@"conditiondifferentialGroup"]ConditionDescription:[jsonDictionary objectForKey:@"conditionDescription"]
                                            ForContext:context];
        
        Condition *condition = (Condition *)[context existingObjectWithID:conditionID error:nil];
        
        //Fetch or Create the organ entity
        NSManagedObjectID *organID =
        [self fetchOrCreateOrganIDForOrganName:[jsonDictionary objectForKey:@"organName"]
                                    ForContext:context];
        Organ *organ= (Organ *)[context existingObjectWithID:organID error:nil];
        
        //Update Relations
        [organ addConditionsObject:condition];
        [condition setOrgan:organ];
        [condition addSlidesObject:slide];
        [slide setCondition:condition];
        
        //Download Images
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[jsonDictionary objectForKey:@"imageURL"]]];
        //UIImage *image = [UIImage imageWithData:imageData];
        slide.slideImage = imageData;
        
        
  
        // Save everything
        NSError *error = nil;
        if ([context save:&error]) {
           NSLog(@"The save was successful!");
        } else {
           NSLog(@"The save wasn't successful: %@", [error userInfo]);
        }
     }
    else
    {
        NSLog(@"Duplicate slide");
    }
}


#pragma -fetchOrCreate

-(NSManagedObjectID *)fetchOrCreateOrganIDForOrganName:(NSString *)organName
                                            ForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Organ"inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"organName == %@",organName]];
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if(result.count == 0){
        // NSLog(@"No Duplicate for %@ need to create",organName);
        Organ *organ = [NSEntityDescription insertNewObjectForEntityForName:@"Organ" inManagedObjectContext:context];
        [organ setValue:organName forKeyPath:@"organName"];
        return [organ objectID];
        
    }
    else {
        //NSLog(@"Found Duplicate entry with organ name as %@",organName);
        Organ *organ = [result objectAtIndex:0];
        return [organ objectID];
    }
}


-(NSManagedObjectID *)fetchOrCreateConditionIDForConditionName:(NSString *)conditionName
                                      ConditionDiffertialGroup:(NSString *)conditionDifferentialGroup
                                          ConditionDescription:(NSString *)conditionDescription
                                                    ForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Condition"inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"conditionName == %@",conditionName]];
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if(result.count ==0){
        //NSLog(@"No Duplicate for %@ need to create",conditionName);
        Condition *condition = [NSEntityDescription insertNewObjectForEntityForName:@"Condition" inManagedObjectContext:context];
        [condition setValue:conditionName forKeyPath:@"conditionName"];
        [condition setValue:conditionDifferentialGroup forKeyPath:@"conditionDifferentialGroup"];
        [condition setValue:conditionDescription forKeyPath:@"conditionDescription"];
        return [condition objectID];
        
    }
    else {
        //NSLog(@"Found Duplicate entry with organ name as %@",conditionName);
        Condition *condition = [result objectAtIndex:0];
        return [condition objectID];
    }
}


-(BOOL)duplicateSlideForSlideName:(NSString *)slideName
                       ForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Slide"inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"slideName == %@",slideName]];
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if(result.count == 0){
        NSLog(@"New slide %@ need to create",slideName);
        return NO;
        
    }
    else {
        
        return YES;
    }
}

#pragma mark -fetch Objects
    
-(void)fetchOrgans
{
    //Grab the context
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Organ"
                                              inManagedObjectContext:context];
    [request setEntity:entity];

    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"organName"
                            ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sd, nil];
   [request setSortDescriptors:sortDescriptors];
    
    self.frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request
                                       managedObjectContext:context
                                       sectionNameKeyPath:nil
                                       cacheName:@"organList"];
    NSError *error;
    [self.frc performFetch:&error]; //FetchedResultsController is generated here
    
   
}

#pragma mark - Custom NSURLSession Call


//getter method for the private instance Variable "_setter"
- (NSURLSession *)session {
    if (!_session) {
        // Create Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //Modify Session configuration
        [sessionConfiguration setAllowsCellularAccess:YES];
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
        // Create Session with "self as data delegate
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    
    return _session;
}


-(void)retrieveData
{
    //get URL from string
    NSURL *dataURL = [NSURL URLWithString:dataURLString];
    
    //initiate the download task property
    self.downloadTask = [self.session downloadTaskWithURL:dataURL];
    
    //start download
    [self.downloadTask resume];
    
}

#pragma - protocol methods for NSURLSessionDelegate and NSURLDataDelegate

//Finished Downloading
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
   // dispatch_async(dispatch_get_main_queue(), ^{
     dispatch_async(queue, ^{
    
        NSArray *jsonArray= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        
        for(int i =0; i< [jsonArray count]; i++)
        {
            
            NSDictionary* jsonDict = jsonArray[i];
            //NSLog(@"jsonDict  = %@",jsonDict);
            [self inserNewSlide:jsonDict];
            
                 dispatch_async(dispatch_get_main_queue(), ^{
                    // UI updates always come from the main queue!
                    float progress = ((double)(i)+1.0)/(double)(jsonArray.count);
                    [self.progressDisplay setProgress:progress];
                     if(progress >= 1){
                         [self.progressDisplay setHidden:YES];
                         [self fetchOrgans];
                         [self.tableView reloadData];
                     
                     }
                });
            
        }
        
      


    });
    
   // [session finishTasksAndInvalidate];

}

//Resume Download
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

//Download In process
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressDisplay setProgress:progress];
        // [self.activityIndicator setHidesWhenStopped:YES];
        //[self.activityIndicator startAnimating];
    });
}

- (void)removeAllObjects
{
    
    NSFetchRequest * allOrgans = [[NSFetchRequest alloc]init];
    NSEntityDescription * entityForName = [NSEntityDescription entityForName:@"Organ"inManagedObjectContext:self.managedObjectContext];
    
    [allOrgans setEntity:entityForName];
    [allOrgans setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *organs = [self.managedObjectContext executeFetchRequest:allOrgans error:&error];
    for (NSManagedObject * organ in organs){
        [self.managedObjectContext deleteObject:organ];
    }
    
    
    NSFetchRequest * allConditions = [[NSFetchRequest alloc]init];
    entityForName = [NSEntityDescription entityForName:@"Condition"inManagedObjectContext:self.managedObjectContext];
    
    [allConditions setEntity:entityForName];
    [allConditions setIncludesPropertyValues:NO];
    
    error = nil;
    NSArray *conditions = [self.managedObjectContext executeFetchRequest:allConditions error:&error];
    for (NSManagedObject * condition in conditions){
        [self.managedObjectContext deleteObject:condition];
    }
    
    
    allConditions = [[NSFetchRequest alloc]init];
    entityForName = [NSEntityDescription entityForName:@"Slide"inManagedObjectContext:self.managedObjectContext];
    
    [allConditions setEntity:entityForName];
    [allConditions setIncludesPropertyValues:NO];
    
    error = nil;
    conditions = [self.managedObjectContext executeFetchRequest:allConditions error:&error];
    for (NSManagedObject * condition in conditions){
        [self.managedObjectContext deleteObject:condition];
    }

    
    
    
    // Save everything
   
    if ([self.managedObjectContext save:&error]) {
        NSLog(@"The save was successful!");
    } else {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }

}



//This is the main search engine

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    
    //Grab the context
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Condition"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"organ.organName"
                            ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sd, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    //Remove white space from begining and end of search string
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    
    
        //Create searchTerm From searchText
        NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
        
        NSString *predicateFormat = @"(organ.organName CONTAINS[cd] %@) OR (conditionName CONTAINS[cd] %@)";
        NSPredicate *predicate;
        if ([searchTerms count] == 1) {
            NSString *term = [searchTerms objectAtIndex:0];
            predicate = [NSPredicate predicateWithFormat:predicateFormat, term, term];
        } else {
            NSMutableArray *subPredicates = [NSMutableArray array];
            for (NSString *term in searchTerms) {
                NSPredicate *p = [NSPredicate predicateWithFormat:predicateFormat, term, term];
                [subPredicates addObject:p];
            }
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        }
        
        [request setPredicate:predicate];
        
    self.searchFrc = [[NSFetchedResultsController alloc]
                      initWithFetchRequest:request
                      managedObjectContext:context
                      sectionNameKeyPath:@"organ.organName"
                      cacheName:nil];
    
    NSError *error = nil;
    [self.searchFrc performFetch:&error];
    
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

//This is where the search happens

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:nil];
    
    return YES;
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFrc.delegate = nil;
    self.searchFrc = nil;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:nil];
    return YES;
}


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
}


@end
