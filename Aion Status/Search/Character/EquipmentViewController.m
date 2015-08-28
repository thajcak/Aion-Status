//
//  EquipmentViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/7/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "EquipmentViewController.h"
#import "EquipmentDetailsViewController.h"

#import "AionOnlineStaticEngine.h"

@interface EquipmentViewController ()

@end

@implementation EquipmentViewController

@synthesize equipmentDictionary = _equipmentDictionary;
@synthesize characterId = _characterId;
@synthesize serverId = _serverId;
@synthesize characterViewController = _characterViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setRowHeight:30.0];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setSectionHeaderHeight:12.0];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//        [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)]];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
        case 1:
            return 2;
        case 2:
            return 5;
        case 3:
            return 7;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 12)];
    [sectionHeaderView setBackgroundColor:[UIColor darkTextColor]];
    
    UILabel *sectionHeaderLabel = [[UILabel alloc] initWithFrame:sectionHeaderView.frame];
    [sectionHeaderLabel setTextAlignment:UITextAlignmentCenter];
    [sectionHeaderLabel setFont:[UIFont systemFontOfSize:10.0]];
    [sectionHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [sectionHeaderLabel setTextColor:[UIColor whiteColor]];
    [sectionHeaderView addSubview:sectionHeaderLabel];
    
    switch (section) {
        case 0:
            [sectionHeaderLabel setText:@"MAIN HAND WEAPONS"];
            break;
        case 1:
            [sectionHeaderLabel setText:@"OFF HAND WEAPONS"];
            break;
        case 2:
            [sectionHeaderLabel setText:@"ARMOR"];
            break;
        case 3:
            [sectionHeaderLabel setText:@"ACCESSORIES"];
            break;
    }
    
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Equipment Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView *equipmentImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 26, 26)];
        [equipmentImage setTag:100];
        [equipmentImage.layer setCornerRadius:8.0f];
        [equipmentImage setClipsToBounds:YES];
        [cell.contentView addSubview:equipmentImage];
        
        UILabel *itemLevelLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(equipmentImage.frame, 2)];
        [itemLevelLabel setTag:110];
        [itemLevelLabel setBackgroundColor:[UIColor clearColor]];
        [itemLevelLabel setTextAlignment:UITextAlignmentCenter];
        [cell.contentView addSubview:itemLevelLabel];
        
        UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(itemLevelLabel.frame, 2)];
        [itemNameLabel setWidth:222.0];
        [itemNameLabel setTag:111];
        [itemNameLabel setBackgroundColor:[UIColor clearColor]];
        [itemNameLabel setShadowColor:[UIColor darkGrayColor]];
        [itemNameLabel setShadowOffset:CGSizeMake(0.0f, -0.1f)];
        [cell.contentView addSubview:itemNameLabel];
    }
    
    // Clear existing Data
    
    UIImageView *equipmentImage = (UIImageView *)[cell viewWithTag:100];
    UILabel *itemLevelLabel = (UILabel *)[cell viewWithTag:110];
    UILabel *itemNameLabel = (UILabel *)[cell viewWithTag:111];
    
    [equipmentImage setImage:nil];
    [itemLevelLabel setText:nil];
    [itemNameLabel setText:nil];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Configure the cell...
    
    NSDictionary *thisPiece = [_equipmentDictionary objectForKey:[self getPositionCodeForIndexPath:indexPath]];
        
    NSString *itemName = [thisPiece valueForKey:@"itemName"];
    if (itemName.length > 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        NSInteger enchantCount = [[thisPiece valueForKey:@"enchantCount"] integerValue];
        if (enchantCount > 0) {
            [itemNameLabel setText:[NSString stringWithFormat:@"+%i %@", enchantCount, itemName]];
        }
        else {
            [itemNameLabel setText:itemName];
        }
        
        NSString *itemQuality = [thisPiece valueForKey:@"quality"];
        if ([itemQuality isEqualToString:@"common"]) {
            [itemNameLabel setTextColor:COMMON_COLOR];
        }
        else if ([itemQuality isEqualToString:@"rare"]) {
            [itemNameLabel setTextColor:RARE_COLOR];
        }
        else if ([itemQuality isEqualToString:@"legend"]) {
            [itemNameLabel setTextColor:LEGEND_COLOR];
        }
        else if ([itemQuality isEqualToString:@"unique"]) {
            [itemNameLabel setTextColor:UNIQUE_COLOR];
        }
        else if ([itemQuality isEqualToString:@"epic"]) {
            [itemNameLabel setTextColor:EPIC_COLOR];
        }
        else {
            [itemNameLabel setTextColor:[UIColor grayColor]];
        }
        
        [itemLevelLabel setText:[thisPiece valueForKey:@"level"]];
        
        NSURL *imageURL = [NSURL URLWithString:[thisPiece valueForKey:@"imageUrl"]];
        [APP_DELEGATE.aionOnlineStaticEngine imageAtURL:imageURL
                                           onCompletion:^(UIImage *fetchedImage, NSURL *fetchUrl, BOOL isInCache) {
                                               if (imageURL == fetchUrl) {
                                                   if (isInCache) {
                                                       [equipmentImage setImage:fetchedImage];
                                                   }
                                                   else {
                                                       [equipmentImage setAlpha:0];
                                                       [equipmentImage setImage:fetchedImage];
                                                       [UIView animateWithDuration:0.4
                                                                        animations:^{
                                                                            [equipmentImage setAlpha:1];
                                                                        }];
                                                   }
                                               }
                                           }];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (UITableViewCellAccessoryDisclosureIndicator == cell.accessoryType) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        EquipmentDetailsViewController *edVC = [[EquipmentDetailsViewController alloc] init];
        [edVC setPieceDictionary:[_equipmentDictionary objectForKey:[self getPositionCodeForIndexPath:indexPath]]];
        [edVC setCharacterId:_characterId];
        [edVC setServerId:_serverId];
        
        UINavigationController *edNC = [[UINavigationController alloc] initWithRootViewController:edVC];
        [edNC.navigationBar setTintColor:[UIColor blackColor]];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:edVC
                                                                      action:SEL(dismissModalViewControllerAnimated:)];
        [edVC.navigationItem setLeftBarButtonItem:doneButton];
        
        [_characterViewController presentModalViewController:edNC animated:YES];
    }
}

#pragma mark - Actions

- (NSString *)getPositionCodeForIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:     // Main Hand Weapons
        {
            switch (indexPath.row) {
                case 0:
                    return @"1";
                case 1:
                    return @"3";
            }
            break;
        }
        case 1:     // Off Hand Weapons
        {
            switch (indexPath.row) {
                case 0:
                    return @"2";
                case 1:
                    return @"4";
            }
            break;
        }
        case 2:     // Armor
        {
            switch (indexPath.row) {
                case 0:
                    return @"11";
                case 1:
                    return @"12";
                case 2:
                    return @"13";
                case 3:
                    return @"14";
                case 4:
                    return @"17";
            }
            break;
        }
        case 3:     // Accessories
        {
            switch (indexPath.row) {
                case 0:
                    return @"7";
                case 1:
                    return @"8";
                case 2:
                    return @"9";
                case 3:
                    return @"10";
                case 4:
                    return @"15";
                case 5:
                    return @"16";
                case 6:
                    return @"18";
            }
            break;
        }
    }
    
    return @"0";
}

@end
