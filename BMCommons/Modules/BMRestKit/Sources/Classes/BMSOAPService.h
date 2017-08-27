//
//  BMSOAPService.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectMappingParserService.h>

@class BMSOAPData;

NS_ASSUME_NONNULL_BEGIN

/**
 Base class for SOAP Web Services.
 */
@interface BMSOAPService : BMObjectMappingParserService {
    
}

/**
 This is a string containing a MGTemplate for substituting the BMSOAPData in the request.
 
 Default is the string which is returned from [BMSOAPService defaultSOAPRequestTemplate]
 */
@property (nullable, strong) NSString *soapRequestTemplate;

/**
 The endpoint URL for the service.
 */
@property (nullable, strong) NSURL *endpointURL;

/**
 The soap action for the service.
 */
@property (nullable, strong) NSString *soapAction;

/**
 The username for the service. 
 
 This username is used in the request for basic/NTLM authentication.
 The default template does not contain a SOAP security header. If you wish to include the security header you have to supply a template manually.
 The username and password are part of the BMSOAPData which is fed to the protected method configureSOAPData:.
 */
@property (nullable, strong) NSString *soapUsername;

/**
 The password for the service.
 
 This password is used in the request for basic/NTLM authentication.
 The default template does not contain a SOAP security header. If you wish to include the security header you have to supply a template manually.
 The username and password are part of the BMSOAPData which is fed to the protected method configureSOAPData:.
 */
@property (nullable, strong) NSString *soapPassword;

/**
 The default SOAP request template.
 
 This is a string containing a MGTemplate kind of template in which a BMSOAPData object is substituted.
 */
+ (NSString *)defaultSOAPRequestTemplate;

@end

@interface BMSOAPService(Protected)

/**
 Sub classes may override this method to manipulate the SOAP data before it is substituted in the request.
 */
- (BMSOAPData *)configureSOAPData:(BMSOAPData *)soapData;

/**
 The request object which is used to generate the XML body of the SOAP request.
 
 The body is substituted as follows in the default template:
 
     <soapenv:Body>
     {{ soap.body }}
     </soapenv:Body>
 
 @see [BMSOAPData body]
 @see [BMMappableObject rootXmlElement]
 */
- (nullable id <BMMappableObject>)requestObject;

/**
 The class to use to map the response to.
 */
- (nullable Class<BMMappableObject>)responseObjectClass;

/**
 The XPath to use as starting point for mapping the response.
 
 Defaults to:
 
    [NSString stringWithFormat:@"/Envelope/Body/%@", elementName];
 */
- (NSString *)xpathForMappingResponseWithElementName:(NSString *)elementName;

@end

NS_ASSUME_NONNULL_END
