//
// Created by Werner Altewischer on 10/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMMiscTestCase.h"
#import <BMCommons/BMUICore.h>
#import <BMCommons/BMCompressDataTransformer.h>
#import <BMCommons/BMStringToDataTransformer.h>
#import <BMCommons/BMBase64DataTransformer.h>
#import <BMCommons/BMChainedTransformer.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMEncodingHelper.h>

@implementation BMMiscTestCase {

}

- (void)testVersionAtLeast {
    NSString *version = @"9.1.1";

    GHAssertFalse(BMOSVersionIsAtLeast(version), @"Expectation failed");

    version = @"9.1.0";

    GHAssertTrue(BMOSVersionIsAtLeast(version), @"Expectation failed");

    version = @"9.1";

    GHAssertTrue(BMOSVersionIsAtLeast(version), @"Expectation failed");

    version = @"9.0.1";

    GHAssertTrue(BMOSVersionIsAtLeast(version), @"Expectation failed");

    version = @"8.1";

    GHAssertTrue(BMOSVersionIsAtLeast(version), @"Expectation failed");
}

- (void)testCompress {
    BMCompressDataTransformer *compressionTransformer = [BMCompressDataTransformer new];
    BMStringToDataTransformer *stringToDataTransformer = [BMStringToDataTransformer new];
    BMBase64DataTransformer *base64Transformer = [BMBase64DataTransformer new];

    BMChainedTransformer *chainedTransformer = [BMChainedTransformer transformerWithChain:@[stringToDataTransformer, compressionTransformer, base64Transformer]];

    NSString *testString = @"[{1, 999, \"wi51248\"},{1, 999, \"wi59671\"},{1, 999, \"wi140101\"},{1, 999, \"wi367160\"},{1, 999, \"wi162764\"},{1, 999, \"wi143821\"},{1, 999, \"wi197154\"},{1, 999, \"wi197228\"},{1, 999, \"wi63547\"},{1, 999, \"wi119307\"},{1, 999, \"wi186785\"},{1, 999, \"wi1932\"},{1, 999, \"wi162601\"},{1, 999, \"wi2594\"},{1, 999, \"wi193636\"},{1, 999, \"wi197227\"},{1, 999, \"wi104394\"},{1, 999, \"wi163826\"},{1, 999, \"wi2601\"},{1, 999, \"wi140100\"},{1, 999, \"wi162762\"},{1, 999, \"wi121178\"},{1, 999, \"wi123209\"},{1, 999, \"wi197226\"},{1, 999, \"wi125035\"},{1, 999, \"wi125034\"},{1, 999, \"wi186786\"},{1, 999, \"wi125031\"},{1, 999, \"wi2600\"},{1, 999, \"wi125033\"},{1, 999, \"wi128799\"},{1, 999, \"wi117190\"},{1, 999, \"wi103587\"},{1, 999, \"wi193770\"},{1, 999, \"wi136088\"},{1, 999, \"wi128927\"},{1, 999, \"wi195370\"},{1, 999, \"wi195377\"},{1, 999, \"wi202100\"},{1, 999, \"wi59673\"},{1, 999, \"wi46564\"},{1, 999, \"wi104392\"},{1, 999, \"wi2606\"},{1, 999, \"wi195376\"},{1, 999, \"wi257\"},{3, 999, \"appels\"},{3, 999, \"kaas\"},{1, 999, \"wi63783\"},{1, 999, \"wi46529\"},{1, 999, \"wi140717\"},{1, 999, \"wi33956\"},{1, 999, \"wi63782\"}]";

    NSString *data = [chainedTransformer transformedValue:testString];

    NSString *url = [BMStringHelper urlStringFromString:[NSString stringWithFormat:@"appie://mylist/amend?items=%@", data]];

    NSString *decodedUrl = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSRange range = [decodedUrl rangeOfString:@"items="];

    NSString *dataCopy = [decodedUrl substringFromIndex:range.location + range.length];

    NSString *outputString = [chainedTransformer reverseTransformedValue:dataCopy];

    GHAssertEqualObjects(testString, outputString, @"Expected the output to be equal to the input");

}

- (void)testBase64 {
    NSString *inputString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce bibendum dui sed nunc viverra, non dapibus est posuere. Nunc a consectetur nulla. Nullam vitae varius sem. Nullam congue pharetra semper. Maecenas vitae suscipit lorem. Morbi ut nulla augue. Fusce elit felis, dignissim ut vulputate ut, auctor euismod dui. Vivamus lobortis orci ut nibh pulvinar sagittis. Aenean vitae est id turpis feugiat gravida. Curabitur non condimentum nisl. Nullam aliquam at enim quis egestas. Quisque sodales blandit placerat. Nam libero magna, tristique vel feugiat nec, pretium nec eros. Donec efficitur lacinia consectetur. Nulla elementum leo nec vestibulum fringilla.";

    for (NSInteger i =0; inputString.length > 1; ++i) {

        inputString = [inputString substringToIndex:inputString.length - 1];

        NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];

        BOOL urlFriendly = NO;

        NSInteger lineLength = 72;

        NSString *base64EncodedString = [BMEncodingHelper base64EncodedStringForData:data withLineLength:lineLength urlFriendly:urlFriendly];

        NSData *dataOut = [BMEncodingHelper dataWithBase64EncodedString:base64EncodedString urlFriendly:urlFriendly];

        NSString *outputString = [[NSString alloc] initWithData:dataOut encoding:NSUTF8StringEncoding];

        GHAssertEqualObjects(inputString, outputString, @"Expected input to equal output");
    }

    
    inputString = @"any carnal pleasure.";
    
    for (NSInteger i =0; inputString.length > 1; ++i) {
        
        inputString = [inputString substringToIndex:inputString.length - 1];
        
        NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];
        
        BOOL urlFriendly = YES;
        
        NSInteger lineLength = 0;
        
        NSString *base64EncodedString = [BMEncodingHelper base64EncodedStringForData:data withLineLength:lineLength urlFriendly:urlFriendly];
        
        NSData *dataOut = [BMEncodingHelper dataWithBase64EncodedString:base64EncodedString urlFriendly:urlFriendly];
        
        //YW55IGNhcm5hbCBwbGVhc3VyZS4=
        
        NSString *outputString = [[NSString alloc] initWithData:dataOut encoding:NSUTF8StringEncoding];
        
        GHAssertEqualObjects(inputString, outputString, @"Expected input to equal output");
    }

}

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

- (NSString *) base64EncodedData:(NSData *)data withLineLength:(unsigned int) lineLength {
    const unsigned char	*bytes = [data bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:[data length]];
    unsigned long ixtext = 0;
    unsigned long lentext = [data length];
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    short i = 0;
    short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;
    
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
        
        for( i = 0; i < ctcopy; i++ )
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
        for( i = ctcopy; i < 4; i++ )
            [result appendFormat:@"%c",'='];
        
        ixtext += 3;
        charsonline += 4;
        
        if( lineLength > 0 ) {
            if (charsonline >= lineLength) {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return result;
}

@end
