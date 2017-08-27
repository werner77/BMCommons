//
//  BMSOAPData.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Data object which is used to substitute in a SOAP request.
 */
@interface BMSOAPData : NSObject

@property (nullable, nonatomic, strong) NSString *username;
@property (nullable, nonatomic, strong) NSString *password;
@property (nullable, nonatomic, strong) NSString *body;

- (NSString *)dateString;
- (NSString *)uuid;

+ (BMSOAPData *)soapDataWithUsername:(NSString *)theUsername password:(NSString *)thePassword body:(NSString *)theBody;

@end

NS_ASSUME_NONNULL_END
