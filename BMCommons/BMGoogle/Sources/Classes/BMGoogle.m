#import <BMCommons/BMGoogle.h>

@implementation BMGoogle

static BMGoogle *instance = nil;

+ (id)instance {
    if (instance == nil) {
        instance = [BMGoogle new];
    }
    return instance;
}

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"BMGoogle.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}

@end
