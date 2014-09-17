//
//  CDBFeatureTableViewController.m
//  CytoAtlas
//
//  Created by Bobby on 9/8/14.
//  Copyright (c) 2014 proqms. All rights reserved.
//

#import "CDBFeatureTableViewController.h"
#import "Features.h"

@interface CDBFeatureTableViewController ()

@end

@implementation CDBFeatureTableViewController

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
    
    [self fetchFeatures]; //This populated the self.featureArray
    
    //remove extra section lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchFeatures
{
    //Grab the context
    
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Features"
                                              inManagedObjectContext:context];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"ANY condition == %@", self.conditionID];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"featureOrder"
                                                                     ascending:YES];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    _featureArray =fetchedObjects; //This array will be used to populate the pages
    
    
}




#pragma mark - Table view data source
- (CGFloat)textViewHeightForText:(NSString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

//UITABLEVIEW PROTOCOL METHODS
#pragma -mark
#pragma -Table View delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    
    NSInteger count = _featureArray.count;
    
    return count;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    Features *feature = [_featureArray objectAtIndex:section];
    return feature.featureName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    
    
    cell.backgroundColor=[UIColor clearColor];
    Features *feature = [_featureArray objectAtIndex:indexPath.section];
    
    //cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.lineBreakMode= NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines=0;
    [cell.textLabel sizeToFit];
    cell.textLabel.text = feature.featureDescription;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Features *feature = [_featureArray objectAtIndex:indexPath.section];
    NSString *cellText =feature.featureDescription;
   // UIFont *cellFont = [UIFont systemFontOfSize:15.0f];
    UIFont *cellFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:cellText
     attributes:@
     {
     NSFontAttributeName: cellFont
     }];
    
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height + 20;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //  view.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95f];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
