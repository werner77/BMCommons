//
//  BMFileHelper.h
//  BehindMedia
//
//  Created by Werner Altewischer on 7/1/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCoreObject.h>

/**
 Class with file utility methods
 */
@interface BMFileHelper : BMCoreObject {

}

/**
 Returns the application's documents directory.
 */
+ (NSString *)documentsDirectory;

/**
 Returns the temporary directory.
 */
+ (NSString *)tempDirectory;

/**
 Creates a unique file with extension "tmp" in the temp dir.
 
 @return The file path of the created file
 */
+ (NSString *)createTempFile;

/**
 Creates a unique file with specified extension in the specified dir
 
 @param dir The directory to create the file in
 @param extension The extension of the file to create. Extension should not include the "."
 @return The file path of the created file
 */
+ (NSString *)createTempFileInDir:(NSString *)dir withExtension:(NSString *)extension;

/**
 Prepends the document dir to the specified filename giving the full path to the file.
 */
+ (NSString *)fullDocumentPath:(NSString *)fileName;

/**
 Prepends the document dir and specified subDir to the specified filename giving the full path to the file.
 */
+ (NSString *)fullDocumentPath:(NSString *)fileName inSubDir:(NSString *)subDir;

/**
 Reads in the file with the specified filename from the documents dir and returns the data contained within it.
 */
+ (NSData *)applicationDataFromFile:(NSString *)fileName;

/**
 (Over)writes application data to the file with the specified filename in the documents dir.
 
 @returns true if successful, false otherwise. Error is logged.
 */
+ (NSString *)writeApplicationData:(NSData *)data toFile:(NSString *)fileName;

/**
 (Over)writes application data to the file with the specified filename in the specified subDir of the documents dir.
 
 @returns true if successful, false otherwise. Error is logged.
 */
+ (NSString *)writeApplicationData:(NSData *)data toFile:(NSString *)fileName inSubDir:(NSString *)subDir;

/**
 Removes the file with the specified filename from the documents dir.
 
 @returns true if successful, false otherwise
 */
+ (BOOL)removeApplicationFile:(NSString *)fileName;

/**
 Returns an array of filenames of the the files in the specified directory.
 */
+ (NSArray *)listDocumentsInDir:(NSString *)directory;

/**
 Returns an array of filenames of the the files in the specified directory with the specified extension.
 */
+ (NSArray *)listDocumentsInDir:(NSString *)directory withExtension:(NSString *)extension;

/**
 Returns an array of file paths of the the files in the specified directory with the specified extension.
 */
+ (NSArray *)listFilePathsInDir:(NSString *)directory withExtension:(NSString *)extension;

/**
 Returns an array of filenames of the the files in the documents directory.
 */
+ (NSArray *)listApplicationDocuments;

/**
 Returns an array of filenames of the the files in the documents directory with the specified extension.
 */
+ (NSArray *)listApplicationDocumentsWithExtension:(NSString *)extension;

/**
 Returns an array of filenames of the the files in the subDir of the documents directory with the specified extension.
 */
+ (NSArray *)listApplicationDocumentsWithExtension:(NSString *)extension inSubDir:(NSString *)subDir;

/**
 Removes all files from the specified directory.
 */
+ (void)cleanDirectory:(NSString *)dir;

/**
 Returns a unique file path to a file in the temp directory with the specified extension. 
 
 File is not created, only a path is returned.
 */
+ (NSString *)uniqueTempFileWithExtension:(NSString *)extension;

/**
 Returns a unique file path to a file in the specified directory with the specified extension. 
 
 File is not created, only a path is returned.
 */
+ (NSString *)uniqueFileInDir:(NSString *)dir withExtension:(NSString *)extension;

/**
 Returns a unique file name with the specified extension.
 */
+ (NSString *)uniqueFileNameWithExtension:(NSString *)extension;

/**
 Returns the creation date for the file at the specified path or nil if the file is not found.
 */
+ (NSDate *)creationDateForFileAtPath:(NSString *)filePath;

@end
