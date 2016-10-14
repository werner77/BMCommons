//
//  ClassOverviewGenerator.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/8/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "ClassOverviewGenerator.h"
#include <stdio.h>
#include <getopt.h>
#import "ClassOverviewGenerator.h"
#import <BMCommons/BMRegexKitLite.h>

@implementation ClassOverviewGenerator

- (NSDictionary *)executeWithPath:(NSString *)path {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *beginMarker = @"/**";
    NSString *endMarker = @"*/";
    NSString *protocolString = @"protocol";
    NSString *interfaceString = @"interface";
    NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionary];
    
    NSArray *files = [fm contentsOfDirectoryAtPath:path error:&error];
    
    for (NSString *file in files) {
        
        if ([[[file pathExtension] lowercaseString] isEqual:@"h"] && ![[file lowercaseString] hasSuffix:@"_private.h"]) {
            NSString *filePath = [path stringByAppendingPathComponent:file];
            
            NSLog(@"Processing file: %@", filePath);
            
            NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            
            NSRange range = NSMakeRange(0, contents.length);
            do {
                range = [contents rangeOfRegex:@"@(interface|protocol)\\s+([A-Za-z0-9() ]+)[\\s:{]" options:0 inRange:NSMakeRange(range.location, contents.length - range.location) capture:2 error:nil];
                
                if (range.location != NSNotFound) {
                    NSString *interfaceName = [[contents substringWithRange:range] stringByReplacingOccurrencesOfString:@" " withString:@""];
                    
                    if (interfaceName.length > 0) {
                        [headerDictionary setObject:@"" forKey:interfaceName];
                    }
                }
            
            } while (range.location != NSNotFound);
            
            NSUInteger loc = 0;
            
            while (YES) {
                NSRange range = [contents rangeOfString:beginMarker options:0 range:NSMakeRange(loc, contents.length - loc)];
                
                if (range.location == NSNotFound) {
                    break;
                } else {
                    loc = range.location + beginMarker.length;
                    
                    NSRange endRange = [contents rangeOfString:endMarker options:0 range:NSMakeRange(loc, contents.length - loc)];
                    
                    if (endRange.location == NSNotFound) {
                        break;
                    } else {
                        NSString *headerText = [contents substringWithRange:NSMakeRange(loc, endRange.location - loc)];
                        
                        NSString *interfaceName = nil;
                                        
                        NSUInteger i = endRange.location + endMarker.length;
                        
                        while (i < contents.length) {
                            unichar c = [contents characterAtIndex:i++];
                            
                            if (![whiteSpaceSet characterIsMember:c]) {
                                
                                if ('@' == c) {
                                    NSArray *markers = @[interfaceString, protocolString];
                                    
                                    for (NSString *markerString in markers) {
                                        NSString *candidateMarker = [contents substringWithRange:NSMakeRange(i, markerString.length)];
                                        if ([markerString isEqual:candidateMarker]) {
                                            i += markerString.length;
                                            
                                            while (i < contents.length) {
                                                c = [contents characterAtIndex:i++];
                                                if (![whiteSpaceSet characterIsMember:c]) {
                                                    break;
                                                }
                                            }
                                            
                                            NSUInteger start = i - 1;
                                            
                                            while (i < contents.length) {
                                                c = [contents characterAtIndex:i++];
                                                if (c == ':' || c == '{' || c == '<' || c == '\n') {
                                                    break;
                                                }
                                            }
                                            
                                            NSUInteger end = i - 1;
                                            
                                            interfaceName = [[[contents substringWithRange:NSMakeRange(start, end - start)] stringByTrimmingCharactersInSet:whiteSpaceSet] stringByReplacingOccurrencesOfString:@" " withString:@""];
                                        }
                                        if (interfaceName.length > 0) {
                                            break;
                                        }
                                    }
                                }
                                
                                break;
                            }
                        }
                        
                        if (interfaceName.length > 0) {
                            NSCharacterSet *trimSet = [NSCharacterSet characterSetWithCharactersInString:@"/*\n\r\t "];
                            headerText = [headerText stringByTrimmingCharactersInSet:trimSet];
                            
                            NSRange newLineRange = [headerText rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
                            
                            if (newLineRange.location != NSNotFound) {
                                headerText = [headerText substringWithRange:NSMakeRange(0, newLineRange.location)];
                            }
                            
                            NSRange bracketRange = [headerText rangeOfRegex:@"[(].*?[)]"];
                            
                            if (bracketRange.location != NSNotFound) {
                                headerText = [headerText stringByReplacingCharactersInRange:bracketRange withString:@""];
                            }
                            
                            headerText = [headerText stringByReplacingOccurrencesOfString:@" ." withString:@"."];
                            [headerDictionary setObject:headerText forKey:interfaceName];
                        }
                    }
                }
            }
        }
    }
    
    return headerDictionary;
}

@end

int main (int argc, char * argv[]) {
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    int ret = 0;
    
    NSString *path = nil;
    NSString *header = nil;
    NSString *outputFile = nil;
    
    int c;
	
	while (1)
	{
		int option_index = 0;
		static struct option long_options[] =
		{
            {"input", 1, 0, 'i'},
            {"header", 1, 0, 'h'},
			{0, 0, 0, 0}
		};
		
		c = getopt_long (argc, argv, "i:h:",
						 long_options, &option_index);
		if (c == -1)
			break;
		
		NSString *optString = optarg ? [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding] : nil;
        
		switch (c)
		{
            case 'i':
                path = optString;
                break;
            case 'h':
                header = optString;
                break;
			case '?':
				break;
				
			default:
				fprintf (stderr, "?? getopt returned character code 0%o ??\n", c);
		}
	}
    
    if (optind == argc - 1) {
		outputFile = [NSString stringWithCString:argv[optind] encoding:NSUTF8StringEncoding];
	}
    
    if (outputFile && path) {
        ClassOverviewGenerator *generator = [ClassOverviewGenerator new];
        
        
        /*
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        NSArray *dirs = [fm contentsOfDirectoryAtPath:path error:&error];
        NSMutableString *outputString = [NSMutableString string];
        
        for (NSString *dir in dirs) {
            NSString *dirPath = [path stringByAppendingPathComponent:dir];
            BOOL isDir = NO;
            BOOL exists = [fm fileExistsAtPath:dirPath isDirectory:&isDir];
            if (exists && isDir && ![dir hasPrefix:@"."]) {
                [outputString appendFormat:@"__%@__\n\n", dir];
                NSDictionary *dict = [generator executeWithPath:dirPath];
                NSArray *orderedClassNames = [[dict allKeys] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
                
                for (NSString *className in orderedClassNames) {
                    NSString *headerText = [dict objectForKey:className];
                    [outputString appendFormat:@"- %@: %@\n", className, headerText];
                }
                [outputString appendString:@"\n\n"];
            }
        }
         */
        
        header = [header stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        
        NSMutableString *outputString = [NSMutableString string];
        
        if (header) {
            [outputString appendString:header];
            [outputString appendString:@"\n"];
        }
        
        NSDictionary *dict = [generator executeWithPath:path];
        NSArray *orderedClassNames = [[dict allKeys] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
        
        for (NSString *className in orderedClassNames) {
            NSString *headerText = [dict objectForKey:className];
            BOOL isCategory = [className rangeOfString:@"("].location != NSNotFound;
            if (!isCategory || headerText.length > 0) {
                if (isCategory) {
                    [outputString appendFormat:@"- %@: %@\n", className, headerText.length > 0 ? headerText : @"No description"];
                } else {
                    [outputString appendFormat:@"- [%@](%@): %@\n", className, className, headerText.length > 0 ? headerText : @"No description"];
                }
            
            }
        }
        [outputString appendString:@"\n"];
        
        [[outputString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:outputFile atomically:YES];
        
        [generator release];
    } else {
        fprintf(stderr, "Usage: ClassOverviewGenerator -i <path to base include dir> [-h <header text>] <output dir>\n");
        ret = 1;
    }
    
    [pool release];
    return ret;
}

