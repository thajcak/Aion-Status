//
//  LegionMembersViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/21/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "LegionMembersViewController.h"

#import "CharacterViewController.h"

@interface LegionMembersViewController ()
{
    NSArray *_legionRanksArray;
}

@end

@implementation LegionMembersViewController

@synthesize membersDictionary = _membersDictionary;
@synthesize parentNavController = _parentNavController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setFrame:CGRectMake(0, 60, 320, 400)];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        
        _legionRanksArray = [NSArray arrayWithObjects:@"Brigade General", @"Deputy", @"Centurion", @"Volunteer", nil];
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
    return [_legionRanksArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_legionRanksArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_membersDictionary objectForKey:[_legionRanksArray objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    NSDictionary *_memberInformation = [[_membersDictionary objectForKey:[_legionRanksArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[_memberInformation valueForKey:@"charName"]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Level %@ %@",
                                   [_memberInformation valueForKey:@"charLevel"],
                                   [_memberInformation valueForKey:@"charClassName"]]];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *_memberInformation = [[_membersDictionary objectForKey:[[_membersDictionary allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    CharacterViewController *cVC = [[CharacterViewController alloc] init];
    [cVC setServerId:[[_memberInformation valueForKey:@"serverID"] integerValue]];
    [cVC setCharacterId:[_memberInformation valueForKey:@"charID"]];
    
    UINavigationController *cNC = [[UINavigationController alloc] initWithRootViewController:cVC];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                    style:UIBarButtonSystemItemDone 
                                                                   target:cVC
                                                                   action:SEL(dismissModalViewControllerAnimated:)];
    [cVC.navigationItem setLeftBarButtonItem:closeButton];
    
    [_parentNavController presentModalViewController:cNC animated:YES];
}

@end
