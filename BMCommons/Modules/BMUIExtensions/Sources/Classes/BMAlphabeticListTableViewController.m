//
//  BMAlphabeticListTableViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 14/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAlphabeticListTableViewController.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMDialogHelper.h>

@interface BMAlphabeticListTableViewController(Private)

+ (NSSortDescriptor *)sortDescriptor;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *)objects;
- (NSString *)keyForSection:(NSInteger)section;
- (NSInteger)nearestSectionForKey:(NSString *)key;
- (NSArray *)objectsInSection:(NSInteger)section;
- (NSDictionary *)groupObjectsAlphabetically:(NSArray *)objects;
- (int)allObjectsCount;
- (void)filterObjectsByName:(NSString *)searchText;

- (void)setAllObjects:(NSDictionary *)dict;

@end

@implementation BMAlphabeticListTableViewController {
	NSDictionary *allObjects;
	NSMutableDictionary *searchedObjects;
	BOOL searching;
	NSString *searchString;
	NSMutableArray *indexTitles;
	BOOL summaryCellEnabled;
}

@synthesize allObjects, searchedObjects, summaryCellEnabled;

- (void)dealloc {
	BM_RELEASE_SAFELY(searchString);
}

#pragma mark -
#pragma mark View methods

- (void)viewDidLoad {
    [super viewDidLoad];

    searchedObjects = [NSMutableDictionary new];
    searching = NO;
	
	indexTitles = [[NSMutableArray alloc] initWithCapacity:28];
	[indexTitles addObject:@"{search}"];
	for (char c = 'A'; c <= 'Z'; ++c) {
		[indexTitles addObject:[NSString stringWithFormat:@"%hhd", c]];
	}
	[indexTitles addObject:@"#"];
	
    BM_PUSH_IGNORE_DEPRECATION_WARNING
    
	if (searching) {
		[self.searchDisplayController setActive:searching];
		[self.searchDisplayController.searchBar setText:searchString];
	} else {
		BM_RELEASE_SAFELY(searchString);
		searching = NO;
	}
    
    BM_POP_IGNORE_WARNING
}

- (void)viewDidUnload {
	BM_RELEASE_SAFELY(indexTitles);
    BM_RELEASE_SAFELY(searchedObjects);
	self.allObjects = nil;
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger sectionCount = self.objects.count;
	if (!searching && self.allObjectsCount > 0 && self.isSummaryCellEnabled) {
		sectionCount++;
	}	
	return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == (self.objects.count)) {
		return 1;
	} else {
		NSArray *objectsInSection = [self objectsInSection:section];
		return objectsInSection.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section >= (self.objects.count)) {
		return nil;
	} else {
		return [self keyForSection:section];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == self.objects.count) {
		cell = [self summaryCellForCount:self.allObjectsCount];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		id<BMNamedObject> object = [self objectAtIndexPath:indexPath];
		cell = [self cellForObject:object];
        /*
		if (searching) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
        */ 
	}
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != self.objects.count) {
		id selectedObject = [self objectAtIndexPath:indexPath];
		[self didSelectRowForObject:selectedObject];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)theTableView {
	if(searching) {
		return nil;
	} else {
		return indexTitles;
	}
}

- (NSInteger)tableView:(UITableView *)theTableView sectionForSectionIndexTitle:(NSString *)theTitle atIndex:(NSInteger)index {
	
	NSInteger section = -1;
	if(!searching) {
		if (index == 0) {
			//Scroll to search box
			[theTableView scrollRectToVisible:[[theTableView tableHeaderView] bounds] animated:NO];
		} else {
			section = [self nearestSectionForKey:theTitle];
		}
	}
	
	return section;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if (!searching && self.allObjectsCount > 0) {
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

BM_PUSH_IGNORE_DEPRECATION_WARNING

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)theSearchString {
    [self filterObjectsByName:theSearchString];
	
	searchString = theSearchString;
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
	searching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	searching = NO;
	[self.tableView reloadData];
}

BM_POP_IGNORE_WARNING

#pragma mark -
#pragma mark Abstract methods to override

- (void)didSelectRowForObject:(id<BMNamedObject>)object {
	
}

- (UITableViewCell *)summaryCellForCount:(NSUInteger)count {
	return nil;
}

- (UITableViewCell *)cellForObject:(id<BMNamedObject>)object {
	static NSString *identifier = @"_ObjectCell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.textLabel.text = object.name;
	return cell;
}

- (NSArray *)loadObjects {
	return nil;
}

#pragma mark - Implementation of super class methods

- (IBAction)reset {
    [searchedObjects removeAllObjects];
    self.allObjects = nil;
    [super reset];
}

- (void)updateEntitiesWithArray:(NSArray *)entityArray totalCount:(NSUInteger)theTotalCount {
    [super updateEntitiesWithArray:entityArray totalCount:theTotalCount];
    self.allObjects = [self groupObjectsAlphabetically:self.entities];
}

@end

@implementation BMAlphabeticListTableViewController(Private)

+ (NSSortDescriptor *)sortDescriptor {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	return sortDescriptor;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {	
	NSArray *objectsInSection = [self objectsInSection:indexPath.section];
	id object = objectsInSection[indexPath.row];
	return object;
}

- (NSDictionary *)objects {
	if (searching) {
		return self.searchedObjects;
	} else {
		return self.allObjects;
	}
}

- (NSString *)keyForSection:(NSInteger)section {
	NSArray *myKeys = [self.objects allKeys];
	NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSString *key = sortedKeys[section];
	return key;
}

- (NSInteger)nearestSectionForKey:(NSString *)key {
	
	if ([key isEqual:@"{search}"]) {
		return 0;
	} else if ([key isEqual:@"#"]) {
		return self.objects.count;
	}
	
	NSArray *myKeys = [self.objects allKeys];
	NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSInteger index = -1;
	while (YES) {
		NSUInteger theIndex = [sortedKeys indexOfObject:key];
		if (![key isEqual:@"A"] && theIndex == NSNotFound) {
			unichar c = [key characterAtIndex:0];
			c--;
			key = [NSString stringWithCharacters:&c length:1];
		} else {
			if (theIndex == NSNotFound) {
				index = -1;
			} else {
				index = theIndex;
			}
			break;
		}
	}
	return index;
}

- (NSArray *)objectsInSection:(NSInteger)section {
	return (self.objects)[[self keyForSection:section]];
}

- (int)allObjectsCount {
	int count = 0;
	NSEnumerator *enumerator = [self.allObjects objectEnumerator];
	
	NSArray *objects;
	while ((objects = [enumerator nextObject])) {
		count += objects.count;
	}
	return count;
}

- (NSDictionary *)groupObjectsAlphabetically:(NSArray *)objects {
	
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:27];
	
	for (id<BMNamedObject> object in objects) {
		if (object.name.length > 0) {
			NSString *key = [[object.name substringToIndex:1] uppercaseString];
			NSMutableArray *array = ret[key];
			
			if (array == nil) {
				array = [NSMutableArray array];
				ret[key] = array;
			}
			
			[array addObject:object];
		}
	}
	
	NSArray *values = ret.allValues;
	for (NSMutableArray *objectArray in values) {
		[objectArray sortUsingDescriptors:@[[[self class] sortDescriptor]]];
	}
	return ret;
}

- (void)filterObjectsByName:(NSString *)searchText {
	
	//Remove all objects first.
	[searchedObjects removeAllObjects];
	
	if (searchText.length > 0) {
		
		NSMutableArray *searchArray = [[NSMutableArray alloc] init];
		NSMutableArray *matchingObjects = [[NSMutableArray alloc] init];
		
		NSEnumerator *enumerator = [self.allObjects objectEnumerator];
		NSArray *objectsInSection;
		while ((objectsInSection = [enumerator nextObject])) {
			[searchArray addObjectsFromArray:objectsInSection];
		}
		
		for (id<BMNamedObject> object in searchArray) {
			NSRange titleResultsRange = [object.name rangeOfString:searchText options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
			
			if (titleResultsRange.length > 0) {
				[matchingObjects addObject:object];
			}
		}
		
		[matchingObjects sortUsingDescriptors:@[[[self class] sortDescriptor]]];		
		searchedObjects[@""] = matchingObjects;
	}
}

- (void)setAllObjects:(NSDictionary *)dict {
	if (allObjects != dict) {
		allObjects = dict;
	}
}

@end
