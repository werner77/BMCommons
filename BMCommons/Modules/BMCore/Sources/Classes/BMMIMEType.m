//
//  BMMIMEType.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMIMEType.h>

@implementation BMMIMEType 

@synthesize contentType, fileExtensions;

static NSDictionary *forwardDictionary = nil;
static NSDictionary *reverseDictionary = nil;

+ (void)initialize {
    if (!forwardDictionary) {
        forwardDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"audio/x-mpeg", @"abs",			
                              @"application/postscript",@"ai",			
                              @"audio/x-aiff",@"aif",			
                              @"audio/x-aiff",@"aifc",		
                              @"audio/x-aiff",@"aiff",		
                              @"application/x-aim",@"aim",			
                              @"image/x-jg",@"art",			
                              @"video/x-ms-asf",@"asf",			
                              @"video/x-ms-asf",@"asx",			
                              @"audio/basic",@"au",			
                              @"video/x-msvideo",@"avi",			
                              @"video/x-rad-screenplay",@"avx",			
                              @"application/x-bcpio",@"bcpio",		
                              @"application/octet-stream",@"bin",			
                              @"image/bmp",@"bmp",			
                              @"text/html",@"body",		
                              @"application/x-cdf",@"cdf",			
                              @"application/x-x509-ca-cert",@"cer",			
                              @"application/java",@"class",		
                              @"application/x-cpio",@"cpio",		
                              @"application/x-csh",@"csh",			
                              @"text/css",@"css",			
                              @"image/bmp",@"dib",			
                              @"application/msword",@"doc",			
                              @"application/xml-dtd",@"dtd",			
                              @"video/x-dv",@"dv",			
                              @"application/x-dvi",@"dvi",			
                              @"application/postscript",@"eps",			
                              @"text/x-setext",@"etx",			
                              @"application/octet-stream",@"exe",			
                              @"image/gif",@"gif",			
                              @"application/x-gtar",@"gtar",		
                              @"application/x-gzip",@"gz",			
                              @"application/x-hdf",@"hdf",			
                              @"application/mac-binhex40",@"hqx",			
                              @"text/x-component",@"htc",			
                              @"text/html",@"htm",			
                              @"text/html",@"html",		
                              @"application/mac-binhex40",@"hqx",			
                              @"image/ief",@"ief",			
                              @"text/vnd.sun.j2me.app-descriptor",@"jad",			
                              @"application/java-archive",@"jar",			
                              @"text/plain",@"java",		
                              @"application/x-java-jnlp-file",@"jnlp",		
                              @"image/jpeg",@"jpe",			
                              @"image/jpeg",@"jpeg",		
                              @"image/jpeg",@"jpg",			
                              @"text/javascript",@"js",			
                              @"text/plain",@"jsf",			
                              @"text/plain",@"jspf",		
                              @"audio/x-midi",@"kar",			
                              @"application/x-latex",@"latex",		
                              @"audio/x-mpegurl",@"m3u",			
                              @"image/x-macpaint",@"mac",			
                              @"application/x-troff-man",@"man",			
                              @"application/mathml+xml",@"mathml",		
                              @"application/x-troff-me",@"me",			
                              @"audio/x-midi",@"mid",			
                              @"audio/x-midi",@"midi",		
                              @"application/x-mif",@"mif",			
                              @"video/quicktime",@"mov",			
                              @"video/x-sgi-movie",@"movie",		
                              @"audio/x-mpeg",@"mp1",			
                              @"audio/x-mpeg",@"mp2",			
                              @"audio/x-mpeg",@"mp3",			
                              @"video/mp4",@"mp4",			
                              @"audio/x-mpeg",@"mpa",			
                              @"video/mpeg",@"mpe",			
                              @"video/mpeg",@"mpeg",		
                              @"audio/x-mpeg",@"mpega",		
                              @"video/mpeg",@"mpg",			
                              @"video/mpeg2",@"mpv2",		
                              @"application/x-wais-source",@"ms",			
                              @"application/x-netcdf",@"nc",			
                              @"application/oda",@"oda",			
                              @"application/vnd.oasis.opendocument.database",@"odb",			
                              @"application/vnd.oasis.opendocument.chart",@"odc",			
                              @"application/vnd.oasis.opendocument.formula",@"odf",			
                              @"application/vnd.oasis.opendocument.graphics",@"odg",			
                              @"application/vnd.oasis.opendocument.image",@"odi",			
                              @"application/vnd.oasis.opendocument.text-master",@"odm",			
                              @"application/vnd.oasis.opendocument.presentation",@"odp",			
                              @"application/vnd.oasis.opendocument.spreadsheet",@"ods",			
                              @"application/vnd.oasis.opendocument.text",@"odt",			
                              @"application/ogg",@"ogg",			
                              @"application/vnd.oasis.opendocument.graphics-template",@"otg",			
                              @"application/vnd.oasis.opendocument.text-web",@"oth",			
                              @"application/vnd.oasis.opendocument.presentation-template",@"otp",			
                              @"application/vnd.oasis.opendocument.spreadsheet-template",@"ots",			
                              @"application/vnd.oasis.opendocument.text-template",@"ott",			
                              @"image/x-portable-bitmap",@"pbm",			
                              @"image/pict",@"pct",			
                              @"application/pdf",@"pdf",			
                              @"image/x-portable-graymap",@"pgm",			
                              @"image/pict",@"pic",			
                              @"image/pict",@"pict",		
                              @"audio/x-scpls",@"pls",			
                              @"image/png",@"png",			
                              @"image/x-portable-anymap",@"pnm",			
                              @"image/x-macpaint",@"pnt",			
                              @"image/x-portable-pixmap",@"ppm",			
                              @"application/vnd.ms-powerpoint",@"ppt",			
                              @"application/vnd.ms-powerpoint",@"pps",			
                              @"application/postscript",@"ps",			
                              @"image/x-photoshop",@"psd",			
                              @"video/quicktime",@"qt",			
                              @"image/x-quicktime",@"qti",			
                              @"image/x-quicktime",@"qtif",		
                              @"image/x-cmu-raster",@"ras",			
                              @"application/rdf+xml",@"rdf",			
                              @"image/x-rgb",@"rgb",			
                              @"application/vnd.rn-realmedia",@"rm",			
                              @"application/x-troff",@"roff",		
                              @"application/rtf",@"rtf",			
                              @"text/richtext",@"rtx",			
                              @"application/x-sh",@"sh",			
                              @"application/x-shar",@"shar",		
                              @"text/x-server-parsed-html",@"shtml",		
                              @"audio/x-midi",@"smf",			
                              @"application/x-stuffit",@"sit",			
                              @"audio/basic",@"snd",			
                              @"application/x-wais-source",@"src",			
                              @"application/x-sv4cpio",@"sv4cpio",		
                              @"application/x-sv4crc",@"sv4crc",		
                              @"image/svg+xml",@"svg",			
                              @"image/svg+xml",@"svgz",		
                              @"application/x-shockwave-flash",@"swf",			
                              @"application/x-troff",@"t",			
                              @"application/x-tar",@"tar",			
                              @"application/x-tcl",@"tcl",			
                              @"application/x-tex",@"tex",			
                              @"application/x-texinfo",@"texi",		
                              @"application/x-texinfo",@"texinfo",		
                              @"image/tiff",@"tif",			
                              @"image/tiff",@"tiff",		
                              @"application/x-troff",@"tr",			
                              @"text/tab-separated-values",@"tsv",			
                              @"text/plain",@"txt",			
                              @"audio/basic",@"ulw",			
                              @"application/x-ustar",@"ustar",		
                              @"application/voicexml+xml",@"vxml",		
                              @"image/x-xbitmap",@"xbm",			
                              @"application/xhtml+xml",@"xht",			
                              @"application/xhtml+xml",@"xhtml",		
                              @"application/vnd.ms-excel",@"xls",			
                              @"application/xml",@"xml",			
                              @"image/x-xpixmap",@"xpm",			
                              @"application/xml",@"xsd",			
                              @"application/xml",@"xsl",			
                              @"application/xslt+xml",@"xslt",		
                              @"application/vnd.mozilla.xul+xml",@"xul",			
                              @"image/x-xwindowdump",@"xwd",			
                              @"application/x-visio",@"vsd",			
                              @"audio/x-wav",@"wav",			
                              @"image/vnd.wap.wbmp",@"wbmp",		
                              @"text/vnd.wap.wml",@"wml",			
                              @"application/vnd.wap.wmlc",@"wmlc",		
                              @"text/vnd.wap.wmlscript",@"wmls",		
                              @"application/vnd.wap.wmlscriptc",@"wmlscriptc",		
                              @"video/x-ms-wmv",@"wmv",			
                              @"x-world/x-vrml",@"wrl",			
                              @"application/wspolicy+xml",@"wspolicy",		
                              @"application/x-compress",@"Z",			
                              @"application/x-compress",@"z",			
                              @"application/zip",@"zip",	
                              nil];
        
        reverseDictionary = [NSMutableDictionary new];
        
        for (NSString *extension in forwardDictionary) {
            
            NSString *contentType = [forwardDictionary objectForKey:extension];
            NSMutableArray *extensions = [reverseDictionary objectForKey:contentType];
            if (!extensions) {
                extensions = [NSMutableArray array];
                [(NSMutableDictionary *)reverseDictionary setObject:extensions forKey:contentType];
            }
            if (![extensions containsObject:extension]) {
                [extensions addObject:extension];
            }
        }
    }
}

+ (BMMIMEType *)mimeTypeForFileExtension:(NSString *)fileExtension {
    NSString *contentType = [forwardDictionary objectForKey:[fileExtension lowercaseString]];
    BMMIMEType *mimeType = nil;
    if (contentType) {
        mimeType = [BMMIMEType new];
        mimeType.contentType = contentType;
        mimeType.fileExtensions = [reverseDictionary objectForKey:contentType];
    } 
    return mimeType;
}

+ (BMMIMEType *)mimeTypeForContentType:(NSString *)contentType {
    NSArray *extensions = [reverseDictionary objectForKey:contentType];
    BMMIMEType *mimeType = nil;
    if (extensions) {
        mimeType = [BMMIMEType new];
        mimeType.contentType = contentType;
        mimeType.fileExtensions = extensions;
    } 
    return mimeType;
}




@end
