#import <libxml/xmlmemory.h>

@interface BMXMLNode()

@property (assign) xmlNode *libXMLNode;
@property (assign) xmlDoc *libXMLDocument;

+ (BMXMLNode *)nodeWithXMLNode:(xmlNode *)nodeWithXMLNode;
- (id)initWithXMLNode:(xmlNode *)node;

@end
