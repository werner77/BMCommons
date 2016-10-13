//
//  BMFileHelper.m
//  BehindMedia
//
//  Created by Werner Altewischer on 7/1/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import "BMFileHelper.h"
#import "BMStringHelper.h"
#import <Foundation/NSPathUtilities.h>
#import <BMCommons/BMCore.h>

@implementation BMFileHelper

+ (NSString *)tempDirectory {
	return NSTemporaryDirectory();
}

+ (NSString *)createTempFile {
	return [self createTempFileInDir:[BMFileHelper tempDirectory] withExtension:@"tmp"];
}

+ (NSString *)uniqueFileNameWithExtension:(NSString *)extension {
    NSString *s = [BMStringHelper stringWithUUID];
    if (![BMStringHelper isEmpty:extension]) {
        s = [s stringByAppendingFormat:@".%@", extension];
    }
	return s;
}

+ (NSString *)uniqueTempFileWithExtension:(NSString *)extension {
	return [self uniqueFileInDir:[self tempDirectory] withExtension:extension];
}

+ (NSString *)uniqueFileInDir:(NSString *)dir withExtension:(NSString *)extension {
	NSString *uniqueFileName = [BMFileHelper uniqueFileNameWithExtension:extension];
	NSString *tempFile = [dir stringByAppendingPathComponent:uniqueFileName];
	return tempFile;
}

+ (NSString *)createTempFileInDir:(NSString *)dir withExtension:(NSString *)extension {
	NSString *tempFile = [BMFileHelper uniqueFileInDir:dir withExtension:extension];
	if ([[NSFileManager defaultManager] createFileAtPath:tempFile contents:nil attributes:nil]) {
		return tempFile;
	} else {
		LogError(@"Could not create temp file");
		return nil;
	}
}

+ (NSString *)documentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* dir = [paths count] > 0 ? [paths objectAtIndex:0] : nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:dir]) {
		[fileManager createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];  
	}
	return dir;
}

+ (NSString *)fullDocumentPath:(NSString *)fileName inSubDir:(NSString *)subDir {
	NSString *documentsDirectory = [BMFileHelper documentsDirectory];
    if (subDir) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:subDir];
    }
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	return path;
}

+ (NSString *)fullDocumentPath:(NSString *)fileName {
	NSString *documentsDirectory = [BMFileHelper documentsDirectory];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	return path;
}

+ (NSData *)applicationDataFromFile:(NSString *)fileName {
	
    NSString *appFile = [BMFileHelper fullDocumentPath:fileName];
	
    NSData *myData = [[NSData alloc] initWithContentsOfFile:appFile];
	
    return myData;
	
}

+ (NSString *)writeApplicationData:(NSData *)data toFile:(NSString *)fileName {
	
    return [self writeApplicationData:data toFile:fileName inSubDir:nil];
}

+ (NSString *)writeApplicationData:(NSData *)data toFile:(NSString *)fileName inSubDir:(NSString *)subDir {
	
    NSString *documentsDirectory = [BMFileHelper documentsDirectory];
	
    if (!documentsDirectory) {
		
        LogError(@"Documents directory not found!");
		
        return nil;
    }
    
    if (subDir) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:subDir];
    }
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];		
    BOOL result = ([data writeToFile:appFile atomically:YES]);	
    
    if (result) {
        return appFile;
    } else {
        return nil;
    }
}


+ (NSArray *)listDocumentsInDir:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *files = [fileManager contentsOfDirectoryAtPath:directory error:&error];
	
	if (!files) {
		LogError(@"Could not list directory %@: %@", directory, [error localizedDescription]);
	}
	
	return files;
}

+ (NSArray *)listDocumentsInDir:(NSString *)directory withExtension:(NSString *)extension {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *files = [fileManager contentsOfDirectoryAtPath:directory error:&error];
	
	if (!files) {
		LogError(@"Could not list directory %@: %@", directory, [error localizedDescription]);
	}
	
	if (![BMStringHelper isEmpty:extension]) {
        NSString *theExtension = [@"." stringByAppendingString:extension];
		NSMutableArray *filteredFiles = [NSMutableArray arrayWithCapacity:files.count];
		for (int i = 0; i < files.count; ++i) {
			NSString *file = [files objectAtIndex:i];
			if ([file hasSuffix:theExtension]) {
				[filteredFiles addObject:file];
			}
		}
		files = filteredFiles;
	}
	
	return files;
}

+ (NSArray *)listFilePathsInDir:(NSString *)directory withExtension:(NSString *)extension {
    NSArray *filenames = [self listDocumentsInDir:directory withExtension:extension];
    NSMutableArray *filePaths = [NSMutableArray array];
    for (NSString *filename in filenames) {
        NSString *filePath = [directory stringByAppendingPathComponent:filename];
        [filePaths addObject:filePath];
    }
    return filePaths;
}

+ (NSArray *)listApplicationDocuments {
	NSString *documentsDirectory = [BMFileHelper documentsDirectory];
	return [BMFileHelper listDocumentsInDir:documentsDirectory];
}

+ (NSArray *)listApplicationDocumentsWithExtension:(NSString *)extension inSubDir:(NSString *)subDir {
	NSString *documentsDirectory = [BMFileHelper documentsDirectory];
    if (subDir) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:subDir];
    }
	return [BMFileHelper listDocumentsInDir:documentsDirectory withExtension:extension];
}


+ (NSArray *)listApplicationDocumentsWithExtension:(NSString *)extension {
    return [self listApplicationDocumentsWithExtension:extension inSubDir:nil];
}

+ (void)cleanDirectory:(NSString *)dir {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSArray *list = [fm contentsOfDirectoryAtPath:dir error:&error];
	
	for (NSString *file in list) {
		if (![fm removeItemAtPath:[dir stringByAppendingPathComponent:file] error:&error]) {
			LogError(@"Could not remove item: %@", [error localizedDescription]);
		}
	}
}

+ (BOOL)removeApplicationFile:(NSString *)fileName {
    
    if ([BMStringHelper isEmpty:fileName]) {
        LogInfo(@"No file specified for removal");
        return NO;
    }
    
	NSString *documentsDirectory = [BMFileHelper documentsDirectory];
	
    if (!documentsDirectory) {
		
        LogError(@"Documents directory not found!");
		
        return NO;
    }
	
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSError *error = nil;
	BOOL ret = [fm removeItemAtPath:appFile error:&error];
	if (!ret) {
		LogError(@"Could not remove document '%@': %@", appFile, error);
	}
	return ret;
}

+ (NSDate *)creationDateForFileAtPath:(NSString *)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attributes = [fm attributesOfItemAtPath:filePath error:nil];
    return [attributes fileCreationDate];
}

@end
