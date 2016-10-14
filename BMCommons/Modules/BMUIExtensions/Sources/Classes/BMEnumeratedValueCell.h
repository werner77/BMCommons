//
//  BMEnumeratedValueCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMValueSelectionCell.h>
#import <BMCommons/BMEnumeratedValue.h>

@interface BMEnumeratedValueCell : BMValueSelectionCell {
	NSArray *possibleValues;
}

@property (nonatomic, strong) NSArray *possibleValues;

@end
