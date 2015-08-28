//
//  SettingsViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "SettingsViewController.h"

#import "SimpleInkEngine.h"

#import "ServerSelectionViewController.h"

#import "MKStoreManager.h"

#import "Setting.h"

@interface SettingsViewController ()
{
    NSArray *_settingsArray;
    CoreDataStore *_dataStore;
}

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setTitle:@"Settings"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *alerts = [userDefaults objectForKey:@"as2alerts"];
    NSArray *serverSelection = [NSArray arrayWithObjects:@"Up to date!", nil];
    NSArray *appOptions = [NSArray arrayWithObjects:@"Love it? Rate it!", @"Give Feedback", @"Donate & Remove Ads", nil];
    NSArray *openSocialOptions = [NSArray arrayWithObjects:@"Facebook", @"Twitter", nil];
    NSArray *disclaimers = [NSArray arrayWithObjects:@"Disclaimer & Credits", nil];
    
    _settingsArray = [[NSArray alloc] initWithObjects:
                      alerts,
                      serverSelection,
                      appOptions,
                      openSocialOptions,
                      disclaimers, nil];
    [self.tableView reloadData];
    
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
    return [_settingsArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if ([_settingsArray objectAtIndex:section] == 0) {
                return @"No Service Alerts";
            }
            return @"Service Alerts";
        }
        case 3:
        {
            return @"Open Feed Posts in App?";
        }

    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 3:
        {
            return @"If turned on, opening a news feed item will send you to the official Facebook or Twitter app to view the post.";
            break;
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *sectionArray = [_settingsArray objectAtIndex:section];
    return [sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];

        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *sectionDictionary = [_settingsArray objectAtIndex:indexPath.section];
            [cell.textLabel setText:[[sectionDictionary valueForKey:[NSString stringWithFormat:@"%i", indexPath.row]] valueForKey:@"headline"]];
            [cell.detailTextLabel setText:[[sectionDictionary valueForKey:[NSString stringWithFormat:@"%i", indexPath.row]] valueForKey:@"date"]];
            [cell setAccessoryView:[self alertImageOfType:[[sectionDictionary valueForKey:[NSString stringWithFormat:@"%i", indexPath.row]] valueForKey:@"type"]]];
            break;
        }
        case 1:
        {
            NSArray *sectionArray = [_settingsArray objectAtIndex:indexPath.section];
            [cell.textLabel setText:[sectionArray objectAtIndex:indexPath.row]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"You're Running: v%@ (%@)",
                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
            break;
        }
        case 3:
        {
            NSArray *sectionArray = [_settingsArray objectAtIndex:indexPath.section];
            [cell.textLabel setText:[sectionArray objectAtIndex:indexPath.row]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UISwitch *cellSwitch = [[UISwitch alloc] init];
            Setting *userSetting = [Setting firstInStore:_dataStore];
            switch (indexPath.row) {
                case 0:
                    [cellSwitch setEnabled:[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]];
                    [cellSwitch setOn:UNBOX_BOOL(userSetting.openInFacebook)];
                    [cellSwitch setTag:100];
                    [cellSwitch addTarget:self action:SEL(updateSwitch:) forControlEvents:UIControlEventValueChanged];
                    break;
                case 1:
                    [cellSwitch setEnabled:[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]];
                    [cellSwitch setOn:UNBOX_BOOL(userSetting.openInTwitter)];
                    [cellSwitch setTag:101];
                    [cellSwitch addTarget:self action:SEL(updateSwitch:) forControlEvents:UIControlEventValueChanged];
                    break;
            }
            [cell setAccessoryView:cellSwitch];
            break;
        }
        default:
        {
            NSArray *sectionArray = [_settingsArray objectAtIndex:indexPath.section];
            [cell.textLabel setText:[sectionArray objectAtIndex:indexPath.row]];
            [cell.detailTextLabel setText:@""];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *sectionDictionary = [_settingsArray objectAtIndex:indexPath.section];
            NSString *text = [[sectionDictionary valueForKey:[NSString stringWithFormat:@"%i", indexPath.row]] valueForKey:@"message"];
            
            CGSize constraint = CGSizeMake(260.0f, 260.0f);
            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGFloat height = MAX(size.height, 100.0f);
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, height)];
            [textView setBackgroundColor:[UIColor clearColor]];
            [textView setTextColor:[UIColor whiteColor]];
            [textView setEditable:NO];
            [textView setText:text];
            [[KGModal sharedInstance] showWithContentView:textView andAnimated:YES];
            
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=372417845"]];
                    break;
                }
            }
            break;
        }
        case 2:
        {
            switch (indexPath.row) {
                case 0:     // Rating
                {
                    NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
                    NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:@"372417845"];

                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
                    break;
                }
                case 1:     // Feedback
                {
                    if ([MFMailComposeViewController canSendMail])
                    {
                        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                        mailViewController.mailComposeDelegate = self;
                        
                        [mailViewController setSubject:@"Feedback"];
                        [mailViewController setToRecipients:[NSArray arrayWithObject:@"support@aionstatusapp.com"]];
                        [mailViewController setMessageBody:[NSString stringWithFormat:@"\n\nCharacter Name:\nServer Name:\n\n-| Debug Information |-\nAion Status Version: %@ (%@)\n iOS Version: %@\nDevice Type: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], [[UIDevice currentDevice] systemVersion], [self getSysInfoByName]] isHTML:NO];
                        
                        mailViewController.navigationBar.barStyle = UIBarStyleBlack;
                        
                        if (mailViewController != nil)
                        {
                            [self presentModalViewController:mailViewController animated:YES];
                        }
                    }
                    else
                    {
                        [IBAlertView showAlertWithTitle:@"Cannot Send Feedback"
                                                message:@"You must have an email account setup before you can send feedback."
                                           dismissTitle:@"Okay"
                                           dismissBlock:^{}];
                    }
                    break;
                }
                case 2:     // Donate
                {
//                    NSArray *productDescriptionArrays;
//                    NSArray *consumables = [[[self storeKitItems] objectForKey:@"Consumables"] allKeys];
//                    NSArray *nonConsumables = [[self storeKitItems] objectForKey:@"Non-Consumables"];
                    
                    if (DID_PAY_PREMIUM) {
                        
                    }
                    else {
                        NSArray *productDescriptionArrays = [[NSArray alloc] initWithArray:[[MKStoreManager sharedManager] purchasableObjectsDescription]];
                        UIActionSheet *upgradeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please select a donation level to remove ads"
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"Cancel"
                                                                          destructiveButtonTitle:nil
                                                                               otherButtonTitles:
                                                             [NSString stringWithFormat:@"%@", [productDescriptionArrays objectAtIndex:0]],
                                                             [NSString stringWithFormat:@"%@", [productDescriptionArrays objectAtIndex:1]],
                                                             [NSString stringWithFormat:@"%@", [productDescriptionArrays objectAtIndex:2]],
                                                             [NSString stringWithFormat:@"%@", [productDescriptionArrays objectAtIndex:3]],
                                                             @"Restore Previous Donation",
                                                             nil];
                        [upgradeActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                        [upgradeActionSheet showInView:self.tabBarController.view];
                    }
                    break;
                }
            }
            break;
        }
        case 4:
        {
            switch (indexPath.row) {
                case 0:     // Disclaimer
                {
                    NSString *text = @"Aion Status is an unofficial companion for Aion Online.\n\nAION game content and materials are trademarks and copyrights of NCsoft Corporation and its Licensors and used with permission. All rights reserved.\n\nThird Party Libraries:\nMKNetworkKit, MKStoreKit, InnerBand, RaptureXML, RelativeDateDescriptor, TSMiniWebBrowser, YRDropdownView, KGModal";
                    
                    CGSize constraint = CGSizeMake(260.0f, 260.0f);
                    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                    CGFloat height = MAX(size.height, 100.0f);
                    
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, height)];
                    [textView setBackgroundColor:[UIColor clearColor]];
                    [textView setTextColor:[UIColor whiteColor]];
                    [textView setEditable:NO];
                    [textView setText:text];
                    [[KGModal sharedInstance] showWithContentView:textView andAnimated:YES];
                }
            }
            break;
        }
    }
}

#pragma mark - In-App Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
		{
            [IBAlertView showAlertWithTitle:nil
                                    message:@"An unknown error occurred and your feedback was not sent."
                               dismissTitle:@"Okay"
                               dismissBlock:^{}];
			break;
        }
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Device Model Methods

- (NSString *)getSysInfoByName
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

#pragma mark - Donate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:		//Common Donation
		{
			[[MKStoreManager sharedManager] buyFeature:@"010"
                                            onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt){
                                                
                                            }
                                           onCancelled:^{}];
			break;
		}
		case 1:		//Superior Donation
		{
//			[[MKStoreManager sharedManager] buyFeature:@"011"];
			break;
		}
		case 2:		//Heroic Donation
		{
//			[[MKStoreManager sharedManager] buyFeature:@"012"];
			break;
		}
		case 3:		//Fabled Donation
		{
//			[[MKStoreManager sharedManager] buyFeature:@"013"];
			break;
		}
		case 4:		//Restore Purchase
		{
            [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{}
                                                                          onError:^(NSError *error){}];
			break;
		}
		case 5:
		{
//			[donationButton setEnabled:YES];
			return;
		}
	}
	
//	[donationButton setEnabled:NO];
//	[donationButton setTitle:@"Processing..." forState:UIControlStateDisabled];
//	[[Global getDefaults] setBool:YES forKey:isProcessingInAppPurchase];
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDonationButtonComplete) name:@"Payment Complete" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDonationButtonIncomplete) name:@"Payment Cancelled" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDonationButtonIncomplete) name:@"Payment Failed" object:nil];
}

#pragma mark - Actions

- (UIImageView *)alertImageOfType:(NSString *)alertType
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    [image setContentMode:UIViewContentModeCenter];
    
    if ([alertType isEqualToString:@"info"]) {
        [image setImage:[UIImage imageNamed:@"information.png"]];
    }
    else if ([alertType isEqualToString:@"alert"]) {
        [image setImage:[UIImage imageNamed:@"exclamation_point.png"]];
    }
    else if ([alertType isEqualToString:@"error"]) {
        [image setImage:[UIImage imageNamed:@"warning_1.png"]];
    }
    else if ([alertType isEqualToString:@"unknown"]) {
        [image setImage:[UIImage imageNamed:@"question_mark.png"]];
    }
    
    return image;
}

- (void)updateSwitch:(id)sender
{
    UISwitch *thisSwitch = (UISwitch *)sender;
    [self updateSetting:thisSwitch.tag withFlag:thisSwitch.isOn];
}

- (void)updateSetting:(NSInteger)tag withFlag:(BOOL)boolSetting
{
    Setting *userSetting = [Setting firstInStore:_dataStore];
    
    switch (tag) {
        case 100:
            [userSetting setOpenInFacebook:BOX_BOOL(boolSetting)];
            break;
        case 101:
            [userSetting setOpenInTwitter:BOX_BOOL(boolSetting)];
            break;
    }
    
    [_dataStore save];
}

@end
