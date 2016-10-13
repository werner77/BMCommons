#import <libxml/xmlmemory.h>
#import <BMCommons/BMXMLDocument.h>

@interface BMXMLDocument()

@property xmlDocPtr xmlDocument;

+ (BMXMLDocument *)documentWithXMLDocument:(xmlDocPtr)doc;

@end
