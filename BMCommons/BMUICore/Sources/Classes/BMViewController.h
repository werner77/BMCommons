//
//  BMViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 28/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMLocalization.h>
#import <BMUICore/BMViewFactory.h>
#import <BMUICore/BMStyleSheet.h>
#import <UIKit/UIKit.h>
#import <BMUICore/BMViewState.h>

@class BMViewController;

extern NSString *const BMViewControllerWillAppearNotification;
extern NSString *const BMViewControllerDidAppearNotification;
extern NSString *const BMViewControllerWillDisappearNotification;
extern NSString *const BMViewControllerDidDisappearNotification;

typedef void(^BMViewControllerDismissBlock)(BMViewController *vc, id result);


/**
 Base class for view controllers.
 
 This class ensures that viewDidLoad is always followed eventually by viewDidUnload (called from dealloc if needed) so the objects allocated or retained in viewDidLoad can be symmetrically released in viewDidUnload. It also handles didReceiveMemoryWarning in a backwards compatible way (calling viewDidUnload if needed).
 Other functionality includes BMStyleSheet support which if attached (see property styleSheet) is pushed on the stack of stylesheets together with this view controller.
 
 The viewState property tracks the view state of this view controller (BMViewStateInvisible, BMViewStateToBecomeVisible, BMViewStateVisible, BMViewStateToBecomeInvisible).
 
 This class also posts a BMViewControllerWillAppearNotification notification on viewWillAppear and keeps track with the property firstAppearAfterLoad and firstLoad of the loading state of the view.
 
 The viewFactory property contains a reference to a BMViewFactory which may be used to create reusable views. The methods keyboardDidShow: and keyboardWillHide: can be overridden by subclasses if they want to be notified of keyboard appearance/hiding.
 */
@interface BMViewController : UIViewController<BMLocalizable>

/**
 Tag to assign to the view controller for convenience (compare with UIView).
 */
@property(nonatomic, assign) NSInteger tag;

/**
 Current view state
 */
@property(nonatomic, readonly) BMViewState viewState;

/**
 Wether the view has not yet appeared after loading the view. After the first viewDidAppear this property will be false.
 */
@property(nonatomic, readonly) BOOL firstAppearAfterLoad;

/**
 Whether the view is loaded for the first time or not. The first viewDidLoad after init this property will be true, false otherwise.
 */
@property(nonatomic, readonly) BOOL firstLoad;

/**
 Factory for loading views/tableviewcells from nibs from the main bundle.
 */
@property(nonatomic, readonly) BMViewFactory *viewFactory;

/**
 Stylesheet to attach to the view controller. 
 
 Will be pushed on first view load and popped on dealloc. Should be set before view load other wise it is ignored.
 */
@property(nonatomic, strong) BMStyleSheet *styleSheet;

/**
 Property added to eliminate differences in behaviour between iOS 6 and 7.
 
 Calls wantsFullScreenLayout under iOS 6 and adjust the edge insets on iOS 7;
 */
@property(nonatomic, assign) BOOL useFullScreenLayout;

/**
 Set to true to unload the view (pre-iOS 6 behaviour) even for iOS >= 6 in the event of a memory warning.
 */
@property(nonatomic, assign) BOOL shouldUnloadViewAtMemoryWarning;

/**
 This block is executed when the view controller is dismissed.
 
 @see [BMViewController dismiss:]
 */
@property(nonatomic, copy) BMViewControllerDismissBlock dismissBlock;

/**
 Returns true iff the view state == BMViewStateVisible.
 */
- (BOOL)isViewVisible;

@end

@interface BMViewController(Protected)

/**
 Method called when the keyboard will show.
 */
- (void)keyboardWillShow:(NSNotification *)notification;

/**
 Method called when the keyboard did show.
 */
- (void)keyboardDidShow:(NSNotification *)notification;

/**
 Method called when the keyboard will hide.
 */
- (void)keyboardWillHide:(NSNotification *)notification;

/**
 Method called when the keyboard did hide.
 */
- (void)keyboardDidHide:(NSNotification *)notification;

/**
 Method called when the keyboard frame will change.
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification;

/**
 Method called when the keyboard frame did change.
 */
- (void)keyboardDidChangeFrame:(NSNotification *)notification;


/**
 Custom class for the view factory to use. 
 
 Default is BMViewFactory.
 */
- (Class)viewFactoryClass;

/**
 Common initialization called both from inithWithNib and initWithCoder.
 */
- (void)commonInit;

/**
 Call to execute the dismiss block (if set) with the specified result object.
 */
- (void)dismissWithResult:(id)result;

/**
 Even though the viewDidUnload/viewWillUnload methods are deprecated in iOS 6, we define them manually here to make view loading/unloading symmetrical.
 
 They are called in dealloc when view is set to nil.
 */
- (void)viewWillUnload;

/**
 Even though the viewDidUnload/viewWillUnload methods are deprecated in iOS 6, we define them manually here to make view loading/unloading symmetrical.
 
 They are called in dealloc when view is set to nil.
 */
- (void)viewDidUnload;

@end
