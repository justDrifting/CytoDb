//
//  CDBSlideViewController.m
//  CytoDb
//
//  Created by Bobby on 3/10/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "CDBSlideViewController.h"
#import "SlideViewController.h"
#import "Organ.h"
#import "Condition.h"
#import "Slide.h"
#import "Features.h"
#import <QuartzCore/QuartzCore.h>
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@interface CDBSlideViewController ()



@end

@implementation CDBSlideViewController



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
    
    
    //self.delegate =

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle: [self selectedRowName]];
 
    [self fetchConditions];    
    
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

    // Return the number of rows in the section.
    
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
 
    
    static NSString *CellIdentifier = @"ConditionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil && tableView != self.tableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    }

    Condition *condition= [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    cell.textLabel.text= [condition valueForKey:@"conditionName"];
    cell.textLabel.font= [UIFont boldSystemFontOfSize:14.0];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping; // Pre-iOS6 use UILineBreakModeWordWrap
    cell.textLabel.numberOfLines = 2;  // 0 means no max.
    
    return cell;
    
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
   
    if ([[[self fetchedResultsControllerForTableView:tableView] sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
        return [sectionInfo name];
    } else return nil;
    
}

#pragma mark -
#pragma mark Helper Method For SearchBar Implementation
//This is a critical helper method for the search function.
//It shows which FRC (Table or Search) is being used by the tableView
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.frc : self.searchFrc;
}





-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        
        UITableViewCell *sender = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"pushToImage" sender:sender];
    }
    else{
       
        UITableViewCell *sender = [self.tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"pushToImage" sender:sender];
        
    }



}
 


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier]isEqualToString:@"pushToImage"]){
       
        if (IS_IPAD) {
            //For iPad
            NSLog(@"we are in ipad");
            UISplitViewController *splitViewController = (UISplitViewController *)self.view.window.rootViewController;
            UINavigationController *currentNavigationController = [splitViewController.viewControllers lastObject];
            UINavigationController *navigationController = [segue destinationViewController];
            
            SlideViewController *slideViewController=(SlideViewController *)[navigationController topViewController];
            
            SlideViewController *currentSlideViewController =(SlideViewController *)[currentNavigationController topViewController];
            
            splitViewController.delegate = slideViewController;
            
             //If popover button exists pass it to the next view
             if(currentSlideViewController.rootPopoverButtonItem !=nil)
             {
                 NSLog(@"PopoverButtonExists");
                 slideViewController.rootPopoverButtonItem = currentSlideViewController.rootPopoverButtonItem;
             }
            
            
            //Check if search is active or list is active then go to SlideVC and show the image etc.
            if(self.searchDisplayController.active){
                
                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                Condition *condition= [[self searchFrc] objectAtIndexPath:indexPath];
                slideViewController.selectedConditionName =[condition valueForKey:@"conditionName"];
                slideViewController.conditionID =[condition objectID];
            }
            else{
                
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                
                Condition *condition= [[self frc] objectAtIndexPath:indexPath];
                slideViewController.selectedConditionName =[condition valueForKey:@"conditionName"];
                slideViewController.conditionID =[condition objectID];
            }
            
            //Pass the MOC to SlideVC
            slideViewController.managedObjectContext=self.managedObjectContext;

        }
        else{
            //iPhone
            NSLog(@"we are in iPhone");
            SlideViewController *slideViewController = (SlideViewController *)segue.destinationViewController;
            
    
            if(self.searchDisplayController.active){
                
                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                
                Condition *condition= [[self searchFrc] objectAtIndexPath:indexPath];
                slideViewController.selectedConditionName =[condition valueForKey:@"conditionName"];
                slideViewController.conditionID =[condition objectID];
            }
            else{
                
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
                
                Condition *condition= [[self frc] objectAtIndexPath:indexPath];
                slideViewController.selectedConditionName =[condition valueForKey:@"conditionName"];
                slideViewController.conditionID =[condition objectID];
            }
        
            slideViewController.managedObjectContext=self.managedObjectContext;
            
            
        }
        
     
      /*
        if (slideViewController.masterPopoverController != nil) {
            [slideViewController.masterPopoverController dismissPopoverAnimated:YES];
        }
       */
        
        
    }

}


#pragma mark -
#pragma mark Content Filtering

-(void)fetchConditions
{
    //Grab the context
    
    NSManagedObjectContext *context = self.managedObjectContext;
   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];


    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Condition"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
   
    
  
    if(![self.selectedRowName isEqualToString:@"All"]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"ANY organ.organName == %@", self.selectedRowName];
        [request setPredicate:predicate];
    }
    
  
    NSSortDescriptor *sd1 = [NSSortDescriptor
                            sortDescriptorWithKey:@"organ.organName"
                            ascending:YES];
   
    NSSortDescriptor *sd2 = [NSSortDescriptor
                            sortDescriptorWithKey:@"conditionOrder"
                            ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];
    
    
    self.frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request
                                       managedObjectContext:context
                                       sectionNameKeyPath:@"organ.organName"
                                       cacheName:nil];

    NSError *error = nil;
    [self.frc performFetch:&error];
    
    self.conditionArray =[[NSMutableArray alloc]init];
    NSArray *sectionObjects = [self.frc sections] ;
    for(int i = 0; i< [sectionObjects count];i++){
        [self.conditionArray addObject:[[sectionObjects objectAtIndex:i] name]];
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
    
    
    if([self.selectedRowName isEqualToString:@"All"]){ //This is a global search searching combination on "organ" & "condition"
        
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
    }
    else{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(organ.organName) == %@ AND (conditionName CONTAINS[cd] %@)",self.selectedRowName, searchText];
    
        [request setPredicate:predicate];
        
    }
    
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


/*
#pragma mark -
#pragma mark FetchedResults Controller Delegate Methods


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.frc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.frc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    [tableView beginUpdates];
}
 
*/
/*

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = controller == self.frc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.frc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        //case NSFetchedResultsChangeUpdate:
         //   [self frc:controller configureCell:[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
          //  break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

*/



@end
