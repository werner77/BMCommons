//
//  BMLabelCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 07/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMObjectPropertyTableViewCell.h>

/**
 Commons tableviewcell that contains a label (read-only string property).
 */
@interface BMLabelCell : BMObjectPropertyTableViewCell {
	IBOutlet UILabel *valueLabel;
	NSString *valueFormat;
	
	id valueFormatterTarget;
	SEL valueFormatterSelector;
}

@property (nonatomic, strong) IBOutlet UILabel *valueLabel;

/**
 A format to use for the label text. The value is fed to the format using [NSString stringWithFormat:format, value]
 */
@property (nonatomic, strong) NSString *valueFormat;

/**
 Target to use for converting the value for display in a more generic way than the above valueFormat property.
 */
@property (nonatomic, strong) id valueFormatterTarget;

/**
 The value formatter selector to use to convert the value for display in a more generic way than the above valueFormat property.
 */
@property (nonatomic, assign) SEL valueFormatterSelector;

@end
