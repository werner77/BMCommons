//
//  BMYouTubeVideoListController.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeVideoListController.h>
#import <MediaPlayer/MediaPlayer.h>
#import <BMCore/BMServiceManager.h>
#import <BMCommons/BMYouTubeListUserVideosService.h>
#import <BMCommons/BMYouTube.h>
#import <BMCore/BMService.h>
#import <BMCore/BMCache.h>
#import <BMCore/BMStringHelper.h>
#import <BMYouTube/BMYouTubeEntryCell.h>
#import <BMYouTube/BMYouTubeListDirectStreamableVideosService.h>
#import "GDataEntryYouTubeVideo.h"

#define CACHE_SIZE 50

@interface BMYouTubeVideoListController()<BMServiceDelegate>
@end

@interface BMYouTubeVideoListController(Private)

- (void)performService;
- (GDataEntryYouTubeVideo *)entryAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isSelected:(GDataEntryYouTubeVideo *)entry;
- (void)setSelected:(BOOL)selected forEntry:(GDataEntryYouTubeVideo *)entry;

@end

@implementation BMYouTubeVideoListController {
    NSString *developerKey;
    GTMOAuth2Authentication *authentication;
    NSMutableArray *entries;
    NSMutableArray *selectedEntries;
    id <BMYouTubeVideoListControllerDelegate> __weak delegate;
    BMYouTubeListUserVideosService *listService;
    NSUInteger _ignoredEntryCount;
}

@synthesize developerKey, authentication, delegate, useNativeMode;

- (id)init {
    if ((self = [self initWithNibName:nil bundle:[BMYouTube bundle]])) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        BMYouTubeCheckLicense();
        self.useNativeMode = BMSTYLEVAR(nativeYouTubeModeEnabled);
        entries = [NSMutableArray new];
        selectedEntries = [NSMutableArray new];
        self.shouldScrollToActiveInputCell = NO;
        self.useNativeMode = NO;
        self.dragToRefreshEnabled = YES;
        self.dragToLoadMoreEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(entries);
    BM_RELEASE_SAFELY(selectedEntries);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = BMSTYLEVAR(youTubeEntryCellRowHeight);
    self.cellCache.maxCount = CACHE_SIZE;
}

- (void)viewDidUnload {
    [[BMServiceManager sharedInstance] cancelServiceInstancesForDelegate:self];
    [super viewDidUnload];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [entries count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id entry = [self entryAtIndexPath:indexPath];
    
    id entryKey = @((NSInteger)entry);
    
    BMYouTubeEntryCell *cell = [self.cellCache objectForKey:entryKey];
    
    if (!cell) {
        NSString *identifier = BMSTYLEVAR(youTubeEntryCellIdentifier);
        cell = (BMYouTubeEntryCell *)[self.viewFactory cellOfKind:identifier forTable:nil atIndexPath:indexPath];
        
        if ([self isSelected:entry]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        cell.target = self;
        cell.selector = @selector(toggleSelectionForCell:);
        cell.thumbnailView.nativeYouTubeModeEnabled = self.useNativeMode;
        
        [cell constructCellWithObject:entry propertyName:nil];
        
        [self.cellCache setObject:cell forKey:entryKey];
    }
    
    return cell;
}

- (void)toggleSelectionForCell:(BMYouTubeEntryCell *)cell {
    id entry = cell.propertyDescriptor.callGetter;
    BOOL selected = ![self isSelected:entry];
    
    if (selected) {
        if ([self.delegate respondsToSelector:@selector(youTubeVideoListController:shouldSelectVideo:)]) {
            if (![self.delegate youTubeVideoListController:self shouldSelectVideo:entry]) {
                //Delegate decided that this item cannot be selected
                return;
            }
        }
    }
    
    [self setSelected:selected forEntry:entry];
    if (selected) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (void)localize {
    [super localize];
    self.title = BMYouTubeLocalizedString(@"controller.videolist.title", @"Select Videos");
}

#pragma mark - Overridden methods

- (void)handleResult:(id)result forService:(id<BMService>)service {
    if ([service isKindOfClass:[BMYouTubeListDirectStreamableVideosService class]]) {
        BMYouTubeListDirectStreamableVideosService *s = (BMYouTubeListDirectStreamableVideosService *)service;
        _ignoredEntryCount += (s.numberOfEntries - [result count]);
    }
    if (listService.startIndex == 0) {
        [entries setArray:result];
    } else {
        [entries addObjectsFromArray:result];
    }
    
    NSArray *currentSelectedEntries = [NSArray arrayWithArray:selectedEntries];
    [selectedEntries removeAllObjects];
    for (GDataEntryYouTubeVideo *entry in currentSelectedEntries) {
        for (GDataEntryYouTubeVideo *entry1 in entries) {
            if ([[entry identifier] isEqual:entry1.identifier]) {
                [selectedEntries addObject:entry1];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Public methods

- (void)load:(BOOL)more {
    if (!more) {
        _ignoredEntryCount = 0;
        BM_RELEASE_SAFELY(listService);
    }
    [self performService];
}

- (NSUInteger)shownCount {
    return entries.count;
}

- (NSUInteger)totalCount {
    NSUInteger totalCount;
    if (listService) {
        totalCount = listService.totalNumberOfEntries - _ignoredEntryCount;
        totalCount = MAX(totalCount, self.shownCount);
    } else {
        totalCount = self.shownCount;
    }
    return totalCount;
}

- (NSArray *)entries {
    return [NSArray arrayWithArray:entries];
}

- (NSArray *)selectedEntries {
    return [NSArray arrayWithArray:selectedEntries];
}

@end

@implementation BMYouTubeVideoListController(Private)

- (void)performService {
    id <BMService> theService = nil;
    if (!listService) {
        listService = [BMYouTubeListUserVideosService new];
    }
    listService.developerKey = self.developerKey;
    listService.authentication = self.authentication;
    if (self.useNativeMode) {
        BMYouTubeListDirectStreamableVideosService *service = [BMYouTubeListDirectStreamableVideosService new];
        service.wrappedService = listService;
        theService = service;
    } else {
        theService = listService;
    }
    [[BMServiceManager sharedInstance] performService:theService withDelegate:self];
}

- (GDataEntryYouTubeVideo *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return entries[indexPath.row];
}

- (BOOL)isSelected:(GDataEntryYouTubeVideo *)entry {
    return [selectedEntries containsObject:entry];
}

- (void)setSelected:(BOOL)selected forEntry:(GDataEntryYouTubeVideo *)entry {
    if (selected && ![self isSelected:entry]) {
        [selectedEntries addObject:entry];
    } else if (!selected) {
        [selectedEntries removeObject:entry];
    }
}

@end
