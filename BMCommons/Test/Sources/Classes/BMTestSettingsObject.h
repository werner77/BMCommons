//
//  BMTestSettingsObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractSettingsObject.h>

typedef NS_ENUM(NSUInteger, AHShoppingListSortType) {
    AHShoppingListItemSortTypeSorted = 1,
    AHShoppingListItemSortTypeNotAvailable = -2,
    AHShoppingListItemSortTypeUnsorted = 99999,
    AHShoppingListItemSortTypeToBeSorted = -1
};

typedef NS_ENUM(NSUInteger, AHShoppingListSortState) {AHShoppingListInputSorted = 0, AHShoppingListStoreSorted = 1, AHShoppingListOrderModeSorted = 2};

@interface BMTestSettingsObject : BMAbstractSettingsObject

@property (nonatomic, strong) NSString *mijnAHEmailAddress;
@property (nonatomic, assign) AHShoppingListSortState myListSortOrderState;
@property (nonatomic, assign) BOOL synchingEnabled;

- (BOOL)isLoggedIn;
- (void)clearMijnAHEmailAddress;

@end
