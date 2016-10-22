//
//  MediaRollController.m
//  BTFD
//
//  Created by Werner Altewischer on 17/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMediaRollController.h>
#import <BMCommons/BMViewFactory.h>
#import <BMCommons/BMMediaContainerThumbnailCell.h>
#import <BMMedia/BMMedia.h>
	
#define CELL_COUNT 1000
#define TABLEVIEW_ALPHA 1.0
#define MEDIA_LOAD_BATCH_SIZE 4
#define MEDIA_PRELOAD_OFFSET 2

#define DEFAULT_CELL_IDENTIFIER @"BMMediaRollThumbnailCell"

@interface BMMediaRollController(Private) 

- (NSInteger)realIndexFromIndex:(NSUInteger)index;
- (NSUInteger)initialIndex;
- (NSIndexPath *)scrollToIndex:(NSUInteger)index;
- (void)calculateSelectionBox;
- (NSIndexPath *)indexPathForSelectedCell:(BOOL)useScrollingDirection;
- (NSIndexPath *)indexPathForSelectedCellWithinMargin:(CGFloat)margin;
- (void)selectSelectedCell;
- (void)selectSelectedCell:(BOOL)useScrollingDirection;
- (void)selectCellWithIndexPath:(NSIndexPath *)indexPath;
- (id <BMMediaContainer>)mediaContainerAtIndex:(NSInteger)index;
- (UIImage *)imageAtIndex:(NSInteger)index;
- (NSInteger)visibleCellIndex;

@end

@implementation BMMediaRollController {
	NSMutableArray *data;
	BMViewFactory *cellFactory;
	id <BMMediaRollControllerDelegate> __weak delegate;
	UITableView *tableView;
	CGRect selectionBox;
	CGFloat selectionBoxMin;
	CGFloat selectionBoxMax;
	BOOL scrollingDown;
	CGFloat lastContentOffset;
	NSInteger mediaLoadCounter;
	
	BOOL snap;
	BOOL multiClick;
	BOOL repeating;
}

@synthesize data;
@synthesize tableView;
@synthesize delegate;
@synthesize snap;
@synthesize multiClick;
@synthesize repeating;
@synthesize cellReuseIdentifier;
@synthesize squareThumbnails;

- (id)initWithTableView:(UITableView *)theTableView cellFactory:(BMViewFactory *)theCellFactory delegate:(id <BMMediaRollControllerDelegate>)theDelegate {
	if (self = [super init]) {

        if (!theCellFactory) {
            theCellFactory = [[BMViewFactory alloc] initWithBundle:[BMMedia bundle]];
        }
		cellFactory = theCellFactory;
		delegate = theDelegate;
		tableView = theTableView;
		tableView.delegate = self;
		tableView.dataSource = self;
		tableView.alpha = 0.0;
		tableView.decelerationRate = UIScrollViewDecelerationRateFast;
		tableView.scrollsToTop = NO;
		tableView.pagingEnabled = NO;
		tableView.showsVerticalScrollIndicator = NO;
		tableView.showsHorizontalScrollIndicator = NO;
        tableView.separatorColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		[self calculateSelectionBox];
        squareThumbnails = YES;
		data = [NSMutableArray new];
	}
	return self;
}

- (void)dealloc {
	for (id <BMMediaContainer> mediaContainer in data) {
		[mediaContainer removeDelegate:self];
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (repeating) {
		return CELL_COUNT;
	} else {
		return data.count;
	}
} 

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger index = [self realIndexFromIndex:indexPath.row];
	
	id <BMMediaContainer> mediaContainer = [self mediaContainerAtIndex:index];
    
    NSString *identifier = self.cellReuseIdentifier;
    
    if (!identifier) {
        identifier = DEFAULT_CELL_IDENTIFIER;
    }
    
    BMMediaContainerThumbnailCell *cell = (BMMediaContainerThumbnailCell *)[cellFactory cellOfType:identifier forTableView:tableView atIndexPath:indexPath];
	[cell constructCellWithObject:mediaContainer propertyName:nil];
   
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFill;
    cell.thumbnailImageView.imageView.contentMode = contentMode;
    
    [cell.thumbnailImageView setTarget:self action:@selector(buttonTapped:)];
    cell.thumbnailImageView.tag = indexPath.row;
    
    if ([self.delegate respondsToSelector:@selector(mediaRollController:customizeCell:atIndex:)]) {
        [self.delegate mediaRollController:self customizeCell:cell atIndex:index];
    }
	
	return cell;	
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.multiClick || [indexPath isEqual:[self indexPathForSelectedCellWithinMargin:5]]) {
		NSInteger index = [self realIndexFromIndex:indexPath.row];
		if (index >= 0) {
            id <BMMediaContainer> media = [self mediaContainerAtIndex:index];
            if ([delegate respondsToSelector:@selector(mediaRollController:didSelectMedia:atIndex:)]) {
                [delegate mediaRollController:self didSelectMedia:media atIndex:index];
            }
		}
	} else {
		[self selectCellWithIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.squareThumbnails) {
        return selectionBox.size.width;
    } else {
        return theTableView.rowHeight;
    }
}

- (void)setData:(NSArray *)theData {
	if (theData != data) {
		for (id <BMMediaContainer> mediaContainer in data) {
			[mediaContainer removeDelegate:self];
		}
		[data removeAllObjects];
		
		if (theData) {
			[data addObjectsFromArray:theData];
			
			for (id <BMMediaContainer> mediaContainer in data) {
				[mediaContainer addDelegate:self];
			}
		}
		[self reload];
	}
}

- (void)reload {
    mediaLoadCounter = 0;
    [self.tableView reloadData];
    if (data.count) {
        [self scrollToIndex:self.initialIndex];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.tableView.alpha = TABLEVIEW_ALPHA;
        [UIView commitAnimations];
    }
    
    if (snap) {
        [self performSelector:@selector(selectSelectedCell) withObject:nil afterDelay:0.5];
    }
}

- (void)reloadCellAtIndex:(NSUInteger)index {
	NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *visibleIndexPath in visibleIndexPaths) {
		NSUInteger realIndex = [self realIndexFromIndex:[visibleIndexPath row]];
		if (index == realIndex) {
			[self.tableView reloadRowsAtIndexPaths:@[visibleIndexPath] withRowAnimation:NO];
		}
	}
}

#pragma mark - Action

- (void)buttonTapped:(UIView *)sender {
    NSInteger row = sender.tag;
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate implementation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.tableView.decelerating) {
		CGFloat offsetDiff = self.tableView.contentOffset.y - lastContentOffset;
		if (offsetDiff > 0) {
			//scrolling down
			scrollingDown = YES;
		} else {
			//scrolling up
			scrollingDown = NO;
		}
		lastContentOffset = self.tableView.contentOffset.y;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (self.snap && !decelerate) {
		[self selectSelectedCell:YES];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {	
	if (self.snap) {
		[self selectSelectedCell:YES];
	}
}

#pragma mark -
#pragma mark MediaContainerDelegate implementation

- (void)mediaContainerDidUpdate:(id <BMMediaContainer>)container {
	NSUInteger index = [data indexOfObjectIdenticalTo:container];	
	if (index != NSNotFound) {
		[self reloadCellAtIndex:index];
	}
}

- (void)mediaContainerWasDeleted:(id <BMMediaContainer>)mediaContainer {
	NSUInteger index = [data indexOfObjectIdenticalTo:mediaContainer];	
	if (index != NSNotFound) {
		if (repeating) {
			[data removeObjectAtIndex:index];
			[tableView reloadData];
		} else {
			[tableView beginUpdates];
			[data removeObjectAtIndex:index];
			[tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
			[tableView endUpdates];
		}
	}
}

@end

@implementation BMMediaRollController(Private) 

- (NSInteger)realIndexFromIndex:(NSUInteger)index {
	NSUInteger count = data.count;
	NSInteger realIndex = -1;
	if (count > 0) {
		if (repeating) {
			realIndex = index % count;
		} else {
			realIndex = index;
		}
	}
	return realIndex;
}

- (NSUInteger)initialIndex {
	if (repeating && data.count) {
		NSUInteger n = CELL_COUNT / data.count;
		return (n / 2) * data.count;
	} else {
		return 0;
	}
}

- (NSIndexPath *)scrollToIndex:(NSUInteger)index {
	NSUInteger indexes[] = {0, index};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	return indexPath;
}
		
- (void)calculateSelectionBox {
	CGRect frame = tableView.frame;		
	if (frame.size.height < frame.size.width) {
		CGFloat selectionSquareDimension = frame.size.height; 
		CGFloat originX = tableView.frame.origin.x + (tableView.frame.size.width - selectionSquareDimension) / 2;
		CGFloat originY = tableView.frame.origin.y;
		selectionBox = CGRectMake(originX, originY, selectionSquareDimension, selectionSquareDimension);
		selectionBoxMin = selectionBox.origin.x;
		selectionBoxMax = selectionBox.origin.x + selectionBox.size.width;
	} else {
		CGFloat selectionSquareDimension = frame.size.width; 
		CGFloat originX = tableView.frame.origin.x;
		CGFloat originY = tableView.frame.origin.y + (tableView.frame.size.height - selectionSquareDimension) / 2;
		selectionBox = CGRectMake(originX, originY, selectionSquareDimension, selectionSquareDimension);
		selectionBoxMin = selectionBox.origin.y;
		selectionBoxMax = selectionBox.origin.y + selectionBox.size.height;
	}
}

- (NSInteger)visibleCellIndex {
	NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
	NSIndexPath *indexPath = visibleCells.count > 1 ? visibleCells[1] : nil;
	return [self realIndexFromIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForSelectedCellWithinMargin:(CGFloat)margin {
	NSIndexPath *theIndexPath = nil;
	CGFloat contentOffsetY = self.tableView.contentOffset.y;	
	CGFloat maxDimension = MAX(self.tableView.frame.size.height, self.tableView.frame.size.width);
	CGFloat lowerThreshold = maxDimension/2 - margin;
	CGFloat upperThreshold = maxDimension/2 + margin;
	for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		CGFloat normalizedMidY = cell.frame.origin.y - contentOffsetY + cell.frame.size.height/2;
		if (normalizedMidY >= lowerThreshold && normalizedMidY < upperThreshold) {
			theIndexPath = indexPath;
			break;
		}
	}
	return theIndexPath;
}

- (NSIndexPath *)indexPathForSelectedCell:(BOOL)useScrollingDirection {
	CGFloat minDistance = 100000;
	NSIndexPath *theIndexPath = nil;
	for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		CGFloat contentOffsetY = self.tableView.contentOffset.y;
		CGFloat normalizedOriginY = cell.frame.origin.y - contentOffsetY;
		
		CGFloat distance = normalizedOriginY - selectionBoxMin;
		CGFloat absDistance = ABS(distance);
		if (absDistance < minDistance) {
			if (!useScrollingDirection || (scrollingDown && distance >= 0) || (!scrollingDown && distance <= 0)) {
				theIndexPath = indexPath;
				minDistance = absDistance;
			}
		}
	}
	return theIndexPath;
}

- (void)selectSelectedCell {
	[self selectSelectedCell:NO];
}

- (void)selectSelectedCell:(BOOL)useScrollingDirection {
	NSIndexPath *indexPath = [self indexPathForSelectedCell:useScrollingDirection];	
	[self selectCellWithIndexPath:indexPath];
}

- (void)selectCellWithIndexPath:(NSIndexPath *)indexPath {
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	NSInteger index = [self realIndexFromIndex:indexPath.row];
	if (index >= 0) {
        id <BMMediaContainer> media = [self mediaContainerAtIndex:index];
        if ([delegate respondsToSelector:@selector(mediaRollController:didCenterMedia:atIndex:)]) {
            [delegate mediaRollController:self didCenterMedia:media atIndex:index];
        }
	}
}

- (id <BMMediaContainer>)mediaContainerAtIndex:(NSInteger)index {
	id <BMMediaContainer> mediaContainer = nil;
	if (index >= 0) {
		mediaContainer = data[index];
	}
	return mediaContainer;
}

- (UIImage *)imageAtIndex:(NSInteger)index {
	return [self mediaContainerAtIndex:index].thumbnailImage;
}

@end
