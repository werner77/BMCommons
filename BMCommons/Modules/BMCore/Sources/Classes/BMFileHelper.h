//
//  BMFileHelper.h
//  BehindMedia
//
//  Created by Werner Altewischer on 7/1/08.
//  Copyright 2008 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class with file utility methods
 */
@interface BMFileHelper : BMCoreObject {

}

/**
 Returns the application's documents directory.
 */
+ (nullable NSString *)documentsDirectory;

/**
 Returns the temporary directory.
 */
+ (NSString *)tempDirectory;

/**
 Creates a unique file with extension "tmp" in the temp dir.
 
 @return The file path of the created file
 */
+ (nullable NSString *)createTempFile;

/**
 Creates a unique file with specified extension in the specified dir
 
 @param dir The directory to create the file in
 @param extension The extension of the file to create. Extension should not include the "."
 @return The file path of the created file
 */
+ (nullable NSString *)createTempFileInDir:(NSString *)dir withExtension:(nullable NSString *)extension;

/**
 Prepends the document dir to the specified filename giving the full path to the file.
 */
+ (nullable NSString *)fullDocumentPath:(NSString *)fileName;

/**
 Prepends the document dir and specified subDir to the specified filename giving the full path to the file.
 */
+ (nullable NSString *)fullDocumentPath:(NSString *)fileName inSubDir:(nullable NSString *)subDir;

/**
 Reads in the file with the specified filename from the documents dir and returns the data contained within it.
 */
+ (nullable NSData *)applicationDataFromFile:(NSString *)fileName;

/**
 (Over)writes application data to the file with the specified filename in the documents dir.
 
 @returns The path to the file written, or nil if unsuccessful.
 */
+ (nullable NSString *)writeApplicationData:(NSData *)data toFile:(NSString *)fileName;

/**
 (Over)writes application data to the file with the specified filename in the specified subDir of the documents dir.
 
 @returns The path to the file written, or nil if unsuccessful.
 */
+ (nullable NSString *)writeApplicationData:(NSData *)data toFile:(NSString *)fileName inSubDir:(nullable NSString *)subDir;

/**
 Removes the file with the specified filename from the documents dir.
 
 @returns true if successful, false otherwise
 */
+ (BOOL)removeApplicationFile:(NSString *)fileName;

/**
 Returns an array of filenames of the the files in the specified directory.
 */
+ (nullable NSArray *)listDocumentsInDir:(NSString *)directory;

/**
 Returns an array of filenames of the the files in the specified directory with the specified extension.
 */
+ (nullable NSArray *)listDocumentsInDir:(NSString *)directory withExtension:(nullable NSString *)extension;

/**
 Returns an array of file paths of the the files in the specified directory with the specified extension.
 */
+ (nullable NSArray *)listFilePathsInDir:(NSString *)directory withExtension:(nullable NSString *)extension;

/**
 Returns an array of filenames of the the files in the documents directory.
 */
+ (nullable NSArray *)listApplicationDocuments;

/**
 Returns an array of filenames of the the files in the documents directory with the specified extension.
 */
+ (nullable NSArray *)listApplicationDocumentsWithExtension:(nullable NSString *)extension;

/**
 Returns an array of filenames of the the files in the subDir of the documents directory with the specified extension.
 */
+ (nullable NSArray *)listApplicationDocumentsWithExtension:(nullable NSString *)extension inSubDir:(nullable NSString *)subDir;

/**
 Removes all files from the specified directory.
 */
+ (void)cleanDirectory:(NSString *)dir;

/**
 Returns a unique file path to a file in the temp directory with the specified extension. 
 
 File is not created, only a path is returned.
 */
+ (NSString *)uniqueTempFileWithExtension:(nullable NSString *)extension;

/**
 Returns a unique file path to a file in the specified directory with the specified extension. 
 
 File is not created, only a path is returned.
 */
+ (NSString *)uniqueFileInDir:(NSString *)dir withExtension:(nullable NSString *)extension;

/**
 Returns a unique file name with the specified extension.
 */
+ (NSString *)uniqueFileNameWithExtension:(nullable NSString *)extension;

/**
 Returns the creation date for the file at the specified path or nil if the file is not found.
 */
+ (nullable NSDate *)creationDateForFileAtPath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
