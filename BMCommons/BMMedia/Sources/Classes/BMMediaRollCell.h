//
//  BMMediaRollCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 26/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Tableview cell containing a media roll.
 
 A media roll is basically a horizontal tableview containing media thumbnails (videos and/or pictures). 
 This class ensures (in layoutSubviews) that the tableview set by the property mediaRoll is property aligned and transformed to a horizontal table view. The cell may be initialized with a NIB.
 
 */
@interface BMMediaRollCell : UITableViewCell

/**
 Horizontal table view.
 
 Table view containing the media thumbnail cells in horizontal direction. This class takes care of the vertical to horizontal transformation. Default is a plain table view with clear background color.
 */
@property(nonatomic, strong) IBOutlet UITableView *mediaRoll;

/**
 Optional placeholder label.
 
 Label containing some text to prompt the user to add media to the media roll.
 Default is a default UILabel with clear background color with centered text alignment.
 */
@property(nonatomic, strong) IBOutlet UILabel *promptLabel;

/**
 Margin to offset the mediaRoll frame horizontally from the border of this cell.
 
 Default is 5.0 pixels.
 */
@property(nonatomic, assign) CGFloat horizontalMargin;

/**
 Margin to offset the mediaRoll frame horizontally from the border of this cell.
 
 Default is 5.0 pixels.
 */
@property(nonatomic, assign) CGFloat verticalMargin;

@end
