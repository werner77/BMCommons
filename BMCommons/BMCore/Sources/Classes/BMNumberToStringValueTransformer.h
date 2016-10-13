//
//  BMNumberToStringValueTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/17/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Transformer for converting an NSNumber to a string and vice versa.
 
 For forward transformation the [NSNumber stringValue] is used. 
 For reverse transformation the class method [NSNumber numberFromString:] is used, which is declared in a BMCommons category.
 */
@interface BMNumberToStringValueTransformer : NSValueTransformer {

}

@end
