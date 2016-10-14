//
//  BMSOAPService.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSOAPService.h>

#import <BMCommons/BMMGTemplateEngine.h>
#import <BMCommons/BMICUTemplateMatcher.h>
#import <BMCommons/BMObjectMappingParserHandler.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMHTTPRequest.h>
#import <BMCommons/BMSOAPData.h>
#import <BMCommons/BMSOAPFault.h>
#import <BMCommons/BMXMLElement.h>
#import <BMCommons/BMMappableObjectXMLSerializer.h>
#import <BMCommons/BMRestKit.h>

@implementation BMSOAPService

@synthesize soapRequestTemplate = _soapRequestTemplate;
@synthesize endpointURL = _endpointURL;
@synthesize soapAction = _soapAction;
@synthesize soapUsername = _soapUsername;
@synthesize soapPassword = _soapPassword;

static NSMutableDictionary *sParserHandlers = nil;

+ (void)initialize {
    //Cache this to improve performance
	if (!sParserHandlers) {
		sParserHandlers = [NSMutableDictionary new];
	}
}

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}


+ (NSString *)defaultSOAPRequestTemplate {
    return
    @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    @"<soapenv:Body>"
    @"{{ soap.body }}"
    @"</soapenv:Body>"
    @"</soapenv:Envelope>";
}

- (NSString *)soapRequestTemplate {
    if (_soapRequestTemplate) {
        return _soapRequestTemplate;
    } else {
        return [[self class] defaultSOAPRequestTemplate];
    }
}

- (void)configureParser:(BMParser *)theParser {
    [super configureParser:theParser];
    if (![theParser isKindOfClass:[BMXMLParser class]]) {
        NSException *ex = [NSException exceptionWithName:@"BMInvalidParserException" reason:@"BMSOAPService requires a BMXMLParser" userInfo:nil];
        @throw ex;
    }
}

#pragma mark -
#pragma mark Implementation of superclass methods

- (BMParserHandler *)handlerForService {
    if (!self.responseObjectClass) {
        return nil;
    }
    
    NSString *responseRootElement = [self.responseObjectClass rootElementName];
	NSString *key = [NSString stringWithFormat:@"%@:%@", responseRootElement, NSStringFromClass(self.responseObjectClass)];
	BMParserHandler *theHandler = [sParserHandlers objectForKey:key];
	if (!theHandler) {
		//This code is CPU intensive that is why we implemented caching
		theHandler = [[BMObjectMappingParserHandler alloc] initWithXPath:[self xpathForMappingResponseWithElementName:responseRootElement]
                                                        rootElementClass:self.responseObjectClass
                                                              errorXPath:@"/Envelope/Body/Fault"
                                                   errorRootElementClass:[BMSOAPFault class]
                                                                delegate:nil];
		[sParserHandlers setObject:theHandler forKey:key];
	}
	return theHandler;
}

- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
    
    if (!self.soapAction) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA
                                       description:@"SOAP action is required"];
        }
        return nil;
    }
    
    id <BMMappableObject> requestObject = self.requestObject;
    if (!requestObject) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA
                                       description:@"Request object is required"];
        }
        return nil;
    }
    
    Class<BMMappableObject> responseObjectClass = self.responseObjectClass;
    if (!responseObjectClass) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA
                                       description:@"Response object class is required"];
        }
        return nil;
    }
    
    if (!self.endpointURL) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA
                                       description:@"SOAP endpoint URL is required"];
        }
        return nil;
    }
    
    NSString *template = self.soapRequestTemplate;
    
    if (!template) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA
                                       description:@"SOAP request template is required"];
        }
        return nil;
    }
    
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 self.soapAction, @"SOAPAction",
							 nil];
    
    BMMappableObjectXMLSerializer *serializer = [BMMappableObjectXMLSerializer new];
    
	BMXMLElement *rootXMLElement = [serializer rootXmlElementFromObject:requestObject];
    
	
	BMSOAPData *soapData = [BMSOAPData soapDataWithUsername:self.soapUsername password:self.soapPassword body:[rootXMLElement XMLString]];
	
	BMMGTemplateEngine *engine = [BMMGTemplateEngine templateEngine];
	[engine setMatcher:[BMICUTemplateMatcher matcherWithTemplateEngine:engine]];
	
	NSString *result = [engine processTemplate:template
                                 withVariables:[NSDictionary dictionaryWithObject:[self configureSOAPData:soapData] forKey:@"soap"]];
	
	NSData *content = [result dataUsingEncoding:NSUTF8StringEncoding];
	
	BMHTTPRequest *theRequest = [[BMHTTPRequest alloc] initPostRequestWithUrl:self.endpointURL
                                                                  contentType:@"text/xml;charset=UTF-8"
                                                                      content:content
                                                           customHeaderFields:headers
                                                                     userName:self.soapUsername
                                                                     password:self.soapPassword
                                                                     delegate:nil];
	
	return theRequest;
}

@end

@implementation BMSOAPService(Protected)

- (BMSOAPData *)configureSOAPData:(BMSOAPData *)soapData {
    return soapData;
}

- (id <BMMappableObject>)requestObject {
    return nil;
}

- (Class<BMMappableObject>)responseObjectClass {
    return nil;
}

- (NSString *)xpathForMappingResponseWithElementName:(NSString *)elementName {
    return [NSString stringWithFormat:@"/Envelope/Body/%@", elementName];
}

@end

