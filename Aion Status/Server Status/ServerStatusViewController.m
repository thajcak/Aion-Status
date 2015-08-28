//
//  ServerStatusViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/15/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "ServerStatusViewController.h"

#import "RegionStatusViewController.h"
#import "CommunityFeedViewController.h"
#import "FacebookFeedViewController.h"
#import "TwitterFeedViewController.h"

@interface ServerStatusViewController ()
{
    RegionStatusViewController *_regionStatusViewController;
    CommunityFeedViewController *_communityFeedViewController;
    FacebookFeedViewController *_facebookFeedViewController;
    TwitterFeedViewController *_twitterFeedViewController;
    
    UIScrollView *_newsScrollView;
    
    UISegmentedControl *_segmentedControl;
    
    UITableView *_visibleTableView;
    
    NSInteger _selectedSegmentIndex;
    CGPoint lastOffset;
}

@end

@implementation ServerStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSArray *segments = [NSArray arrayWithObjects:@"Status", @"Community", @"Facebook", @"Twitter", nil];
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
        [_segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [_segmentedControl addTarget:self
                              action:SEL(segmentedControllerValueChanged)
                    forControlEvents:UIControlEventValueChanged];
        [self.navigationItem setTitleView:_segmentedControl];
        
        _selectedSegmentIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lil_fiber.png"]]];
    
    _newsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.view.height)];
    [_newsScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [_newsScrollView setAlwaysBounceVertical:NO];
    [_newsScrollView setPagingEnabled:YES];
    [_newsScrollView setDelegate:self];
    [_newsScrollView setShowsHorizontalScrollIndicator:NO];
    [_newsScrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_newsScrollView];
    
    _regionStatusViewController = [[RegionStatusViewController alloc] initWithStyle:UITableViewStylePlain];
    [_regionStatusViewController setContainerScrollView:_newsScrollView];
    
    _communityFeedViewController = [[CommunityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    [_communityFeedViewController setContainerScrollView:_newsScrollView];
    [_communityFeedViewController setStatusViewController:self];
    
    _facebookFeedViewController = [[FacebookFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    [_facebookFeedViewController setContainerScrollView:_newsScrollView];
    [_facebookFeedViewController setStatusViewController:self];
    
    _twitterFeedViewController = [[TwitterFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    [_twitterFeedViewController setContainerScrollView:_newsScrollView];
    [_twitterFeedViewController setStatusViewController:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_newsScrollView setContentSize:CGSizeMake(1280.0f, _newsScrollView.height)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_selectedSegmentIndex == -1) {
        [_segmentedControl setSelectedSegmentIndex:0];
        [self segmentedControllerValueChanged];
    }
    
    if ([userDefaults boolForKey:didPayPremium]) {
        [_newsScrollView setHeight:self.view.height];
        [_newsScrollView setContentSize:CGSizeMake(1280.0f, self.view.height)];
        
    } else {
        [_newsScrollView setHeight:self.view.height-50.0f];
        [_newsScrollView setContentSize:CGSizeMake(1280.0f, self.view.height-50.0f)];
        [[GADMasterViewController sharedInstance] resetAdView:self];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Segmented Control

- (void)segmentedControllerValueChanged
{
    [_segmentedControl setEnabled:NO];
    
    UITableView *newTableView = [self tableViewAtIndex:_segmentedControl.selectedSegmentIndex];
    [newTableView setLeft:320*_segmentedControl.selectedSegmentIndex];
    [_newsScrollView addSubview:newTableView];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [_newsScrollView setContentOffset:CGPointMake((320*_segmentedControl.selectedSegmentIndex), 0.0f)];
                     }
                     completion:^(BOOL finished) {
                         _selectedSegmentIndex = _segmentedControl.selectedSegmentIndex;
                         [_segmentedControl setEnabled:YES];
                         [self clearOtherTablesViews];
                     }];
}
     
- (UITableView *)tableViewAtIndex:(NSInteger)index
{
    switch (index) {
        case 0: return _regionStatusViewController.tableView;
        case 1: return _communityFeedViewController.tableView;
        case 2: return _facebookFeedViewController.tableView;
        case 3: return _twitterFeedViewController.tableView;
    }
    
    return nil;
}

- (void)clearOtherTablesViews
{
    for (int i = 0; i < _segmentedControl.numberOfSegments; i++) {
        if(i != _selectedSegmentIndex) {
            [[self tableViewAtIndex:i] removeFromSuperview];
        }
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UITableView *leftTableView = [self tableViewAtIndex:_selectedSegmentIndex-1];
    [leftTableView setLeft:320*(_selectedSegmentIndex-1)];
    [_newsScrollView addSubview:leftTableView];
    
    UITableView *rightTableView = [self tableViewAtIndex:_selectedSegmentIndex+1];
    [rightTableView setLeft:320*(_selectedSegmentIndex+1)];
    [_newsScrollView addSubview:rightTableView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _selectedSegmentIndex = scrollView.contentOffset.x/320;
    [_segmentedControl setSelectedSegmentIndex:_selectedSegmentIndex];
    [self clearOtherTablesViews];
}


@end
