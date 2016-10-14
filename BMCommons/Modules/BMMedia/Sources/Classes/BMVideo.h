//
//  BMVideo.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaItemWithDuration.h>

/**
 Default BMVideoContainer implementation relying on NSCoding for persistence.
 
 @see BMMediaItem
 */
@interface BMVideo : BMMediaItemWithDuration<BMVideoContainer>

@end