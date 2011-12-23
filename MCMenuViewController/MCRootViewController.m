//
//  MCRootViewController.m
//  MCMenuViewController
//
//  Created by Junior Bontognali on 19.12.11.
//  Copyright (c) 2011 Mocha Code. All rights reserved.
//

#import "MCRootViewController.h"
#import "MCMenuViewController.h"
#import "MCDetailViewController.h"

@implementation MCRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"MCMenuViewController";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)pushThisAwesomeMenu:(id)sender
{
    MCMenuViewController *menuController = [[[MCMenuViewController alloc] init] autorelease];
    
    MCDetailViewController *detailVC = [[[MCDetailViewController alloc] initWithNibName:@"MCDetailViewController" 
                                                                                bundle:nil] autorelease];
    detailVC.title = @"first view controller";
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:detailVC] autorelease];
    [navController.navigationBar setTintColor:[UIColor redColor]];
    
    [menuController setDetailViewController:navController];
    [self.navigationController pushViewController:menuController animated:YES];
}

@end
