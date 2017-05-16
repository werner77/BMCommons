//
//  BMHTTPRequest.h
//
//  Created by Werner Altewischer on 22/07/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCommons/BMHTTPStatusCodes.h>
#import <Foundation/Foundation.h>
#import <BMCommons/BMHTTPContentPart.h>
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/BMURLConnectionInputStream.h>
#import <BMCommons/NSURLRequest+BMCommons.h>

#define BM_HTTP_METHOD_POST @"POST"
#define BM_HTTP_METHOD_GET @"GET"
#define BM_HTTP_METHOD_PUT @"PUT"
#define BM_HTTP_METHOD_DELETE @"DELETE"

#define BM_HTTP_REQUEST_DEFAULT_TIMEOUT 60.0
#define BM_HTTP_REQUEST_DEFAULT_CACHE_POLICY NSURLRequestUseProtocolCachePolicy

@class BMHTTPRequest;

/**
 Delegate protocol for BMHTTPRequest.
 */
@protocol BMHTTPRequestDelegate<NSObject>

@optional

/**
 Message sent when the request returned successfully.
 */
- (void)requestSucceeded:(BMHTTPRequest *)request;

/**
 Message sent when the request failed.
 */
- (void)requestFailed:(BMHTTPRequest *)request;

/**
 Message sent when a response is received.

 @param request The request
 @param response The response
 */
- (void)request:(BMHTTPRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 Message sent when the request is uploading (Http post).
 
 @param request The request
 @param progress Progress between 0.0 and 1.0
 */
- (void)request:(BMHTTPRequest *)request updatedUploadProgress:(float)progress;

/**
 Message sent when the response is downloading to signal progress.
 
 @param request The request for which the response is downloaded
 @param progress Progress between 0.0 and 1.0
 */
- (void)request:(BMHTTPRequest *)request updatedDownloadProgress:(float)progress;

/**
 The timeout interval to use for the request, default is 60.0 seconds.
 */
- (NSTimeInterval)timeoutIntervalForRequest:(BMHTTPRequest *)request;

/**
 The cache policy to use, default is [BMHTTPRequest defaultCachePolicy].
 */
- (NSURLRequestCachePolicy)cachePolicyForRequest:(BMHTTPRequest *)request;

@end

/**
 Class for sending HTTP requests. 
 
 This class is a wrapper around NSURLRequest.
 Among other things this class supports the following:
 
 - Different kinds of authentication, including Basic, Client certificate and NTLM.
 - Streaming support, which is handy for big responses that can lead to memory problems.
 - Support for allowing self-signed certificates (HTTPS).
 - Cookie storage support
 - Support for multi-part POST and form encoded POST
 
 */
@interface BMHTTPRequest : BMCoreObject<NSCoding> 

/**
 Sets the default cache policy to use for NSURLRequests.
 
 If not set it defaults to NSURLRequestUseProtocolCachePolicy.
 */
+ (void)setDefaultCachePolicy:(NSURLRequestCachePolicy)policy;
+ (NSURLRequestCachePolicy)defaultCachePolicy;

/**
 Sets the default time-out to use for NSURLRequests.
 
 If not set it defaults to 60.0 seconds.
 */
+ (void)setDefaultTimeoutInterval:(NSTimeInterval)time;
+ (NSTimeInterval)defaultTimeoutInterval;

/**
 Clears the NSURLCache for the current application and optionally also removes all stored cookies.
 */
+ (void)clearCaches:(BOOL)removeCookies;

/**
 Last error that occured if any.
 */
@property(strong, readonly) NSError *lastError;

/**
 The data that was received. 
 
 If you use the inputStreamForConnection method rather than the send method this property returns nil always, because the response data is not buffered in that case.
 */
@property(strong, readonly) NSData *replyData;

/**
 Optional numeric identifier to attach to the request to distinguish it from other requests.
 */
@property(assign) NSInteger identifier;

/**
 Username for HTTP basic authentication.
 */
@property(strong) NSString *userName;

/**
 Password for HTTP basic authentication.
 */
@property(strong) NSString *password;

/**
 Delegate for this request.
 
 Implementation of BMHTTPRequestDelegate.
 */
@property(weak) id<BMHTTPRequestDelegate> delegate;

/**
 The headers of the HTTP response.
 */
@property(strong, readonly) NSDictionary *responseHeaderFields;

/**
 The inputstream that was returned by inputStreamForConnection if called.
 */
@property(strong, readonly) BMURLConnectionInputStream *inputStream;

/**
 The URL for the request.
 */
@property(readonly) NSURL *url;

/**
 The NSURLRequest that is used internally by this class. 
 
 Use this property to manipulate it before sending if needed.
 */
@property(readonly) NSMutableURLRequest *request;

/**
 * The response received if any.
 */
@property(readonly) NSURLResponse *response;

/**
 The HTTP response code returned by the server.
 */
@property(readonly) NSInteger httpResponseCode;

/**
 Context object to attach to the request
 */
@property(strong) id context;

/**
 Whether self-signed certificates are OK when using SSL. 
 
 If false, self-signed certificates will result in an error (default behavior)
 */
@property(assign) BOOL shouldAllowSelfSignedCert;

/**
 Persistent reference to the client identity in the keychain of the current application to use for authentication. 
 
 Use when client certificate authentication is required by the server.
 */
@property(strong) NSData *clientIdentityRef;

/**
 Whether cookies returned by the server should be stored or not.
 */
@property(assign) BOOL manageCookies;

/**
 Initializes a HTTP POST request with the specified contentType and binary content.
 
 @param url The URL to POST to.
 @param contentType The content type for the data, see BMMIMEType.
 @param content The data representing the content to post.
 @param customHeaderFields A dictionary with any custom HTTP headers to send
 @param username Basic authentication username
 @param password Basic authentication password
 @param delegate The delegate
 */
- (id)initPostRequestWithUrl:(NSURL *)url
				 contentType:(NSString *)contentType
					 content:(NSData *)content
		  customHeaderFields:(NSDictionary *)customHeaderFields
					userName:(NSString *)username
					password:(NSString *)password
					delegate:(id <BMHTTPRequestDelegate>)delegate;


/**
 Initializes a HTTP POST request of contentType application/x-www-form-urlencoded by using the parameters specified in the dictionary.
 
 @param url The URL to POST to.
 @param parameters The form parameters to post which will be encoded in the body of the request.
 @param customHeaderFields A dictionary with any custom HTTP headers to send
 @param username Basic authentication username
 @param password Basic authentication password
 @param delegate The delegate
 */
- (id)initPostRequestWithUrl:(NSURL *)url
				  parameters:(NSDictionary *)parameters
		  customHeaderFields:(NSDictionary *)customHeaderFields
					userName:(NSString *)username
					password:(NSString *)password
					delegate:(id <BMHTTPRequestDelegate>)delegate;

/**
 Initializes a multipart HTTP POST request with an array of BMHTTPContentPart objects.
 
 A BMHTTPMultPartBodyInputStream is used for reading in the content parts which will not load all data in memory at once but will read and upload the data in a streaming fashion. This is suitable for large files, such as video uploads.
 
 @param url The URL to POST to.
 @param contentParts An array of BMHTTPContentPart objects describing the parts to send in the request
 @param customHeaderFields A dictionary with any custom HTTP headers to send
 @param username Basic authentication username
 @param password Basic authentication password
 @param delegate The delegate
 @see BMHTTPContentPart
 */
- (id)initMultiPartPostRequestWithUrl:(NSURL *)url
						 contentParts:(NSArray *)contentParts
				   customHeaderFields:(NSDictionary *)customHeaderFields
							 userName:(NSString *)username
							 password:(NSString *)password
							 delegate:(id <BMHTTPRequestDelegate>)delegate;

/**
 Initializes a HTTP GET request with the specified url and parameters which are appended to the url.
 
 @param url The URL for the request.
 @param parameters The GET parameters which will be appended to the URL as querystring, e.g. "?param1=value1&param2=value2"
 @param customHeaderFields A dictionary with any custom HTTP headers to send
 @param username Basic authentication username
 @param password Basic authentication password
 @param delegate The delegate
 */
- (id)initGetRequestWithUrl:(NSURL *)url
				 parameters:(NSDictionary *)parameters
		 customHeaderFields:(NSDictionary *)customHeaderFields
				   userName:(NSString *)username
				   password:(NSString *)password
				   delegate:(id <BMHTTPRequestDelegate>)delegate;

/**
 Designated initializer. 
 
 Initializes a barebones HTTP request.
 
 @param url The URL for the request.
 @param customHeaderFields A dictionary with any custom HTTP headers to send
 @param username Basic authentication username
 @param password Basic authentication password
 @param delegate The delegate
 */
- (id)initWithUrl:(NSURL *)url
customHeaderFields:(NSDictionary *)customHeaderFields
		 userName:(NSString *)username
		 password:(NSString *)password
		 delegate:(id <BMHTTPRequestDelegate>)delegate;


/**
 * MD5 Hash of the request body to uniquely identify the request together with the url (e.g. for caching)
 */
- (NSString *)md5Hash;

/**
 Reply data interpreted as a UTF-8 string. 
 
 Is only defined when the send method is used, rather than the inputStreamForConnection method.
 */
- (NSString *)reply;

/**
 Cancels the request.
 */
- (void)cancel;

/**
 Use this method to send and buffer all response data in memory (use the property replyData to retrieve it). 
 
 This object will be owner of the connection.
 */
- (void)send;

/**
 * Use this method to get an input stream for the request to stream the response and avoid loading all data in memory at once.
 * 
 Also, parsing of XML can already start while the response is downloading. 
 Beware that reply and replyData are not valid when using this method.
 
 The input stream is the owner of the connection, i.e. connection is closed when inputstream is closed.
 */
- (BMURLConnectionInputStream *)inputStreamForConnection;

/**
 Returns the result of [self isSuccessfulHTTPResponse:self.httpResponseCode]
 */
- (BOOL)isSuccessfulHTTPResponse;

/**
 Sets the HTTP request headers from the supplied dictionary in the internal NSURLRequest. 
 */
- (void)setRequestHeadersWithFields:(NSDictionary *)customHeaderFields;

@end

@interface BMHTTPRequest(Protected)

/**
 Override to perform additional preparation on the URL request before it is executed.
 */
- (void)prepareRequest:(NSMutableURLRequest *)request;

/**
 The outcome of this method determines whether the delegate message requestSucceeded or requestFailed is sent upon connectionDidFinishLoading.
 
 By default only codes in the 200 range are considered to be successes. Override if you also want to signal other HTTP responses as a success.
 */
- (BOOL)isSuccessfulHTTPResponse:(NSInteger)httpStatusCode;

/**
 By default returns YES iff the error code == NSURLErrorNetworkConnectionLost, because of a bug in the iOS NSURLConnection framework.
 
 See: http://stackoverflow.com/questions/25372318/error-domain-nsurlerrordomain-code-1005-the-network-connection-was-lost
 */
- (BOOL)isRetriableError:(NSError *)error;

@end
