//
//  BMValuePickerCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMEnumeratedValueCell.h>

@interface BMValuePickerCell : BMEnumeratedValueCell {
    NSString *valueSelectionControllerNibName;
}

@property (nonatomic, strong) NSString *valueSelectionControllerNibName;

@end
