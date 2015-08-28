//
//  CharacterViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/6/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "CharacterViewController.h"

#import "CharacterStatsViewController.h"
#import "EquipmentViewController.h"

#import "AionOnlineEngine.h"

@interface CharacterViewController ()
{
    MKNetworkOperation *_characterDetailsOperation;
    
    NSDictionary *_characterData;
    
    UIScrollView *_informationScrollView;
    UIPageViewController *_pageViewController;
    
    UIView *_statsContainer;
    UIView *_equipmentContainer;
    UIView *_stigmasContainer;
    
    UIView *_navigationBarHeader;
    UILabel *_nameLabel;
    UILabel *_titleLabel;
    
    UIImageView *_raceIcon;
    
    UIImageView *_classIcon;
    UILabel *_levelClassLabel;
    UILabel *_legionLabel;
    
    UILabel *_abyssTitleLabel;
    UILabel *_abyssKillsDay;
    UILabel *_abyssKillsWeek;
    UILabel *_abyssKillsAll;
    UILabel *_abyssPointsDay;
    UILabel *_abyssPointsWeek;
    UILabel *_abyssPointsAll;
    
    CharacterStatsViewController *_statsViewController;
    EquipmentViewController *_equipmentViewController;
    
    BOOL _didLoadCharacterData;
}

@end

@implementation CharacterViewController

@synthesize serverId = _serverId;
@synthesize characterId = _characterId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _informationScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.height-(DID_PAY_PREMIUM ? 0 : 50))];
        [_informationScrollView setPagingEnabled:YES];
        [_informationScrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"concrete_wall.png"]]];
        [_informationScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_informationScrollView setAutoresizesSubviews:YES];
        [_informationScrollView setShowsHorizontalScrollIndicator:NO];
        
        //////
        //Base Section Views
        //////
        _statsContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, _informationScrollView.height-30)];
        [_statsContainer setBackgroundColor:[UIColor whiteColor]];
        [_statsContainer setAutoresizingMask:(UIViewAutoresizingFlexibleHeight)];
        [_statsContainer.layer setShadowColor:[UIColor blackColor].CGColor];
        [_statsContainer.layer setShadowOffset:CGSizeMake(4.0f, 4.0f)];
        [_statsContainer.layer setShadowOpacity:1.0f];
        [_statsContainer.layer setShadowRadius:3.0f];
        [_statsContainer.layer setCornerRadius:10.0f];
        [_statsContainer.layer setBorderWidth:1.0f];
        [_statsContainer.layer setBorderColor:[UIColor blackColor].CGColor];
        [_informationScrollView addSubview:_statsContainer];
        
        UIView *statsContent = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, _statsContainer.height)];
        [statsContent setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper.png"]]];
        [statsContent.layer setCornerRadius:10.0f];
        [statsContent setClipsToBounds:YES];
        [statsContent setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_informationScrollView addSubview:statsContent];
        
        _raceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 300, _statsContainer.height-106)];
        [_raceIcon setContentMode:UIViewContentModeScaleAspectFit];
        [_raceIcon setAlpha:0.2];
        [statsContent addSubview:_raceIcon];
        
        UIView *equipmentInfoView = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 320, 416)];
        [equipmentInfoView setClipsToBounds:YES];
        [_informationScrollView addSubview:equipmentInfoView];
        
        _statsViewController = [[CharacterStatsViewController alloc] init];
        [_statsViewController.tableView setFrame:CGRectMake(0, 60, 300, _informationScrollView.height-135)];
        [statsContent addSubview:_statsViewController.tableView];
        
        //////
        // Armor Setup
        //////
        UIView *equipmentShadowView = [[UIView alloc] initWithFrame:CGRectMake(330, 10, 300, _informationScrollView.height-30)];
        [equipmentShadowView setBackgroundColor:[UIColor blackColor]];
        [equipmentShadowView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [equipmentShadowView.layer setShadowColor:[UIColor blackColor].CGColor];
        [equipmentShadowView.layer setShadowRadius:2.0f];
        [equipmentShadowView.layer setShadowOffset:CGSizeMake(3.0f, 3.0f)];
        [equipmentShadowView.layer setShadowOpacity:1.0f];
        [equipmentShadowView.layer setCornerRadius:10.0f];
        [_informationScrollView addSubview:equipmentShadowView];
        
        _equipmentContainer = [[UIView alloc] initWithFrame:CGRectMake(330, 10, 300, _informationScrollView.height-30)];
        [_equipmentContainer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper.png"]]];
        [_equipmentContainer.layer setBorderColor:[UIColor blackColor].CGColor];
        [_equipmentContainer.layer setBorderWidth:1.0f];
        [_equipmentContainer.layer setCornerRadius:10.0f];
        [_equipmentContainer setClipsToBounds:YES];
        [_equipmentContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_informationScrollView addSubview:_equipmentContainer];
        
        _equipmentViewController = [[EquipmentViewController alloc] init];
        [_equipmentViewController.tableView setFrame:CGRectMake(0, 0, 300, _informationScrollView.height-30)];
        [_equipmentViewController setCharacterViewController:self];
        [_equipmentContainer addSubview:_equipmentViewController.tableView];
        
        //////
        // Stigma Setup
        //////
        
        UILabel *stigmasSoonLabel = [[UILabel alloc] initWithFrame:CGRectMake(640, 0, 320, _informationScrollView.height)];
        [stigmasSoonLabel setText:@"Temporarily Removed\n\nNew Source\nfor Stigmas\nComing Soon!"];
        [stigmasSoonLabel setNumberOfLines:6];
        [stigmasSoonLabel setTextAlignment:UITextAlignmentCenter];
        [stigmasSoonLabel setFont:[UIFont boldSystemFontOfSize:32.0]];
        [stigmasSoonLabel setShadowColor:[UIColor blackColor]];
        [stigmasSoonLabel setShadowOffset:CGSizeMake(0, -1)];
        [stigmasSoonLabel setTextColor:[UIColor colorWith256Red:255 green:255 blue:255 alpha:25]];
        [stigmasSoonLabel setBackgroundColor:[UIColor clearColor]];
        [stigmasSoonLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_informationScrollView addSubview:stigmasSoonLabel];
        
        //////
        //Abyss Information Setup
        //////
        UIView *abyssInfoView = [[UIView alloc] initWithFrame:CGRectMake(-10, statsContent.height-46, CONTAINER_WIDTH+20, 46)];
        [abyssInfoView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [abyssInfoView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackmamba.png"]]];
        [abyssInfoView.layer setShadowColor:[UIColor blackColor].CGColor];
        [abyssInfoView.layer setShadowOffset:CGSizeMake(0, -2.0f)];
        [abyssInfoView.layer setShadowRadius:3.0f];
        [abyssInfoView.layer setShadowOpacity:1.0f];
        [abyssInfoView.layer setBorderColor:[UIColor blackColor].CGColor];
        [abyssInfoView.layer setBorderWidth:1.0];
        [statsContent addSubview:abyssInfoView];
        
        UILabel *killsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, 50, 15)];
        [killsLabel setBackgroundColor:[UIColor clearColor]];
        [killsLabel setTextColor:[UIColor whiteColor]];
        [killsLabel setFont:[UIFont systemFontOfSize:14.0]];
        [killsLabel setText:@"Kills"];
        [abyssInfoView addSubview:killsLabel];
        
        UILabel *pointsLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(killsLabel.frame, 0)];
        [pointsLabel setBackgroundColor:[UIColor clearColor]];
        [pointsLabel setTextColor:[UIColor whiteColor]];
        [pointsLabel setFont:[UIFont systemFontOfSize:14.0]];
        [pointsLabel setText:@"Points"];
        [abyssInfoView addSubview:pointsLabel];
        
        _abyssKillsDay = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(killsLabel.frame, 0)];
        [_abyssKillsDay setWidth:80.0];
        [_abyssKillsDay setBackgroundColor:[UIColor clearColor]];
        [_abyssKillsDay setTextColor:[UIColor whiteColor]];
        [_abyssKillsDay setTextAlignment:UITextAlignmentRight];
        [_abyssKillsDay setFont:[UIFont systemFontOfSize:14.0]];
        [abyssInfoView addSubview:_abyssKillsDay];
        
        _abyssKillsWeek = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_abyssKillsDay.frame, 0)];
        [_abyssKillsWeek setBackgroundColor:[UIColor clearColor]];
        [_abyssKillsWeek setTextColor:[UIColor whiteColor]];
        [_abyssKillsWeek setTextAlignment:UITextAlignmentRight];
        [_abyssKillsWeek setFont:[UIFont systemFontOfSize:14.0]];
        [abyssInfoView addSubview:_abyssKillsWeek];
        
        _abyssKillsAll = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_abyssKillsWeek.frame, 0)];
        [_abyssKillsAll setBackgroundColor:[UIColor clearColor]];
        [_abyssKillsAll setTextColor:[UIColor whiteColor]];
        [_abyssKillsAll setTextAlignment:UITextAlignmentRight];
        [_abyssKillsAll setFont:[UIFont systemFontOfSize:14.0]];
        [abyssInfoView addSubview:_abyssKillsAll];
        
        _abyssPointsDay = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(_abyssKillsDay.frame, 0)];
        [_abyssPointsDay setBackgroundColor:[UIColor clearColor]];
        [_abyssPointsDay setTextColor:[UIColor whiteColor]];
        [_abyssPointsDay setTextAlignment:UITextAlignmentRight];
        [_abyssPointsDay setFont:[UIFont systemFontOfSize:14.0]];
        [abyssInfoView addSubview:_abyssPointsDay];
        
        _abyssPointsWeek = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_abyssPointsDay.frame, 0)];
        [_abyssPointsWeek setBackgroundColor:[UIColor clearColor]];
        [_abyssPointsWeek setTextColor:[UIColor whiteColor]];
        [_abyssPointsWeek setTextAlignment:UITextAlignmentRight];
        [_abyssPointsWeek setFont:[UIFont systemFontOfSize:14.0]];
        [abyssInfoView addSubview:_abyssPointsWeek];
        
        _abyssPointsAll = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(_abyssPointsWeek.frame, 0)];
        [_abyssPointsAll setBackgroundColor:[UIColor clearColor]];
        [_abyssPointsAll setTextColor:[UIColor whiteColor]];
        [_abyssPointsAll setTextAlignment:UITextAlignmentRight];
        [_abyssPointsAll setFont:[UIFont systemFontOfSize:14.0]];
        [abyssInfoView addSubview:_abyssPointsAll];
        
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(_abyssKillsDay.frame, -25)];
        [dayLabel setHeight:10.0];
        [dayLabel setBackgroundColor:[UIColor clearColor]];
        [dayLabel setTextColor:[UIColor whiteColor]];
        [dayLabel setFont:[UIFont systemFontOfSize:10]];
        [dayLabel setTextAlignment:UITextAlignmentRight];
        [dayLabel setText:@"DAY"];
        [abyssInfoView addSubview:dayLabel];
        
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(dayLabel.frame, 0)];
        [weekLabel setBackgroundColor:[UIColor clearColor]];
        [weekLabel setTextColor:[UIColor whiteColor]];
        [weekLabel setFont:[UIFont systemFontOfSize:10]];
        [weekLabel setTextAlignment:UITextAlignmentRight];
        [weekLabel setText:@"WEEK"];
        [abyssInfoView addSubview:weekLabel];
        
        UILabel *allLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(weekLabel.frame, 0)];
        [allLabel setBackgroundColor:[UIColor clearColor]];
        [allLabel setTextColor:[UIColor whiteColor]];
        [allLabel setFont:[UIFont systemFontOfSize:10]];
        [allLabel setTextAlignment:UITextAlignmentRight];
        [allLabel setText:@"ALL"];
        [abyssInfoView addSubview:allLabel];
        
        //////
        //Character Information Setup
        //////
        UIView *characterInfoView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, CONTAINER_WIDTH+20, 60)];
        [characterInfoView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackmamba.png"]]];
        [characterInfoView.layer setShadowColor:[UIColor blackColor].CGColor];
        [characterInfoView.layer setShadowOffset:CGSizeMake(0, 2.0f)];
        [characterInfoView.layer setShadowRadius:3.0f];
        [characterInfoView.layer setShadowOpacity:1];
        [characterInfoView.layer setBorderColor:[UIColor blackColor].CGColor];
        [characterInfoView.layer setBorderWidth:1.0];
        
        _classIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 2, 56, 56)];
        [characterInfoView addSubview:_classIcon];
        
        _levelClassLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 20)];
        [_levelClassLabel setBackgroundColor:[UIColor clearColor]];
        [_levelClassLabel setTextColor:[UIColor whiteColor]];
        [_levelClassLabel setTextAlignment:UITextAlignmentCenter];
        [_levelClassLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        [_levelClassLabel setShadowColor:[UIColor darkTextColor]];
        [_levelClassLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [characterInfoView addSubview:_levelClassLabel];
        
        _legionLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(_levelClassLabel.frame, 0)];
        [_legionLabel setHeight:18.0];
        [_legionLabel setBackgroundColor:[UIColor clearColor]];
        [_legionLabel setTextColor:[UIColor whiteColor]];
        [_legionLabel setTextAlignment:UITextAlignmentCenter];
        [_legionLabel setFont:[UIFont systemFontOfSize:14.0]];
        [characterInfoView addSubview:_legionLabel];
        
        _abyssTitleLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_Y(_legionLabel.frame, 0)];
        [_abyssTitleLabel setHeight:20.0];
        [_abyssTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_abyssTitleLabel setTextColor:[UIColor whiteColor]];
        [_abyssTitleLabel setTextAlignment:UITextAlignmentCenter];
        [_abyssTitleLabel setFont:[UIFont systemFontOfSize:18.0]];
        [_abyssTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [characterInfoView addSubview:_abyssTitleLabel];
        
        [statsContent addSubview:characterInfoView];
        
        //////
        // Navigation Helpers
        //////
        UIView *navigationHelpersContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _informationScrollView.height-12, 960.0f, 12.0f)];
        [navigationHelpersContainer setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_informationScrollView addSubview:navigationHelpersContainer];
        
        UILabel *toEquipmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 12)];
        [toEquipmentLabel setTextColor:[UIColor whiteColor]];
        [toEquipmentLabel setBackgroundColor:[UIColor clearColor]];
        [toEquipmentLabel setTextAlignment:UITextAlignmentRight];
        [toEquipmentLabel setFont:[UIFont systemFontOfSize:10.0]];
        [toEquipmentLabel setShadowColor:[UIColor darkTextColor]];
        [toEquipmentLabel setShadowOffset:CGSizeMake(0, -1.0f)];
        [toEquipmentLabel setText:@"EQUIPMENT >>"];
        [navigationHelpersContainer addSubview:toEquipmentLabel];
        
        UILabel *toStatsLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(toEquipmentLabel.frame, 10)];
        [toStatsLabel setTextColor:[UIColor whiteColor]];
        [toStatsLabel setBackgroundColor:[UIColor clearColor]];
        [toStatsLabel setFont:[UIFont systemFontOfSize:10.0]];
        [toStatsLabel setShadowColor:[UIColor darkTextColor]];
        [toStatsLabel setShadowOffset:CGSizeMake(0, -1.0f)];
        [toStatsLabel setText:@"<< STATS"];
        [navigationHelpersContainer addSubview:toStatsLabel];
        
        UILabel *toStigmasLabel = [[UILabel alloc] initWithFrame:toStatsLabel.frame];
        [toStigmasLabel setTextColor:[UIColor whiteColor]];
        [toStigmasLabel setBackgroundColor:[UIColor clearColor]];
        [toStigmasLabel setFont:[UIFont systemFontOfSize:10.0]];
        [toStigmasLabel setTextAlignment:UITextAlignmentRight];
        [toStigmasLabel setShadowColor:[UIColor darkTextColor]];
        [toStigmasLabel setShadowOffset:CGSizeMake(0, -1.0f)];
        [toStigmasLabel setText:@"STIGMAS >>"];
        [navigationHelpersContainer addSubview:toStigmasLabel];
        
        UILabel *toEquipment2Label = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(toStatsLabel.frame, 10)];
        [toEquipment2Label setTextColor:[UIColor whiteColor]];
        [toEquipment2Label setBackgroundColor:[UIColor clearColor]];
        [toEquipment2Label setFont:[UIFont systemFontOfSize:10.0]];
        [toEquipment2Label setShadowColor:[UIColor darkTextColor]];
        [toEquipment2Label setShadowOffset:CGSizeMake(0, -1.0f)];
        [toEquipment2Label setText:@"<< EQUIPMENT"];
        [navigationHelpersContainer addSubview:toEquipment2Label];
        
        [self.view addSubview:_informationScrollView];
        
        _didLoadCharacterData = NO;
        
        _navigationBarHeader = [[UIView alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
        [_navigationBarHeader setBackgroundColor:[UIColor clearColor]];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 200, 30)];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_nameLabel setShadowColor:[UIColor darkGrayColor]];
        [_nameLabel setShadowOffset:CGSizeMake(0, -1)];
        [_nameLabel setTextAlignment:UITextAlignmentCenter];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
        [_navigationBarHeader addSubview:_nameLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 200, 14)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setShadowColor:[UIColor darkGrayColor]];
        [_titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [_titleLabel setTextAlignment:UITextAlignmentCenter];
        [_titleLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_navigationBarHeader addSubview:_titleLabel];
        
        [self.navigationItem setTitleView:_navigationBarHeader];
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [_informationScrollView setContentSize:CGSizeMake(960, _informationScrollView.height-44)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_didLoadCharacterData) {
        _characterDetailsOperation = [APP_DELEGATE.aionOnlineEngine
                                      detailsForCharacterId:_characterId
                                      onServer:_serverId
                                      onCompletion:^(NSDictionary *results) {
                                          _characterData = results;
                                          [self updateCharacterInformation];
                                          _didLoadCharacterData = YES;
                                      }
                                      onError:^(NSError *error) {
                                          [YRDropdownView showDropdownInView:self.view
                                                                       title:@"Server Error"
                                                                      detail:@"The Aion Online website responded with an error.\nThis character's data is cached and may be unavailable or out of date."
                                                                    animated:YES];
                                      }];
    }
    
    if ([userDefaults boolForKey:didPayPremium]) {
        
    } else {
        [[GADMasterViewController sharedInstance] resetAdView:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_characterDetailsOperation cancel];
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

- (void)updateCharacterInformation
{
    NSDictionary *characterDetails = [_characterData objectForKey:@"characterInfo"];
    [_classIcon setImage:[self getIconForClass:[[characterDetails valueForKey:@"classCode"] integerValue]]];
    [_levelClassLabel setText:[NSString stringWithFormat:@"%@ %@", [characterDetails valueForKey:@"level"], [characterDetails valueForKey:@"className"]]];
    
    if (((NSString *)[characterDetails valueForKey:@"guildName"]).length > 0) {
        [_legionLabel setText:[NSString stringWithFormat:@"<%@>", [characterDetails valueForKey:@"guildName"]]];
    }
    else {
        [_legionLabel setText:@"No Legion"];
    }
    
    switch ([[characterDetails valueForKey:@"raceCode"] integerValue]) {
        case 0:
            [_raceIcon setImage:[UIImage imageNamed:@"Elyos.png"]];
            break;
        case 1:
            [_raceIcon setImage:[UIImage imageNamed:@"Asmodian.png"]];
            break;
    }
    
    [_nameLabel setText:[characterDetails valueForKey:@"charName"]];
    
    NSDictionary *titleDictionary = [characterDetails objectForKey:@"fittedTitle"];
    if (((NSString *)[titleDictionary valueForKey:@"fittedTitleName"]).length > 0) {
        [_titleLabel setText:[titleDictionary valueForKey:@"fittedTitleName"]];
    }
    else {
        [_titleLabel setText:@"No Title"];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    
    NSDictionary *abyssDictionary = [_characterData objectForKey:@"abyss"];
    [_abyssKillsDay setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[abyssDictionary valueForKey:@"todayAbyssKillCnt"] integerValue]]]];
    [_abyssKillsWeek setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[abyssDictionary valueForKey:@"thisWeekAbyssKillCnt"] integerValue]]]];
    [_abyssKillsAll setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[abyssDictionary valueForKey:@"totalAbyssKillCnt"] integerValue]]]];
    [_abyssPointsDay setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[abyssDictionary valueForKey:@"todayAbyssPoint"] integerValue]]]];
    [_abyssPointsWeek setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[abyssDictionary valueForKey:@"thisWeekAbyssPoint"] integerValue]]]];
    [_abyssPointsAll setText:[numberFormatter stringFromNumber:[NSNumber numberWithInt:[[abyssDictionary valueForKey:@"abyssPoint"] integerValue]]]];
    [_abyssTitleLabel setText:[abyssDictionary valueForKey:@"currentName"]];
    
    //////
    // Stats Table View
    //////
    [_statsViewController setStatsDictionary:[_characterData objectForKey:@"stat"]];
    [_statsViewController.tableView reloadData];
    [_statsViewController updateTableHeaderView];
    
    //////
    // Equipment Table View
    //////
    NSMutableDictionary *equipmentDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dictionary in [_characterData objectForKey:@"itemList"]) {
        [equipmentDictionary setObject:dictionary forKey:[[dictionary valueForKey:@"positionCode"] stringValue]];
    }
    
    [_equipmentViewController setEquipmentDictionary:equipmentDictionary];
    [_equipmentViewController setCharacterId:[characterDetails valueForKey:@"charID"]];
    [_equipmentViewController setServerId:[characterDetails valueForKey:@"serverID"]];
    [_equipmentViewController.tableView reloadData];
}

- (UIImage *)getIconForClass:(NSInteger)classId
{
    UIImage *classImage;
    
    switch (classId) {
        case 0:
		{
			classImage = [UIImage imageNamed:@"warrior.png"];
			break;
		}
		case 1:
		{
			classImage = [UIImage imageNamed:@"gladiator.png"];
			break;
		}
		case 2:
		{
			classImage = [UIImage imageNamed:@"templar.png"];
			break;
		}
		case 3:
		{
			classImage = [UIImage imageNamed:@"scout.png"];
			break;
		}
		case 4:
		{
			classImage = [UIImage imageNamed:@"assassin.png"];
			break;
		}
		case 5:
		{
			classImage = [UIImage imageNamed:@"ranger.png"];
			break;
		}
		case 6:
		{
			classImage = [UIImage imageNamed:@"mage.png"];
			break;
		}
		case 7:
		{
			classImage = [UIImage imageNamed:@"sorcerer.png"];
			break;
		}
		case 8:
		{
			classImage = [UIImage imageNamed:@"spiritmaster.png"];
			break;
		}
		case 9:
		{
			classImage = [UIImage imageNamed:@"priest.png"];
			break;
		}
		case 10:
		{
			classImage = [UIImage imageNamed:@"cleric.png"];
			break;
		}
		case 11:
		{
			classImage = [UIImage imageNamed:@"chanter.png"];
			break;
		}
    }
    
    return classImage;
}

#pragma mark - Page View Controller


@end
