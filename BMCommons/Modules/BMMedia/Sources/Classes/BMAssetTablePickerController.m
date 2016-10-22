//
//  AssetTablePicker.m
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAssetTablePickerController.h>
#import <BMCommons/BMAssetCell.h>
#import <BMCommons/BMAlbumPickerController.h>
#import "ALAsset+BMMedia.h"
#import <BMCommons/BMAssetPickerController.h>
#import <BMMedia/BMAssetThumbnailView.h>
#import <BMMedia/BMMedia.h>

@interface BMAssetTablePickerController()<BMAssetThumbnailViewDelegate>

@end

@interface BMAssetTablePickerController(Private)

-(NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath;
-(void)updateView;
-(void)setAssets:(NSArray *)theAssets;
-(BMMediaKind)supportedMediaKinds;
-(void)preparePhotosWithSupportedMediaKinds:(NSNumber *)n;
-(void)updateSelectableAssets:(BMMediaKind)mediaKinds;
-(NSInteger)numberOfCellsPerRow;

@end

@implementation BMAssetTablePickerController {
	ALAssetsGroup *assetGroup;
	NSMutableArray *assets;
    NSArray *selectableAssets;
    NSMutableArray *photoAssets;
    NSMutableArray *videoAssets;
    NSMutableArray *selectedAssets;
    UILabel *footerLabel;
	id<BMAssetTablePickerControllerDelegate> __weak delegate;
    BMMediaKind filteredMediaKinds;
    UISegmentedControl *selectionControl;
    UIActivityIndicatorView *activityIndicator;
}

@synthesize delegate;
@synthesize assetGroup;
@synthesize selectedAssets;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

        selectedAssets = [NSMutableArray new];
        filteredMediaKinds = BMMediaKindAll;
        self.adjustContentInsetsForTranslucentBars = YES;
    }
    return self;
}


#pragma mark - UIViewController methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    assets = [NSMutableArray new];
    photoAssets = [NSMutableArray new];
    videoAssets = [NSMutableArray new];
    
    self.tableView.rowHeight = 79;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];
    self.tableView.backgroundColor = BMSTYLEVAR(assetPickerBackgroundColor);
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,45)];
    
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerView.backgroundColor = [UIColor clearColor];
    footerLabel = [[UILabel alloc] initWithFrame:footerView.bounds];
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    footerLabel.textColor = BMSTYLEVAR(assetPickerSummaryTextColor);
    footerLabel.font = BMSTYLEVAR(assetPickerSummaryTextFont);
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.backgroundColor = [UIColor clearColor];
    [footerView addSubview:footerLabel];
    
    self.tableView.tableFooterView = footerView;
    
    
    selectionControl = [[UISegmentedControl alloc] initWithItems:@[BMMediaLocalizedString(@"assetpicker.selectioncontrol.all", @"All"),
                                                                                       BMMediaLocalizedString(@"assetpicker.selectioncontrol.photos", @"Photos"),
                                                                                       BMMediaLocalizedString(@"assetpicker.selectioncontrol.videos", @"Videos")]];    
    if (filteredMediaKinds == BMMediaKindAll) {
        selectionControl.selectedSegmentIndex = 0;
    } else if (filteredMediaKinds == BMMediaKindPicture) {
        selectionControl.selectedSegmentIndex = 1;
    } else {
        selectionControl.selectedSegmentIndex = 2;
    }
    [selectionControl addTarget:self action:@selector(onSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    
    BMMediaKind supportedMediaKinds = self.supportedMediaKinds;
    if ((supportedMediaKinds & BMMediaKindVideo) &&  (supportedMediaKinds & BMMediaKindPicture)) {
        self.navigationItem.titleView = selectionControl;
    } else {
        self.navigationItem.titleView = nil;
    }
    
    [self setTitle:BMMediaLocalizedString(@"assetpicker.title.loading", @"Loading...")];
        
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [self performSelector:@selector(preparePhotosWithSupportedMediaKinds:) withObject:[NSNumber numberWithInt:(int)self.supportedMediaKinds] afterDelay:0.0];
}

- (void)viewDidUnload {
    selectableAssets = nil;
    BM_RELEASE_SAFELY(selectionControl);
    BM_RELEASE_SAFELY(footerLabel);
    BM_RELEASE_SAFELY(assets);
    BM_RELEASE_SAFELY(photoAssets);
    BM_RELEASE_SAFELY(videoAssets);
    BM_RELEASE_SAFELY(activityIndicator);
    [super viewDidUnload];
}

- (void)localize {
    [super localize];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:BMUICoreLocalizedString(@"button.title.done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    [selectionControl setTitle:BMMediaLocalizedString(@"assetpicker.selectioncontrol.all", @"All") forSegmentAtIndex:0];
    [selectionControl setTitle:BMMediaLocalizedString(@"assetpicker.selectioncontrol.photos", @"Photos") forSegmentAtIndex:1];
    [selectionControl setTitle:BMMediaLocalizedString(@"assetpicker.selectioncontrol.videos", @"Videos") forSegmentAtIndex:2];    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource/Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfCellsPerRow = self.numberOfCellsPerRow;
    return selectableAssets.count / numberOfCellsPerRow + (selectableAssets.count % numberOfCellsPerRow > 0 ? 1 : 0);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell-%zd", self.numberOfCellsPerRow];
    
    BMAssetCell *cell = (BMAssetCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {	
        cell = [[BMAssetCell alloc] initWithReuseIdentifier:cellIdentifier numberOfThumbnails:self.numberOfCellsPerRow];
        for (BMAssetThumbnailView *v in cell.thumbnailViews) {
            v.delegate = self;
        }
    }
    
    NSArray *assetsForIndexPath = [self assetsForIndexPath:indexPath];
    int i = 0;
    for (BMAssetThumbnailView *v in cell.thumbnailViews) {
        ALAsset *theAsset = i < assetsForIndexPath.count ? assetsForIndexPath[i++] : nil;
        [v setAsset:theAsset];
        v.selected = [selectedAssets containsObject:theAsset];
    }
    return cell;
}

#pragma mark - Actions

- (void) doneAction:(id)sender {	
    [self.delegate assetTablePicker:self didFinishWithSelectedAssets:selectedAssets];
}

- (void)onSelectionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        //All
        filteredMediaKinds = BMMediaKindAll;
    } else if (sender.selectedSegmentIndex == 1) {
        //Photos
        filteredMediaKinds = BMMediaKindPicture;
    } else {
        //Videos
        filteredMediaKinds = BMMediaKindVideo;
    }
    [self updateView];
}

#pragma mark BMAssetDelegate implementation

- (BOOL)assetThumbnailView:(BMAssetThumbnailView *)assetView shouldChangeSelectionStatus:(BOOL)selected {
    
    NSUInteger maxTotal = [self.delegate assetTablePicker:self maxNumberOfSelectableAssetsOfKind:BMMediaKindUnknown];
    
    if (selected) {
        if (![self.delegate assetTablePicker:self allowSelectionOfAsset:assetView.asset]) {
            return NO;
        }
        
        if (maxTotal == 1) {
            [self performSelector:@selector(doneAction:) withObject:nil afterDelay:0.0];
        }
    }
    return YES;
}

- (void)assetThumbnailView:(BMAssetThumbnailView *)assetView didChangeSelectionStatus:(BOOL)selected {
    if (selected && assetView.asset && ![selectedAssets containsObject:assetView.asset]) {
        [selectedAssets addObject:assetView.asset];
    } else if (!selected) {
        [selectedAssets removeObject:assetView.asset];
    }
}

#pragma mark - Other methods

- (NSUInteger)numberOfSelectedAssetsOfKind:(BMMediaKind)mediaKind {
    NSUInteger count = 0;
    for (ALAsset *asset in selectedAssets) {
		if((asset.bmMediaKind & mediaKind))
        {            
            count++;	
		}
	}
    return count;
}

- (NSUInteger)numberOfSelectedAssets {
    return [self numberOfSelectedAssetsOfKind:(BMMediaKindPicture | BMMediaKindVideo)];
}

@end

@implementation BMAssetTablePickerController(Private)

- (BMMediaKind)supportedMediaKinds {
    BMMediaKind supportedMediaKinds = BMMediaKindUnknown;
    if ([self.delegate assetTablePicker:self maxNumberOfSelectableAssetsOfKind:BMMediaKindPicture] > (NSUInteger)0) {
        supportedMediaKinds |= BMMediaKindPicture;
    }
    if ([self.delegate assetTablePicker:self maxNumberOfSelectableAssetsOfKind:BMMediaKindVideo] > (NSUInteger)0) {
        supportedMediaKinds |= BMMediaKindVideo;
    }
    return supportedMediaKinds;
}

- (NSInteger)numberOfCellsPerRow {
    return [BMAssetCell numberOfThumbnailsForWidth:self.view.frame.size.width];
}

-(NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
    NSInteger numberOfCellsPerRow = self.numberOfCellsPerRow;
    NSInteger index = (_indexPath.row * numberOfCellsPerRow);
    NSInteger maxIndex = MIN(index + numberOfCellsPerRow, selectableAssets.count);
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSInteger i = index; i < maxIndex; ++i) {
        [ret addObject:selectableAssets[i]];
    }
    return ret;
}

- (void)updateView {
    BMMediaKind supportedMediaKinds = self.supportedMediaKinds;
    BMMediaKind effectiveSupportedMediaKinds = (supportedMediaKinds & filteredMediaKinds);
    [self updateSelectableAssets:effectiveSupportedMediaKinds];
    [self.tableView reloadData];
    NSInteger maxRow = [self tableView:self.tableView numberOfRowsInSection:0] - 1;
    if (maxRow >= 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:maxRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];    
    }
    
    NSInteger photoCount = photoAssets.count;
    NSInteger videoCount = videoAssets.count;
    [self setTitle:BMMediaLocalizedString(@"assetpicker.title.pickmedia", @"Pick Media")];
    
    NSString *photosTitle = photoCount == 1 ? BMMediaLocalizedString(@"assetpicker.summary.photo", @"photo") : BMMediaLocalizedString(@"assetpicker.summary.photos", @"photos");
    NSString *videosTitle = videoCount == 1 ? BMMediaLocalizedString(@"assetpicker.summary.video", @"video") : BMMediaLocalizedString(@"assetpicker.summary.videos", @"videos");
    
    if ((effectiveSupportedMediaKinds & BMMediaKindVideo) &&  (effectiveSupportedMediaKinds & BMMediaKindPicture)) {
        footerLabel.text = [NSString stringWithFormat:@"%zd %@, %zd %@", photoCount, photosTitle, videoCount, videosTitle];
    } else if ((effectiveSupportedMediaKinds & BMMediaKindVideo)) {
        footerLabel.text = [NSString stringWithFormat:@"%zd %@", videoCount, videosTitle];
    } else {
        footerLabel.text = [NSString stringWithFormat:@"%zd %@", photoCount, photosTitle];
    }
}

- (void)setAssets:(NSArray *)theAssets {
    [activityIndicator stopAnimating];
    [assets removeAllObjects];
    for (ALAsset *asset in theAssets) {
        BMMediaKind mediaKind = asset.bmMediaKind;
        if (mediaKind == BMMediaKindVideo) {
            [videoAssets addObject:asset];
        } else if (asset.bmMediaKind == BMMediaKindPicture) {
            [photoAssets addObject:asset];
        }
        [assets addObject:asset];
    }
    [self updateView];
}

-(void)preparePhotosWithSupportedMediaKinds:(NSNumber *)n {
    BMMediaKind supportedMediaKinds = [n intValue];
    
    NSMutableArray *theAssets = [NSMutableArray array];
    
    @autoreleasepool {
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result == nil) {
                *stop = YES;
            } else if ((result.bmMediaKind & supportedMediaKinds)) {
                [theAssets addObject:result];
            }
        }];
    }
    
    [self setAssets:theAssets];
}

- (void)updateSelectableAssets:(BMMediaKind)mediaKinds {
    if ((mediaKinds & BMMediaKindVideo) && (mediaKinds & BMMediaKindPicture)) {
        selectableAssets = assets;
    } else if ((mediaKinds & BMMediaKindVideo)) {
        selectableAssets = videoAssets;
    } else {
        selectableAssets = photoAssets;
    }
}

@end
