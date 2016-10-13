//
//  BMButtonCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectPropertyTableViewCell.h>

@interface BMButtonCell : BMObjectPropertyTableViewCell {
    IBOutlet UIButton *button;
}

@property (nonatomic, strong) IBOutlet UIButton *button;

@end
