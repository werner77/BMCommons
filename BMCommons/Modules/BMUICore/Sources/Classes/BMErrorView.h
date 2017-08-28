//
//  BMErrorView.h
//  BMCommons
//
//  Created by Werner Altewischer on 02/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 View to display on error for example in conjunction with BMTableViewController.
 
 @see [BMTableViewController errorView]
 */
@interface BMErrorView : UIView

/**
 Image view for an image to display.
 */
@property (nullable, nonatomic, strong) IBOutlet UIImageView*  imageView;

/**
 Label for title text.
 */
@property (nullable, nonatomic, strong) IBOutlet UILabel* titleLabel;

 /**
  Label for sub title text.
  */
@property (nullable, nonatomic, strong) IBOutlet UILabel* subtitleLabel;

/**
 Button for refresh.
 */
@property (nullable, nonatomic, strong) IBOutlet UIButton *refreshButton;

/**
 Label for description text.
 */
@property (nullable, nonatomic, strong) IBOutlet UILabel *descriptionLabel;

@end

NS_ASSUME_NONNULL_END