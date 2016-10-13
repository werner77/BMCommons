//
//  BMVideo.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMVideo.h"

@implementation BMVideo

static NSArray *streamableContentTypes = nil;

@synthesize width, height, mediaOrientation;

+ (void)initialize {
    if (!streamableContentTypes) {
        streamableContentTypes = @[@"video/quicktime", @"video/mp4"];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.width forKey:@"width"];
    [coder encodeObject:self.height forKey:@"height"];
    [coder encodeInt64:self.mediaOrientation forKey:@"mediaOrientation"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        self.width = [coder decodeObjectForKey:@"width"];
        self.height = [coder decodeObjectForKey:@"height"];
        self.mediaOrientation = (NSUInteger)[coder decodeInt64ForKey:@"mediaOrientation"];
    }
    return self;
}


//Put custom code here
- (BMMediaKind)mediaKind {
	return BMMediaKindVideo;
}

- (BOOL)isStreamable {    
    return self.contentType == nil || [streamableContentTypes containsObject:[self.contentType lowercaseString]];
}

+ (NSString *)fileExtension {
	return @"mov";
}

@end
