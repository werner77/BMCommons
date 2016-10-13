//
//  BMEncodingHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 20/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMEncodingHelper.h"
#import <BMCommons/NSString+BMCommons.h>

@implementation BMEncodingHelper

#define APPEND_CHAR(buffer, c, k, l) ({ if (k >= l) { \
l *= 2; \
char *newBuffer = realloc(buffer, (size_t)l); \
if (newBuffer == NULL) { \
	free(buffer); \
	return nil; \
} else { \
	buffer = newBuffer; \
} \
} \
buffer[k++] = c; })

static char defaultEncodingTable[65] = {
		'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
		'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
		'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
		'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/', '='};

static char urlFriendlyEncodingTable[65] = {
		'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
		'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
		'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
		'w','x','y','z','0','1','2','3','4','5','6','7','8','9','-','_', '.'};


+ (NSString *)base64EncodedStringForData:(NSData *)data {
    return [self base64EncodedStringForData:data withLineLength:0 urlFriendly:NO];
}

+ (NSData *)base64EncodedDataForData:(NSData *)data {
	return [self base64EncodedDataForData:data withLineLength:0 urlFriendly:NO];
}

+ (NSString *)hexEncodedStringForBytes:(unsigned char *)bytes length:(NSUInteger)length {
    return [NSString bmHexEncodedStringForBytes:bytes length:length];
}

+ (NSString *)hexEncodedStringForData:(NSData *)data {
    return [NSString bmHexEncodedStringForData:data];
}

+ (NSData *) dataWithBase64EncodedString:(NSString *)string {
	return [self dataWithBase64EncodedString:string urlFriendly:NO];
}

+ (NSData *)dataWithBase64EncodedData:(NSData *)data {
    return [self dataWithBase64EncodedData:data urlFriendly:NO];
}

+ (NSData *)dataWithBase64EncodedData:(NSData *)base64Data urlFriendly:(BOOL)urlFriendly {
    NSMutableData *mutableData = nil;
    
    char *encodingTable = urlFriendly ? urlFriendlyEncodingTable : defaultEncodingTable;
    
    if( base64Data ) {
        uint64_t ixtext = 0;
        uint64_t lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[4], outbuf[4];
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        const unsigned char *base64Bytes = nil;
        
        base64Bytes = [base64Data bytes];
        lentext = [base64Data length];
        mutableData = [NSMutableData dataWithCapacity:(NSUInteger)lentext];
        
        while( YES ) {
            if( ixtext >= lentext ) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
            else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
            else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
            else if( ch == encodingTable[62] ) ch = 62;
            else if( ch == encodingTable[64] ) flendtext = YES;
            else if( ch == encodingTable[63] ) ch = 63;
            else flignore = YES;
            
            if( ! flignore ) {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if( flendtext ) {
                    if( ! ixinbuf ) break;
                    if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if( ixinbuf == 4 ) {
                    ixinbuf = 0;
                    outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                    outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                    outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                    
                    for( i = 0; i < ctcharsinbuf; i++ )
                        [mutableData appendBytes:&outbuf[i] length:1];
                }
                
                if( flbreak )  break;
            }
        }
    }
    
    return mutableData;
}

+ (NSData *) dataWithBase64EncodedString:(NSString *)string urlFriendly:(BOOL)urlFriendly {
    if (string) {
        return [self dataWithBase64EncodedData:[string dataUsingEncoding:NSASCIIStringEncoding] urlFriendly:urlFriendly];
    } else {
        return nil;
    }
}

+ (NSString *)base64EncodedStringForData:(NSData *)data withLineLength:(NSUInteger) lineLength {
	return [self base64EncodedStringForData:data withLineLength:lineLength urlFriendly:NO];
}

+ (NSData *)base64EncodedDataForData:(NSData *)data withLineLength:(NSUInteger) lineLength {
	return [self base64EncodedDataForData:data withLineLength:lineLength urlFriendly:NO];
}

+ (NSString *)base64EncodedStringForData:(NSData *)data withLineLength:(NSUInteger) lineLength urlFriendly:(BOOL)urlFriendly {
	return [self base64EncodedObjectForData:data withLineLength:lineLength urlFriendly:urlFriendly returnAsString:YES];
}

+ (NSData *)base64EncodedDataForData:(NSData *)data withLineLength:(NSUInteger) lineLength urlFriendly:(BOOL)urlFriendly {
	return [self base64EncodedObjectForData:data withLineLength:lineLength urlFriendly:urlFriendly returnAsString:NO];
}

+ (id)base64EncodedObjectForData:(NSData *)data withLineLength:(NSUInteger) lineLength urlFriendly:(BOOL)urlFriendly returnAsString:(BOOL)returnAsString {

	char *encodingTable = urlFriendly ? urlFriendlyEncodingTable : defaultEncodingTable;

	const unsigned char	*bytes = [data bytes];

	NSUInteger dataLength = data.length;
	uint64_t outputBufferLength = ((dataLength + 2) / 3 * 4);
	if (lineLength > 0) {
		outputBufferLength += (outputBufferLength / lineLength);
	}
	char *outputBuffer = malloc((size_t)outputBufferLength);

	uint64_t ixtext = 0;
	uint64_t lentext = [data length];
	int64_t ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	short i = 0;
	short charsonline = 0, ctcopy = 0;
	uint64_t ix = 0;
	uint64_t k = 0;

	while( YES ) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;

		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}

		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;

		switch( ctremaining ) {
			case 1:
				ctcopy = 2;
				break;
			case 2:
				ctcopy = 3;
				break;
		}

		for( i = 0; i < ctcopy; i++ ) {
			APPEND_CHAR(outputBuffer, encodingTable[outbuf[i]], k, outputBufferLength);
		}

		for( i = ctcopy; i < 4; i++ ) {
			APPEND_CHAR(outputBuffer, encodingTable[64], k, outputBufferLength);
		}

		ixtext += 3;
		charsonline += 4;

		if( lineLength > 0 ) {
			if (charsonline >= lineLength) {
				charsonline = 0;
				APPEND_CHAR(outputBuffer, '\n', k, outputBufferLength);
			}
		}
	}

	if (returnAsString) {
		return [[NSString alloc] initWithBytesNoCopy:outputBuffer length:(NSUInteger)k encoding:NSASCIIStringEncoding freeWhenDone:YES];
	} else {
		return [NSData dataWithBytesNoCopy:outputBuffer length:(NSUInteger)k freeWhenDone:YES];
	}
}

@end
