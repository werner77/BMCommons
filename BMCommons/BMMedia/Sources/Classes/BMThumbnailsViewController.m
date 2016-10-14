//
//  BMThumbnailsViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMThumbnailsViewController.h>
#import <BMMedia/BMThumbnailView.h>
#import <BMThree20/Three20UI/BMTTThumbsTableViewCell.h>
#import <BMThree20/Three20UI/BMTTLoadMoreTableViewCell.h>
#import <BMMedia/BMMedia.h>

@interface BMThumbnailsViewController ()

@end

@implementation BMThumbnailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *c = BMSTYLEVAR(thumbsViewBackgroundColor);
    if (c) {
        self.view.backgroundColor = c;
        self.tableView.backgroundColor = c;
        self.tableView.backgroundView.backgroundColor = c;
    }
    
    [_selectionControl setTitle:BMMediaLocalizedString(@"assetpicker.selectioncontrol.all", @"All") forSegmentAtIndex:0];
    [_selectionControl setTitle:BMMediaLocalizedString(@"assetpicker.selectioncontrol.photos", @"Photos") forSegmentAtIndex:1];
    [_selectionControl setTitle:BMMediaLocalizedString(@"assetpicker.selectioncontrol.videos", @"Videos") forSegmentAtIndex:2];    
}

- (BMTTThumbsTableViewCell *)createThumbsCellWithReuseIdentifier:(NSString *)identifier {
    BMTTThumbsTableViewCell *cell = [super createThumbsCellWithReuseIdentifier:identifier];
    [cell setThumbViewClass:[BMThumbnailView class]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[BMTTLoadMoreTableViewCell class]]) {
        BMTTLoadMoreTableViewCell *loadMoreCell = (BMTTLoadMoreTableViewCell *)cell;
        UIColor *c = BMSTYLEVAR(thumbsViewSummaryMainTextColor);
        if (c) {
            loadMoreCell.titleLabel.textColor = c;
        }
        c = BMSTYLEVAR(thumbsViewSummarySubTextColor);
        if (c) {
            loadMoreCell.subTitleLabel.textColor = c;
        }
        UIFont *f = BMSTYLEVAR(thumbsViewSummaryMainTextFont);
        if (f) {
            loadMoreCell.titleLabel.font = f;
        }
        f = BMSTYLEVAR(thumbsViewSummarySubTextFont);
        if (f) {
            loadMoreCell.subTitleLabel.font = f;
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
