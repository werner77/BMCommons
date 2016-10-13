
#import <UIKit/UIKit.h>

@protocol BMTTPhoto;
@class BMTTThumbsTableViewCell;

@protocol BMTTThumbsTableViewCellDelegate<NSObject>
@required

- (void)thumbsTableViewCell:(BMTTThumbsTableViewCell*)cell didSelectPhoto:(id<BMTTPhoto>)photo;

@end
