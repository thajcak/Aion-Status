//
//  ServerSelectionViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "ServerSelectionViewController.h"

#import "Server.h"

@interface ServerSelectionViewController ()
{
    CoreDataStore *_dataStore;
    
    NSArray *_availableServers;
    NSIndexPath *_primaryServer;
    
    enum _serverListType;
}

@end

@implementation ServerSelectionViewController

@synthesize serverList = _serverList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setTitle:@"Select Server"];
        
        _serverList = kSearchServers;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataStore = [CoreDataStore createStore];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getServerList];
}

- (void)getServerList
{
    switch (_serverList) {
        case kSearchServers:
        {
            _availableServers = [Server allForPredicate:[NSPredicate predicateWithFormat:@"onSearch == YES"] 
                                                orderBy:@"name" 
                                              ascending:YES
                                                inStore:_dataStore];
            break;
        }
        case kAbyssServers:
        {
            _availableServers = [Server allForPredicate:[NSPredicate predicateWithFormat:@"onAbyss == YES"] 
                                                orderBy:@"name" 
                                              ascending:YES
                                                inStore:_dataStore];
            break;
        }
    }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_availableServers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Reset cell accessory view
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    // Configure the cell...
    
    Server *thisServer = (Server *)[_availableServers objectAtIndex:indexPath.row];
    [cell.textLabel setText:thisServer.name];
    
    switch (_serverList) {
        case kAbyssServers:
        {
            if ([thisServer.isSelectedPvP boolValue]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                _primaryServer = indexPath;
            }
            break;
        }   
        case kSearchServers:
        {
            if ([thisServer.isSelectedSearch boolValue]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                _primaryServer = indexPath;
            }
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // animate the cell highlight fading
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![indexPath isEqual:_primaryServer]) {
        // get the Core Data Object IDs from the array of available servers
        id oldPrimaryServerId = [[_availableServers objectAtIndex:_primaryServer.row] objectID];
        id newPrimaryServerId = [[_availableServers objectAtIndex:indexPath.row] objectID];
        
        Server *oldPrimaryServer = (Server *)[_dataStore entityByObjectID:oldPrimaryServerId];
        Server *newPrimaryServer = (Server *)[_dataStore entityByObjectID:newPrimaryServerId];
        
        switch (_serverList) {
            case kAbyssServers:
            {
                [oldPrimaryServer setIsSelectedPvP:BOX_BOOL(NO)];
                [newPrimaryServer setIsSelectedPvP:BOX_BOOL(YES)];
                break;
            }   
            case kSearchServers:
            {
                [oldPrimaryServer setIsSelectedSearch:BOX_BOOL(NO)];
                [newPrimaryServer setIsSelectedSearch:BOX_BOOL(YES)];
                break;
            }
        }
        
        [_dataStore save];
        
        [self getServerList];
        
        // reload the two rows that need updating
        NSArray *cellsToReload = [NSArray arrayWithObjects:indexPath, _primaryServer, nil];
        [tableView reloadRowsAtIndexPaths:cellsToReload withRowAnimation:UITableViewRowAnimationFade];
    
        // set the primary server
        _primaryServer = indexPath;
    }
}

@end
