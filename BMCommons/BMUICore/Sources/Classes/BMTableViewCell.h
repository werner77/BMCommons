//
//  BMClickableTableViewCell.h
//  BehindMedia
//
//  Created by Werner Altewischer on 27/10/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BMUICore/BMClickable.h>
#import <BMCore/BMReusableObject.h>

/**
 Tableview cell that works together with BMTableViewController. 
 
 If this cell is selected it will call the specified target/selector.
 */
@interface BMTableViewCell : UITableViewCell<BMClickable, BMReusableObject> 

/**
 Target to call when the cell is clicked.
 */
@property(nonatomic, weak) NSObject *target;

/**
 Selector to call when the cell is clicked.
 */
@property(nonatomic, assign) SEL selector;
@property(nonatomic, assign) UITableViewCellSelectionStyle enabledSelectionStyle;
@property(nonatomic, assign) UITableViewCellSelectionStyle disabledSelectionStyle;

/**
 Support for changing the reuse identifier of the cell.
 */
- (void)setReuseIdentifier:(NSString *)identifier;

@end
