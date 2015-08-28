//
//  RegionStatusViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/15/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "RegionStatusViewController.h"

#import "SimpleInkEngine.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 280.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface RegionStatusViewController ()
{
    NSDictionary *_serverList;
}
@end

@implementation RegionStatusViewController

@synthesize containerScrollView = _containerScrollView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setFrame:CGRectMake(0, 0, 320, _containerScrollView.height)];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [APP_DELEGATE.simpleInkEngine
     getServerStatus:^(NSDictionary *response) {
         _serverList = response;
         [self.tableView reloadData];
     }
     onError:^(NSError *error) {
         
     }];
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
    return [[_serverList allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"North America - NCsoft";
        case 1:
            return @"Europe - Gameforge";
        case 2:
            return @"United Kingdom";
        case 3:
            return @"France";
        case 4:
            return @"Germany";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self getArrayForIndexPath:section] count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    }
    
    NSArray *thisServer = [[self getArrayForIndexPath:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setText:[thisServer valueForKey:@"name"]];
    
    UIImageView *statusImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
    if ([[thisServer valueForKey:@"status"] integerValue] == 1) {
        [statusImage setImage:[UIImage imageNamed:@"Online.png"]];
    } else {
        [statusImage setImage:[UIImage imageNamed:@"Offline.png"]];
    }
    [cell setAccessoryView:statusImage];
    
    return cell;
}

- (NSArray *)getArrayForIndexPath:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_serverList objectForKey:@"US"];
        case 1:
            return [_serverList objectForKey:@"EU"];
        case 2:
            return [_serverList objectForKey:@"GB"];
        case 3:
            return [_serverList objectForKey:@"FR"];
        case 4:
            return [_serverList objectForKey:@"DE"];
    }
    
    return nil;
}

@end
