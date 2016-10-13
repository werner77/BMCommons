#import "BMXMLNode_Private.h"

@interface BMXMLElement()

+ (BMXMLElement *)elementWithXMLNode:(xmlNode *)node;
- (BMXMLElement *)initWithXMLNode:(xmlNode *)node;

@end
