//
//  WebViewController.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/22/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
{
    UIWebView *_webView;
    
    UIActivityIndicatorView *_activityIndicatorView;
    
    UIToolbar *_toolbar;
    
    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_refreshButton;
    
    BOOL _isOnHTMLContents;
}

@end

@implementation WebViewController

@synthesize urlString = _urlString;
@synthesize htmlContents = _htmlContents;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.height-44-44)];
        [_webView setDelegate:self];
        [_webView setScalesPageToFit:YES];
        [self.view addSubview:_webView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityIndicatorView setHidesWhenStopped:YES];
        
        UIBarButtonItem *fakeButton = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicatorView];
        [self.navigationItem setRightBarButtonItem:fakeButton];
        
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height-88, 320, 44)];
        [self.view addSubview:_toolbar];
        
        _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] 
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:SEL(goBack)];
        [_backButton setEnabled:NO];
        _forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:SEL(goForward)];
        [_forwardButton setEnabled:NO];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];;
        
        [_toolbar setItems:[NSArray arrayWithObjects:_backButton, space, _forwardButton, space, space, space, nil]];
        
        _isOnHTMLContents = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_htmlContents == nil) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    }
    else {
        _htmlContents = [_htmlContents stringByAppendingFormat:@"<meta name=\"viewport\" content=\"width=320,user-scalable=yes,initial-scale=0.70\"><style type=\"text/css\">img{max-width: 436px; width: auto; height: auto;}<\\style>"];
        [_webView loadHTMLString:_htmlContents baseURL:[NSURL URLWithString:@"http://na.aiononline.com"]];
        _isOnHTMLContents = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicatorView stopAnimating];
    [self setTitle:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    
    if ([_webView canGoForward]) {
        [_forwardButton setEnabled:YES];
    }
    else {
        [_forwardButton setEnabled:NO];
    }
    
    if ([_webView canGoBack]) {
        [_backButton setEnabled:YES];
    }
    else {
        if (_htmlContents != nil && !_isOnHTMLContents) {
            [_backButton setEnabled:YES];
        }
        else {
            [_backButton setEnabled:NO];
        }
    }
    
    if (_isOnHTMLContents) {
        _isOnHTMLContents = NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicatorView stopAnimating];
}

#pragma mark - Actions

- (void)goForward
{
    [_webView goForward];
}

- (void)goBack
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else {
        [_webView loadHTMLString:_htmlContents baseURL:[NSURL URLWithString:@"http://na.aiononline.com"]];
        _isOnHTMLContents = YES;
    }
}

@end
