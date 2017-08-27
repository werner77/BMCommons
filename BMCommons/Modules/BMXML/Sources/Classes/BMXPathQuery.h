//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class for performing XPath queries.
 *
 * @warning After the instance is released the results of the query have to be processed because the xml document releases with this instance and the XMLNode class does not retain
 * the references to the underlying xmlNode pointers in the doc.
 * This means that the NSArray (and the XMLNode instances it contains) returned from performXPathQuery has to be processed and converted into other objects before the XPathQuery is released.
 */
@interface BMXPathQuery : NSObject

- (nullable id)initWithXMLDocument:(NSData *)document;
- (nullable id)initWithHTMLDocument:(NSData *)document;
- (nullable NSArray *)performXPathQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
