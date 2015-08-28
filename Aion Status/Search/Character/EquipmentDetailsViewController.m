//
//  EquipmentDetailsViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/8/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "EquipmentDetailsViewController.h"

#import "AionOnlineEngine.h"

@interface EquipmentDetailsViewController ()
{
    MKNetworkOperation *_equipmentDetailsOperation;
    
    NSDictionary *_equipmentDetails;
    
    UIView *_navBarTitleView;
    UILabel *_itemNameLabel;
}
@end

@implementation EquipmentDetailsViewController

@synthesize pieceDictionary = _pieceDictionary;
@synthesize characterId = _characterId;
@synthesize serverId = _serverId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setRowHeight:22.0];
        
        _navBarTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [self.navigationItem setTitleView:_navBarTitleView];
        
        _itemNameLabel = [[UILabel alloc] initWithFrame:_navBarTitleView.frame];
        [_itemNameLabel setBackgroundColor:[UIColor clearColor]];
        [_itemNameLabel setShadowColor:[UIColor darkGrayColor]];
        [_itemNameLabel setShadowOffset:CGSizeMake(0, -1)];
        [_itemNameLabel setNumberOfLines:2];
        [_itemNameLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        [_itemNameLabel setTextAlignment:UITextAlignmentCenter];
        [_navBarTitleView addSubview:_itemNameLabel];
        
        [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper.png"]]];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _equipmentDetailsOperation = [APP_DELEGATE.aionOnlineEngine equipmentInformationForCharacterId:_characterId
                                                                                          serverId:_serverId
                                                                                            nameId:[_pieceDictionary valueForKey:@"itemNameID"]
                                                                                      positionName:[_pieceDictionary valueForKey:@"positionName"]
                                                                                      onCompletion:^(NSDictionary *results) {
                                                                                          _equipmentDetails = results;
                                                                                          [self.tableView reloadData];
                                                                                      }
                                                                                           onError:^(NSError *error) {
                                                                                               [IBAlertView  showAlertWithTitle:[error domain]
                                                                                                                        message:[error localizedDescription]
                                                                                                                   dismissTitle:@"Okay"
                                                                                                                   dismissBlock:^{}];
                                                                                           }];

    NSString *itemName = [_pieceDictionary valueForKey:@"itemName"];
    
    NSInteger enchantCount = [[_pieceDictionary valueForKey:@"enchantCount"] integerValue];
    if (enchantCount > 0) {
        [_itemNameLabel setText:[NSString stringWithFormat:@"+%i %@", enchantCount, itemName]];
    }
    else {
        [_itemNameLabel setText:itemName];
    }
    
    NSString *itemQuality = [_pieceDictionary valueForKey:@"quality"];
    if ([itemQuality isEqualToString:@"common"]) {
        [_itemNameLabel setTextColor:COMMON_COLOR];
    }
    else if ([itemQuality isEqualToString:@"rare"]) {
        [_itemNameLabel setTextColor:RARE_COLOR];
    }
    else if ([itemQuality isEqualToString:@"legend"]) {
        [_itemNameLabel setTextColor:LEGEND_COLOR];
    }
    else if ([itemQuality isEqualToString:@"unique"]) {
        [_itemNameLabel setTextColor:UNIQUE_COLOR];
    }
    else if ([itemQuality isEqualToString:@"epic"]) {
        [_itemNameLabel setTextColor:EPIC_COLOR];
    }
    else {
        [_itemNameLabel setTextColor:[UIColor grayColor]];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_equipmentDetailsOperation cancel];
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
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *thisSection = [[self dictionaryForSection:section] allKeys];
    
    if (section != 0 && [thisSection count] > 0) {
        return 23.0f;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *thisSection = [[self dictionaryForSection:section] allKeys];

    if (section != 0 && [thisSection count] > 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)];
        [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"concrete_wall.png"]]];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.frame];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [headerLabel setTextAlignment:UITextAlignmentCenter];
        [headerLabel setShadowColor:[UIColor darkGrayColor]];
        [headerLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [headerView addSubview:headerLabel];
        
        switch (section) {
            case 1:
                [headerLabel setText:@"Stats"];
                break;
            case 2:
                [headerLabel setText:@"Bonuses"];
                break;
            case 3:
                [headerLabel setText:@"Armsfusion Bonuses"];
                break;
            case 4:
                [headerLabel setText:@"Manastones"];
                break;
            case 5:
                [headerLabel setText:@"Armsfusion Manastones"];
                break;
            case 6:
                [headerLabel setText:@"Godstone"];
                break;
            case 7:
            {
                NSString *itemSetName = [[self dictionaryForSection:section] valueForKey:@"setItemName"];
                NSString *itemsEquiped = [[self dictionaryForSection:section] valueForKey:@"setItemUsingCount"];
                NSString *itemsInSet = [[self dictionaryForSection:section] valueForKey:@"setItemCount"];
                [headerLabel setText:[NSString stringWithFormat:@"%@ (%@/%@)", itemSetName, itemsEquiped, itemsInSet]];
                break;
            }
            case 8:
            {
                [headerLabel setText:@"Equip Effect (2 Items)"];
                [headerLabel setTextColor:[self headerTextColorForBonusSet:2]];
                break;
            }
            case 9:
            {
                [headerLabel setText:@"Equip Effect (3 Items)"];
                [headerLabel setTextColor:[self headerTextColorForBonusSet:3]];
                break;
            }
            case 10:
            {
                [headerLabel setText:@"Equip Effect (4 Items)"];
                [headerLabel setTextColor:[self headerTextColorForBonusSet:4]];
                break;
            }
            case 11:
            {
                [headerLabel setText:@"Equip Effect (5 Items)"];
                [headerLabel setTextColor:[self headerTextColorForBonusSet:5]];
                break;
            }
        }
        
        return headerView;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [self dictionaryForSection:section];
    switch (section) {
        case 0:
        {
            return ([[sectionDictionary allKeys] count] - 5);
        }
        case 7:
        {
            return ([[sectionDictionary allKeys] count] - 3);
        }
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 8:
        case 9:
        case 10:
        case 11:
        {
            return [[sectionDictionary allKeys] count];
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    return 21.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 152, 20)];
        [keyLabel setTag:100];
        [keyLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:keyLabel];
        
        UILabel *keyItemSetLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 255, 20)];
        [keyItemSetLabel setTag:101];
        [keyItemSetLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:keyItemSetLabel];
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:RECT_STACKED_OFFSET_BY_X(keyLabel.frame, 0)];
        [valueLabel setTag:110];
        [valueLabel setBackgroundColor:[UIColor clearColor]];
        [valueLabel setTextAlignment:UITextAlignmentRight];
        [cell.contentView addSubview:valueLabel];
        
        UILabel *centeredValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 304, 20)];
        [centeredValueLabel setTag:120];
        [centeredValueLabel setBackgroundColor:[UIColor clearColor]];
        [centeredValueLabel setTextAlignment:UITextAlignmentCenter];
        [cell.contentView addSubview:centeredValueLabel];
    }
    
    // Clear existing data
    
    UILabel *keyLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *keySetItemLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:110];
    UILabel *centeredValueLabel = (UILabel *)[cell viewWithTag:120];
    
    [keyLabel setText:nil];
    [keySetItemLabel setText:nil];
    [valueLabel setText:nil];
    [centeredValueLabel setText:nil];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    // Configure the cell...
    
    NSDictionary *sectionDictionary = [self dictionaryForSection:indexPath.section];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    [keyLabel setText:@"Grade"];
                    [valueLabel setText:[sectionDictionary valueForKey:@"Grade"]];
                    break;
                case 1:
                    [keyLabel setText:@"Type"];
                    [valueLabel setText:[sectionDictionary valueForKey:@"Type"]];
                    break;
                default:
                    [centeredValueLabel setText:[sectionDictionary valueForKey:[NSString stringWithFormat:@"impossibleProperty_%i", indexPath.row - 2]]];
                    break;
            }
            break;
        }
        case 1:
        case 2:
        {
            NSArray *keysArray = [[sectionDictionary allKeys] sortedArrayAsCaseInsensitive];
            if ([keysArray containsObject:@"attackDelay"]) {
                keysArray = [keysArray sortedArrayUsingComparator:^(id obj1, id obj2){
                    if ([(NSString *)obj1 isEqualToString:@"attackDelay"]) {
                        return NSOrderedAscending;
                    }
                    else if ([(NSString *)obj2 isEqualToString:@"attackDelay"]) {
                        return NSOrderedDescending;
                    }
                    else {
                        return NSOrderedSame;
                    }
                }];
            }
            NSString *dictionarySection = [keysArray objectAtIndex:indexPath.row];
            
            if ([dictionarySection isEqualToString:@"attackDelay"]) {
                [centeredValueLabel setText:[sectionDictionary valueForKey:dictionarySection]];
            }
            else {
                [keyLabel setText:dictionarySection];
                [valueLabel setText:[sectionDictionary valueForKey:dictionarySection]];
            }
            
            break;
        }
        case 6:
        {
            NSString *dictionarySection = [[sectionDictionary allKeys] objectAtIndex:indexPath.row];
            [centeredValueLabel setText:[sectionDictionary valueForKey:dictionarySection]];
            break;
        }
        case 7:
        {
            NSMutableArray *keysArray = [[NSMutableArray alloc] initWithArray:[[sectionDictionary allKeys] sortedArrayAsCaseInsensitive]];
            
            [keysArray removeObject:@"setItemName"];
            [keysArray removeObject:@"setItemUsingCount"];
            [keysArray removeObject:@"setItemCount"];
            
            
            NSString *dictionarySection = [keysArray objectAtIndex:indexPath.row];
            
            [keySetItemLabel setText:dictionarySection];
            
            NSString *dictionarySectionString = [sectionDictionary valueForKey:dictionarySection];
            if ([dictionarySectionString isEqualToString:@"true"] || [dictionarySectionString isEqualToString:@"false"]) {
                if ([[sectionDictionary valueForKey:dictionarySection] boolValue]) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            else {
                [valueLabel setText:dictionarySectionString];
            }
            break;
        }
        case 8:
        case 9:
        case 10:
        case 11:
        {
            NSArray *keysArray = [[sectionDictionary allKeys] sortedArrayAsCaseInsensitive];
            NSString *dictionarySection = [keysArray objectAtIndex:indexPath.row];
            
            [keyLabel setText:dictionarySection];
            [valueLabel setText:[sectionDictionary valueForKey:dictionarySection]];
            break;
        }
        case 3:
        case 4:
        case 5:
        {
            NSArray *keysArray = [[sectionDictionary allKeys] sortedArrayAsCaseInsensitive];
            NSString *dictionarySection = [keysArray objectAtIndex:indexPath.row];
            
            [keyLabel setText:dictionarySection];
            [valueLabel setText:[sectionDictionary valueForKey:dictionarySection]];
            
            break;
        }
    }
    
    return cell;
}

#pragma mark - Actions

- (NSDictionary *)dictionaryForSection:(NSInteger)section
{    
    id sectionData;
    
    switch (section) {
        case 0:
            sectionData = [_equipmentDetails objectForKey:@"info"];
            break;
        case 1:
            sectionData = [_equipmentDetails objectForKey:@"base"];
            break;
        case 2:
            sectionData = [_equipmentDetails objectForKey:@"bonus"];
            break;
        case 3:
            sectionData = [_equipmentDetails objectForKey:@"sub_bonus"];
            break;
        case 4:
            sectionData = [_equipmentDetails objectForKey:@"enchant_stones"];
            break;
        case 5:
            sectionData = [_equipmentDetails objectForKey:@"sub_enchant_stones"];
            break;
        case 6:
            sectionData = [_equipmentDetails objectForKey:@"proc_info"];
            break;
        case 7:
            sectionData = [_equipmentDetails objectForKey:@"set_item_list"];
            break;
        case 8:
            sectionData = [_equipmentDetails objectForKey:@"set_effect_2"];
            break;
        case 9:
            sectionData = [_equipmentDetails objectForKey:@"set_effect_3"];
            break;
        case 10:
            sectionData = [_equipmentDetails objectForKey:@"set_effect_4"];
            break;
        case 11:
            sectionData = [_equipmentDetails objectForKey:@"set_effect_5"];
            break;
    }
    
    if ([sectionData isKindOfClass:[NSDictionary class]]) {
        return sectionData;
    }
    else if (sectionData != nil) {
        return [NSDictionary dictionaryWithObjectsAndKeys:sectionData, @"value", nil];
    }
    
    return nil;
}

- (UIColor *)headerTextColorForBonusSet:(NSInteger)bonusSet
{
    NSInteger numberOfEquipedItems = [[[self dictionaryForSection:7] valueForKey:@"setItemUsingCount"] integerValue];
    
    if (bonusSet > numberOfEquipedItems) {
        return [UIColor colorWithHexString:@"FF4A4A"];
    }
    
    return [UIColor colorWithHexString:@"4BCFFF"];
}

@end
