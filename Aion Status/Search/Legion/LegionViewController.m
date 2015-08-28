//
//  LegionViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/21/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "LegionViewController.h"

#import "LegionMembersViewController.h"

#import "AionOnlineEngine.h"

@interface LegionViewController ()
{
    MKNetworkOperation *_legionNetworkOperation;
    
    NSDictionary *_legionData;
    
    UIView *_legionInformationView;

    UILabel *_legionLevelLabel;
    UILabel *_legionRankLabel;
    UILabel *_legionMembersLabel;
    UILabel *_legionPointsLabel;
    
    UIImageView *_raceImageView;
    
    LegionMembersViewController *_legionMembersViewController;
    
    BOOL _didLoadLegionData;
}

@end

@implementation LegionViewController

@synthesize serverId = _serverId;
@synthesize legionId = _legionId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _didLoadLegionData = NO;
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"concrete_wall.png"]]];
        
        _legionMembersViewController = [[LegionMembersViewController alloc] initWithStyle:UITableViewStylePlain];
        [_legionMembersViewController setParentNavController:self];
        [self.view addSubview:_legionMembersViewController.tableView];
        
        _legionInformationView = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, 330, 60)];
        [_legionInformationView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackmamba.png"]]];
        [_legionInformationView.layer setShadowColor:[UIColor blackColor].CGColor];
        [_legionInformationView.layer setShadowOffset:CGSizeMake(0, 0)];
        [_legionInformationView.layer setShadowRadius:10.0];
        [_legionInformationView.layer setShadowOpacity:1];
        [_legionInformationView.layer setBorderColor:[UIColor blackColor].CGColor];
        [_legionInformationView.layer setBorderWidth:1.0];
        [self.view addSubview:_legionInformationView];
        
        _raceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 95, 320, 286)];
        [_raceImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_raceImageView setAlpha:0.25];
        [self.view addSubview:_raceImageView];
        
        _legionLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 156, 30)];
        [_legionLevelLabel setTextAlignment:UITextAlignmentCenter];
        [_legionLevelLabel setTextColor:[UIColor whiteColor]];
        [_legionLevelLabel setBackgroundColor:[UIColor clearColor]];
        [_legionLevelLabel setFont:[UIFont systemFontOfSize:18.0]];
        [_legionInformationView addSubview:_legionLevelLabel];
        
        _legionRankLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_legionLevelLabel.frame, 0)];
        [_legionRankLabel setTextAlignment:UITextAlignmentCenter];
        [_legionRankLabel setTextColor:[UIColor whiteColor]];
        [_legionRankLabel setBackgroundColor:[UIColor clearColor]];
        [_legionRankLabel setFont:[UIFont systemFontOfSize:18.0]];
        [_legionInformationView addSubview:_legionRankLabel];
        
        _legionMembersLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(_legionLevelLabel.frame, 0)];
        [_legionMembersLabel setTextColor:[UIColor whiteColor]];
        [_legionMembersLabel setBackgroundColor:[UIColor clearColor]];
        [_legionMembersLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_legionInformationView addSubview:_legionMembersLabel];
        
        _legionPointsLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_legionMembersLabel.frame, 0)];
        [_legionPointsLabel setTextAlignment:UITextAlignmentRight];
        [_legionPointsLabel setTextColor:[UIColor whiteColor]];
        [_legionPointsLabel setBackgroundColor:[UIColor clearColor]];
        [_legionPointsLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_legionInformationView addSubview:_legionPointsLabel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_didLoadLegionData) {
        _legionNetworkOperation = [APP_DELEGATE.aionOnlineEngine
                                   detailsForLegionId:_legionId
                                   onServer:_serverId
                                   onCompletion:^(NSDictionary *results) {
                                       _legionData = results;
                                       _didLoadLegionData = YES;
                                       [_legionMembersViewController setMembersDictionary:[_legionData objectForKey:@"memberList"]];
                                       [_legionMembersViewController.tableView reloadData];
                                       [self updateLegionInformation];
                                   }
                                   onError:^(NSError *error) {
                                       [IBAlertView  showAlertWithTitle:[error domain]
                                                                message:[error localizedDescription]
                                                           dismissTitle:@"Okay"
                                                           dismissBlock:^{}];
                                   }];
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

#pragma mark - Actions

- (void)updateLegionInformation
{
    [self setTitle:[_legionData valueForKey:@"legionName"]];
    [_raceImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [_legionData valueForKey:@"race"]]]];
    [_legionLevelLabel setText:[NSString stringWithFormat:@"Level %@", [_legionData valueForKey:@"level"]]];
    [_legionMembersLabel setText:[NSString stringWithFormat:@"%@ members", [_legionData valueForKey:@"memberCount"]]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [_legionPointsLabel setText:[NSString stringWithFormat:@"%@ points", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[_legionData valueForKey:@"contributingPoints"] integerValue]]]]];
    
    NSInteger legionRank = [[_legionData valueForKey:@"ranking"] integerValue];
    if (legionRank == 0) {
        [_legionRankLabel setText:@"No Ranking"];
    }
    else {
        [_legionRankLabel setText:[NSString stringWithFormat:@"Rank %i", legionRank]];
    }
    
    
}

@end
