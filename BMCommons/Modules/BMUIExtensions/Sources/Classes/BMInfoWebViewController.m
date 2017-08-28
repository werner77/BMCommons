//
//  BMInfoWebViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/6/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMInfoWebViewController.h>
#import "UIWebView+BMCommons.h"
#import <BMCommons/BMUICore.h>

#define X_MARGIN 10
#define Y_MARGIN 0

@implementation BMInfoWebViewController {
	IBOutlet UITableViewCell *tableCell;
	IBOutlet UIWebView *webView;
	IBOutlet UIView *headerView;
	IBOutlet UIView *footerView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	CGFloat rowHeight;
	BOOL webViewLoaded;
	NSString *htmlResourceName;
}

@synthesize htmlResourceName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.timeoutInterval = 30.0;
        self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(htmlResourceName);
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (!tableCell && !webView) {
		tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_Cell"];
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(X_MARGIN, Y_MARGIN, tableCell.bounds.size.width - 2 * X_MARGIN, tableCell.bounds.size.height - 2 * Y_MARGIN)];
		webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|
									UIViewAutoresizingFlexibleHeight);
		[tableCell addSubview:webView];
        [tableCell setBackgroundColor:[UIColor clearColor]];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        activityIndicator.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
        activityIndicator.hidesWhenStopped = YES;
        [self.view addSubview:activityIndicator];
	}
    
    rowHeight = self.tableView.rowHeight;
	tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
	if (!webView.delegate) {
		webView.delegate = self;
	}
	[webView bmApplyRTFLabelTemplate];
    
    [self loadWebResource];
    
	self.tableView.hidden = YES;
}

- (void)viewDidUnload {
	BM_RELEASE_SAFELY(activityIndicator);
	webViewLoaded = NO;
	webView.delegate = nil;
	BM_RELEASE_SAFELY(tableCell);
	BM_RELEASE_SAFELY(webView);
	BM_RELEASE_SAFELY(headerView);
	BM_RELEASE_SAFELY(footerView);
	[super viewDidUnload];
}

#pragma mark -
#pragma mark BMLocalizable

- (void)localize {
	[super localize];
}

#pragma mark -
#pragma mark UITableView delegate/datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return tableCell;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (footerView) {
		return footerView.frame.size.height;
	} else {
		return 0.0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (headerView) {
		return headerView.frame.size.height;
	} else {
		return 0.0;
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	webViewLoaded = YES;
	rowHeight = [self determineRowHeight];
	[self.tableView reloadData];
	[activityIndicator stopAnimating];
	self.tableView.hidden = NO;
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
	LogDebug(@"Could not load data in webview: %@", error);
	[activityIndicator stopAnimating];
}

#pragma mark -
#pragma mark Methods to be overridden by sub classes

- (CGFloat)determineRowHeight {
	return [webView sizeThatFits:CGSizeZero].height + 15.0;
}
- (void)loadWebResource {
    NSURL *url = [NSURL URLWithString:[self htmlResourceName]];
    if ([url scheme] || [url isFileURL])   {
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url cachePolicy:self.cachePolicy timeoutInterval:self.timeoutInterval];
        [webView loadRequest:urlRequest];
    } else {
		[webView bmLoadHTMLResourceWithName:[self htmlResourceName] forLocalization:nil];
    }
}

@end
