//
//  CDBOrganViewController.m
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "CDBOrganViewController.h"
#import "CDBSlideViewController.h"
#import "CDBAppDelegate.h"
#import "SlideViewController.h"
#import "Organ.h"
#import "Condition.h"
#import "Slide.h"
#import "Features.h"
#import "UIImageView+WebCache.h"
#import "Reachability.h"



//#define dataURLString @"http://localhost/json.php"
#define dataURLString @"http://proqms.info/json.php"
#define zDataURLString @"http://proqms.info/json04.php"
//#define zDataURLString @"http://localhost/json04_local.php"

@interface CDBOrganViewController ()

@property (nonatomic) NSURLSession *backgroundSession;
@property (nonatomic) NSURLSessionDownloadTask *backgroundDownloadTask;

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

    

    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource=self;
    self.searchDisplayController.searchResultsDelegate=self;
    
    
    //If core data is empty start downloading database
    if(![self coreDataHasEntriesForEntityName:@"Slide"])
    {
        [self.showAllButton setEnabled:NO];
        [self retrieveData];
        
        NSLog(@"Nothing in Core Data Downloading Database");
      UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 100.0, 120.0, 40.0)];
        // UILabel *loadingLabel = [UILabel alloc];
        [loadingLabel setBackgroundColor:[UIColor darkGrayColor]];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [loadingLabel setCenter:self.view.center];
        [self.view addSubview:loadingLabel];
        loadingLabel.tag = 888;
        loadingLabel.text = @"Loading";
    }
    

   
    [self fetchOrgans];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial01"]){
        [self displayTutorial];
       // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial01"];
       // [[NSUserDefaults standardUserDefaults] synchronize];
    }


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


#pragma  -Refresh table
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
    
    
    if([[segue identifier]isEqualToString:@"showAllConditions"])
    {
        // Get the new view controller using [segue destinationViewController].
        CDBSlideViewController *destinationController = (CDBSlideViewController *)segue.destinationViewController;
        
        destinationController.selectedRowName=@"All";
        destinationController.managedObjectContext=self.managedObjectContext;

    }

}


#pragma mark - CoreData CRUD Methods
#pragma -insertSlide

-(void)insertSlide:(NSArray *)sourceArray
{
    
    //Grab the context
    NSManagedObjectContext *context = [self managedObjectContext ];
    
  
    
    [self deleteManagedObjectForEntityName:@"Slide" InContext:context];
    [self deleteManagedObjectForEntityName:@"Features" InContext:context];
    [self deleteManagedObjectForEntityName:@"Condition" InContext:context];
    [self deleteManagedObjectForEntityName:@"Organ" InContext:context];
    
    
    
    for (NSDictionary *sourceDict in sourceArray) {
        
        
        Organ *organ = [NSEntityDescription insertNewObjectForEntityForName:@"Organ"
                                                     inManagedObjectContext:context];
        
        [organ setValue:[sourceDict objectForKey:@"sourceName"] forKey:@"organName"];
        
        organ.organName = [sourceDict objectForKey:@"sourceName"];
        

        NSArray *conditionArray = [[NSArray alloc] initWithArray:[sourceDict objectForKey:@"dxs"]];
    
        for (NSDictionary *dxDict in conditionArray ) {
            //NSLog(@"Dx Name is %@",[dxDict objectForKey:@"dxName"]);
        
            Condition *condition = [NSEntityDescription insertNewObjectForEntityForName:@"Condition"
                                                         inManagedObjectContext:context];
            
            [condition setValue:[dxDict objectForKey:@"dxName"] forKey:@"conditionName"];
            [condition setValue:[dxDict objectForKey:@"dxDescription"] forKey:@"conditionDescription"];
            [condition setOrgan:organ];
            
            NSArray *slideArray = [[NSArray alloc] initWithArray:[dxDict objectForKey:@"slides"]];
           
            for (NSDictionary *slideDict in slideArray) {
                //NSLog(@"Slide url is %@",[slideDict objectForKey:@"imageURL"]);
                Slide *slide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide"
                                                                     inManagedObjectContext:context];
                
                [slide setValue:[slideDict objectForKey:@"slideName"] forKey:@"slideName"];
                [slide setValue:[slideDict objectForKey:@"slideDescription"] forKey:@"slideDescription"];
                [slide setValue:[slideDict objectForKey:@"imageURL"] forKey:@"imageURL"];
                
                //CreatefilePathFrom SlideName getting rid of " : " with "_"
                NSString *thumbnailPath = slide.slideName;
                
                thumbnailPath =[thumbnailPath stringByReplacingOccurrencesOfString:@" : " withString:@"_"];
                thumbnailPath =[thumbnailPath stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                thumbnailPath =[thumbnailPath stringByAppendingString:@".jpg"];
                slide.slideImagePath = thumbnailPath;
                
                
            /*  NSBundle *mainBundle = [NSBundle mainBundle];
                NSString *myFile = [mainBundle pathForResource: @"placeholder" ofType: @"png"];
              
                NSLog(@"my file %@", myFile);
            */
               
                
                [slide setCondition:condition];
              
            }
           
            if([[dxDict objectForKey:@"features"] isKindOfClass:[NSNull class]]){
                
                //Create features with just the dxDescription:
                Features *feature = [NSEntityDescription insertNewObjectForEntityForName:@"Features"
                                                                  inManagedObjectContext:context];
                //Initialize this with the condition description as dummy:
                [feature setValue:@"Description" forKey:@"featureName"];
                [feature setValue:condition.conditionDescription forKey:@"featureDescription"];
                
                NSNumber *order = [NSNumber numberWithInteger:1];
                [feature setValue:order forKey:@"featureOrder"];
                //This links it to the condition
                [feature setCondition:condition];
               
            }
            else{
            
                
               NSArray *featureArray
                = [[NSArray alloc] initWithArray:[dxDict objectForKey:@"features"]];
                
               
                for (NSDictionary *featureDict in featureArray) {
                    
                    Features *feature = [NSEntityDescription insertNewObjectForEntityForName:@"Features"
                                                                      inManagedObjectContext:context];
                    
                    
                    [feature setValue:[featureDict objectForKey:@"featureName"] forKey:@"featureName"];
                    [feature setValue:[featureDict objectForKey:@"featureDescription"] forKey:@"featureDescription"];
                    
                    //Convert the feature order json string to number ** PITA **
                    NSString *numberString = [featureDict objectForKey:@"featureOrder"];
                    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber * featureOrder = [numberFormatter numberFromString:numberString];
                    [feature setValue:featureOrder forKey:@"featureOrder"];
                    
                    
                    //This links it to the condition
                    [feature setCondition:condition];
                    
    
                  
                }
                
            }//endElse

        }

    }

    // Save everything
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"The save was successful!");
    } else {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }
    
    
    
}



//This is unused

-(void)insertNewSlide:(NSDictionary *)jsonDictionary
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
        [self fetchOrCreateConditionIDForConditionName:[jsonDictionary objectForKey:@"dxName"]
                              ConditionDiffertialGroup:[jsonDictionary objectForKey:@"conditiondifferentialGroup"]ConditionDescription:[jsonDictionary objectForKey:@"dxDescription"]
                                            ForContext:context];
        
        Condition *condition = (Condition *)[context existingObjectWithID:conditionID error:nil];
        
        //Fetch or Create the organ entity
        NSManagedObjectID *organID =
        [self fetchOrCreateOrganIDForOrganName:[jsonDictionary objectForKey:@"sourceName"]
                                    ForContext:context];
        Organ *organ= (Organ *)[context existingObjectWithID:organID error:nil];
        
        //Update Relations
        [organ addConditionsObject:condition];
        [condition setOrgan:organ];
        [condition addSlidesObject:slide];
        [slide setCondition:condition];
        
        //Download Images
      //  NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[jsonDictionary objectForKey:@"imageURL"]]];
        //UIImage *image = [UIImage imageWithData:imageData];
        //slide.slideImage = imageData;
        
        
  
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

//Fetch or create unused

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
    
    [self.showAllButton setEnabled:[[self.frc fetchedObjects] count]];
    
       // NSLog(@"Frc Object Count  %lu",[[self.frc fetchedObjects] count]);
    
   
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


//getter method for the private instance Variable "_setter"
- (NSURLSession *)backgroundSession {
    
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
	static NSURLSession *backgroundSession = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
		backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return backgroundSession;
}



-(void)retrieveData
{
    //Check if background session exists, if yes then do nothing
     if (self.backgroundDownloadTask)
     {   NSLog(@" DOWNLOAD TASK EXISTS");
        return;
    }
    
    if(![self internetIsActive]){
        
            //Alert User of no internet
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
                                                            message:@"Internet required for database download"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            NSLog(@"Showing alert");
    
        return;
    }
    /*
     Create a new download task using the URL session. Tasks start in the “suspended” state; to start a task you need to explicitly call -resume on a task after creating it.
     */
    [self.progressDisplay setHidden:NO];
    [self.progressDisplay setProgress:0.0f];
    
    NSURL *downloadURL = [NSURL URLWithString:zDataURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
	self.backgroundDownloadTask = [self.session downloadTaskWithRequest:request];
    [self.backgroundDownloadTask resume];
    
   
}

//This is not being used
-(void)retrieveThumbnailFromURL:(NSURL *)thumbnailURL
{
    
    self.backgroundDownloadTask = [self.backgroundSession downloadTaskWithURL:thumbnailURL];
    
    //start download
    [self.backgroundDownloadTask resume];
    
}



#pragma - protocol methods for NSURLSessionDelegate and NSURLDataDelegate

//Finished Downloading
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  
    
   if(downloadTask == self.backgroundDownloadTask)
    {
    
        NSData *data = [NSData dataWithContentsOfURL:location];
        
        //Send the parsing task to GCD
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(queue, ^{
            
            NSArray *jsonArray= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"jsonArray  = %@",jsonArray);
            
            //If array is empty do nothing
            if(jsonArray == nil || jsonArray.count == 0){
                
                NSLog(@"Downloaded Empty Array");
                //[self.progressDisplay setHidden:YES];
                //[self.tableView reloadData];

            }
            else {
                
               // [self insertSlide:jsonArray];
                //[self.progressDisplay setHidden:YES];
               //[self fetchOrgans];
               // [self.tableView reloadData];
                //[self downloadThumbnailsForSlides];
                
                
                //Main Thread for progress bar update
                dispatch_async(dispatch_get_main_queue(), ^{
                    // UI updates always come from the main queue!
                    // float progress = ((double)(i)+1.0)/(double)(jsonArray.count);
                    //[self.progressDisplay setProgress:progress];
                    //if(progress >= 1){
                    //[self.progressDisplay setHidden:YES];
                    
                    NSLog(@"Going to the main thread to insert Slides");
                    [self insertSlide:jsonArray];
                    [self fetchOrgans];
                    UIView *loadingLable = [self.view viewWithTag:888];
                    [loadingLable setHidden:YES];
                    [self.tableView reloadData];
               /*
                    if(!self.loading){
                    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    dispatch_async(queue2, ^{
                        self.loading = YES;
                        
                        [self downloadThumbnailsForSlides];
                    });
                    }
                */

                });
                
            }

        });
  
    }
}
                       


//Resume Download
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {

    
    
}

//Download In process
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
   /*
    if(downloadTask == self.downloadTask){
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressDisplay setProgress:progress];
        // [self.activityIndicator setHidesWhenStopped:YES];
        //[self.activityIndicator startAnimating];
    });
        
    }
    */
    //Background Task
    if(downloadTask == self.backgroundDownloadTask){
    
     /*
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: progress: %lf", progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressDisplay.progress = progress;
        });
      */
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
    
    if (error == nil)
    {
        NSLog(@"Task: %@ completed successfully", task);
    }
    else
    {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
        
    }
	/*
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.progressDisplay.progress = progress;
	});
    */
    self.backgroundDownloadTask = nil;
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    CDBAppDelegate *appDelegate = (CDBAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");

}


#pragma download Thumbnails
-(void)downloadThumbnailsForSlides
{
   
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Slide"inManagedObjectContext:self.managedObjectContext]];
    NSArray *slideArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    NSUInteger index = 0;
    [self.progressDisplay setProgress:0.0f];
    
    for(Slide *slide in slideArray){
        
        
        //convert imageURL to thumbURL
        NSString *imageURL = slide.imageURL;
        imageURL = [imageURL stringByReplacingOccurrencesOfString:@"Images" withString:@"thumbnails"];
        imageURL = [imageURL stringByReplacingOccurrencesOfString:@"png" withString:@"jpg"];
        
        NSURL *originURL =[NSURL URLWithString:imageURL];
        
        index++;
        float progress = (double)(index)/(double)(slideArray.count);
        //Main Thread for progress bar update
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressDisplay.progress = progress;
          //  NSLog(@"Slide download %f",progress);
            
        });
        

        
        
        //background download the thumbnail and store it to the thumb file path
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:originURL
                         options:SDWebImageHighPriority
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                        {
                            
                            if (image) {
                 
                                NSData *thumbData =[NSData dataWithData:UIImageJPEGRepresentation(image,1.0f)];
                                //Save the file to slideImagePath
                                NSError *error =nil;
                                NSString *filepath =[self documentsPathForFileName:slide.slideImagePath];
                                [thumbData writeToFile:filepath options:NSDataWritingAtomic error:&error];
                 
                                // NSLog(@"Write returned error: %@", [error localizedDescription]);
                            }
             
                            if(slide == slideArray.lastObject) {
                                NSLog(@"last slide downloaded");
                                self.loading =NO;
                                [self.progressDisplay setHidden:YES];
                            }
             
                        }];
        
        
    }
    
    
}


#pragma -Delete Objects By Name

-(void)deleteManagedObjectForEntityName:(NSString *)entityName InContext:(NSManagedObjectContext *)context
{
    NSFetchRequest * allEntity = [[NSFetchRequest alloc]init];
    NSEntityDescription * entityForName = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [allEntity setEntity:entityForName];
    [allEntity setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *entityArray = [self.managedObjectContext executeFetchRequest:allEntity error:&error];
  
    for (NSManagedObject * entity in entityArray){
        [self.managedObjectContext deleteObject:entity];
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


- (IBAction)showAll:(id)sender {
}
                             

- (NSManagedObject*)managedObjectFromStructure:(NSDictionary*)structureDictionary withManagedObjectContext:(NSManagedObjectContext*)moc
    {
        NSString *objectName = [structureDictionary objectForKey:@"ManagedObjectName"];
        NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:moc];
        [managedObject setValuesForKeysWithDictionary:structureDictionary];
        
  /*
        for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) {
            NSRelationshipDescription *description = [relationshipName objectForKey:relationshipName];
            if (![description isToMany]) {
                NSDictionary *childStructureDictionary = [structureDictionary objectForKey:relationshipName];
                NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
                
             //   [managedObject  setObject:childObject forKey:relationshipName];
                continue;
            }
            NSMutableSet *relationshipSet = [managedObject mutableSetValueForKey:relationshipName];
            NSArray *relationshipArray = [structureDictionary objectForKey:relationshipName];
            for (NSDictionary *childStructureDictionary in relationshipArray) {
                NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
                [relationshipSet addObject:childObject];
            }
        }*/
        return managedObject;
    }
                             
- (NSArray*)managedObjectsFromJSONStructure:(NSArray*)structureArray withManagedObjectContext:(NSManagedObjectContext*)moc
{
        NSMutableArray *objectArray = [[NSMutableArray alloc] init];
        for (NSDictionary *structureDictionary in structureArray) {
            [objectArray addObject:[self managedObjectFromStructure:structureDictionary withManagedObjectContext:moc]];
        }
        return objectArray;
}
                             
#pragma -mark
#pragma -is Core Data Empty

- (BOOL)coreDataHasEntriesForEntityName:(NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Fetch error: %@", error);
        abort();
    }
    if ([results count] == 0) {
        return NO;
    }
    return YES;
}

#pragma -file path generator

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}





-(void)displayTutorial
{
    UIViewController *userguideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTutorialViewController"];
    [userguideViewController.view setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5f]];
    //Add Tapgesture to the userguide
    UITapGestureRecognizer  *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dismissUserGuide)];
    
    singleTap.numberOfTapsRequired = 1;
    
   /* [userguideViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                      self.view.frame.size.height)];
    
    userguideViewController.view.center=self.view.center;
   
    userguideViewController.view.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    */
    
    [self addChildViewController:userguideViewController];
    [self.view addSubview:userguideViewController.view];
    [userguideViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
     userguideViewController.view.frame = self.view.bounds;
     userguideViewController.view.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
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

                         
                     }
                     completion:^(BOOL finished){
                         
                         [taggedView removeFromSuperview];
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial01"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                     }];
    
}



-(BOOL)shouldAutorotate
{
    
    
    //if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial01"])
    //    return NO;
    //else
    NSLog(@"Attempting to autorotate");
    return NO;
}

#pragma -Internet Check

-(BOOL)internetIsActive
{

    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        return NO;
    } else {
        NSLog(@"There IS internet connection");
        
        return YES;
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0 && ![self coreDataHasEntriesForEntityName:@"Slide"]) {
        // do something here..
        NSLog(@"No Internet and empty core dat : app is unusable");
        [self retrieveData];
    }
}

@end
