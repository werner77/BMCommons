//
//  BMTableView.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/12/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMReusableObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Custom UITableView.
 */
@interface BMTableView : UITableView<BMReusableObjectContainer>

@end

NS_ASSUME_NONNULL_END
