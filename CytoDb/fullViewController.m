//
//  fullViewController.m
//  CytoDb
//
//  Created by Bobby on 3/21/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "fullViewController.h"

@interface fullViewController ()

@end

@implementation fullViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fullImageDisplay.image = self.fullImage;
    
    UITapGestureRecognizer *modalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSmallView)];
    
    [self.fullImageDisplay addGestureRecognizer:modalTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)goToSmallView
{
    [self performSegueWithIdentifier:@"goToSmallView" sender:self];

}

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
