//
//  BMHTTPStatusCodes.m
//
//  Created by Werner Altewischer on 03/09/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCommons/BMHTTPStatusCodes.h>


@implementation BMHTTPStatusCodes

static NSDictionary *httpStatusCodeMap = nil;

+ (void)initialize {
    if (!httpStatusCodeMap) {
        httpStatusCodeMap = @{
                              @"100":@"Continue",
                              @"101":@"Switching Protocols",
                              @"200":@"OK",
                              @"201":@"Created",
                              @"202":@"Accepted",
                              @"203":@"Non-Authoritative Information",
                              @"204":@"No Content",
                              @"205":@"Reset Content",
                              @"206":@"Partial Content",
                              @"300":@"Multiple Choices",
                              @"301":@"Moved Permanently",
                              @"302":@"Found",
                              @"303":@"See Other",
                              @"304":@"Not Modified",
                              @"305":@"Use Proxy",
                              @"306":@"Switch Proxy",
                              @"307":@"Temporary Redirect",
                              @"400":@"Bad Request",
                              @"401":@"Unauthorized",
                              @"402":@"Payment Required",
                              @"403":@"Forbidden",
                              @"404":@"Not Found",
                              @"405":@"Method Not Allowed",
                              @"406":@"Not Acceptable",
                              @"407":@"Proxy Authentication Required",
                              @"408":@"Request Timeout",
                              @"409":@"Conflict",
                              @"410":@"Gone",
                              @"411":@"Length Required",
                              @"412":@"Precondition Failed",
                              @"413":@"Request Entity Too Large",
                              @"414":@"Request-URI Too Long",
                              @"415":@"Unsupported Media Type",
                              @"416":@"Requested Range Not Satisfiable",
                              @"417":@"Expectation Failed",
                              @"500":@"Internal Server Error",
                              @"501":@"Not Implemented",
                              @"502":@"Bad Gateway",
                              @"503":@"Service Unavailable",
                              @"504":@"Gateway Timeout",
                              @"505":@"HTTP Version Not Supported",
                              @"102":@"Processing",
                              @"207":@"Multi-Status",
                              @"422":@"Unprocessable Entity",
                              @"423":@"Locked",
                              @"424":@"Failed Dependency",
                              @"425":@"Unordered Collection",
                              @"426":@"Upgrade Required",
                              @"449":@"Retry With",
                              @"506":@"Variant Also Negotiates",
                              @"507":@"Insufficient Storage",
                              @"509":@"Bandwidth Limit Exceeded",
                              @"510":@"Not Extended",
                              @"208":@"Already Reported",
                              @"226":@"IM Used",
                              @"419":@"Authentication Timeout",
                              @"420":@"Enhance Your Calm",
                              @"428":@"Precondition Required",
                              @"429":@"Too Many Requests",
                              @"431":@"Request Header Field Too Large",
                              @"444":@"No Response",
                              @"450":@"Blocked by Parental Controls",
                              @"451":@"Unavailable for Legal Reasons",
                              @"494":@"Request Header Too Large",
                              @"495":@"Certificate Error",
                              @"496":@"No Certificate",
                              @"497":@"HTTP To HTTPS",
                              @"499":@"Client Closed Request",
                              @"508":@"Loop Detected",
                              @"511":@"Network Authentication Required",
                              @"598":@"Network Read Timeout",
                              @"599":@"Network Connection Timeout"
                              };
    }
}

+ (NSString *)messageForCode:(NSInteger)code {
	return [BMHTTPStatusCodes messageForStringCode:[[NSNumber numberWithInteger:code] stringValue]];
}

+ (NSString *)messageForStringCode:(NSString *)code {
	NSString *errorString = [httpStatusCodeMap objectForKey:code];
	return errorString ? errorString : @"Unknown HTTP status code"; 
}

@end
