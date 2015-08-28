//
//  WebViewController.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/22/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *htmlContents;

@end
