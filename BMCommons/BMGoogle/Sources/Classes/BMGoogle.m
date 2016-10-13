#import <BMCommons/BMGoogle.h>
#if BM_PRIVATE_ENABLED
#import <BMCore/BMLicenseKey_Private.h>
#endif
#import <BMGoogle/BMGoogle.h>

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

BM_LICENSED_MODULE_IMPLEMENTATION(BMGoogle)

@end
