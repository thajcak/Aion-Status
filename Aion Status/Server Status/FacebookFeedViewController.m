//
//  FacebookFeedViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/16/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "FacebookFeedViewController.h"

#import "TSMiniWebBrowser.h"

#import "AionOnlineEngine.h"

#import "RelativeDateDescriptor.h"
#import "Setting.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 2.0f
#define CELL_BACKGROUND_WIDTH 320.0f
#define CELL_BACKGROUND_MARGIN 10.0f
#define CELL_HEADER_COLOR [UIColor colorWithHexString:@"3A5999"]
#define CELL_FOOTER_COLOR [UIColor colorWithHexString:@"95B0E6"]

@interface FacebookFeedViewController ()
{
    NSArray *_facebookPosts;
    
    CoreDataStore *_dataStore;
}

@end

@implementation FacebookFeedViewController

@synthesize containerScrollView = _containerScrollView;
@synthesize statusViewController = _statusViewController;

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
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [tableHeaderView setBackgroundColor:[UIColor clearColor]];
    
    [self.tableView setTableHeaderView:tableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView setFrame:CGRectMake(640, 0, 320, _containerScrollView.height)];
    
    [APP_DELEGATE.aionOnlineEngine 
     getFacebookFeed:^(NSArray *results) {
         _facebookPosts = results;
         [self.tableView reloadData];
     }
     onError:^(NSError *error) {
         [IBAlertView  showAlertWithTitle:[error domain]
                                  message:[error localizedDescription]
                             dismissTitle:@"Okay"
                             dismissBlock:^{}];
     }];
    
    _dataStore = [CoreDataStore createStore];
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
    return [_facebookPosts count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellDictionary = [_facebookPosts objectAtIndex:indexPath.row];
    NSString *text = [cellDictionary valueForKey:@"message"];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 24.0f);
    
    if (((NSString *)[cellDictionary valueForKey:@"msgLink"]).length > 0) {
        height += 14.0f;
    }
    
    return height + (CELL_BACKGROUND_MARGIN * 2) + 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(CELL_BACKGROUND_MARGIN, 0, CELL_BACKGROUND_WIDTH - (CELL_BACKGROUND_MARGIN * 2), 44 - (CELL_BACKGROUND_MARGIN / 2) + 14)];
        [backgroundView setBackgroundColor:[UIColor colorWithHexString:@"CFD6E6"]];
        [backgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
        [backgroundView.layer setShadowRadius:2.0f];
        [backgroundView.layer setShadowOpacity:0.8f];
        [backgroundView.layer setShadowOffset:CGSizeMake(1, 1)];
        [backgroundView.layer setCornerRadius:4.0f];
        [backgroundView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [backgroundView.layer setBorderWidth:1.0f];
        [backgroundView setTag:90];
        [cell.contentView addSubview:backgroundView];
        
        UIView *backgroundContentView = [[UIView alloc] initWithFrame:backgroundView.frame];
        [backgroundContentView setClipsToBounds:YES];
        [backgroundContentView.layer setCornerRadius:4.0f];
        [backgroundContentView setTag:91];
        [backgroundView addSubview:backgroundContentView];
        
        UIView *headerView = [[UIView alloc] initWithFrame:backgroundView.frame];
        [headerView setHeight:14.0f];
        [headerView setLeft:0.0f];
        [headerView setBackgroundColor:CELL_HEADER_COLOR];
        [backgroundContentView addSubview:headerView];
        
        UILabel *headerText = [[UILabel alloc] initWithFrame:headerView.frame];
        [headerText setLeft:2.0f];
        [headerText setBackgroundColor:[UIColor clearColor]];
        [headerText setFont:[UIFont systemFontOfSize:12.0f]];
        [headerText setTextAlignment:UITextAlignmentLeft];
        [headerText setTextColor:[UIColor whiteColor]];
        [headerText setTag:92];
        [backgroundView addSubview:headerText];
        
        UILabel *headerTime = [[UILabel alloc] initWithFrame:headerText.frame];
        [headerTime setRight:298.0f];
        [headerTime setBackgroundColor:[UIColor clearColor]];
        [headerTime setFont:[UIFont systemFontOfSize:12.0f]];
        [headerTime setTextAlignment:UITextAlignmentRight];
        [headerTime setTextColor:[UIColor whiteColor]];
        [headerTime setTag:93];
        [backgroundView addSubview:headerTime];
        
        UIView *footerView = [[UIView alloc] initWithFrame:headerView.frame];
        [footerView setBackgroundColor:CELL_FOOTER_COLOR];
        [footerView setTag:95];
        [backgroundContentView addSubview:footerView];
        
        UILabel *footerText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 14)];
        [footerText setBackgroundColor:[UIColor clearColor]];
        [footerText setFont:[UIFont systemFontOfSize:12.0f]];
        [footerText setTextAlignment:UITextAlignmentCenter];
        [footerText setTextColor:[UIColor whiteColor]];
        [footerText setTag:96];
        [footerView addSubview:footerText];
        
        UILabel *messageText = [[UILabel alloc] init];
        [messageText setBackgroundColor:[UIColor clearColor]];
        [messageText setLineBreakMode:UILineBreakModeWordWrap];
        [messageText setMinimumFontSize:FONT_SIZE];
        [messageText setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [messageText setNumberOfLines:0];
        [messageText setTag:100];
        [cell.contentView addSubview:messageText];
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // reset
    
    UIView *backgroundView = (UIView *)[cell viewWithTag:90];
    UIView *backgroundContentView = (UIView *)[cell viewWithTag:91];
    UILabel *headerText = (UILabel *)[cell viewWithTag:92];
    UILabel *headerTime = (UILabel *)[cell viewWithTag:93];
    UIView *footerView = (UIView *)[cell viewWithTag:95];
    UILabel *footerText = (UILabel *)[cell viewWithTag:96];
    UILabel *messageText = (UILabel *)[cell viewWithTag:100];
    
    // set
    
    NSDictionary *cellDictionary = [_facebookPosts objectAtIndex:indexPath.row];
    NSString *text = [cellDictionary valueForKey:@"message"];
    if (text.length == 0) {
        text = [cellDictionary valueForKey:@"itemName"];
    }
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    [messageText setText:text];
    [messageText setFrame:CGRectMake(CELL_CONTENT_MARGIN + CELL_BACKGROUND_MARGIN, (CELL_CONTENT_MARGIN) + 14, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 24.0f) - 2)];
    
    [backgroundView setHeight:messageText.frame.size.height + (CELL_CONTENT_MARGIN * 2) + 14];
    
    if (((NSString *)[cellDictionary valueForKey:@"msgLink"]).length > 0) {
        [backgroundView setHeight:backgroundView.frame.size.height + 14];
        [footerView setBottom:backgroundView.frame.size.height];
        [footerView setAlpha:1.0f];
        
        [footerText setText:[NSString stringWithFormat:@"View %@", [cellDictionary valueForKey:@"type"]]];
    }
    else {
        [footerView setAlpha:0.0f];
    }
    
    [backgroundContentView setFrame:backgroundView.frame];
    [backgroundContentView setLeft:0.0f];
    [backgroundContentView setTop:0.0f];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSTimeInterval timeInterval = [[[[cellDictionary valueForKey:@"createdTsGMT"] stringValue] substringWithRange:NSMakeRange(0, 10)] integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    RelativeDateDescriptor *dateDescriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"in %@"];
    
    [headerTime setText:[dateDescriptor describeDate:date relativeTo:[NSDate date]]];
    
    [headerText setText:[NSString stringWithFormat:@"%@ Comments | %@ Likes", [cellDictionary valueForKey:@"commentsCount"], [cellDictionary valueForKey:@"likesCount"]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *cellDictionary = [_facebookPosts objectAtIndex:indexPath.row];

    Setting *setting = [Setting firstInStore:_dataStore];
    if (UNBOX_BOOL(setting.openInFacebook)) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", [cellDictionary valueForKey:@"postId"]]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        if (((NSString *)[cellDictionary valueForKey:@"msgLink"]).length > 0) {
            TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:[cellDictionary valueForKey:@"msgLink"]]];
            [_statusViewController.navigationController pushViewController:webBrowser animated:YES];
        }
    }
}

@end
