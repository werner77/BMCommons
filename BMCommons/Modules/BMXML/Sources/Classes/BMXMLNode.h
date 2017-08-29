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

File: XMLNode.h
Abstract: A text node in an XML document.

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

@class BMXMLElement;

typedef NS_ENUM(NSUInteger, BMXMLNodeKind) {
    BMXMLNodeTextKind,
    BMXMLNodeElementKind
};

typedef NS_ENUM(NSUInteger, BMXMLExtraInfoFlags) {
    BMXMLExtraInfoArrayElement = 1,
    BMXMLExtraInfoIsJSONQuoted = 2,
    BMXMLExtraInfoEmptyElement = 4
};

NS_ASSUME_NONNULL_BEGIN

@interface BMXMLNode : NSObject <NSCopying>

/**
 * Used for json compatibility, whether the value is quoted or not.
 */
@property (nonatomic, getter=isJsonQuotedValueType) BOOL jsonQuotedValueType;

+ (BMXMLNode *)nodeWithString:(NSString *)string;

/**
 * Initializes this node with the specified text.
 */
- (id)initWithString:(NSString *)string;

/**
 * The kind of node.
 */
- (BMXMLNodeKind) kind;

/**
 * Returns true iff this node is a text node.
 */
- (BOOL) isTextNode;

/**
 * Returns true iff this node is an element node.
 */
- (BOOL) isElementNode;

/**
 * The index of this node within its parent.
 *
 * Returns NSNotFound if not within a parent context.
 */
- (NSInteger) index;

/**
 * The parent of this node.
 */
- (nullable BMXMLElement *)parent;

/**
 * Returns the next sibling if present, otherwise delegates to parent.
 *
 * @return The next node if present, nil otherwise.
 */
- (nullable BMXMLNode *)nextNode;

/**
 * Returns the next sibling if present.
 *
 * @return The next node if present, nil otherwise.
 */
- (nullable BMXMLNode *)nextSibling;

/**
 * Returns the previous sibling if present, otherwise delegates to parent.
 *
 * @return The previous node if present, nil otherwise.
 */
- (nullable BMXMLNode *)previousNode;

/**
 * Returns the previous sibling if present.
 *
 * @return The previous node if present, nil otherwise.
 */
- (nullable BMXMLNode *)previousSibling;

/**
 * Returns this node serialized as XMLString.
 *
 * @return The string or nil if serialization failed.
 */
- (nullable NSString *)XMLString;

/**
 * Returns the node content as string.
 *
 * @return The string or nil if serialization failed.
 */
- (nullable NSString *)stringValue;

/**
 * Returns this node serialized as json string value which is properly escaped to be valid JSON.
 *
 * @return The string value or nil if unsucceful.
 */
- (nullable NSString *)jsonStringValue;

/**
 * The root element by recursively traversing the parents for this node.
 *
 * @return The root element if found, nil otherwise.
 */
- (nullable BMXMLElement *)rootElement;

/**
 * Detaches this node from the XML tree.
 */
- (void)detach;

/**
 * Adds a node as next sibling.
 *
 * @param node The node
 */
- (BMXMLNode *)addNodeAsNextSibling:(BMXMLNode *)node;

/**
 * Adds a node as previous sibling.
 *
 * @param node The node
 */
- (BMXMLNode *)addNodeAsPreviousSibling:(BMXMLNode *)node;

@end

NS_ASSUME_NONNULL_END

