//
//  BMResizableToolbar.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UIToolbar with adjustable height.
 */
@interface BMResizableToolbar : UIToolbar

@property (nonatomic, assign) CGFloat height;

@end

NS_ASSUME_NONNULL_END
