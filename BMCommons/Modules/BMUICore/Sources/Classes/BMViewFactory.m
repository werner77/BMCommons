#import <BMCommons/BMViewFactory.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/BMWeakReferenceRegistry.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/BMNib.h>

@implementation BMViewFactory {
	NSBundle *_bundle;
    NSMutableDictionary *_registeredNibs;
}

NSString * const BMCollectionViewCellKind = @"UICollectionViewCell";
NSString * const BMTableViewCellKind = @"UITableViewCell";
NSString * const BMTableViewHeaderFooterViewKind = @"UITableViewHeaderFooterView";

@synthesize bundle = _bundle;

- (id) initWithBundle:(NSBundle *)theBundle {
	if ((self = [super init])) {
		if (!theBundle) theBundle = [NSBundle mainBundle];
		_bundle = theBundle;
        _registeredNibs = [NSMutableDictionary new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (id)init {
    return [self initWithBundle:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)releaseMemory {
    for (BMNib *nib in [_registeredNibs allValues]) {
        [nib clearCache];
    }
}

- (NSString *)nibNameForKind:(NSString *)cellKind {
	return cellKind;
}

- (UIView<BMReusableObject> *)viewOfType:(NSString *)theKind {
	NSArray * templates = [_bundle loadNibNamed:[self nibNameForKind:theKind] owner:nil options:nil];
    UIView *v = nil;
	for (id template in templates) {
		if ([template isKindOfClass:[UIView class]] && [template respondsToSelector:@selector(reuseIdentifier)] && 
			[[template reuseIdentifier] isEqual:theKind]) {
			v = template;
			break;
		}
	}
	return (UIView <BMReusableObject> *)v;
}

- (UIView<BMReusableObject> *)viewOfType:(NSString *)theKind forContainer:(id <BMReusableObjectContainer>)container {
    id<BMReusableObject> o = [container dequeueReusableObjectWithIdentifier:theKind];
    
    if ([o isKindOfClass:[UIView class]]) {
        return (UIView<BMReusableObject> *)o;
    } else {
        return [self viewOfType:theKind];
    }
}

- (UIView *)viewFromNib:(NSString *)theNibName {
    return [self viewFromNib:theNibName withOwner:nil];
}

- (UIView *)viewFromNib:(NSString *)theNibName withOwner:(id)owner {
	NSArray * templates = [_bundle loadNibNamed:theNibName owner:owner options:nil];
    UIView *v = nil;
	for (id template in templates) {
		if ([template isKindOfClass:[UIView class]]) {
			v = template;
			break;
		}
	}
	return v;
}

- (UITableViewCell*)cellOfType:(NSString*)type forTableView:(UITableView*)aTableView atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (BMOSVersionIsAtLeast(@"6.0")) {
        if ([self registerOnceReusableViewOfType:type ofKind:BMTableViewCellKind forView:aTableView]) {
            cell = [aTableView dequeueReusableCellWithIdentifier:type forIndexPath:indexPath];
        }
    }
    return cell;
}

- (UIView*)headerFooterViewOfType:(NSString*)type forTableView:(UITableView*)aTableView {
    UIView *view = nil;
    if (BMOSVersionIsAtLeast(@"6.0")) {
        if ([self registerOnceReusableViewOfType:type ofKind:BMTableViewHeaderFooterViewKind forView:aTableView]) {
            view = [aTableView dequeueReusableHeaderFooterViewWithIdentifier:type];
        }
    }
    return view;
}

- (UICollectionViewCell *)cellOfType:(NSString *)type forCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (BMOSVersionIsAtLeast(@"6.0")) {
        if ([self registerOnceReusableViewOfType:type ofKind:BMCollectionViewCellKind forView:collectionView]) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
        }
    }
    return cell;
}

- (UICollectionReusableView *)reusableViewOfType:(NSString *)type ofKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    if (BMOSVersionIsAtLeast(@"6.0")) {
        if ([self registerOnceReusableViewOfType:type ofKind:kind forView:collectionView]) {
            view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:type forIndexPath:indexPath];
        }
    }
    return view;
}

- (NSString *)keyForView:(UIView *)v type:(NSString *)type kind:(NSString *)kind {
    return [NSString stringWithFormat:@"%llu:%@:%@", (unsigned long long)v, type, kind];
}

- (BOOL)registerOnceReusableViewOfType:(NSString *)type ofKind:(NSString *)kind forView:(UIView *)view {
    BOOL isRegistered = NO;
    
    UITableView *tableView = [view bmCastSafely:[UITableView class]];
    UICollectionView *collectionView = [view bmCastSafely:[UICollectionView class]];
    
    if (type && kind && view) {
        id key = [self keyForView:view type:type kind:kind];
        
        isRegistered = [_registeredNibs objectForKey:key] != nil;
        
        if (!isRegistered) {
            BMNib *nib = nil;
            
            NSString *nibPath = [self.bundle pathForResource:type ofType:@"nib"];
            if (nibPath != nil) {
                nib = [BMNib nibWithNibName:type bundle:self.bundle];
            }
            
            if (nib == nil) {
                Class clazz = NSClassFromString(type);
                if (clazz) {
                    if (([kind isEqualToString:BMTableViewCellKind] && [clazz isSubclassOfClass:[UITableViewCell class]]) ||
                        ([kind isEqualToString:BMTableViewHeaderFooterViewKind]) ||
                        ([kind isEqualToString:BMCollectionViewCellKind] && [clazz isSubclassOfClass:[UICollectionViewCell class]]) ||
                        ([clazz isSubclassOfClass:[UICollectionReusableView class]])) {
                        
                        nib = [BMNib nibWithObjectClass:clazz];
                    } else {
                        LogWarn(@"Class %@ is not supported as reusable view", NSStringFromClass(clazz));
                    }
                } else {
                    LogWarn(@"Could not load nib or class for view type: %@", type);
                }
            }
            
            if (nib != nil) {
                NSUInteger defaultPreCacheSize = [BMNib defaultPreCacheSizeForNibName:type];
                NSUInteger defaultMinPreCacheSize = [BMNib defaultCacheSizeForNibName:type];
                nib.preCacheSize = defaultPreCacheSize;
                nib.cacheSize = defaultMinPreCacheSize;
                if ([kind isEqualToString:BMTableViewCellKind]) {
                    [tableView registerNib:nib forCellReuseIdentifier:type];
                } else if ([kind isEqualToString:BMTableViewHeaderFooterViewKind]) {
                    [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:type];
                } else if ([kind isEqualToString:BMCollectionViewCellKind]) {
                    [collectionView registerNib:nib forCellWithReuseIdentifier:type];
                } else {
                    [collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:type];
                }
                [_registeredNibs setObject:nib forKey:key];
                isRegistered = YES;
            }
            
            if (isRegistered) {
                [[BMWeakReferenceRegistry sharedInstance] registerReference:collectionView forOwner:self withCleanupBlock:^{
                    [_registeredNibs removeObjectForKey:key];
                }];
            }
        }
    }
    return isRegistered;
}

@end  
