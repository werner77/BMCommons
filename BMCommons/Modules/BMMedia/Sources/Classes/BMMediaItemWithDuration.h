//
//  BMMediaItemWithDuration.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaItem.h>

/**
 Default BMMediaWithDurationContainer implementation relying on NSCoding for persistence.
 
 @see BMMediaItem
 */
@interface BMMediaItemWithDuration : BMMediaItem<BMMediaWithDurationContainer>

@property (nonatomic, strong) NSNumber *duration;

@end