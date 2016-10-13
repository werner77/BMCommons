
#import <BMYouTube/BMYouTube.h>
#if BM_PRIVATE_ENABLED
#import <BMCore/BMLicenseKey_Private.h>
#endif

@implementation BMYouTube

static BMYouTube *instance = nil;

+ (id)instance {
    if (instance == nil) {
        instance = [BMYouTube new];
    }
    return instance;
}

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"BMYouTube.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}

BM_LICENSED_MODULE_IMPLEMENTATION(BMYouTube)

@end