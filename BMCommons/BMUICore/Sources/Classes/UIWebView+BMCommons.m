//
//  UIWebView+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "UIWebView+BMCommons.h"


@implementation UIWebView(BMCommons)

- (void)bmApplyRTFLabelTemplate {
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.userInteractionEnabled = NO;
	UIScrollView* sv = nil;
	for(UIView* v in self.subviews){
		if([v isKindOfClass:[UIScrollView class] ]){
			sv = (UIScrollView*) v;
			sv.scrollEnabled = NO;
			sv.showsHorizontalScrollIndicator = NO;
			sv.showsVerticalScrollIndicator = NO;
			sv.minimumZoomScale = 1.0;
			sv.maximumZoomScale = 1.0;
			sv.bounces = NO;
		}	
	}
}

- (void)bmLoadHTMLResourceWithName:(NSString *)htmlResourceName forLocalization:(NSString *)localizationName {
	NSString *filePath = nil;
	if (localizationName) {
		filePath = [[NSBundle mainBundle] pathForResource:htmlResourceName 
															 ofType:@"html" 
														inDirectory:nil 
													forLocalization:localizationName];
	} else {
		filePath = [[NSBundle mainBundle] pathForResource:htmlResourceName ofType:@"html"];
	}
	
	if (filePath) {
		NSString *basePath = [filePath stringByDeletingLastPathComponent];
		NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		[self loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:basePath isDirectory:YES]];
	}
}

- (void)bmLoadHTMLResourceWithName:(NSString *)htmlResourceName {
	[self bmLoadHTMLResourceWithName:htmlResourceName forLocalization:nil];
}

@end
