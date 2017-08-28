//
//  BMTextViewCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 28/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMTextCell.h>
#import <BMCommons/BMAutoResizable.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMTextViewCell : BMTextCell <UITextViewDelegate, BMAutoResizable>

@property (nullable, nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, assign) BOOL sizeToFit;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat yMargin;
@property (nullable, nonatomic, strong) NSString *placeHolder;

@end

NS_ASSUME_NONNULL_END
