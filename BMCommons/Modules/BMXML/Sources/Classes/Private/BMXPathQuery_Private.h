#import <libxml/tree.h>
#import <BMCommons/BMXPathQuery.h>

@interface BMXPathQuery()

@property (nonatomic, assign) xmlDocPtr doc;

- (id)initWithDoc:(xmlDocPtr)theDoc;

@end
