//
//  AbyssViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "AbyssViewController.h"
#import "ServerSelectionViewController.h"

#import "AionOnlineEngine.h"
#import "SimpleInkEngine.h"

#import "Server.h"

#import "UIImage+BBlock.h"
#import "UIPopoverController+iPhone.h"

@interface AbyssViewController ()

@end

@implementation AbyssViewController
{
    pvpLocation _pvpLocation;
    
    UISegmentedControl *_mapSelectionControl;
    
    UIScrollView *_abyssMapView;
    UIImageView *_abyssMapOverlay;
    UIImageView *_abyssMarkerLayer;
    UIImageView *_abyssVulnerabilityLayer;
    
    UIImageView *_balaureaMapView;
    UIImageView *_balaureaMarkerLayer;
    UIImageView *_balaureaVulnerabilityLayer;
    
    UIImageView *_statsImageView;
    
    UIView *_statsBackground;
    UIView *_statsInformationView;
    UIView *_taxInflationView;
    
    UILabel *_elyosTaxLabel;
    UILabel *_asmodianTaxLabel;
    UILabel *_elyosInflationLabel;
    UILabel *_asmodianInflationLabel;
    
    IBButton *_selectServerButton;
    
    CoreDataStore *_dataStore;
    Server *_selectedServer;
    
    NSDictionary *_fortresses;
    NSDictionary *_artifacts;
    NSDictionary *_stats;
    
    UIBarButtonItem *_opacityButton;
    UIPopoverController *_popoverController;
    
    UILabel *_serverNameLabel;
    
    UILabel *_elyosControlLabel;
    UILabel *_asmodianControlLabel;
    
    NSArray *_abyssFortressIdsArray;
    NSArray *_balaureaFortressIdsArray;
    
    UIButton *_ratioButton;
    UIButton *_taxInflationButton;
    
    NSDictionary *_fortressDictionary;
    NSArray *_artifactArray;
    CGPoint _fortressLocation;
    NSString *_selectedFortressId;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if ([USER_DEFAULTS objectForKey:@"visiblePvPArea"] == nil) {
        [USER_DEFAULTS setInteger:kAbyssMap forKey:@"visiblePvPArea"];
    }
    
    if ([USER_DEFAULTS objectForKey:@"abyssOpacity"] == nil) {
        [USER_DEFAULTS setFloat:0.5f forKey:@"abyssOpacity"];
    }
    
    [USER_DEFAULTS synchronize];
    
    _pvpLocation = [USER_DEFAULTS integerForKey:@"visiblePvPArea"];
    
    _mapSelectionControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Abyss", @"Balaurea", nil]];
    [_mapSelectionControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_mapSelectionControl setWidth:200.0];
    [_mapSelectionControl addTarget:self
                             action:SEL(mapSelectionChanged)
                   forControlEvents:UIControlEventValueChanged];
    [_mapSelectionControl setSelectedSegmentIndex:_pvpLocation];
    [self.navigationItem setTitleView:_mapSelectionControl];
    
    UIBarButtonItem *selectServerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"globe_2.png"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:SEL(showServerSelectionView)];
    [self.navigationItem setLeftBarButtonItem:selectServerButton];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *abyssBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AbyssBackground.png"]];
    [abyssBackground setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 367.0f)];
    [self.view addSubview:abyssBackground];
    
    _dataStore = [CoreDataStore createStore];
    
    _abyssMapView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 350)];
    [_abyssMapView setContentSize:CGSizeMake(960, 350)];
    [_abyssMapView setDelegate:self];
    [_abyssMapView setShowsHorizontalScrollIndicator:NO];
    [_abyssMapView setPagingEnabled:YES];
    
    UIImageView *topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AbyssMapTop.png"]];
    [topImage setFrame:RECT_WITH_X(_abyssMapView.frame, 0)];
    [_abyssMapView addSubview:topImage];
    
    UIImageView *coreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AbyssMapCore.png"]];
    [coreImage setFrame:RECT_STACKED_OFFSET_BY_X(topImage.frame, 0)];
    [_abyssMapView addSubview:coreImage];
    
    UIImageView *baseImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AbyssMapBase.png"]];
    [baseImage setFrame:RECT_STACKED_OFFSET_BY_X(coreImage.frame, 0)];
    [_abyssMapView addSubview:baseImage];
    
    _abyssMapOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 960, 350)];
    [_abyssMapOverlay setAlpha:0.5];
    [_abyssMapOverlay setUserInteractionEnabled:NO];
    [_abyssMapView addSubview:_abyssMapOverlay];
    
    _abyssMarkerLayer = [[UIImageView alloc] initWithFrame:_abyssMapOverlay.frame];
    [_abyssMarkerLayer setUserInteractionEnabled:NO];
    [_abyssMapView addSubview:_abyssMarkerLayer];
    
    _abyssVulnerabilityLayer = [[UIImageView alloc] initWithFrame:_abyssMapOverlay.frame];
    [_abyssVulnerabilityLayer setUserInteractionEnabled:NO];
    [_abyssMapView addSubview:_abyssVulnerabilityLayer];
    
    _balaureaMapView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balaureaMap.png"]];
    [_balaureaMapView setUserInteractionEnabled:YES];
    [_balaureaMapView setFrame:CGRectMake(0, 0, 320, 367)];
    [_balaureaMapView setContentMode:UIViewContentModeCenter];
    
    _balaureaMarkerLayer = [[UIImageView alloc] initWithFrame:_balaureaMapView.frame];
    [_balaureaMarkerLayer setUserInteractionEnabled:NO];
    [_balaureaMapView addSubview:_balaureaMarkerLayer];
    
    _balaureaVulnerabilityLayer = [[UIImageView alloc] initWithFrame:_balaureaMapView.frame];
    [_balaureaVulnerabilityLayer setUserInteractionEnabled:NO];
    [_balaureaMapView addSubview:_balaureaVulnerabilityLayer];
    
    _selectServerButton = [IBButton softButtonWithTitle:@"Select Your Server" color:[UIColor colorWithHexString:@"724D65"]];
    [_selectServerButton setHeight:44.0];
    [_selectServerButton setWidth:200.0];
    [_selectServerButton addTarget:self
                            action:SEL(showServerSelectionView)
                  forControlEvents:UIControlEventTouchUpInside];
    
    _opacityButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contrast.png"]
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self
                                                     action:SEL(showOpacitySlider)];
    [self.navigationItem setRightBarButtonItem:_opacityButton];
    
    //////
    // Tap Recognition
    //////
    UITapGestureRecognizer *abyssTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:SEL(showFortressDetails:)];
    UITapGestureRecognizer *balaureaTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:SEL(showFortressDetails:)];
    [_abyssMapView addGestureRecognizer:abyssTapGestureRecognizer];
    [_balaureaMapView addGestureRecognizer:balaureaTapGestureRecognizer];
    
    _abyssFortressIdsArray = [NSArray arrayWithObjects:BOX_INT(1011), BOX_INT(1131), BOX_INT(1132), BOX_INT(1141), BOX_INT(1211), BOX_INT(1221), BOX_INT(1231), BOX_INT(1241), BOX_INT(1251), nil];
    _balaureaFortressIdsArray = [NSArray arrayWithObjects:BOX_INT(2011), BOX_INT(2021), BOX_INT(3011), BOX_INT(3021), nil];
    
    //////
    // Ownership information
    //////
    _statsBackground = [[UIView alloc] initWithFrame:CGRectMake(-5, (isiPhone5 ? self.view.height-38-50 : self.view.height-20), 330, (isiPhone5 ? 38 : 20))];
    [_statsBackground setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_statsBackground.layer setShadowColor:[UIColor blackColor].CGColor];
    [_statsBackground.layer setShadowOpacity:1.0f];
    [_statsBackground setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_statsBackground];
    
    _statsInformationView = [[UIView alloc] initWithFrame:CGRectMake(0, _statsBackground.frame.origin.y, 320, _statsBackground.height)];
    [_statsInformationView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_statsInformationView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_statsInformationView];
    
    _statsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _statsInformationView.height-14, 320, 14)];
    [_statsInformationView addSubview:_statsImageView];
    
    _elyosControlLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _statsInformationView.height-14, 155, 14)];
    [_elyosControlLabel setBackgroundColor:[UIColor clearColor]];
    [_elyosControlLabel setTextColor:[UIColor whiteColor]];
    [_elyosControlLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_statsInformationView addSubview:_elyosControlLabel];
    
    _asmodianControlLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_elyosControlLabel.frame, 0)];
    [_asmodianControlLabel setBackgroundColor:[UIColor clearColor]];
    [_asmodianControlLabel setTextColor:[UIColor whiteColor]];
    [_asmodianControlLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_asmodianControlLabel setTextAlignment:UITextAlignmentRight];
    [_statsInformationView addSubview:_asmodianControlLabel];
    
    //////
    // Tax & Inflation
    //////
    _taxInflationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (isiPhone5 ? self.view.height-40-50 : self.view.height), 320.0f, 24.0f)];
    [_taxInflationView setBackgroundColor:[UIColor clearColor]];
    [_taxInflationView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:_taxInflationView];
    
    UIImageView *elyosEmblem = [[UIImageView alloc] initWithFrame:CGRectMake(2.0f, 0.0f, _taxInflationView.height, _taxInflationView.height)];
    [elyosEmblem setImage:[UIImage imageNamed:@"Elyos.png"]];
    [elyosEmblem setContentMode:UIViewContentModeScaleAspectFit];
    [_taxInflationView addSubview:elyosEmblem];
    
    UIImageView *asmodianEmblem = [[UIImageView alloc] initWithFrame:CGRectMake(_taxInflationView.width-_taxInflationView.height-2.0f, 0.0f, _taxInflationView.height, _taxInflationView.height)];
    [asmodianEmblem setImage:[UIImage imageNamed:@"Asmodian.png"]];
    [asmodianEmblem setContentMode:UIViewContentModeScaleAspectFit];
    [_taxInflationView addSubview:asmodianEmblem];
    
    UILabel *taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(115.0f, 0.0f, 90.0f, 12.0f)];
    [taxLabel setTextAlignment:UITextAlignmentCenter];
    [taxLabel setBackgroundColor:[UIColor clearColor]];
    [taxLabel setTextColor:[UIColor whiteColor]];
    [taxLabel setText:@"TAX RATE"];
    [taxLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_taxInflationView addSubview:taxLabel];
    
    _elyosTaxLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(taxLabel.frame, -taxLabel.width*2)];
    [_elyosTaxLabel setBackgroundColor:[UIColor clearColor]];
    [_elyosTaxLabel setTextColor:[UIColor whiteColor]];
    [_elyosTaxLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_elyosTaxLabel setTextAlignment:UITextAlignmentCenter];
    [_taxInflationView addSubview:_elyosTaxLabel];
    
    _asmodianTaxLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(taxLabel.frame, 0.0f)];
    [_asmodianTaxLabel setBackgroundColor:[UIColor clearColor]];
    [_asmodianTaxLabel setTextColor:[UIColor whiteColor]];
    [_asmodianTaxLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_asmodianTaxLabel setTextAlignment:UITextAlignmentCenter];
    [_taxInflationView addSubview:_asmodianTaxLabel];
    
    UILabel *inflationLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(taxLabel.frame, 0.0f)];
    [inflationLabel setTextAlignment:UITextAlignmentCenter];
    [inflationLabel setBackgroundColor:[UIColor clearColor]];
    [inflationLabel setTextColor:[UIColor whiteColor]];
    [inflationLabel setText:@"INFLATION"];
    [inflationLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_taxInflationView addSubview:inflationLabel];
    
    _elyosInflationLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(inflationLabel.frame, -inflationLabel.width*2)];
    [_elyosInflationLabel setBackgroundColor:[UIColor clearColor]];
    [_elyosInflationLabel setTextColor:[UIColor whiteColor]];
    [_elyosInflationLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_elyosInflationLabel setTextAlignment:UITextAlignmentCenter];
    [_taxInflationView addSubview:_elyosInflationLabel];
    
    _asmodianInflationLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(inflationLabel.frame, 0.0f)];
    [_asmodianInflationLabel setBackgroundColor:[UIColor clearColor]];
    [_asmodianInflationLabel setTextColor:[UIColor whiteColor]];
    [_asmodianInflationLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_asmodianInflationLabel setTextAlignment:UITextAlignmentCenter];
    [_taxInflationView addSubview:_asmodianInflationLabel];
    
    if (isiPhone5) {
        
    }
    else {
        _ratioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ratioButton setImage:[UIImage imageNamed:@"abyssTaxButton.png"] forState:UIControlStateNormal];
        [_ratioButton addTarget:self action:SEL(showOwnershipRatio) forControlEvents:UIControlEventTouchUpInside];
        [_ratioButton setFrame:CGRectMake(-10.0f, _statsBackground.frame.origin.y-50.0f, 37.0f, 37.0f)];
        [_ratioButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_ratioButton setEnabled:NO];
        [self.view addSubview:_ratioButton];
        
        _taxInflationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_taxInflationButton setImage:[UIImage imageNamed:@"abyssOwnershipButton.png"] forState:UIControlStateNormal];
        [_taxInflationButton addTarget:self action:SEL(showTaxInflation) forControlEvents:UIControlEventTouchUpInside];
        [_taxInflationButton setFrame:CGRectMake(10.0f, _statsBackground.frame.origin.y-40.0f, 37.0f, 37.0f)];
        [_taxInflationButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self.view addSubview:_taxInflationButton];
    }
    
    _serverNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 90)];
    [_serverNameLabel setBackgroundColor:[UIColor clearColor]];
    [_serverNameLabel setTextColor:[UIColor whiteColor]];
    [_serverNameLabel setShadowColor:[UIColor darkGrayColor]];
    [_serverNameLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [_serverNameLabel setFont:[UIFont fontWithName:@"Zapfino" size:24.0f]];
    [self.view addSubview:_serverNameLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _selectedServer = [Server firstWithKey:@"isSelectedPvP" value:BOX_BOOL(YES) inStore:_dataStore];
    
    if (_selectedServer == nil) {
        [_selectServerButton setCenter:_abyssMapView.center];
        [self.view addSubview:_selectServerButton];
    }
    else {
        [_selectServerButton removeFromSuperview];
        [_serverNameLabel setText:_selectedServer.name];
    }
    
    
    if ([userDefaults boolForKey:@"isiPhone5"]) {
        if ([userDefaults boolForKey:didPayPremium]) {
            
        } else {
            [[GADMasterViewController sharedInstance] resetAdView:self];
        }
    } else {
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_selectedServer != nil) {
        [_mapSelectionControl sendActionsForControlEvents:UIControlEventValueChanged];
        [APP_DELEGATE.aionOnlineEngine 
         pvpOwnershipInformation:^(NSDictionary *results) {
             _fortresses = [results objectForKey:@"Fortresses"];
             _artifacts = [results objectForKey:@"Artifacts"];
             dispatch_async(dispatch_get_global_queue(0, 0), ^{
                 [self createAbyssMap];
                 [self addAbyssMarkers];
                 [self createVulnerabilityOverlay];
             });
         }
         onError:^(NSError *error) {
             [IBAlertView  showAlertWithTitle:[error domain]
                                      message:[error localizedDescription]
                                 dismissTitle:@"Okay"
                                 dismissBlock:^{}];
         }];
        
        [APP_DELEGATE.aionOnlineEngine
         pvpStats:^(NSDictionary *results){
             _stats = results;
             dispatch_async(dispatch_get_global_queue(0, 0), ^{
                 [self createStatsDisplay];
             });
         }
         onError:^(NSError *error) {
             [IBAlertView  showAlertWithTitle:[error domain]
                                      message:[error localizedDescription]
                                 dismissTitle:@"Okay"
                                 dismissBlock:^{}];
         }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [_abyssMapView setAlpha:0];
                         [_balaureaMapView setAlpha:0];
                     }];
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

- (void)mapSelectionChanged
{
    [_mapSelectionControl setUserInteractionEnabled:NO];
//    [_mapSelectionControl setEnabled:NO];
    switch (_mapSelectionControl.selectedSegmentIndex) {
        case 0:
        {
            _pvpLocation = kAbyssMap;
            [_abyssMapView setAlpha:0];
            [self.view insertSubview:_abyssMapView belowSubview:_statsBackground];
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [_balaureaMapView setAlpha:0];
                                 [_abyssMapView setAlpha:1];
                             }
                             completion:^(BOOL finished) {
                                 [_balaureaMapView removeFromSuperview];
                                 [_mapSelectionControl setUserInteractionEnabled:YES];
//                                 [_mapSelectionControl setEnabled:YES];
                             }];
            break;
        }
        case 1:
        {
            _pvpLocation = kBalaureaMap;
            [_balaureaMapView setAlpha:0];
            [self.view insertSubview:_balaureaMapView belowSubview:_statsBackground];
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [_abyssMapView setAlpha:0];
                                 [_balaureaMapView setAlpha:1];
                             }
                             completion:^(BOOL finished) {
                                 [_abyssMapView removeFromSuperview];
                                 [_mapSelectionControl setUserInteractionEnabled:YES];
//                                 [_mapSelectionControl setEnabled:YES];
                             }];
            break;
        }
    }
    
    [USER_DEFAULTS setInteger:_pvpLocation forKey:@"visiblePvPArea"];
    [USER_DEFAULTS synchronize];
}

#pragma mark - Select Server

- (void)showServerSelectionView
{
    ServerSelectionViewController *ssVC = [[ServerSelectionViewController alloc] init];
    [ssVC setServerList:kAbyssServers];
    
    UINavigationController *ssNC = [[UINavigationController alloc] initWithRootViewController:ssVC];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonSystemItemDone
                                                                  target:ssVC
                                                                  action:SEL(dismissModalViewControllerAnimated:)];
    [ssVC.navigationItem setLeftBarButtonItem:doneButton];
    
    [self presentModalViewController:ssNC animated:YES];
}

#pragma mark - Map Creation

- (void)createAbyssMap
{
    UIGraphicsBeginImageContextWithOptions(_abyssMapView.contentSize, NO, [[UIScreen mainScreen] scale]);
    
    for (NSString *fortressIdString in _fortresses) {
        NSInteger fortressId = [fortressIdString integerValue];
        if (fortressId < 2000) {
            CGRect imageFrame = CGRectMake(0, 0, 320, 350);

            if (fortressId < 1100) {
                imageFrame = RECT_WITH_X(imageFrame, 320);
            }
            else if (fortressId > 1100 && fortressId < 1200) {
                imageFrame = RECT_WITH_X(imageFrame, 640);
            }
            
            NSDictionary *fortress = [_fortresses objectForKey:fortressIdString];
            [[UIImage imageNamed:[NSString stringWithFormat:@"AbyssMask%@%@.png", [self fortressNameForId:fortressId], [fortress valueForKey:@"race"]]] drawInRect:imageFrame];
        }
    }
    
    NSDictionary *topArtifact = [_artifacts objectForKey:@"1224"];
    CGRect topArtifactImageFrame = CGRectMake(0, 0, 320, 350);
    [[UIImage imageNamed:[NSString stringWithFormat:@"AbyssMaskArtifactTop%@.png", [topArtifact valueForKey:@"race"]]] drawInRect:topArtifactImageFrame];
    
    NSDictionary *baseArtifact = [_artifacts objectForKey:@"1135"];
    CGRect baseArtifactImageFrame = CGRectMake(640, 0, 320, 350);
    [[UIImage imageNamed:[NSString stringWithFormat:@"AbyssMaskArtifactBase%@.png", [baseArtifact valueForKey:@"race"]]] drawInRect:baseArtifactImageFrame];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [_abyssMapOverlay setImage:resultingImage];
    });
}

- (void)addAbyssMarkers
{
    // Abyss View
    UIGraphicsBeginImageContextWithOptions(_abyssMapView.contentSize, NO, [[UIScreen mainScreen] scale]);
    
    for (NSString *artifactId in _artifacts) {
        if ([artifactId integerValue] < 2000) {
            CGPoint artifactLocation = [self getMarkerLocation:[artifactId integerValue]];
            [[UIImage imageNamed:[NSString stringWithFormat:@"Artifact%@.png", [[_artifacts objectForKey:artifactId] valueForKey:@"race"]]] drawAtPoint:artifactLocation];
        }
    }
    
    for (NSString *fortressId in _fortresses) {
        if ([fortressId integerValue] < 2000) {
            CGPoint fortressLocation = [self getMarkerLocation:[fortressId integerValue]];
            [[UIImage imageNamed:[NSString stringWithFormat:@"Fortress%@.png", [[_fortresses objectForKey:fortressId] valueForKey:@"race"]]] drawAtPoint:fortressLocation];
        }
    }
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [_abyssMarkerLayer setImage:resultingImage];
    });
    
    // Balaurea View
    UIGraphicsBeginImageContextWithOptions(_balaureaMarkerLayer.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    for (NSString *artifactId in _artifacts) {
        if ([artifactId integerValue] >= 2000) {
            CGPoint artifactLocation = [self getMarkerLocation:[artifactId integerValue]];
            [[UIImage imageNamed:[NSString stringWithFormat:@"Artifact%@.png", [[_artifacts objectForKey:artifactId] valueForKey:@"race"]]] drawAtPoint:artifactLocation];
        }
    }
    
    for (NSString *fortressId in _fortresses) {
        if ([fortressId integerValue] >= 2000) {
            CGPoint fortressLocation = [self getMarkerLocation:[fortressId integerValue]];
            [[UIImage imageNamed:[NSString stringWithFormat:@"Fortress%@.png", [[_fortresses objectForKey:fortressId] valueForKey:@"race"]]] drawAtPoint:fortressLocation];
        }
    }
    
    UIImage *resultingImage2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [_balaureaMarkerLayer setImage:resultingImage2];
    });
}

- (void)createVulnerabilityOverlay
{
    // Abyss View
    UIGraphicsBeginImageContextWithOptions(_abyssVulnerabilityLayer.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    for (NSString *fortressId in _fortresses) {
        if ([fortressId integerValue] < 2000 ) {
            NSString *fortressStatusNow = [[_fortresses objectForKey:fortressId] valueForKey:@"status"];
            NSString *fortressStatusNext = [[_fortresses objectForKey:fortressId] valueForKey:@"nextStatus"];

            if ([fortressStatusNow contains:@"Vulnerable"]) {
                [[UIImage imageNamed:@"VulnerableNow.png"] drawAtPoint:[self getMarkerLocation:[fortressId integerValue]]];
            }
            else if ([fortressStatusNext contains:@"Vulnerable"]) {
                [[UIImage imageNamed:@"VulnerableSoon.png"] drawAtPoint:[self getMarkerLocation:[fortressId integerValue]]];
            }
        }
    }
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [_abyssVulnerabilityLayer setImage:resultingImage];
        [_abyssVulnerabilityLayer setAlpha:0.8f];
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat)
                         animations:^{
                             [_abyssVulnerabilityLayer setAlpha:0.2];
                         }completion:^(BOOL finished){}];
    });
    
    // Balaurea View
    UIGraphicsBeginImageContextWithOptions(_balaureaVulnerabilityLayer.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    for (NSString *fortressId in _fortresses) {
        if ([fortressId integerValue] >= 2000) {
            NSString *fortressStatusNow = [[_fortresses objectForKey:fortressId] valueForKey:@"status"];
            NSString *fortressStatusNext = [[_fortresses objectForKey:fortressId] valueForKey:@"nextStatus"];
            
            if ([fortressStatusNow contains:@"Vulnerable"]) {
                [[UIImage imageNamed:@"VulnerableNow.png"] drawAtPoint:[self getMarkerLocation:[fortressId integerValue]]];
            }
            else if ([fortressStatusNext contains:@"Vulnerable"]) {
                [[UIImage imageNamed:@"VulnerableSoon.png"] drawAtPoint:[self getMarkerLocation:[fortressId integerValue]]];
            }
        }
    }
    
    UIImage *resultingImage2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [_balaureaVulnerabilityLayer setImage:resultingImage2];
        [_balaureaVulnerabilityLayer setAlpha:0.8f];
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat)
                         animations:^{
                             [_balaureaVulnerabilityLayer setAlpha:0.2];
                         }completion:^(BOOL finished){}];
    });
}

- (void)createStatsDisplay
{
    NSDictionary *serverStatus = [_stats objectForKey:_selectedServer.name];
    
    NSInteger percentElyos = [[serverStatus valueForKey:@"controlElyos"] integerValue];
    NSInteger percentBalaur = [[serverStatus valueForKey:@"controlBalaur"] integerValue];
    NSInteger percentAsmodian = [[serverStatus valueForKey:@"controlAsmodian"] integerValue];
    
    UIGraphicsBeginImageContext(CGSizeMake(320.0, 14));
	[[UIImage imageNamed:@"GraphElyos.png"] drawInRect:CGRectMake(0, 0, (percentElyos * 3.5), 14)];
	[[UIImage imageNamed:@"GraphBalaur.png"] drawInRect:CGRectMake((percentElyos * 3.2), 0, (percentBalaur * 3.5), 14)];
	[[UIImage imageNamed:@"GraphAsmodian.png"] drawInRect:CGRectMake(((percentElyos + percentBalaur) * 3.2), 0, (percentAsmodian * 3.5), 14)];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_statsImageView setImage:resultingImage];
        
        [_elyosControlLabel setText:[NSString stringWithFormat:@"ELYOS: %i%%", percentElyos]];
        [_asmodianControlLabel setText:[NSString stringWithFormat:@"ASMODIAN: %i%%", percentAsmodian]];
        [_elyosTaxLabel setText:[NSString stringWithFormat:@"%i%%", [[serverStatus valueForKey:@"taxElyos"] integerValue]]];
        [_elyosInflationLabel setText:[NSString stringWithFormat:@"%i%%", [[serverStatus valueForKey:@"inflationElyos"] integerValue]]];
        [_asmodianTaxLabel setText:[NSString stringWithFormat:@"%i%%", [[serverStatus valueForKey:@"taxAsmodian"] integerValue]]];
        [_asmodianInflationLabel setText:[NSString stringWithFormat:@"%i%%", [[serverStatus valueForKey:@"inflationAsmodian"] integerValue]]];
    });
}

#pragma mark - Location & Naming

- (NSString *)fortressNameForId:(NSInteger)fortressId
{
    NSString *fortressName;
    switch (fortressId) {
        case 1011:
            fortressName = @"Core";
            break;
        case 1131:
            fortressName = @"SielWest";
            break;
        case 1132:
            fortressName = @"SielEast";
            break;
        case 1141:
            fortressName = @"Sulfur";
            break;
        case 1211:
            fortressName = @"Roah";
            break;
        case 1221:
            fortressName = @"Krotan";
            break;
        case 1231:
            fortressName = @"Kysis";
            break;
        case 1241:
            fortressName = @"Miren";
            break;
        case 1251:
            fortressName = @"Asteria";
            break;
        default:
            fortressName = @"";
            break;
    }
    return fortressName;
}

- (CGPoint)getMarkerLocation:(NSInteger)idNumber 
{
	switch (idNumber) 
	{
			//fortresses
		case 1011:			//Divine
			return CGPointMake(142+320, 180);
		case 1131:			//Siel West
			return CGPointMake(209+640, 247);
		case 1132:			//Siel East
			return CGPointMake(240+640, 230);
		case 1141:			//Sulfur
			return CGPointMake(68+640, 105);
		case 1211:			//Roah
			return CGPointMake(30, 243);
		case 1221:			//Krotan
			return CGPointMake(79, 172);
		case 1231:			//Kysis
			return CGPointMake(164, 219);
		case 1241:			//Miren
			return CGPointMake(181, 144);
		case 1251:			//Asteria
			return CGPointMake(248, 37);
		case 2011:			//Temple of Scales
			return CGPointMake(122, 200);
		case 2021:			//Altar of Avarice
			return CGPointMake(90, 92);
		case 3011:			//Vorgaltem Citadel
			return CGPointMake(187, 132);
		case 3021:			//Crimson Temple
			return CGPointMake(218, 218);
			//core artifacts
		case 1012:
			return CGPointMake(175+320, 188);
		case 1013:
			return CGPointMake(161+320, 211);
		case 1014:
			return CGPointMake(173+320, 202);
		case 1015:
			return CGPointMake(141+320, 161);
		case 1016:
			return CGPointMake(121+320, 196);
		case 1017:
			return CGPointMake(122+320, 175);
		case 1018:
			return CGPointMake(147+320, 216);
		case 1019:
			return CGPointMake(167+320, 168);
		case 1020:
			return CGPointMake(174+320, 176);
			//base artifacts
		case 1133:			//Siel East Artifact
			return CGPointMake(195+640, 245);
		case 1134:			//Siel West Artifact
			return CGPointMake(229+640, 218);
		case 1135:			//Abyssal Aegis (island)
			return CGPointMake(242+640, 265);
		case 1142:			//Sulfur Artifacts
			return CGPointMake(83+640, 102);
		case 1143:
			return CGPointMake(63+640, 96);
		case 1144:
			return CGPointMake(56+640, 121);
		case 1145:
			return CGPointMake(84+640, 125);
		case 1146:
			return CGPointMake(94+640, 103);
			//top artifacts
		case 1212:			//Roah Artifacts
			return CGPointMake(25, 257);
		case 1213:
			return CGPointMake(40, 232);
		case 1214:
			return CGPointMake(44, 274);
		case 1215:
			return CGPointMake(11, 267);
		case 1222:			//Krotan Artifacts
			return CGPointMake(72, 188);
		case 1223:
			return CGPointMake(100, 177);
		case 1224:			//Flaming Hell (island)
			return CGPointMake(150, 188);
		case 1232:			//Kysis Artifacts
			return CGPointMake(159, 235);
		case 1233:
			return CGPointMake(178, 214);
		case 1242:			//Miren Artifacts
			return CGPointMake(172, 144);
		case 1243:
			return CGPointMake(201, 146);
		case 1252:			//Asteria Artifacts
			return CGPointMake(276, 40);
		case 1253:
			return CGPointMake(260, 54);
		case 1254:
			return CGPointMake(245, 33);
			//Balaurea artifacts
		case 2012:			//Inggison Artifacts
			return CGPointMake(83, 222);
		case 2013:
			return CGPointMake(114, 171);
		case 2022:
			return CGPointMake(33, 94);
		case 2023:
			return CGPointMake(72, 62);
		case 3012:			//Gelkmaros Artifacts
			return CGPointMake(235, 141);
		case 3013:
			return CGPointMake(275, 135);
		case 3022:
			return CGPointMake(259, 242);
		case 3023:
			return CGPointMake(250, 188);
		default:
			return CGPointMake(-20, 0);
	}
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - Actions

- (void)showOpacitySlider
{
    if ([_popoverController isPopoverVisible]) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        UIViewController *popoverVC = [[UIViewController alloc] init];
        [popoverVC.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
        
        UISlider *opacitySlider = [[UISlider alloc] init];
        [opacitySlider setWidth:200];
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
        opacitySlider.transform = trans;
        [opacitySlider setCenter:CGPointMake(20, 110)];
        [opacitySlider setValue:[USER_DEFAULTS floatForKey:@"abyssOpacity"]];
        [opacitySlider addTarget:self
                          action:SEL(opacityChanged:)
                forControlEvents:UIControlEventValueChanged];
        [popoverVC.view addSubview:opacitySlider];
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverVC];
        [_popoverController setDelegate:self];
        [_popoverController setPopoverContentSize:CGSizeMake(40, 220)];
        [_popoverController presentPopoverFromBarButtonItem:_opacityButton
                                   permittedArrowDirections:UIPopoverArrowDirectionUp
                                                   animated:YES];
    }
}

- (void)opacityChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    [_abyssMapOverlay setAlpha:slider.value];
}

- (float)distanceBetweenFortress:(CGPoint)firstPoint andTap:(CGPoint)secondPoint
{
    float xDistance = secondPoint.x - firstPoint.x;
    float yDistance = secondPoint.y - firstPoint.y;
    float distance = sqrtf((xDistance * xDistance) + (yDistance * yDistance));
    return distance;
}

- (void)showTaxInflation
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [_taxInflationButton setFrame:CGRectMake(20.0f, _statsBackground.frame.origin.y-35.0f, 37.0f, 37.0f)];
                         [_ratioButton setFrame:CGRectMake(-20.0f, _statsBackground.frame.origin.y-55.0f, 37.0f, 37.0f)];
                     }
                     completion:^(BOOL finished) {
                         [_taxInflationButton setEnabled:NO];
                         [_ratioButton setEnabled:YES];
                         [self.view bringSubviewToFront:_ratioButton];
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:(UIViewAnimationCurveEaseOut)
                                          animations:^{
                                              [_taxInflationButton setFrame:CGRectMake(-10.0f, _statsBackground.frame.origin.y-50.0f, 37.0f, 37.0f)];
                                              [_ratioButton setFrame:CGRectMake(10.0f, _statsBackground.frame.origin.y-40.0f, 37.0f, 37.0f)];
                                          }
                                          completion:^(BOOL finished) {}];
                     }];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [_statsInformationView setFrame:CGRectMake(0.0f, _statsBackground.frame.origin.y+_statsBackground.height, 320.0f, _statsBackground.height)];
                         [_taxInflationView setFrame:CGRectMake(0.0f, (isiPhone5 ? self.view.height-40-50-24 : self.view.height-24), 320.0f, 24.0f)];
                     }];
}

- (void)showOwnershipRatio
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationCurveEaseIn)
                     animations:^{
                         [_taxInflationButton setFrame:CGRectMake(-20.0f, _statsBackground.frame.origin.y-55.0f, 37.0f, 37.0f)];
                         [_ratioButton setFrame:CGRectMake(20.0f, _statsBackground.frame.origin.y-35.0f, 37.0f, 37.0f)];
                     }
                     completion:^(BOOL finished) {
                         [_taxInflationButton setEnabled:YES];
                         [_ratioButton setEnabled:NO];
                         [self.view bringSubviewToFront:_taxInflationButton];
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:(UIViewAnimationCurveEaseOut)
                                          animations:^{
                                              [_taxInflationButton setFrame:CGRectMake(10.0f, _statsBackground.frame.origin.y-40.0f, 37.0f, 37.0f)];
                                              [_ratioButton setFrame:CGRectMake(-10.0f, _statsBackground.frame.origin.y-50.0f, 37.0f, 37.0f)];
                                          }
                                          completion:^(BOOL finished) {}];
                     }];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [_statsInformationView setFrame:CGRectMake(0.0f, _statsBackground.frame.origin.y, 320.0f, _statsBackground.height)];
                         [_taxInflationView setFrame:CGRectMake(0.0f, (isiPhone5 ? self.view.height-40-50 : self.view.height), 320.0f, 24.0f)];
                     }];
}

#pragma mark - Popover View Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [USER_DEFAULTS setFloat:_abyssMapOverlay.alpha forKey:@"abyssOpacity"];
    [USER_DEFAULTS synchronize];
}

#pragma mark - Tap Gesture Recognizer

- (void)showFortressDetails:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint tapLocation = [sender locationInView:sender.view];
        
        NSArray *fortressIdArray;
        if ([sender.view isEqual:_abyssMapView]) {
            fortressIdArray = _abyssFortressIdsArray;
        }
        else {
            fortressIdArray = _balaureaFortressIdsArray;
        }
        
        for (NSNumber *fortressId in fortressIdArray) {
            CGPoint fortressPoint = [self getMarkerLocation:UNBOX_INT(fortressId)];
            fortressPoint.x += 9;
            fortressPoint.y += 9;
            float distance = [self distanceBetweenFortress:fortressPoint andTap:tapLocation];
            
            if (distance <= 20.0f) {
                [self showDetailsForFortress:fortressId];
                
                return;
            }
        }
    }
}

- (void)showDetailsForFortress:(id)fortressId
{
    _fortressDictionary = [_fortresses objectForKey:[fortressId stringValue]];
    _selectedFortressId = fortressId;
    
    NSMutableArray *artifactArray = [[NSMutableArray alloc] init];
    for (NSString *artifactId in _artifacts) {
        if ([artifactId integerValue] > [fortressId integerValue]
            && [artifactId integerValue] < ([fortressId integerValue] + 10)
            && [artifactId integerValue] != 1224)
        {
            [artifactArray addObject:[_artifacts objectForKey:artifactId]];
        }
    }
    
    if ([fortressId integerValue] >= 1220 && [fortressId integerValue] <= 1241) {
        [artifactArray addObject:[_artifacts objectForKey:@"1224"]];
    }
    
    _artifactArray = artifactArray;
    _fortressLocation = [self getMarkerLocation:[fortressId integerValue]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, self.view.height-60.0f) style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorColor:[UIColor clearColor]];
    
//    [self.view addSubview:fortressVC.tableView];
    [[KGModal sharedInstance] showWithContentView:tableView andAnimated:YES];
//    [self presentModalViewController:fortressVC animated:YES];
}

#pragma mark - Table View Delegate

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 105.0f)];
    
    UIImageView *mapImage = [[UIImageView alloc] initWithFrame:CGRectMake(-2.0f, -2.0f, 264.0f, 102.0f)];
    [mapImage setBackgroundColor:[UIColor blackColor]];
    [mapImage.layer setBorderColor:[UIColor grayColor].CGColor];
    [mapImage.layer setBorderWidth:1.0f];
    [headerView addSubview:mapImage];
    
    CGPoint drawLocation = CGPointMake(185.0f-_fortressLocation.x, 55.0f-_fortressLocation.y);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(260.0f, 100.0f), NO, [[UIScreen mainScreen] scale]);
    if ([_selectedFortressId integerValue] < 2000) {
        [_abyssMapOverlay.image drawAtPoint:drawLocation];
        [_abyssMarkerLayer.image drawAtPoint:drawLocation];
        [_abyssVulnerabilityLayer.image drawAtPoint:drawLocation];
    }
    else if ([_selectedFortressId integerValue] > 2000){
        [_balaureaMapView.image drawAtPoint:drawLocation];
        [_balaureaMarkerLayer.image drawAtPoint:drawLocation];
        [_balaureaVulnerabilityLayer.image drawAtPoint:drawLocation];
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [mapImage setImage:resultingImage];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
	[gradient setFrame:CGRectMake(0, 0, 100, 264.0f)];
    [gradient setTransform:CATransform3DMakeRotation((-90*(M_PI/180)), 0, 0, 1)];
    [gradient setPosition:CGPointMake(132, 52)];
	[gradient setColors:[NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor blackColor] CGColor], (id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil]];
	[mapImage.layer addSublayer:gradient];
    
    UILabel *fortressNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, 260.0f, 55.0f)];
    [fortressNameLabel setTextColor:[UIColor whiteColor]];
    [fortressNameLabel setBackgroundColor:[UIColor clearColor]];
    [fortressNameLabel setFont:[UIFont fontWithName:@"Zapfino" size:16.0f]];
    [fortressNameLabel setText:[_fortressDictionary valueForKey:@"name"]];
    [headerView addSubview:fortressNameLabel];
    
    UILabel *fortressOwnerLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(fortressNameLabel.frame, 10.0f)];
    [fortressOwnerLabel setHeight:30.0f];
    [fortressOwnerLabel setBackgroundColor:[UIColor clearColor]];
    [fortressOwnerLabel setTextColor:[UIColor whiteColor]];
    [fortressOwnerLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
    [fortressOwnerLabel setText:[NSString stringWithFormat:@"%@", [_fortressDictionary valueForKey:@"legion"]]];
    [headerView addSubview:fortressOwnerLabel];
    
    UILabel *vulnerabilityLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(fortressOwnerLabel.frame, -fortressOwnerLabel.height)];
    [vulnerabilityLabel setBackgroundColor:[UIColor clearColor]];
    [vulnerabilityLabel setTextColor:[UIColor whiteColor]];
    [vulnerabilityLabel setFont:[UIFont systemFontOfSize:16.0f]];
    
    NSString *fortressStatusNow = [_fortressDictionary valueForKey:@"status"];
    NSString *fortressStatusNext = [_fortressDictionary valueForKey:@"nextStatus"];
    if ([fortressStatusNow contains:@"Vulnerable"]) {
        [vulnerabilityLabel setText:@"Vulnerable"];
    }
    else if ([fortressStatusNext contains:@"Vulnerable"]) {
        [vulnerabilityLabel setText:@"Vulnerable Soon"];
    }
    [headerView addSubview:vulnerabilityLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_artifactArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell.textLabel setText:[[_artifactArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[_artifactArray objectAtIndex:indexPath.row] valueForKey:@"legion"]]];
    
    UIImageView *ownerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Artifact%@@2x.png", [[_artifactArray objectAtIndex:indexPath.row] valueForKey:@"race"]]]];
    [cell setAccessoryView:ownerIcon];
    
    return cell;
}

@end
