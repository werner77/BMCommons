//
//  BMKeyValuePair.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMDynamicObject : NSObject {
	//Dictionary for storing all the fields
	NSMutableDictionary *_fieldDictionary;
}

@property (nonatomic, strong, readonly) NSDictionary *fieldDictionary;

@end