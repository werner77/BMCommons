//
//  BMPicture.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <BMCommons/BMPicture.h>
#import <BMCommons/UIImageToJPEGDataTransformer.h>
#import <BMCommons/BMImageHelper.h>

#define DEFAULT_MAX_FULLSIZE_RESOLUTION 1600

@implementation BMPicture {
}

@synthesize width, height, mediaOrientation;

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

- (void)dealloc {
    BM_RELEASE_SAFELY(width);
    BM_RELEASE_SAFELY(height);
}

- (void)setImage:(UIImage *)theImage {
    [self setData:[self dataFromImage:theImage]];
}

- (UIImage *)image {
	return [self.storage imageForUrl:self.url];
}

+ (NSString *)fileExtension {
	return @"jpg";
}

- (BMMediaKind)mediaKind {
	return BMMediaKindPicture;
}

- (void)saveFullSizeImage:(UIImage *)theImage {
    CGSize size;
    [BMImageHelper saveAndScaleImage:theImage withMaxResolution:[[self class] maxFullSizeResolution] target:self selector:@selector(setData:) targetSize:&size];
    self.width = [NSNumber numberWithInteger:(NSInteger)size.width];
    self.height = [NSNumber numberWithInteger:(NSInteger)size.height];
}

+ (NSInteger)maxFullSizeResolution {
    return DEFAULT_MAX_FULLSIZE_RESOLUTION;
}

@end
