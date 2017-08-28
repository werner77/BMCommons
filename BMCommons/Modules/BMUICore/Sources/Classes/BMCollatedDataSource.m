//
// Created by Werner Altewischer on 16/12/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCollatedDataSource.h>
#import "NSArray+BMCommons.h"

@interface BMCollatedDataSource()

@property (nonatomic, strong) UILocalizedIndexedCollation *collation;
@property (nonatomic, assign) SEL stringSelector;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, assign) NSUInteger totalObjectCount;

@end

@implementation BMCollatedDataSource {

}

- (instancetype)init {
    return [self initWithCollation:[UILocalizedIndexedCollation currentCollation] stringSelector:@selector(description)];
}

- (instancetype)initWithCollation:(UILocalizedIndexedCollation *)collation stringSelector:(SEL)stringSelector {
    if ((self = [super init])) {
        self.collation = collation;
        self.stringSelector = stringSelector;
    }
    return self;
}


- (void)setData:(NSArray *)data {

    UILocalizedIndexedCollation *collation = self.collation;
    SEL stringSelector = self.stringSelector;

    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];

    //create an array to hold the data for each section
    for(NSUInteger i = 0; i < sectionCount; i++)
    {
        [sections addObject:[NSMutableArray array]];
    }

    //put each object into a section
    for (id object in data)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:stringSelector];
        [sections[index] addObject:object];
    }

    //sort each section
    for (NSUInteger i = 0; i < sectionCount; ++i) {
        NSArray *section = sections[i];
        sections[i] = [collation sortedArrayFromArray:section collationStringSelector:stringSelector];
    }

    self.sections = sections;
    self.totalObjectCount = data.count;
}

- (NSArray *)sortedDataForSection:(NSInteger)section {
    return [_sections bmSafeObjectAtIndex:section];
}

- (NSUInteger)sectionCount {
    return _sections.count;
}

- (NSUInteger)objectCountForSection:(NSInteger)section {
    return [[_sections bmSafeObjectAtIndex:section] count];
}

- (id)objectForItem:(NSInteger)item inSection:(NSInteger)section {
    return [[self sortedDataForSection:section] bmSafeObjectAtIndex:item];
}

@end