//
//  BMSwitchCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMObjectPropertyTableViewCell.h>

/**
 Commons tableviewcell that contains a switch (represents a boolean value)
 */
@interface BMSwitchCell : BMObjectPropertyTableViewCell {
	IBOutlet UISwitch *valueSwitch;
}

@property(nonatomic, strong) IBOutlet UISwitch *valueSwitch;

@end
