//
//  BMValuePickerCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMValuePickerCell.h>
#import <BMCommons/BMEnumeratedValueSelectionViewController.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMEnumeratedValueToStringTransformer.h>
#import <BMCommons/BMUICore.h>

@implementation BMValuePickerCell {
    NSString *valueSelectionControllerNibName;
}

@synthesize valueSelectionControllerNibName;

- (void)dealloc {
    BM_RELEASE_SAFELY(valueSelectionControllerNibName);
}

#pragma mark -
#pragma mark Public methods

- (id <BMEditViewController>)selectionViewController {
    if (self.possibleValues.count > 0) {
        NSString *nibName = self.valueSelectionControllerNibName;
        BMEnumeratedValueSelectionViewController *vc;
        if (nibName) {
            vc = [[BMEnumeratedValueSelectionViewController alloc] initWithNibName:nibName bundle:nil];
        } else {
            vc = [[BMEnumeratedValueSelectionViewController alloc] init];
        }
        vc.possibleValues = self.possibleValues;
        vc.valueTransformer = self.displayValueTransformer;
        vc.propertyDescriptor = [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"selectedValue" 
                                                                         withTarget:self];
        vc.saveWhenValueIsSelected = YES;
        return vc;
    } else {
        return nil;
    }
}

@end
