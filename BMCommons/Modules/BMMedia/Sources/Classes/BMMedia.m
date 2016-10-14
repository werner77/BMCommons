//
//  BMMedia.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMMedia/BMMedia.h>
#import <BMMedia/BMMediaContainer.h>

@implementation BMMedia

static BMMedia *instance = nil;

+ (id)instance {
    if (instance == nil) {
        instance = [BMMedia new];
    }
    return instance;
}

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"BMMedia.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}

+ (BMMediaOrientation)mediaOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BMMediaOrientation theOrientation = BMMediaOrientationUnknown;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        theOrientation = BMMediaOrientationLandscape;
    } else if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        theOrientation = BMMediaOrientationPortrait;
    }

    return theOrientation;
}

@end



