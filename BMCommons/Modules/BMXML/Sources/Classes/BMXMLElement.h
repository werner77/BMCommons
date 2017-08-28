/***

Important:

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not 
final. Apple is supplying this information to help you plan for the adoption of 
the technologies and programming interfaces described herein. This information 
is subject to change, and software implemented based on this sample code should 
be tested with final operating system software and final documentation. Newer 
versions of this sample code may be provided with future seeds of the API or 
technology. For information about updates to this and other developer 
documentation, view the New & Updated sidebars in subsequent documentation seeds.

***/

/*

File: XMLElement.h
Abstract: An element in an XML document.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc.
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <Foundation/Foundation.h>
#import <BMCommons/BMXMLNode.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class describing an XML element.
 */
@interface BMXMLElement : BMXMLNode

+ (nullable instancetype)elementWithName:(NSString *)name;
- (nullable instancetype)initWithName:(NSString *)name;

/**
 * Whether this element is part of an array
 *
 * Used for JSON compatibility
 */
@property (nonatomic, assign, getter=isArrayElement) BOOL arrayElement;

/**
 * Whether or not this element represents an empty element
 *
 * Used for JSON compatibility
 */
@property (nonatomic, assign, getter=isEmptyElement) BOOL emptyElement;

/**
 * The name of this element.
 */
- (NSString *)name;

/**
 * The optional namespace prefix for this element.
 */
- (nullable NSString *)namespacePrefix;

/**
 * Array of BMXMLNodes comprising the children of the receiver.
 */
- (NSArray *)children;

/**
 * Array of BMXMLNodes comprising the descendants of the receiver.
 */
- (NSArray *)descendants;

/**
 * Number of children of the receiver.
 */
- (NSUInteger)childCount;

/**
 * Returns the first child or nil if no children are present.
 */
- (nullable BMXMLNode *)firstChild;

/**
 * Returns the last child or nil if no children are present.
 */
- (nullable BMXMLNode *)lastChild;

/**
 * Returns the fully qualified name.
 */
- (NSString *)qualifiedName;

/**
 * Optional dictionary containing the attributes as key-value pairs for this element.
 */
- (nullable NSDictionary *)attributes;

/**
 * Attributes encoded as string.
 */
- (NSString *)attributesString;

/**
 * Returns the child at the specified index.
 */
- (BMXMLNode *)childAtIndex:(NSUInteger)index;

/**
 * Returns the first child corresponding with the supplied name or nil if not found.
 */
- (nullable BMXMLElement *)firstChildNamed:(NSString *)matchName;

/**
 * Returns the last child corresponding with the supplied name or nil if not found.
 */
- (nullable BMXMLElement *)lastChildNamed:(NSString *)matchName;

/**
 * Returns the first descendant corresponding with the supplied name or nil if not found.
 */
- (nullable BMXMLElement *)firstDescendantNamed:(NSString *)matchName;

/**
 * Returns the children corresponding with the supplied match name.
 */
- (NSArray *)childrenNamed:(NSString *)matchName;

/**
 * Returns the descendants corresponding with the supplied match name.
 */
- (NSArray *)descendantsNamed:(NSString *)matchName;

/**
 * Returns all elements that contain an attribute with the specified name.
 */
- (NSArray *)elementsWithAttributeNamed:(NSString *)attributeName;

/**
 * Returns all elements that contain an attribute with the specified name and value.
 */
- (NSArray *)elementsWithAttributeNamed:(NSString *)attributeName attributeValue:(NSString *)attributeValue;

/**
 * Returns an array of elements corresponding with the specified XPath expression.
 *
 * @param XPath The XPath expression
 * @param outError The error
 * @return The array of elements found or nil in case of error.
 */
- (nullable NSArray *)elementsForXPath:(NSString *)XPath error:(NSError *_Nullable *_Nullable )outError;
- (nullable NSArray *)elementsForXPath:(NSString *)XPath prepareNamespaces:(nullable NSArray *)namespaces error:(NSError *_Nullable *_Nullable )outError;
- (nullable NSArray *)elementsForXPath:(NSString *)XPath namespaces:(nullable NSDictionary *)namespaces error:(NSError * _Nullable *_Nullable )outError;

/**
 * Inserts a child node at the specified index.
 *
 * @param node The node to insert.
 * @param index The index to insert the node at.
 * @return Copy of the added node.
 */
- (BMXMLNode *)insertChild:(BMXMLNode *)node atIndex:(NSUInteger)index;

/**
 * Adds a child node.
 *
 * @param node The child node to add.
 * @return Copy of the added child node
 */
- (BMXMLNode *)addChild:(BMXMLNode *)node;

/**
 * Adds a text child node.
 *
 * @param text The text content for the node to add
 * @return The added node
 */
- (BMXMLNode *)addTextChild:(NSString *)text;

/**
 * Adds a child node with the specified name.
 *
 * @param childName The name for the node to add
 * @return The added node
 */
- (BMXMLElement *)addChildNamed:(NSString *)childName;

/**
 * Adds a child node with the specified name and text content.
 *
 * @param childName The name for the node to add
 * @param nodeContent The text content for the node to add.
 * @return The added node
 */
- (BMXMLElement *)addChildNamed:(NSString *)childName withTextContent:(NSString *)nodeContent;
- (BMXMLElement *)addChildNamed:(NSString *)childName withTextContent:(NSString *)nodeContent cdata:(BOOL)cdata;

/**
 * Merges consecutive child text nodes into one if encountered.
 */
- (void)consolidateConsecutiveTextNodes;

/**
 * The value of the attribute with the specified name.
 * @param name The attribute name
 * @return The value or nil if not found.
 */
- (nullable NSString *)attributeNamed:(NSString *)name;

/**
 * Adds an attribute with the specified name and value.
 *
 * @param attributeName The attribute name
 * @param attributeValue The attibute value.
 * @return The BMXMLNode representing the new attribute.
 */
- (BMXMLNode *)addAttribute:(NSString *)attributeName value:(NSString *)attributeValue;

/**
 * Deletes the attribute with the specified name if found.
 *
 * @param attributeName The name of the attribute.
 */
- (void)deleteAttributeNamed:(NSString *)attributeName;

/**
 * Returns the value of the attribute with the specified name of the first child node with the specified child name.
 *
 * @param name The name of the attribute.
 * @param childName The name of the child node.
 * @return The value of the attribute or nil if not found.
 */
- (nullable NSString *)attributeNamed:(NSString *)name ofFirstChildNodeNamed:(NSString *)childName;

/**
 * The text of the first text node corresponding with the specified child name.
 *
 * @param childName The child name
 * @return The text content if found, nil otherwise.
 */
- (nullable NSString *)nodeTextOfFirstChildNodeNamed:(NSString *)childName;

/**
 * Returns the receiver serialized as a string in JSON format.
 *
 * @param attributePrefix The prefix to use for key names to translate XML attributes to JSON
 * @param textContentIdentifier The key name to use for XML text content for translation to JSON
 * @return The JSON string if successful, nil otherwise.
 */
- (nullable NSString *)JSONStringWithAttributePrefix:(NSString *)attributePrefix textContentIdentifier:(NSString *)textContentIdentifier;

@end

NS_ASSUME_NONNULL_END
