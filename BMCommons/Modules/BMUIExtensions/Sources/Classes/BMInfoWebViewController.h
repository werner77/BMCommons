//
//  BMInfoWebViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/6/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMTableViewController.h>

NS_ASSUME_NONNULL_BEGIN

/**
 View controller to load a rich text HTML resource in a table view (single cell).
 */
@interface BMInfoWebViewController : BMTableViewController<UIWebViewDelegate>

@property (nullable, nonatomic, strong) NSString *htmlResourceName;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 Starts loading of the resource
 */
- (void)loadWebResource;

/**
 Determines the height of the tableview cell for displaying the webview.
 */
- (CGFloat)determineRowHeight;

@end

NS_ASSUME_NONNULL_END
