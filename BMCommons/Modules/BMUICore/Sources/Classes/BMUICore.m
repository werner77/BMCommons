

#import <BMCommons/BMUICore.h>
#import <BMCommons/UIScreen+BMCommons.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
static int gNetworkTaskCount = 0;

//IPhone specific

CGRect BMRectInset(CGRect rect, UIEdgeInsets insets) {
	return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top,
					  rect.size.width - (insets.left + insets.right),
					  rect.size.height - (insets.top + insets.bottom));
}

CGPoint BMPointAlignedToRect(BMViewLayoutAlignment alignment, CGRect rect) {
	return BMPointAlignedToRectWithInsets(alignment, rect, UIEdgeInsetsZero);
}

CGPoint BMPointAlignedToRectWithInsets(BMViewLayoutAlignment alignment, CGRect rect, UIEdgeInsets insets) {
	CGRect effectiveRect = BMRectInset(rect, insets);
	CGPoint point = CGPointZero;

	if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentCenterHorizontally)) {
		point.x = (CGRectGetMaxX(effectiveRect) - CGRectGetMinX(effectiveRect))/2.0f;
	} else if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentRight)) {
		point.x = CGRectGetMaxX(effectiveRect);
	} else {
		point.x = CGRectGetMinX(effectiveRect);
	}

	if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentCenterVertically)) {
		point.y = (CGRectGetMaxY(effectiveRect) - CGRectGetMinY(effectiveRect))/2.0f;
	} else if (BM_CONTAINS_BIT(alignment, BMViewLayoutAlignmentBottom)) {
		point.y = CGRectGetMaxY(effectiveRect);
	} else {
		point.y = CGRectGetMinY(effectiveRect);
	}
	return point;
}

CGPoint BMPointAlignedToSize(BMViewLayoutAlignment alignment, CGSize size) {
	return BMPointAlignedToSizeWithInsets(alignment, size, UIEdgeInsetsZero);
}

CGPoint BMPointAlignedToSizeWithInsets(BMViewLayoutAlignment alignment, CGSize size, UIEdgeInsets insets) {
	return BMPointAlignedToRectWithInsets(alignment, CGRectMake(0, 0, size.width, size.height), insets);
}


CGRect BMRectMakeIntegral(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
	return CGRectIntegral(CGRectMake(x, y, width, height));
}

CGPoint BMPointMakeIntegral(CGFloat x, CGFloat y) {
	return CGPointMake(roundf(x), roundf(y));
}

CGSize BMSizeMakeIntegral(CGFloat width, CGFloat height) {
	return CGSizeMake(ceilf(width), ceilf(height));
}

CGSize BMSizeInset(CGSize size, UIEdgeInsets edgeInsets) {
	return CGSizeMake(size.width - edgeInsets.left - edgeInsets.right, size.height - edgeInsets.top - edgeInsets.bottom);
}

UIEdgeInsets BMEdgeInsetsInvert(UIEdgeInsets edgeInsets) {
	return UIEdgeInsetsMake(-edgeInsets.top, -edgeInsets.left, -edgeInsets.bottom, -edgeInsets.right);
}

UIEdgeInsets BMEdgeInsetsMakeIntegral(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
	return UIEdgeInsetsMake(roundf(top), roundf(left), roundf(bottom), roundf(right));
}

UIEdgeInsets BMEdgeInsetsAdd(UIEdgeInsets insets1, UIEdgeInsets insets2) {
	return UIEdgeInsetsMake(insets1.top + insets2.top, insets1.left + insets2.left, insets1.bottom + insets2.bottom, insets1.right + insets2.right);
}

UIEdgeInsets BMEdgeInsetsSubtract(UIEdgeInsets insets1, UIEdgeInsets insets2) {
	return UIEdgeInsetsMake(insets1.top - insets2.top, insets1.left - insets2.left, insets1.bottom - insets2.bottom, insets1.right - insets2.right);
}

UIEdgeInsets BMEdgeInsetsWithDiffFromRects(CGRect rect1, CGRect rect2) {
	return UIEdgeInsetsMake(CGRectGetMinY(rect1) - CGRectGetMinY(rect2), CGRectGetMinX(rect1) - CGRectGetMinX(rect2), CGRectGetMaxY(rect2) - CGRectGetMaxY(rect1), CGRectGetMaxX(rect2) - CGRectGetMaxX(rect1));
}

BOOL BMIsPhoneSupported() {
	NSString *deviceType = [UIDevice currentDevice].model;
	return [deviceType isEqualToString:@"iPhone"];
}

BOOL BMIsIPhone5() {
    CGRect bounds = [[UIScreen mainScreen] bmPortraitBounds];
    return (bounds.size.height == 568.0f);
}

UIDeviceOrientation BMDeviceOrientation() {
	UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
	if (!orient) {
		return UIDeviceOrientationPortrait;
	} else {
		return orient;
	}
}

void BMRotateToOrientation(UIInterfaceOrientation orientation) {
    UIInterfaceOrientation currentOrientation = BMInterfaceOrientation();
    if (currentOrientation != orientation) {
        // http://stackoverflow.com/questions/181780/is-there-a-documented-way-to-set-the-iphone-orientation
        // http://openradar.appspot.com/radar?id=697
        // [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait]; // Using the following code to get around apple's static analysis...
        SEL selector = NSSelectorFromString(@"setOrientation:");
        if ([[UIDevice currentDevice] respondsToSelector:selector]) {
            
            NSMethodSignature *sig = [[UIDevice currentDevice] methodSignatureForSelector:selector];
            if (sig) {
                NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
                [invo setTarget:[UIDevice currentDevice]];
                [invo setSelector:selector];
                [invo setArgument:&orientation atIndex:2];
                [invo invoke];
            }
        }
    }
}


UIInterfaceOrientation BMInterfaceOrientation() {
	UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
	return orient;
}

BOOL BMIsSupportedOrientation(UIInterfaceOrientation orientation) {
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			return YES;
		default:
			return NO;
	}
}

CGAffineTransform BMRotateTransformForOrientation(UIInterfaceOrientation orientation) {
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}

CGRect BMScreenBounds() {
	CGRect bounds = [UIScreen mainScreen].bmPortraitBounds;
	if (UIInterfaceOrientationIsLandscape(BMInterfaceOrientation())) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	return bounds;
}

CGRect BMApplicationFrame() {
	CGRect frame = [UIScreen mainScreen].bmPortraitApplicationFrame;
	return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

CGRect BMNavigationFrame() {
	CGRect frame = [UIScreen mainScreen].bmPortraitApplicationFrame;
	return CGRectMake(0, 0, frame.size.width, frame.size.height - BMToolbarHeight());
}

CGRect BMKeyboardNavigationFrame() {
	return BMRectContract(BMNavigationFrame(), 0, BMKeyboardHeight());
}

CGRect BMToolbarNavigationFrame() {
	CGRect frame = [UIScreen mainScreen].bmPortraitApplicationFrame;
	return CGRectMake(0, 0, frame.size.width, frame.size.height - BMToolbarHeight()*2);
}

CGFloat BMStatusHeight() {
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    return MIN(statusBarFrame.size.width, statusBarFrame.size.height);
}

CGFloat BMBarsHeight() {
	CGRect frame = [UIApplication sharedApplication].statusBarFrame;
	if (UIInterfaceOrientationIsPortrait(BMInterfaceOrientation())) {
		return frame.size.height + BM_TOOLBAR_HEIGHT;
	} else {
		return frame.size.width + BM_LANDSCAPE_TOOLBAR_HEIGHT;
	}
}

CGFloat BMToolbarHeight() {
	return BMToolbarHeightForOrientation(BMInterfaceOrientation());
}

CGFloat BMToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		return BM_ROW_HEIGHT;
	} else {
		return BM_LANDSCAPE_TOOLBAR_HEIGHT;
	}
}

CGFloat BMKeyboardHeight() {
	return BMKeyboardHeightForOrientation(BMInterfaceOrientation());
}

CGFloat BMKeyboardHeightForOrientation(UIInterfaceOrientation orientation) {
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		return BM_KEYBOARD_HEIGHT;
	} else {
		return BM_LANDSCAPE_KEYBOARD_HEIGHT;
	}
}

void BMNetworkRequestStarted() {
	if (gNetworkTaskCount++ == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

void BMNetworkRequestStopped() {
	if (--gNetworkTaskCount == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@implementation BMUICore

static BMUICore *instance = nil;

+ (id)instance {
    if (!instance) {
        instance = [BMUICore new];
    }
    return instance;
}

+ (NSBundle *)bundle {
	static NSBundle *bundle = nil;
	if (bundle == nil) {
		NSString* path = [[[NSBundle bundleForClass:self] resourcePath]
				stringByAppendingPathComponent:@"BMUICore.bundle"];
		bundle = [NSBundle bundleWithPath:path];
	}
	return bundle;
}

@end
