//
//  BMViewFactory.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BMUICore/BMUICoreObject.h>
#import <BMCore/BMReusableObject.h>
#import <BMCore/BMVersionAvailability.h>

//Kinds for use by [BMViewFactory registerOnceReusableViewOfType:ofKind:forView:]
extern NSString * const BMCollectionViewCellKind;
extern NSString * const BMTableViewCellKind;
extern NSString * const BMTableViewHeaderFooterViewKind;

/**
 Class that constructs (reusable) views by loading them from a nib.
 */
@interface BMViewFactory : BMUICoreObject

/**
 The bundle used.
 */
@property (nonatomic, readonly) NSBundle *bundle;

/**
 Designated initializer.
 
 Initializes the factory using the specified bundle.
 
 If bundle is nil the [NSBundle mainBundle] is used.
 */
- (id)initWithBundle:(NSBundle *)bundle;

/**
 Loads a tableview cell from the bundle set.
 
 The nib name should equal the cellkind and the nib should only contain this tableview cell with reuseIdentifier set to
the same value.
 */
- (UITableViewCell*)cellOfKind:(NSString*)theCellKind forTable:(UITableView*)aTableView;

/**
 This method is present for sub classes to override. 
 
 Default just calls cellOfKind:forTable:
 When using custom backgrounds for tableviews you may want to use different cells depending on what position in the (grouped) UITableView they have.
 */
- (UITableViewCell*)cellOfKind:(NSString*)theCellKind forTable:(UITableView*)aTableView atIndexPath:(NSIndexPath *)indexPath;

/**
 Loads a view from a nib with the specified name (kind).
 
 Also checks whether the reuse identifier of the view corresponds to the kind.
 */
- (UIView<BMReusableObject> *)viewOfKind:(NSString *)kind;

/**
 Loads a reusable view from the container or from the nib if not available for dequeueing.
 
 @see viewOfKind:
 @see [BMReusableObjectContainer dequeueReusableObjectWithIdentifier:]
 */
- (UIView<BMReusableObject> *)viewOfKind:(NSString *)theKind forContainer:(id <BMReusableObjectContainer>)container;

/**
 Loads the first view in the specified nib using the specified owner as owner.
 
 @see [NSBundle loadNibNamed:owner:options]
 */
- (UIView *)viewFromNib:(NSString *)theNibName withOwner:(id)owner;

/**
 Calls viewFromNib:withOwner: with nil owner.
 */
- (UIView *)viewFromNib:(NSString *)theNibName;

/**
 Releases memory held by caches.
 
 Is called automatically on low memory conditions.
 */
- (void)releaseMemory;

#ifdef __IPHONE_6_0

BM_START_IGNORE_TOO_NEW

/**
 Returns a cell of the specified type for the specified tableview at the specified indexpath.
 
 Tries to load a nib with the specified type name and registers it if not already registered. If no such nib exists the type is interpreted as class name and this
 class (if existent and of the proper type) is registered for the cell type. The UINib+BMCommons category constructor [UINib nibWithObjectClass:] is used in the latter case to reuse precaching behavior to optimize scrolling. In case of failure to register or dequeue, nil is returned.
 
 @see [UINib nibWithObjectClass:]
 */
- (UITableViewCell*)cellOfType:(NSString*)type forTableView:(UITableView*)aTableView atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns a view of the specified type for the specified tableview at the specified indexpath.
 
 Tries to load a nib with the specified type name and registers it if not already registered. If no such nib exists the type is interpreted as class name and this
 class (if existent and of the proper type) is registered for the cell type. The UINib+BMCommons category constructor [UINib nibWithObjectClass:] is used in the latter case to reuse precaching behavior to optimize scrolling. In case of failure to register or dequeue, nil is returned.
 
 @see [UINib nibWithObjectClass:]
 */
- (UIView*)headerFooterViewOfType:(NSString*)type forTableView:(UITableView*)aTableView;

/**
 Returns a cell with the specified reuse identifier loaded from a nib with a similar name from the bundle set.
 
 If the type is a class name and cannot be loaded from nib it will be instantiated by the classname instead. The UINib+BMCommons category constructor [UINib nibWithObjectClass:] is used in the latter case to reuse precaching behavior to optimize scrolling.
 This methods automatically uses dequeuing as provided by the collectionView for reuse.
 
 @see [UINib nibWithObjectClass:]
 */
- (UICollectionViewCell *)cellOfType:(NSString *)type forCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns a reusable view with the specified reuse identifier loaded from a nib with a similar name from the bundle set.
 
 If the type is a class name and cannot be loaded from nib it will be instantiated by the classname instead. The UINib+BMCommons category constructor [UINib nibWithObjectClass:] is used in the latter case to reuse precaching behavior to optimize scrolling.
 This methods automatically uses dequeuing as provided by the collectionView for reuse.
 
 @see [UINib nibWithObjectClass:]
 */
- (UICollectionReusableView *)reusableViewOfType:(NSString *)type ofKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
 This method registers the specified reusable view with type (reuseIdentifier/nib name/class name) of the specified kind (BMCollectionViewCellKind, BMTableViewCellKind, BMTableViewHeaderFooterViewKind or kinds defined by UICollectionView) for the specified view (an instance of UICollectionView or UITableView).
 
 This method is called automatically by the cellOfType: or reusableViewOfType: methods above but it may be called manually to initiate precaching for the specified type of reusable view.
 
 Returns YES if registered, NO otherwise (e.g. because an invalid type or kind was specified).
 */
- (BOOL)registerOnceReusableViewOfType:(NSString *)type ofKind:(NSString *)kind forView:(UIView *)view;

BM_END_IGNORE_TOO_NEW

#endif

@end  