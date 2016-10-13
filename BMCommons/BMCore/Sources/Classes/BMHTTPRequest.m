//
//  BMHTTPRequest.m
//
//  Created by Werner Altewischer on 22/07/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import "BMHTTPRequest.h"
#import "BMEncodingHelper.h"
#import "BMStringHelper.h"
#import "BMURLConnectionInputStream.h"
#import "NSData+BMEncryption.h"
#import "BMErrorHelper.h"
#import "BMErrorCodes.h"
#import "BMSecurityHelper.h"
#import "NSString+BMCommons.h"
#import "BMLogging.h"
#import "BMHTTPMultiPartBodyInputStream.h"
#import <BMCommons/BMCore.h>

#define BOUNDARY_STRING @"0xUn1quEKhTmLbOuNdArYx0"

#define FIELD_CONTENT_TYPE @"Content-Type"
#define FIELD_CONTENT_ENCODING @"Content-Encoding"
#define FIELD_CONTENT_LENGTH @"Content-Length"
#define FIELD_AUTHORIZATION @"Authorization"
#define VALUE_ENCODING_GZIP @"gzip"

static const NSUInteger kMaxRetryCount = 1;

@interface BMHTTPRequest ()<BMURLConnectionInputStreamDelegate>

@end

@interface BMHTTPRequest (Private)

- (void)setHttpCookies;

- (void)storeHttpCookiesForResponse:(NSHTTPURLResponse *)response;

- (void)setLastError:(NSError *)theError;

- (void)setReplyData:(NSData *)theData;

- (void)setInputStream:(BMURLConnectionInputStream *)theStream;

- (void)requestCompleted:(BOOL)success;

+ (NSString *)encodeUserName:(NSString *)userName andPassword:(NSString *)password;

+ (NSString *)queryStringForParameters:(NSDictionary *)parameters;

- (void)updateUploadProgress:(float)progress;
- (void)updateDownloadProgress:(float)progress;

@end

@implementation BMHTTPRequest {
    NSUInteger _sendCount;
}

@synthesize httpResponseCode = _httpResponseCode;
@synthesize response = _response;
@synthesize lastError = _lastError;
@synthesize replyData = _replyData;
@synthesize identifier = _identifier;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize responseHeaderFields = _responseHeaderFields;
@synthesize inputStream = _inputStream;
@synthesize request = _request;
@synthesize context = _context;
@synthesize shouldAllowSelfSignedCert = _shouldAllowSelfSignedCert;
@synthesize clientIdentityRef = _clientIdentityRef;
@synthesize manageCookies = _manageCookies;

static NSURLRequestCachePolicy defaultCachePolicy = BM_HTTP_REQUEST_DEFAULT_CACHE_POLICY;
static NSTimeInterval defaultTimeoutInterval = BM_HTTP_REQUEST_DEFAULT_TIMEOUT;

+ (void)setDefaultCachePolicy:(NSURLRequestCachePolicy)policy {
    defaultCachePolicy = policy;
}

+ (NSURLRequestCachePolicy)defaultCachePolicy {
    return defaultCachePolicy;
}

+ (void)setDefaultTimeoutInterval:(NSTimeInterval)time {
    defaultTimeoutInterval = time;
}

+ (NSTimeInterval)defaultTimeoutInterval {
    return defaultTimeoutInterval;
}

- (id)initPostRequestWithUrl:(NSURL *)theUrl
                 contentType:(NSString *)contentType
                     content:(NSData *)content
          customHeaderFields:(NSDictionary *)customHeaderFields
                    userName:(NSString *)theUserName
                    password:(NSString *)thePassword
                    delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    if ((self = [self initWithUrl:theUrl customHeaderFields:customHeaderFields userName:theUserName password:thePassword
                         delegate:theDelegate])) {
        [_request setHTTPMethod:BM_HTTP_METHOD_POST];
        [_request addValue:contentType forHTTPHeaderField:FIELD_CONTENT_TYPE];
        [_request addValue:[NSString stringWithFormat:@"%d", (int)content.length] forHTTPHeaderField:FIELD_CONTENT_LENGTH];
        [_request setHTTPBody:content];
        LogDebug(@"Body: %@\n", [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]);
    }
    return self;
}

- (id)initPostRequestWithUrl:(NSURL *)theUrl
                  parameters:(NSDictionary *)parameters
          customHeaderFields:(NSDictionary *)theCustomHeaderFields
                    userName:(NSString *)theUserName
                    password:(NSString *)thePassword
                    delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    NSString *queryString = [[self class] queryStringForParameters:parameters];
    NSData *data = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    return [self initPostRequestWithUrl:theUrl contentType:@"application/x-www-form-urlencoded" content:data customHeaderFields:theCustomHeaderFields
                               userName:theUserName password:thePassword delegate:theDelegate];
}

- (id)initMultiPartPostRequestWithUrl:(NSURL *)theUrl
                         contentParts:(NSArray *)contentParts
                   customHeaderFields:(NSDictionary *)customHeaderFields
                             userName:(NSString *)theUserName
                             password:(NSString *)thePassword
                             delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    if ((self = [self initWithUrl:theUrl customHeaderFields:customHeaderFields userName:theUserName password:thePassword
                         delegate:theDelegate])) {
        [_request setHTTPMethod:BM_HTTP_METHOD_POST];
        
        NSString *stringBoundary = BOUNDARY_STRING;
        NSString *theContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
        LogDebug(@"Creating MultiPart form request with boundary: %@", stringBoundary);
        [_request addValue:theContentType forHTTPHeaderField:FIELD_CONTENT_TYPE];
        
        BMHTTPMultiPartBodyInputStream *is = [[BMHTTPMultiPartBodyInputStream alloc] initWithContentParts:contentParts boundaryString:stringBoundary];
        [_request setHTTPBodyStream:is];
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        _httpResponseCode = 0;
        _response = nil;
        self.lastError = nil;
        self.replyData = nil;
        BM_RELEASE_SAFELY(_responseHeaderFields);
        _eventSent = NO;
    }
    return self;
}

- (id) initWithRequest:(NSURLRequest *)theRequest
              delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    if ((self = [self init])) {
        self.delegate = theDelegate;
        _url = [theRequest URL];
        
        if ([theRequest isKindOfClass:[NSMutableURLRequest class]]) {
            _request = (NSMutableURLRequest *)theRequest;
        } else {
            _request = [theRequest mutableCopy];
        }
    }
    return self;
}

- (id) initWithUrl:(NSURL *)theUrl
customHeaderFields:(NSDictionary *)customHeaderFields
          userName:(NSString *)theUserName
          password:(NSString *)thePassword
          delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    
    //creating the url request:
    if (!theUrl) {
        LogError(@"Invalid URL: %@", theUrl);
        return nil;
    } else {
        
        NSTimeInterval timeout = [[self class] defaultTimeoutInterval];
        NSURLRequestCachePolicy cachePolicy = [[self class] defaultCachePolicy];
        
        if ([theDelegate respondsToSelector:@selector(cachePolicyForRequest:)]) {
            cachePolicy = [theDelegate cachePolicyForRequest:self];
        }
        if ([theDelegate respondsToSelector:@selector(timeoutIntervalForRequest:)]) {
            timeout = [theDelegate timeoutIntervalForRequest:self];
        }
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:cachePolicy timeoutInterval:timeout];
        
        for (NSString *headerField in customHeaderFields) {
            NSString *headerValue = [customHeaderFields objectForKey:headerField];
            [urlRequest addValue:headerValue forHTTPHeaderField:headerField];
        }
        
        //adding header information:
        if (theUserName && thePassword) {
            NSString *encodedCredentials = [[self class] encodeUserName:theUserName andPassword:thePassword];
            NSString *authorizationHeader = [NSString stringWithFormat:@"Basic %@", encodedCredentials];
            [urlRequest addValue:authorizationHeader forHTTPHeaderField:FIELD_AUTHORIZATION];
        }
        
        LogInfo(@"Initialized request for URL: %@\n", theUrl);
        
#if LOGGING_LEVEL_DEBUG
        LogDebug(@"Header fields:\n");
        NSDictionary *allHeaderFields = [urlRequest allHTTPHeaderFields];
        for (id key in allHeaderFields) {
            LogDebug(@"%@: %@\n", key, [allHeaderFields objectForKey:key]);
        }
#endif
        
        if ((self = [self initWithRequest:urlRequest delegate:theDelegate])) {
            self.userName = theUserName;
            self.password = thePassword;
        }
        return self;
    }
}

- (id)initGetRequestWithUrl:(NSURL *)theUrl
                 parameters:(NSDictionary *)theParameters
         customHeaderFields:(NSDictionary *)theCustomHeaderFields
                   userName:(NSString *)theUserName
                   password:(NSString *)thePassword
                   delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    NSString *queryString = [[self class] queryStringForParameters:theParameters];
    if (queryString.length > 0) {
        NSString *modifiedUrl = [theUrl absoluteString];
        if ([modifiedUrl rangeOfString:@"?"].location == NSNotFound) {
            modifiedUrl = [[theUrl absoluteString] stringByAppendingFormat:@"?%@", queryString];
        } else {
            modifiedUrl = [[theUrl absoluteString] stringByAppendingFormat:@"&%@", queryString];
        }
        theUrl = [NSURL URLWithString:modifiedUrl];
    }
    return [self initWithUrl:theUrl customHeaderFields:theCustomHeaderFields userName:theUserName password:thePassword
                    delegate:theDelegate];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [self init])) {
        _request = [coder decodeObjectForKey:@"request"];
        self.identifier = (NSInteger)[coder decodeInt64ForKey:@"identifier"];
        self.userName = [coder decodeObjectForKey:@"username"];
        self.password = [coder decodeObjectForKey:@"password"];
        _url = [coder decodeObjectForKey:@"url"];
        self.shouldAllowSelfSignedCert = [coder decodeBoolForKey:@"shouldAllowSelfSignedCert"];
        self.clientIdentityRef = [coder decodeObjectForKey:@"clientIdentityRef"];
        self.manageCookies = [coder decodeBoolForKey:@"manageCookies"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.request forKey:@"request"];
    [coder encodeInt64:self.identifier forKey:@"identifier"];
    [coder encodeObject:self.userName forKey:@"username"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeBool:self.shouldAllowSelfSignedCert forKey:@"shouldAllowSelfSignedCert"];
    [coder encodeObject:self.clientIdentityRef forKey:@"clientIdentityRef"];
    [coder encodeBool:self.manageCookies forKey:@"manageCookies"];
}

- (void)resetState {
    _receivedData = [NSMutableData data];
    _eventSent = NO;
    _bytesReceived = 0;
    _bytesToReceive = 0;
    _response = nil;
    _httpResponseCode = 0;
    self.lastError = nil;
    self.replyData = nil;
    BM_RELEASE_SAFELY(_responseHeaderFields);
}

- (void)startConnection {
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    if (!_connection) {
        self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_NO_CONNECTION description:BMLocalizedString(@"httprequest.error.noconnection", @"Could not get connection")];
        [self requestCompleted:NO];
    } else {
        [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_connection start];
    }
    // Now wait for the URL connection to call us back.
}

- (void)send {
    LogInfo(@"Sending request with HTTP method: %@", [_request HTTPMethod]);
    
    [self resetState];
    
    _sendCount = 1;
    
    if (_manageCookies) {
        [self setHttpCookies];
    }
    
    [self prepareRequest:_request];
    [self startConnection];
}

- (void)resend {
    LogInfo(@"Resending request with HTTP method: %@", [_request HTTPMethod]);
    [self resetState];
    
    _sendCount++;
    
    [self startConnection];
}

- (BMURLConnectionInputStream *)inputStreamForConnection {
    LogInfo(@"Sending request with HTTP method: %@", [_request HTTPMethod]);
    
    [self resetState];
    
    _receivedData = nil;
    
    if (_manageCookies) {
        [self setHttpCookies];
    }
    
    [self prepareRequest:_request];
    
    self.inputStream = [[BMURLConnectionInputStream alloc] initWithRequest:_request urlConnectionDelegate:self];
    if (self.inputStream == nil) {
        self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_NO_CONNECTION description:BMLocalizedString(@"httprequest.error.noconnection", @"Could not get connection")];
        [self requestCompleted:NO];
    } else {
        self.inputStream.delegate = self;
    }
    return self.inputStream;
}

- (void)cancel {
    [self.inputStream close];
    [_connection cancel];
    
    _connection = nil;
    self.inputStream = nil;
}

- (NSString *)reply {
    return [BMStringHelper stringRepresentationOfData:self.replyData];
}

- (NSString *)md5Hash {    
    return [_request.HTTPBody bmStringWithMD5Digest];
}

- (BOOL)isSuccessfulHTTPResponse:(NSInteger)httpStatusCode {
    //By default only return codes in the 200 range as success:
    return (httpStatusCode >= 200 && httpStatusCode < 300);
}

- (BOOL)isSuccessfulHTTPResponse {
    return [self isSuccessfulHTTPResponse:self.httpResponseCode];
}

- (BOOL)isRetriableError:(NSError *)error {
    return [[error domain] isEqual:NSURLErrorDomain] && [error code] == NSURLErrorNetworkConnectionLost;
}

- (void)setRequestHeadersWithFields:(NSDictionary *)customHeaderFields {
    for (NSString *headerField in customHeaderFields) {
        NSString *headerValue = [customHeaderFields objectForKey:headerField];
        LogDebug(@"Adding custom header field(key, value): (%@, %@)", headerField, headerValue);
        [_request addValue:headerValue forHTTPHeaderField:headerField];
    }
}

- (void)prepareRequest:(NSMutableURLRequest *)request {
    
}

#pragma mark - BMURLConnectionInputStreamDelegate

- (BOOL)stream:(BMURLConnectionInputStream *)inputStream isRetriableError:(NSError *)error withRetryCount:(NSUInteger)retryCount {
    return retryCount < kMaxRetryCount && [self isRetriableError:error];
}

#pragma mark - Overridden getters and setters
-(void)setManageCookies:(BOOL)manageCookiesValue {
	_manageCookies = manageCookiesValue;
	[self.request setHTTPShouldHandleCookies:_manageCookies];
}

- (void)dealloc {
    _inputStream.urlConnectionDelegate = nil;
}

+ (void)clearCaches:(BOOL)removeCookies {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    if (removeCookies) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [NSArray arrayWithArray:[cookieStorage cookies]]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

@end

@implementation BMHTTPRequest (Private)

- (void)setLastError:(NSError *)theError {
    if (_lastError != theError) {
        _lastError = theError;
    }
}

- (void)setReplyData:(NSData *)theData {
    if (_replyData != theData) {
        _replyData = theData;
    }
}

- (void)setInputStream:(BMURLConnectionInputStream *)theStream {
    if (_inputStream != theStream) {
        _inputStream = theStream;
    }
}

- (void) setHttpCookies {
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:_url];
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
	[_request setAllHTTPHeaderFields:headers];
}

- (void) storeHttpCookiesForResponse:(NSHTTPURLResponse *)response {
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:_url];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:_url mainDocumentURL:nil];
}

+ (void)addKey:(NSString *)key withValue:(id)p toQueryString:(NSMutableString *)queryString {
    NSString *parameter = [p isKindOfClass:[NSString class]] ? p : [p description];
    NSString *escapedKey = [key bmStringWithPercentEscapes];
    NSString *escapedValue = [parameter bmStringWithPercentEscapes];
    if (queryString.length > 0) {
        [queryString appendString:@"&"];
    }
    [queryString appendFormat:@"%@=%@", escapedKey, escapedValue];
}

+ (NSString *)queryStringForParameters:(NSDictionary *)theParameters {
    NSMutableString *queryString = [NSMutableString string];
    for (NSString *key in theParameters) {
        id p = [theParameters objectForKey:key];
        if (p == nil || p == [NSNull null]) continue;
        if ([p conformsToProtocol:@protocol(NSFastEnumeration)]) {
            for (id p1 in (id <NSFastEnumeration>)p) {
                [self addKey:key withValue:p1 toQueryString:queryString];
            }
        } else {
            [self addKey:key withValue:p toQueryString:queryString];
        }
    }
    return queryString;
}

+ (NSString *)encodeUserName:(NSString *)theUserName andPassword:(NSString *)thePassword {
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", theUserName, thePassword];
    return [BMEncodingHelper base64EncodedStringForData:[credentials dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)requestCompleted:(BOOL)success // IN
{
    if (!_eventSent) {
        if (success) {
            if ([_delegate respondsToSelector:@selector(requestSucceeded:)]) {
                [_delegate requestSucceeded:self];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(requestFailed:)]) {
                [_delegate requestFailed:self];
            }
        }
        _eventSent = YES;
    }
}

- (void)updateUploadProgress:(float)progress {
    LogDebug(@"Updated upload progress to: %f", progress);
    if ([self.delegate respondsToSelector:@selector(request:updatedUploadProgress:)]) {
        [self.delegate request:self updatedUploadProgress:progress];
    }
}

- (void)updateDownloadProgress:(float)progress {
    LogDebug(@"Updated download progress to: %f", progress);
    if ([self.delegate respondsToSelector:@selector(request:updatedDownloadProgress:)]) {
        [self.delegate request:self updatedDownloadProgress:progress];
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection // IN
{
    if (_receivedData) {
        self.replyData = _receivedData;
    }
    
    LogInfo(@"Request completed");
    
    _receivedData = nil;
    [self requestCompleted:[self isSuccessfulHTTPResponse:self.httpResponseCode]];
}

- (void)connection:(NSURLConnection *)theConnection // IN
  didFailWithError:(NSError *)error              // IN
{
    LogError(@"Connection error: %@\n", [error localizedDescription]);
    
    if (_receivedData) {
        _receivedData = nil;
    }
    
    if (_sendCount <= kMaxRetryCount && self.inputStream == nil && [self isRetriableError:error]) {
        [self resend];
    } else {
        if (!self.lastError) {
            self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER
                                                      code:BM_ERROR_CONNECTION_FAILURE
                                               description:BMLocalizedString(@"httprequest.error.connectionfailed", @"Connection failed")
                                           underlyingError:error
                              ];
        }
        [self requestCompleted:NO];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space {
    BOOL canAuthenticate = NO;
    if (_shouldAllowSelfSignedCert && [[space authenticationMethod]
                                      isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        canAuthenticate = YES; // Self-signed cert will be accepted
    } else if ([[space authenticationMethod] isEqual:NSURLAuthenticationMethodHTTPBasic]) {
        canAuthenticate = YES;
    } else if ([[space authenticationMethod] isEqual:NSURLAuthenticationMethodNTLM]) {
        canAuthenticate = YES;
    } else if (self.clientIdentityRef != nil && [[space authenticationMethod] isEqual:NSURLAuthenticationMethodClientCertificate]) {
#if TARGET_OS_IPHONE
        canAuthenticate = YES;
#endif
    }
    return canAuthenticate;
}

- (NSInputStream *)connection:(NSURLConnection *)theConnection needNewBodyStream:(NSURLRequest *)theRequest {
    LogDebug(@"Need new body stream for request: %@", theRequest);
    
    if ([theRequest.HTTPBodyStream isKindOfClass:[BMHTTPMultiPartBodyInputStream class]]) {
        //Reusable
        BMHTTPMultiPartBodyInputStream *stream = (BMHTTPMultiPartBodyInputStream *)theRequest.HTTPBodyStream;
        [stream reset];
        return stream;
    } else {
        return nil;
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    //Try to determine from the body stream
    if (totalBytesExpectedToWrite <= 0 && [_request.HTTPBodyStream isKindOfClass:[BMHTTPMultiPartBodyInputStream class]]) {
        BMHTTPMultiPartBodyInputStream *stream = (BMHTTPMultiPartBodyInputStream *)_request.HTTPBodyStream;
        totalBytesExpectedToWrite = (NSInteger)[stream length];
    }
    
    if (totalBytesExpectedToWrite > 0) {
        float progress = ((float)totalBytesWritten)/((float)totalBytesExpectedToWrite);
        progress = MIN(1.0, progress);
        progress = MAX(0.0, progress);
        [self updateUploadProgress:progress];
    }
    
    
}

- (void)connection:(NSURLConnection *)theConnection // IN
didReceiveResponse:(NSURLResponse *)theResponse     // IN
{
    if (_receivedData) {[_receivedData setLength:0];}
    
    _bytesReceived = 0;
    _bytesToReceive = 0;
    
    BM_RELEASE_SAFELY(_responseHeaderFields);

    _response = theResponse;
    
    //sometimes we have mock requests which do not have response headers and codes, so lets assume thay are always ok
    if ([theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)theResponse;
        LogInfo(@"Got response from server: %d", (int)httpResponse.statusCode);
        
        _responseHeaderFields = [httpResponse allHeaderFields];
        
        NSString *n = [_responseHeaderFields objectForKey:@"Content-Length"];
        if (n) {
            _bytesToReceive = [n longLongValue];
        }
        
        _httpResponseCode = httpResponse.statusCode;
        
        if (![self isSuccessfulHTTPResponse:httpResponse.statusCode]) {
            NSString *message = [BMHTTPStatusCodes messageForCode:httpResponse.statusCode];
            self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER
                                                      code:httpResponse.statusCode
                                               description:message];
        }
        
        if (_manageCookies) {
    		[self storeHttpCookiesForResponse:httpResponse];
    	}
    } else {
        LogWarn("Response is not an HTTP response");
    	//Lets assume a correct response
    	_httpResponseCode = HTTP_STATUS_OK;
    }

    if ([self.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [self.delegate request:self didReceiveResponse:self.response];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connection:(NSURLConnection *)theConnection // IN
    didReceiveData:(NSData *)data                // IN
{
    LogInfo(@"Got data: %d bytes", (int)data.length);
    LogDebug(@"Data: %@", [BMStringHelper stringRepresentationOfData:data]);
    if (_receivedData) {
        [_receivedData appendData:data];
    }
    
    _bytesReceived += data.length;
    
    if (_bytesToReceive > 0) {
        float progress = ((float)_bytesReceived) / ((float)_bytesToReceive);
        progress = MIN(1.0, progress);
        progress = MAX(0.0, progress);
        [self updateDownloadProgress:progress];
    }
}

- (void)connection:(NSURLConnection *)theConnection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    LogInfo(@"Authentication method: %@", challenge.protectionSpace.authenticationMethod);
    
    if ([challenge.protectionSpace.authenticationMethod isEqual:NSURLAuthenticationMethodHTTPBasic] ||
        [challenge.protectionSpace.authenticationMethod isEqual:NSURLAuthenticationMethodNTLM]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.userName
                                                                        password:self.password
                                                                     persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:newCredential
                   forAuthenticationChallenge:challenge];
            
        } else {
            self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_AUTHENTICATION description:BMLocalizedString(@"httprequest.error.invalidcredentials", @"Invalid credentials. Please verify your username/password.")];
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            [self requestCompleted:NO];
        }
    } else if ([challenge.protectionSpace.authenticationMethod isEqual:NSURLAuthenticationMethodServerTrust]) {
        
        //Only called in the case shouldAllowSelfSignedCert==YES
        SecTrustResultType result;
        
        OSStatus returnValue = SecTrustEvaluate(challenge.protectionSpace.serverTrust,
                                                &result);
        
        if (returnValue == 0) {
            //OK
            /*
             kSecTrustResultInvalid,
             kSecTrustResultProceed,
             kSecTrustResultConfirm,
             kSecTrustResultDeny,
             kSecTrustResultUnspecified,
             kSecTrustResultRecoverableTrustFailure,
             kSecTrustResultFatalTrustFailure,
             kSecTrustResultOtherError
             */
            
            LogDebug(@"Result of trust evaluation: %lu", (unsigned long) result);
        } else {
            LogWarn(@"Could not evaluate trust");
        }
        
        if ([challenge previousFailureCount] == 0) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        } else {
            self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_SECURITY description:BMLocalizedString(@"httprequest.error.untrustedserver", @"Untrusted server. The server identity cannot be confirmed.")];
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            [self requestCompleted:NO];
        }
        
    } else if ([challenge.protectionSpace.authenticationMethod isEqual:NSURLAuthenticationMethodClientCertificate]) {
        
        if ([challenge previousFailureCount] > 0) {
            self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_AUTHENTICATION description:BMLocalizedString(@"httprequest.error.invalidclientcertificate", @"Could not find a valid client certificate.")];
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            [self requestCompleted:NO];
        } else {
            
#if TARGET_OS_IPHONE
            //Only called in the case clientIdentityRef != null
            
            LogInfo(@"Authenticate client certificate");
            
            SecIdentityRef myIdentity = [BMSecurityHelper newIdentityForPersistentRef:self.clientIdentityRef];
            SecCertificateRef myCert = [BMSecurityHelper copyCertificateFromIdentity:myIdentity];
            
            if (myIdentity && myCert) {
                
                SecCertificateRef certArray[1] = {myCert};
                CFArrayRef myCerts = CFArrayCreate(NULL, (void *) certArray, 1, NULL);
                
                NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity
                                                                         certificates:(__bridge NSArray *) myCerts
                                                                          persistence:NSURLCredentialPersistenceNone];
                
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                CFRelease(myCerts);
            } else {
                [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
            
            if (myIdentity) CFRelease(myIdentity);
            if (myCert) CFRelease(myCert);
#else
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
#endif
        }
    } else {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

@end
