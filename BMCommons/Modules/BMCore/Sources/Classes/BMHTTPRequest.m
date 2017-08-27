//
//  BMHTTPRequest.m
//
//  Created by Werner Altewischer on 22/07/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCommons/BMHTTPRequest.h>
#import <BMCommons/BMEncodingHelper.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMURLConnectionInputStream.h>
#import "NSData+BMEncryption.h"
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMErrorCodes.h>
#import <BMCommons/BMSecurityHelper.h>
#import "NSString+BMCommons.h"
#import <BMCommons/BMLogging.h>
#import <BMCommons/BMHTTPMultiPartBodyInputStream.h>
#import <BMCommons/BMCore.h>

#define FIELD_CONTENT_TYPE @"Content-Type"
#define FIELD_CONTENT_ENCODING @"Content-Encoding"
#define FIELD_CONTENT_LENGTH @"Content-Length"
#define FIELD_AUTHORIZATION @"Authorization"
#define VALUE_ENCODING_GZIP @"gzip"

static const NSUInteger kMaxRetryCount = 1;

@interface BMHTTPRequest ()<BMURLConnectionInputStreamDelegate>

@property(strong)   NSMutableURLRequest *request;
@property(strong)   NSURLResponse *response;
@property(strong) 	NSError* lastError;
@property(strong) 	NSMutableData *receivedData;
@property(assign) 	BOOL eventSent;
@property(strong) 	NSData* replyData;
@property(strong) 	NSDictionary * responseHeaderFields;
@property(strong) 	NSURLConnection *connection;
@property(strong) 	BMURLConnectionInputStream* inputStream;
@property(assign) 	NSInteger httpResponseCode;
@property(assign)   long long bytesToReceive;
@property(assign)   long long bytesReceived;
@property(assign)   NSUInteger sendCount;

@end

@interface BMHTTPRequest (Private)

- (void)setHttpCookies;
- (void)storeHttpCookiesForResponse:(NSHTTPURLResponse *)response;
- (void)requestCompleted:(BOOL)success;
- (void)updateUploadProgress:(float)progress;
- (void)updateDownloadProgress:(float)progress;

+ (NSString *)encodeUserName:(NSString *)userName andPassword:(NSString *)password;
+ (NSString *)queryStringForParameters:(NSDictionary *)parameters;

@end

@implementation BMHTTPRequest {
    BOOL _manageCookies;
}

@synthesize httpResponseCode = _httpResponseCode;
@synthesize response = _response;
@synthesize lastError = _lastError;
@synthesize replyData = _replyData;
@synthesize identifier = _identifier;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize delegate = _delegate;
@synthesize responseHeaderFields = _responseHeaderFields;
@synthesize inputStream = _inputStream;
@synthesize request = _request;
@synthesize context = _context;
@synthesize shouldAllowSelfSignedCert = _shouldAllowSelfSignedCert;
@synthesize clientIdentityRef = _clientIdentityRef;

static NSURLRequestCachePolicy defaultCachePolicy = BM_HTTP_REQUEST_DEFAULT_CACHE_POLICY;
static NSTimeInterval defaultTimeoutInterval = BM_HTTP_REQUEST_DEFAULT_TIMEOUT;

+ (void)setDefaultCachePolicy:(NSURLRequestCachePolicy)policy {
    @synchronized (BMHTTPRequest.class) {
        defaultCachePolicy = policy;
    }
}

+ (NSURLRequestCachePolicy)defaultCachePolicy {
    @synchronized (BMHTTPRequest.class) {
        return defaultCachePolicy;
    }
}

+ (void)setDefaultTimeoutInterval:(NSTimeInterval)time {
    @synchronized (BMHTTPRequest.class) {
        defaultTimeoutInterval = time;
    }
}

+ (NSTimeInterval)defaultTimeoutInterval {
    @synchronized (BMHTTPRequest.class) {
        return defaultTimeoutInterval;
    }
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
        NSMutableURLRequest *request = self.request;
        [request setHTTPMethod:BM_HTTP_METHOD_POST];
        if (contentType != nil) {
            [request addValue:contentType forHTTPHeaderField:FIELD_CONTENT_TYPE];
        }
        [request addValue:[NSString stringWithFormat:@"%tu", (content == nil ? 0 : content.length)] forHTTPHeaderField:FIELD_CONTENT_LENGTH];
        [request setHTTPBody:content];
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
        NSMutableURLRequest *request = self.request;
        [request setHTTPMethod:BM_HTTP_METHOD_POST];

        BMHTTPMultiPartBodyInputStream *is = [[BMHTTPMultiPartBodyInputStream alloc] initWithContentParts:contentParts boundaryString:nil];
        NSString *theContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", is.boundaryString];
        LogDebug(@"Creating MultiPart form request with boundary: %@", stringBoundary);
        [request addValue:theContentType forHTTPHeaderField:FIELD_CONTENT_TYPE];
        [request setHTTPBodyStream:is];
    }
    return self;
}

- (id)init {
    return [self initWithRequest:[NSMutableURLRequest new] delegate:nil];
}

- (id)initWithRequest:(NSURLRequest *)theRequest
             delegate:(id <BMHTTPRequestDelegate>)theDelegate {
    if ((self = [super init])) {

        if (theRequest == nil) {
            return nil;
        }

        self.httpResponseCode = 0;
        self.response = nil;
        self.lastError = nil;
        self.replyData = nil;
        self.responseHeaderFields = nil;
        self.eventSent = NO;
        self.delegate = theDelegate;
        if ([theRequest isKindOfClass:[NSMutableURLRequest class]]) {
            self.request = (NSMutableURLRequest *)theRequest;
        } else {
            self.request = [theRequest mutableCopy];
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
        self.request = [coder decodeObjectForKey:@"request"];
        self.identifier = (NSInteger)[coder decodeInt64ForKey:@"identifier"];
        self.userName = [coder decodeObjectForKey:@"username"];
        self.password = [coder decodeObjectForKey:@"password"];
        self.shouldAllowSelfSignedCert = [coder decodeBoolForKey:@"shouldAllowSelfSignedCert"];
        self.clientIdentityRef = [coder decodeObjectForKey:@"clientIdentityRef"];
        self.manageCookies = [coder decodeBoolForKey:@"manageCookies"];

        if (self.request == nil) {
            //Required fields not filled
            return nil;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.request forKey:@"request"];
    [coder encodeInt64:self.identifier forKey:@"identifier"];
    [coder encodeObject:self.userName forKey:@"username"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeBool:self.shouldAllowSelfSignedCert forKey:@"shouldAllowSelfSignedCert"];
    [coder encodeObject:self.clientIdentityRef forKey:@"clientIdentityRef"];
    [coder encodeBool:self.manageCookies forKey:@"manageCookies"];
}

- (NSURL *)url {
    return self.request.URL;
}

- (void)resetState {
    self.receivedData = [NSMutableData data];
    self.eventSent = NO;
    self.bytesReceived = 0;
    self.bytesToReceive = 0;
    self.response = nil;
    self.httpResponseCode = 0;
    self.lastError = nil;
    self.replyData = nil;
    self.responseHeaderFields = nil;
}

- (void)startConnection {
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    self.connection = connection;
    if (!connection) {
        self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_NO_CONNECTION description:BMLocalizedString(@"httprequest.error.noconnection", @"Could not get connection")];
        [self requestCompleted:NO];
    } else {
        if ([NSThread isMainThread]) {
            [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        } else {
            NSOperationQueue *operationQueue = [NSOperationQueue new];
            [connection setDelegateQueue:operationQueue];
        }
        [connection start];
    }
    // Now wait for the URL connection to call us back.
}

- (void)send {
    NSMutableURLRequest *request = self.request;
    LogInfo(@"Sending request with HTTP method: %@", [request HTTPMethod]);

    [self resetState];

    self.sendCount = 1;

    if (self.manageCookies) {
        [self setHttpCookies];
    }

    [self prepareRequest:request];
    [self startConnection];
}

- (void)resend {
    LogInfo(@"Resending request with HTTP method: %@", [self.request HTTPMethod]);
    [self resetState];

    self.sendCount++;

    [self startConnection];
}

- (BMURLConnectionInputStream *)inputStreamForConnection {
    NSMutableURLRequest *request = self.request;
    
    LogInfo(@"Sending request with HTTP method: %@", [request HTTPMethod]);

    [self resetState];

    self.receivedData = nil;

    if (self.manageCookies) {
        [self setHttpCookies];
    }

    [self prepareRequest:request];

    BMURLConnectionInputStream *inputStream = [[BMURLConnectionInputStream alloc] initWithRequest:request urlConnectionDelegate:self];
    self.inputStream = inputStream;
    if (inputStream == nil) {
        self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER code:BM_ERROR_NO_CONNECTION description:BMLocalizedString(@"httprequest.error.noconnection", @"Could not get connection")];
        [self requestCompleted:NO];
    } else {
        inputStream.delegate = self;
    }
    return inputStream;
}

- (void)cancel {
    [self.inputStream close];
    [self.connection cancel];

    self.connection = nil;
    self.inputStream = nil;
}

- (NSString *)reply {
    return [BMStringHelper stringRepresentationOfData:self.replyData];
}

- (NSString *)md5Hash {
    return [self.request.HTTPBody bmStringWithMD5Digest];
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
        [self.request addValue:headerValue forHTTPHeaderField:headerField];
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
    @synchronized(self) {
        _manageCookies = manageCookiesValue;
        [self.request setHTTPShouldHandleCookies:self.manageCookies];
    }
}

- (BOOL)manageCookies {
    @synchronized (self) {
        return _manageCookies;
    }
}

- (void)dealloc {
    self.inputStream.urlConnectionDelegate = nil;
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



- (void) setHttpCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.url];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [self.request setAllHTTPHeaderFields:headers];
}

- (void) storeHttpCookiesForResponse:(NSHTTPURLResponse *)response {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:self.url];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:self.url mainDocumentURL:nil];
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
    if (!self.eventSent) {
        id <BMHTTPRequestDelegate> delegate = self.delegate;
        if (success) {
            if ([delegate respondsToSelector:@selector(requestSucceeded:)]) {
                [delegate requestSucceeded:self];
            }
        } else {
            if ([delegate respondsToSelector:@selector(requestFailed:)]) {
                [delegate requestFailed:self];
            }
        }
        self.eventSent = YES;
    }
}

- (void)updateUploadProgress:(float)progress {
    LogDebug(@"Updated upload progress to: %f", progress);
    id <BMHTTPRequestDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(request:updatedUploadProgress:)]) {
        [delegate request:self updatedUploadProgress:progress];
    }
}

- (void)updateDownloadProgress:(float)progress {
    LogDebug(@"Updated download progress to: %f", progress);
    id <BMHTTPRequestDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(request:updatedDownloadProgress:)]) {
        [delegate request:self updatedDownloadProgress:progress];
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection // IN
{
    NSMutableData *receivedData = self.receivedData;
    if (receivedData) {
        self.replyData = receivedData;
    }

    LogInfo(@"Request completed");

    self.receivedData = nil;
    [self requestCompleted:[self isSuccessfulHTTPResponse:self.httpResponseCode]];
}

- (void)connection:(NSURLConnection *)theConnection // IN
  didFailWithError:(NSError *)error              // IN
{
    LogError(@"Connection error: %@\n", [error localizedDescription]);

    if (self.receivedData) {
        self.receivedData = nil;
    }

    if (self.sendCount <= kMaxRetryCount && self.inputStream == nil && [self isRetriableError:error]) {
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
    if (self.shouldAllowSelfSignedCert && [[space authenticationMethod]
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
    NSMutableURLRequest *request = self.request;
    if (totalBytesExpectedToWrite <= 0 && [request.HTTPBodyStream isKindOfClass:[BMHTTPMultiPartBodyInputStream class]]) {
        BMHTTPMultiPartBodyInputStream *stream = (BMHTTPMultiPartBodyInputStream *) request.HTTPBodyStream;
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
    if (self.receivedData) {[self.receivedData setLength:0];}

    self.bytesReceived = 0;
    self.bytesToReceive = 0;

    self.responseHeaderFields = nil;

    self.response = theResponse;

    //sometimes we have mock requests which do not have response headers and codes, so lets assume thay are always ok
    if ([theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)theResponse;
        LogInfo(@"Got response from server: %d", (int)httpResponse.statusCode);

        self.responseHeaderFields = [httpResponse allHeaderFields];

        NSString *n = [self.responseHeaderFields objectForKey:@"Content-Length"];
        if (n) {
            self.bytesToReceive = [n longLongValue];
        }

        self.httpResponseCode = httpResponse.statusCode;

        if (![self isSuccessfulHTTPResponse:httpResponse.statusCode]) {
            NSString *message = [BMHTTPStatusCodes messageForCode:httpResponse.statusCode];
            self.lastError = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_SERVER
                                                      code:httpResponse.statusCode
                                               description:message];
        }

        if (self.manageCookies) {
            [self storeHttpCookiesForResponse:httpResponse];
        }
    } else {
        LogWarn("Response is not an HTTP response");
        //Lets assume a correct response
        self.httpResponseCode = HTTP_STATUS_OK;
    }

    id <BMHTTPRequestDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [delegate request:self didReceiveResponse:self.response];
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
    if (self.receivedData) {
        [self.receivedData appendData:data];
    }

    self.bytesReceived += data.length;

    if (self.bytesToReceive > 0) {
        float progress = ((float)self.bytesReceived) / ((float)self.bytesToReceive);
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
