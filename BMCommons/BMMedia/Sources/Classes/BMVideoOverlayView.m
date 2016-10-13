//
//  BMVideoOverlayView.m
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMVideoOverlayView.h"
#import <BMMedia/BMMedia.h>

@implementation BMVideoOverlayView

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        BMMediaCheckLicense();
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        BMMediaCheckLicense();
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	int numOverlayRows = 5;
	int fillHeight = rect.size.height / numOverlayRows;
	
	UIColor *fillColor = [UIColor colorWithWhite:0.1 alpha:0.7];
	CGContextSetFillColorWithColor(context, [fillColor CGColor]);
	
	CGRect overlayRect = CGRectMake(0, rect.size.height - fillHeight, rect.size.width, fillHeight);
	CGContextFillRect(context, overlayRect);
	
	UIImage *camImage = [UIImage imageNamed:@"BMMedia.bundle/icon_cam.png"]; 
	
	CGFloat imageHeight = (int)(fillHeight * 2.0 / 3.0);
	CGFloat imageWidth = (int)(camImage.size.width * imageHeight / camImage.size.height);
	CGFloat x = (int)(rect.size.width / 16);
	CGFloat y = (int)(rect.size.height - (fillHeight + imageHeight)/2);
	
	CGContextDrawImage(context, CGRectMake(x, y, imageWidth, imageHeight), [camImage CGImage]);
}

@end
