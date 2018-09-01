#import <libxml/globals.h>
#import <BMCommons/BMXMLDocument.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMXMLDocument()

@property xmlDocPtr xmlDocument;

+ (nullable BMXMLDocument *)documentWithXMLDocument:(xmlDocPtr)doc;
- (nullable instancetype)initWithXMLDocument:(xmlDocPtr)doc NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
