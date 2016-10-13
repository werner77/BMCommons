//
//  BMTextViewCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 28/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUIExtensions/BMTextCell.h>
#import <BMUICore/BMAutoResizable.h>

@interface BMTextViewCell : BMTextCell <UITextViewDelegate, BMAutoResizable> {
	IBOutlet UITextView *textView;
	BOOL sizeToFit;
	CGFloat minHeight;
	CGFloat yMargin;
    NSString *placeHolder;
    BOOL placeHolderPresent;
    UIColor *originalTextColor;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, assign) BOOL sizeToFit;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat yMargin;
@property (nonatomic, strong) NSString *placeHolder;


@end
