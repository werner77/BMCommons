//
//  AlbumPickerController.m
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <BMCommons/BMAlbumPickerController.h>
#import <BMCommons/BMAssetPickerController.h>
#import <BMCommons/BMAssetTablePickerController.h>
#import <BMUICore/BMTableViewCell.h>
#import <BMMedia/BMMedia.h>

@interface BMAlbumPickerController()

@end

@interface BMAlbumPickerController(Private)

-(void)loadAlbums;
-(void)reloadTableView;

@end

@implementation BMAlbumPickerController {
	ALAssetsLibrary *library;
	NSArray *assetGroups;
	NSOperationQueue *queue;
	id<BMAssetTablePickerControllerDelegate> __weak delegate;
}

@synthesize delegate, assetGroups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        BMMediaCheckLicense();
        self.adjustContentInsetsForTranslucentBars = YES;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:BMMediaLocalizedString(@"albumpicker.title.loading", @"Loading...")];
    
    self.tableView.rowHeight = 57;
	
    library = [[ALAssetsLibrary alloc] init];
    
    [self performSelector:@selector(loadAlbums) withObject:nil afterDelay:0.0];
}

- (void)viewDidUnload {
	BM_RELEASE_SAFELY(assetGroups);
    BM_RELEASE_SAFELY(library);
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)assetGroups[indexPath.row];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%zd)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)assetGroups[indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	BMAssetTablePickerController *picker = [[BMAssetTablePickerController alloc] initWithStyle:UITableViewStylePlain];
	picker.delegate = self.delegate;
    
    // Move me    
    picker.assetGroup = assetGroups[indexPath.row];
    [self.navigationController pushViewController:picker animated:YES];
}

- (void)reloadWithAlbums:(NSArray *)albums {
    if (assetGroups != albums) {
        assetGroups = albums;
    }
    [self reloadTableView];
}

@end

@implementation BMAlbumPickerController(Private)

- (void)loadAlbums {
    NSMutableArray *theGroups = [NSMutableArray array];
    
    // Group enumerator Block
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
    {
        if (group == nil) 
        {
            // Keep this line!  w/o it the asset count is broken for some reason.  Makes no sense
            [group numberOfAssets];
            
            // Reload albums
            [self reloadWithAlbums:theGroups];
            
            *stop = YES;
        } else {
            [theGroups addObject:group];
        }
    };
    
    // Group Enumerator Failure Block
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:BMMediaLocalizedString(@"albumpicker.error.loading", @"Error loading albums: %@"), [error description]] delegate:nil
                                               cancelButtonTitle:BMMediaLocalizedString(@"button.ok", @"OK") otherButtonTitles:nil];
        [alert show];
        
        LogWarn(@"A problem occured %@", [error description]);	                                 
    };	
    
    // Enumerate Albums
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator 
                         failureBlock:assetGroupEnumberatorFailure];
}

-(void)reloadTableView {
	[self setTitle:BMMediaLocalizedString(@"albumpicker.title", @"Albums")];
	[self.tableView reloadData];
}


@end
