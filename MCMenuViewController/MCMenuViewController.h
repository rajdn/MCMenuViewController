//
//  MCMenuViewController.h
//  MCMenuViewController
//
//  Created by Junior Bontognali on 20.12.11.
//  Copyright (c) 2011 Mocha Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MCMenuViewController : UITableViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIViewController *detailViewController; //It can be whatever you want
@property (nonatomic, assign, readonly) UITableView *detailTableView;
@property (nonatomic, retain) NSIndexPath *lastSelection;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGesture;

- (void)showMenu;

@end
