

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
    CGRect bounds = [UIScreen mainScreen].bmPortraitBounds;
    CGRect applicationFrame = [UIScreen mainScreen].bmPortraitApplicationFrame;
    
    if (bounds.size.width != applicationFrame.size.width) {
        return bounds.size.width - applicationFrame.size.width;
    } else {
        return bounds.size.height - applicationFrame.size.height;
    }
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
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"BMUICore.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}

BM_LICENSED_MODULE_IMPLEMENTATION(BMUICore)

@end
