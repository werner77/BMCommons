#import <libxml/tree.h>
#import <BMCommons/BMXPathQuery.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMXPathQuery()

@property (nonatomic, assign) xmlDocPtr doc;

- (id)initWithDoc:(xmlDocPtr)theDoc freeWhenDone:(BOOL)freeWhenDone NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
