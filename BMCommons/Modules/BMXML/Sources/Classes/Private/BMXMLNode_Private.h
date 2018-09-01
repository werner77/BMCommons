#import <libxml/globals.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMXMLNode()

@property (assign) xmlNode *libXMLNode;
@property (nullable, assign) xmlDoc *libXMLDocument;

+ (nullable instancetype)instanceWithXMLNode:(xmlNode *)nodeWithXMLNode;
- (nullable instancetype)initWithXMLNode:(xmlNode *)node NS_DESIGNATED_INITIALIZER;

+ (BOOL)isSupportedNodeType:(xmlElementType)type;

@end

NS_ASSUME_NONNULL_END
