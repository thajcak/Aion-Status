//
//  CharacterStatsViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/7/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "CharacterStatsViewController.h"

@interface CharacterStatsViewController ()
{
    UIView *_headerView;
    UILabel *_hpLabel;
    UILabel *_mpLabel;
}

@end

@implementation CharacterStatsViewController

@synthesize statsDictionary = _statsDictionary;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    [_headerView setBackgroundColor:[UIColor clearColor]];
    
    _hpLabel = [[UILabel alloc] initWithFrame:RECT_INSET_BY_LEFT_RIGHT(_headerView.frame, 0, 160)];
    [_hpLabel setBackgroundColor:[UIColor clearColor]];
    [_hpLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [_hpLabel setTextAlignment:UITextAlignmentCenter];
    [_hpLabel setTextColor:[UIColor colorWithHexString:@"DE4241"]];
    [_headerView addSubview:_hpLabel];
    
    _mpLabel = [[UILabel alloc] initWithFrame:RECT_INSET_BY_LEFT_RIGHT(_headerView.frame, 160, 0)];
    [_mpLabel setBackgroundColor:[UIColor clearColor]];
    [_mpLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [_mpLabel setTextAlignment:UITextAlignmentCenter];
    [_mpLabel setTextColor:[UIColor colorWithHexString:@"41B1E0"]];
    [_headerView addSubview:_mpLabel];
    
    [self.tableView setTableHeaderView:_headerView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setRowHeight:15.0];
    [self.tableView setSectionHeaderHeight:12.0];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 10)]];
    
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            // Physical Offense
            return 6;
        case 1:
            // Magical Offense
            return 5;
        case 2:
            // Physical Defense
            return 4;
        case 3:
            // Magical Defense
            return 5;
        case 4:
            // Critical Defense
            return 4;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 14)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:sectionHeaderView.frame];
    [headerLabel setBackgroundColor:[UIColor lightTextColor]];
    [headerLabel setTextAlignment:UITextAlignmentCenter];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
    
    NSString *headerText;
    switch (section) {
        case 0:
            headerText = @"⇓ PHYSICAL OFFENSE ⇓";
            break;
        case 1:
            headerText = @"⇓ MAGICAL OFFENSE ⇓";
            break;
        case 2:
            headerText = @"⇓ PHYSICAL DEFENSE ⇓";
            break;
        case 3:
            headerText = @"⇓ MAGICAL RESISTANCE ⇓";
            break;
        case 4:
            headerText = @"⇓ CRITICAL DEFENSE ⇓";
            break;
    }
    
    [headerLabel setText:headerText];
    [sectionHeaderView addSubview:headerLabel];
    
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DoubleValueCell = @"Double Value Cell";
    static NSString *TripleValueCell = @"Triple Value Cell";
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:TripleValueCell];
            break;
        case 1:
        case 2:
        case 3:
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:DoubleValueCell];
            break;
    }
    
    if (nil == cell) {
        switch (indexPath.section) {
            case 0:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TripleValueCell];
                
                UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 112, 15)];
                [keyLabel setTag:100];
                [keyLabel setBackgroundColor:[UIColor clearColor]];
                [keyLabel setFont:[UIFont systemFontOfSize:12.0]];
                [keyLabel setTextColor:[UIColor blackColor]];
                [cell.contentView addSubview:keyLabel];
                
                UILabel *value1Label = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(keyLabel.frame, 0)];
                [value1Label setWidth:86];
                [value1Label setTag:110];
                [value1Label setBackgroundColor:[UIColor clearColor]];
                [value1Label setFont:[UIFont systemFontOfSize:12.0]];
                [value1Label setTextColor:[UIColor blackColor]];
                [value1Label setTextAlignment:UITextAlignmentRight];
                [cell.contentView addSubview:value1Label];
                
                UILabel *value2Label = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(value1Label.frame, 0)];
                [value2Label setTag:111];
                [value2Label setBackgroundColor:[UIColor clearColor]];
                [value2Label setFont:[UIFont systemFontOfSize:12.0]];
                [value2Label setTextColor:[UIColor blackColor]];
                [value2Label setTextAlignment:UITextAlignmentRight];
                [cell.contentView addSubview:value2Label];
                
                break;
            }
            case 1:
            case 2:
            case 3:
            case 4:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DoubleValueCell];
                
                UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 142, 15)];
                [keyLabel setTag:100];
                [keyLabel setBackgroundColor:[UIColor clearColor]];
                [keyLabel setFont:[UIFont systemFontOfSize:12.0]];
                [keyLabel setTextColor:[UIColor blackColor]];
                [cell.contentView addSubview:keyLabel];
                
                UILabel *value1Label = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(keyLabel.frame, 0)];
                [value1Label setTag:110];
                [value1Label setBackgroundColor:[UIColor clearColor]];
                [value1Label setFont:[UIFont systemFontOfSize:12.0]];
                [value1Label setTextColor:[UIColor blackColor]];
                [value1Label setTextAlignment:UITextAlignmentRight];
                [cell.contentView addSubview:value1Label];
                break;
            }
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Clear existing data
    
    UILabel *keyLabel = (UILabel *)[cell viewWithTag:100];    
    UILabel *value1Label = (UILabel *)[cell viewWithTag:110];
    UILabel *value2Label = (UILabel *)[cell viewWithTag:111];
    
    [keyLabel setText:@""];
    [value1Label setText:@""];
    [value2Label setText:@""];
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case 0:     //Physical Offense
            switch (indexPath.row) {
                case 0:
                {
                    [value1Label setText:@"Main Hand"];
                    [value2Label setText:@"Off Hand"];
                    break;
                }   
                case 1:
                {
                    [keyLabel setText:@"Attack"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"physicalRight"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"basePhysicalRight"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    NSInteger total2Value = [[_statsDictionary valueForKey:@"physicalLeft"] integerValue];
                    NSInteger base2Value = [[_statsDictionary valueForKey:@"basePhysicalLeft"] integerValue];
                    if (total2Value > base2Value) {
                        [value2Label setText:[NSString stringWithFormat:@"%i (+%i)", total2Value, (total2Value - base2Value)]];
                    }
                    else {
                        [value2Label setText:[NSString stringWithFormat:@"%i", total2Value]];
                    }
                    
                    break;
                }
                case 2:
                {
                    [keyLabel setText:@"Accuracy"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"accuracyRight"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseAccuracyRight"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    NSInteger total2Value = [[_statsDictionary valueForKey:@"accuracyLeft"] integerValue];
                    NSInteger base2Value = [[_statsDictionary valueForKey:@"baseAccuracyLeft"] integerValue];
                    if (total2Value > base2Value) {
                        [value2Label setText:[NSString stringWithFormat:@"%i (+%i)", total2Value, (total2Value - base2Value)]];
                    }
                    else {
                        [value2Label setText:[NSString stringWithFormat:@"%i", total2Value]];
                    }
                    
                    break;
                }
                case 3:
                {
                    [keyLabel setText:@"Critical Strike"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"criticalRight"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseCriticalRight"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    NSInteger total2Value = [[_statsDictionary valueForKey:@"criticalLeft"] integerValue];
                    NSInteger base2Value = [[_statsDictionary valueForKey:@"baseCriticalLeft"] integerValue];
                    if (total2Value > base2Value) {
                        [value2Label setText:[NSString stringWithFormat:@"%i (+%i)", total2Value, (total2Value - base2Value)]];
                    }
                    else {
                        [value2Label setText:[NSString stringWithFormat:@"%i", total2Value]];
                    }
                    
                    break;
                }
                case 4:
                {
                    [keyLabel setText:@"Attack Speed"];
                    
                    double total2Value = [[_statsDictionary valueForKey:@"attackSpeed"] doubleValue];
                    double base2Value = [[_statsDictionary valueForKey:@"baseAttackSpeed"] doubleValue];
                    if (total2Value > base2Value) {
                        [value2Label setText:[NSString stringWithFormat:@"%g (+%g)", total2Value, (total2Value - base2Value)]];
                    }
                    else {
                        [value2Label setText:[NSString stringWithFormat:@"%g", total2Value]];
                    }
                    
                    break;
                }
                case 5:
                {
                    [keyLabel setText:@"Movement Speed"];
                    
                    double total2Value = [[_statsDictionary valueForKey:@"moveSpeed"] doubleValue];
                    double base2Value = [[_statsDictionary valueForKey:@"baseMoveSpeed"] doubleValue];
                    if (total2Value > base2Value) {
                        [value2Label setText:[NSString stringWithFormat:@"%g (+%g)", total2Value, (total2Value - base2Value)]];
                    }
                    else {
                        [value2Label setText:[NSString stringWithFormat:@"%g", total2Value]];
                    }
                    
                    break;
                }
            }
            break;
        case 1:     //Magical Offense
        {
            switch (indexPath.row) {
                case 0:
                {
                    [keyLabel setText:@"Magic Boost"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"magicalBoost"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseMagicalBoost"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 1:
                {
                    [keyLabel setText:@"Healing Boost"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"HealBoost"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseHealBoost"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 2:
                {
                    [keyLabel setText:@"Magical Accuracy"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"magicalAccuracy"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseMagicalAccuracy"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 3:
                {
                    [keyLabel setText:@"Critical Spell"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"magicalCriticalRight"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseMagicalCriticalRight"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 4:
                {
                    [keyLabel setText:@"Casting Speed"];
                    
                    double total1Value = [[_statsDictionary valueForKey:@"castingTimeRatio"] doubleValue];
                    double base1Value = [[_statsDictionary valueForKey:@"baseCastingTimeRatio"] doubleValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%g (+%g)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%g", total1Value]];
                    }
                    
                    break;
                }
            }
            break;
        }
        case 2:     // Physical Defense
        {
            switch (indexPath.row) {
                case 0:
                {
                    [keyLabel setText:@"Physical Defense"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"physicalDefend"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"basePhysicalDefend"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 1:
                {
                    [keyLabel setText:@"Block"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"block"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseBlock"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 2:
                {
                    [keyLabel setText:@"Parry"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"parry"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseParry"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 3:
                {
                    [keyLabel setText:@"Evasion"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"dodge"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseDodge"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
            }
            break;
        }
        case 3:     //Magical Resistance
        {
            switch (indexPath.row) {
                case 0:
                {
                    [keyLabel setText:@"Magic Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"magicResist"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseMagicResist"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 1:
                {
                    [keyLabel setText:@"Earth Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"earthResist"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseEarthResist"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 2:
                {
                    [keyLabel setText:@"Air Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"airResist"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseAirResist"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 3:
                {
                    [keyLabel setText:@"Fire Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"fireResist"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseFireResist"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 4:
                {
                    [keyLabel setText:@"Water Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"waterResist"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseWaterResist"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
            }
            break;
        }
        case 4:     // Critical Defense
        {
            switch (indexPath.row) {
                case 0:
                {
                    [keyLabel setText:@"Physical Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"phyCriticalReduceRate"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"basePhyCriticalReduceRate"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 1:
                {
                    [keyLabel setText:@"Physical Fortitude"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"phyCriticalDamageReduce"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"basePhyCriticalDamageReduce"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 2:
                {
                    [keyLabel setText:@"Spell Resistance"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"magCriticalReduceRate"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseMagCriticalReduceRate"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
                case 3:
                {
                    [keyLabel setText:@"Spell Fortitude"];
                    
                    NSInteger total1Value = [[_statsDictionary valueForKey:@"magCriticalDamageReduce"] integerValue];
                    NSInteger base1Value = [[_statsDictionary valueForKey:@"baseMagCriticalDamageReduce"] integerValue];
                    if (total1Value > base1Value) {
                        [value1Label setText:[NSString stringWithFormat:@"%i (+%i)", total1Value, (total1Value - base1Value)]];
                    }
                    else {
                        [value1Label setText:[NSString stringWithFormat:@"%i", total1Value]];
                    }
                    
                    break;
                }
            }
            break;
        }
    }
    
    return cell;
}

#pragma mark - Actions

- (void)updateTableHeaderView
{
    [_hpLabel setText:[[_statsDictionary valueForKey:@"hp"] stringValue]];
    [_mpLabel setText:[[_statsDictionary valueForKey:@"mp"] stringValue]];
    [self.tableView setTableHeaderView:_headerView];
}

@end
