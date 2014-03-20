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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle: [self selectedRowName]];
 //   NSLog(@"From VCB : %@",[self selectedRowName]);
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
   
    return [self.conditionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConditionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
   // Condition *condition= [self.conditionArray objectAtIndex:indexPath.row];
    cell.textLabel.text= [self.conditionArray objectAtIndex:indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier]isEqualToString:@"pushToImage"]){
     
        SlideViewController *slideViewController = (SlideViewController *)segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //send selected Row name("conditionName") and the database context to the slideview controller
        slideViewController.selectedConditionName =[self.conditionArray objectAtIndex:indexPath.row];
        slideViewController.managedObjectContext=self.managedObjectContext;
    }

}



-(void)fetchConditions
{
    //Grab the context
    
    NSManagedObjectContext *context = self.managedObjectContext;
   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];


    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Condition"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"ANY organ.organName == %@", self.selectedRowName];
    
    [request setPredicate:predicate];
    
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"conditionName"
                            ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sd, nil];
    [request setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request
                                       managedObjectContext:context
                                       sectionNameKeyPath:@"conditionName"
                                       cacheName:nil];

    NSError *error = nil;
    [frc performFetch:&error];
    
    self.conditionArray =[[NSMutableArray alloc]init];
    NSArray *sectionObjects = [frc sections] ;
    for(int i = 0; i< [sectionObjects count];i++){
        [self.conditionArray addObject:[[sectionObjects objectAtIndex:i] name]];
    }
    
}




@end
