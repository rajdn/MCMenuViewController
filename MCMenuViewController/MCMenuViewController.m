//
//  MCMenuViewController.m
//  MCMenuViewController
//
//  Created by Junior Bontognali on 20.12.11.
//  Copyright (c) 2011 Mocha Code. All rights reserved.
//

#import "MCMenuViewController.h"
#import "MCDetailViewController.h"

#define kDetailOverlayWidth 40.0f
#define kDetailMoveDuration .3f
#define kDetailBounceEffet YES

typedef enum {
    kMCMenuSlideDirectionLeft,
    kMCMenuSlideDirectionRight
} MCMenuSlideDirection;

@interface MCMenuViewController (Private)
- (void)showDetailController;
@end

@implementation MCMenuViewController

@synthesize detailViewController = _detailViewController;
@synthesize detailTableView = _detailTableView;
@synthesize lastSelection = _lastSelection;
@synthesize panGesture = _panGesture;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_lastSelection release];
    [_panGesture release];
    [_detailViewController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _detailTableView = nil;
    _lastSelection = nil;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Add the detailViewController
    // Check if there's a navigationController
    UIViewController *hostController = self;
    if (self.navigationController)
        hostController = self.navigationController;
    
    [_detailViewController.view setTransform:CGAffineTransformMakeTranslation(self.view.frame.size.width, 0)];
    // Add shadows
    _detailViewController.view.layer.shadowRadius = 3.0f;
    _detailViewController.view.layer.shadowOffset = CGSizeZero;
    _detailViewController.view.layer.shadowOpacity = 0.6f; 
    
    // If detailViewController is a Nav Controller, add back button
    if ([_detailViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)_detailViewController;
        UIViewController *rootController = [[navController viewControllers] objectAtIndex:0];
        
        UIBarButtonItem *anotherButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] 
                                                                          style:UIBarButtonItemStyleBordered 
                                                                         target:self 
                                                                         action:@selector(showMenu)] autorelease];          
        rootController.navigationItem.leftBarButtonItem = anotherButton;
        
        // If tableViewController, disable tableView interaction
        // FYI: I'm not only checking if it's a tableViewController because sometimes we need a custom UIViewController with tableView
        if ([rootController respondsToSelector:@selector(tableView)]) {
            _detailTableView = [(id)rootController tableView]; // The brutal id casting is to avoid the warning
            [_detailTableView setUserInteractionEnabled:NO];         
        }
    }
    
    // Add pan gesture Recognizer
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    _panGesture.delegate = self;
    [_detailViewController.view addGestureRecognizer:_panGesture];
    
    [hostController.view addSubview:_detailViewController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:(kDetailMoveDuration * 0.5) 
                     animations:^{
                         [_detailViewController.view setTransform:CGAffineTransformMakeTranslation(self.view.frame.size.width - kDetailOverlayWidth, 0)];
                     }
     ];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (kDetailBounceEffet) {
        [UIView animateWithDuration:(kDetailMoveDuration * 0.5)
                         animations:^{
                             _detailViewController.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 [self.detailViewController.view removeFromSuperview];
                             }
                         }];
    } else {
        [self.detailViewController.view removeFromSuperview];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"menu item %i", indexPath.row];
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */    
    id newDetailVC = nil;
    if (![indexPath isEqual:self.lastSelection]) {
        MCDetailViewController *detailVC = [[[MCDetailViewController alloc] initWithNibName:@"MCDetailViewController" 
                                                                                     bundle:nil] autorelease];
        detailVC.title = [NSString stringWithFormat:@"Contoller %i", indexPath.row];
        newDetailVC = [[UINavigationController alloc] initWithRootViewController:detailVC];
        [[newDetailVC navigationBar] setTintColor:[UIColor redColor]];
    }
    
    if (kDetailBounceEffet) {
        [UIView animateWithDuration:(kDetailMoveDuration * 0.5)
                         animations:^{
                             _detailViewController.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 if (newDetailVC) 
                                     self.detailViewController = newDetailVC;
                                 
                                 [self showDetailController];
                             }
                         }];
    } else {
        if (newDetailVC) 
            self.detailViewController = newDetailVC;
    }
    
    self.lastSelection = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)showDetailController
{
    [UIView animateWithDuration:kDetailMoveDuration 
                     animations:^{
                         _detailViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                         // Remove shadows to have a smoother animation
                         _detailViewController.view.layer.shadowRadius = 0.0f;
                         _detailViewController.view.layer.shadowOffset = CGSizeZero;
                         _detailViewController.view.layer.shadowOpacity = 0.0f;
                     } completion:^(BOOL finished){
                         if (finished) {
                             if (_detailTableView)
                                 [_detailTableView setUserInteractionEnabled:YES];
                         }
                     }];

}

#pragma mark - Show Menu

- (void)showMenu
{
    [UIView animateWithDuration:kDetailMoveDuration 
                     animations:^{
                         _detailViewController.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width - kDetailOverlayWidth, 0);
                         _detailViewController.view.layer.shadowRadius = 3.0f;
                         _detailViewController.view.layer.shadowOffset = CGSizeZero;
                         _detailViewController.view.layer.shadowOpacity = 0.6f;
                     } completion:^(BOOL finished){
                      if (_detailTableView)
                             [_detailTableView setUserInteractionEnabled:NO];
                     }];
}

#pragma mark - Pan Gesture Recognizer and delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // Check for horizontal pan gesture (slide)
    if (gestureRecognizer == _panGesture) {
        
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.detailViewController.view];
        
        if ([panGesture velocityInView:self.detailViewController.view].x < 500 && 
            sqrt((translation.x * translation.x) / (translation.y * translation.y)) > 1)
            return YES;
        
        return NO;
    }
    
    return YES;
    
}

- (void)pan:(UIPanGestureRecognizer*)gesture {
    static CGFloat xOrigin;
    static MCMenuSlideDirection slideDirection;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {        
        xOrigin = _detailViewController.view.frame.origin.x;
        if([gesture velocityInView:self.view].x > 0) {
            slideDirection = kMCMenuSlideDirectionRight;
        } else {
            slideDirection = kMCMenuSlideDirectionLeft;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [gesture velocityInView:self.detailViewController.view];
        slideDirection = (velocity.x < 0) ? kMCMenuSlideDirectionLeft : kMCMenuSlideDirectionRight;
        NSLog(@"slideDirection -> %@", (slideDirection == kMCMenuSlideDirectionRight)?@"Right":@"Left");
        
        CGPoint translation = [gesture translationInView:self.detailViewController.view];
        
        CGFloat xTranslation = xOrigin + translation.x;
        if (xTranslation < 0)
            xTranslation = 0;
        else if (xTranslation > self.view.frame.size.width - kDetailOverlayWidth)
            xTranslation = self.view.frame.size.width - kDetailOverlayWidth;
        
        self.detailViewController.view.transform = CGAffineTransformMakeTranslation(xTranslation, 0);
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.view setUserInteractionEnabled:NO];
        [self.detailViewController.view setUserInteractionEnabled:NO];
        
        CGPoint velocity = [gesture velocityInView:self.detailViewController.view];
        NSLog(@"velocity.x -> %f", velocity.x);
        NSLog(@"slideDirection -> %@", (slideDirection == kMCMenuSlideDirectionRight)?@"Right":@"Left");
        NSLog(@"end");
        
        CGFloat span =  (slideDirection == kMCMenuSlideDirectionRight)?
                        (self.view.frame.size.width - kDetailOverlayWidth - self.detailViewController.view.frame.origin.x):
                        (self.detailViewController.view.frame.origin.x);
        
        CGFloat duration = span / ((velocity.x>0)?velocity.x:600);
        NSLog(@"duration %f", duration);
        
        if (slideDirection == kMCMenuSlideDirectionRight) {
            [UIView animateWithDuration:duration 
                             animations:^{
                                 _detailViewController.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width - kDetailOverlayWidth, 0);
                                 _detailViewController.view.layer.shadowRadius = 3.0f;
                                 _detailViewController.view.layer.shadowOffset = CGSizeZero;
                                 _detailViewController.view.layer.shadowOpacity = 0.6f;
                             } completion:^(BOOL finished){
                                 [self.view setUserInteractionEnabled:YES];
                                 [self.detailViewController.view setUserInteractionEnabled:YES];
                                 
                                 if (_detailTableView)
                                     [_detailTableView setUserInteractionEnabled:NO];
                             }];
        } else {
            [UIView animateWithDuration:duration 
                             animations:^{
                                 _detailViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 // Remove shadows to have a smoother animation
                                 _detailViewController.view.layer.shadowRadius = 0.0f;
                                 _detailViewController.view.layer.shadowOffset = CGSizeZero;
                                 _detailViewController.view.layer.shadowOpacity = 0.0f;
                             } completion:^(BOOL finished){
                                 if (finished) {
                                     [self.view setUserInteractionEnabled:YES];
                                     [self.detailViewController.view setUserInteractionEnabled:YES];
                                     
                                     if (_detailTableView)
                                         [_detailTableView setUserInteractionEnabled:YES];
                                 }
                             }];
        }
    }

}

#pragma mark - Getter and Setter

- (void)setDetailViewController:(UIViewController *)detailViewController
{
    if (_detailViewController == nil) {
        _detailViewController = [detailViewController retain];
        return;
    }
    
    if (_detailViewController != detailViewController) {
        [_detailViewController.view removeFromSuperview];
        [_detailViewController release];
        _detailViewController = [detailViewController retain];
        
        UIViewController *hostController = self;
        if (self.navigationController)
            hostController = self.navigationController;
        
        [_detailViewController.view setTransform:CGAffineTransformMakeTranslation(self.view.frame.size.width - kDetailOverlayWidth, 0)];
        
        // Add shadows
        _detailViewController.view.layer.shadowRadius = 3.0f;
        _detailViewController.view.layer.shadowOffset = CGSizeZero;
        _detailViewController.view.layer.shadowOpacity = 0.6f; 
        
        // If detailViewController is a  Controller, add back button
        if ([_detailViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)_detailViewController;
            UIViewController *rootController = [[navController viewControllers] objectAtIndex:0];
            
            UIBarButtonItem *anotherButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] 
                                                                               style:UIBarButtonItemStyleBordered 
                                                                              target:self 
                                                                              action:@selector(showMenu)] autorelease];          
            rootController.navigationItem.leftBarButtonItem = anotherButton;
            
            // If tableViewController, disable tableView interaction
            // FYI: I'm not only checking if it's a tableViewController because sometimes we need a custom UIViewController with tableView
            if ([rootController respondsToSelector:@selector(tableView)]) {
                _detailTableView = [(id)rootController tableView]; // The brutal id casting is to avoid the warning
                [_detailTableView setUserInteractionEnabled:NO];         
            }
        }
        
        [hostController.view addSubview:_detailViewController.view];
        
        if (_panGesture) [_panGesture release];
        // Add pan gesture Recognizer
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panGesture.delegate = self;
        [_detailViewController.view addGestureRecognizer:_panGesture];
    }
}

@end
