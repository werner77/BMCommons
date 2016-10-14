This is the documentation for the BMCommons framework developed by Werner Altewischer for BehindMedia.

The BMCommons framework consists of multiple modules:

BMCore
----------

A module with core functionality that can be used for both MacOSX and iOS applications. It contains:

- A lot of helper classes for different things such as [BMApplicationHelper](BMApplicationHelper), [BMErrorHelper](BMErrorHelper), [BMSecurityHelper](BMSecurityHelper), [BMEncodingHelper](BMEncodingHelper), [BMEncryptionHelper](BMEncryptionHelper), [BMErrorHelper](BMErrorHelper), [BMStringHelper](BMStringHelper), [BMDateHelper](BMDateHelper) and more;
- Extensions of Foundation classes such as [BMTwoWayDictionary](BMTwoWayDictionary) and [BMOrderedDictionary](BMOrderedDictionary)
- Categories on Foundation classes such as [NSString(BMCommons)](NSString(BMCommons)), [NSDateFormatter(BMCommons)](NSDateFormatter(BMCommons)), [NSNumber(BMCommons)](NSNumber(BMCommons)), [NSData(Encryption)](NSData(Encryption)), [NSData(Compression)](NSData(Compression)), [NSArray(BMCommons)](NSArray(BMCommons)) and more;
- A streaming networking library with among other classes [BMHTTPRequest](BMHTTPRequest), [BMURLCache](BMURLCache) and [BMAsyncDataLoader](BMAsyncDataLoader);
- Proxy support via [BMProxy](BMProxy) and [BMImmutableProxy](BMImmutableProxy);
- The core classes of the [BMService](BMService) framework such as [BMServiceManager](BMServiceManager), [BMAbstractService](BMAbstractService), [BMHTTPService](BMHTTPService) and [BMCompositeService](BMCompositeService);
- Base input stream classes such as [BMAbstractInputStream](BMAbstractInputStream), [BMBufferedInputStream](BMBufferedInputStream), [BMURLConnectionInputStream](BMURLConnectionInputStream) and [BMHTTPMultiPartBodyInputStream](BMHTTPMultiPartBodyInputStream);
- Caching through [BMCache](BMCache) and [BMURLCache](BMURLCache);
- An extension of NSOperationQueue for multi-threading through BMOperationQueue;
- Extended localization support through [BMLocalization](BMLocalization) (allowing in-app locale changes)
- [BMApplicationContext](BMApplicationContext) class acting as a registry for singleton objects and initialization point for the application.
- [BMSettingsRegistry](BMSettingsRegistry), [BMSettingsObject](BMSettingsObject) and [BMAbstractSettingsObject](BMAbstractSettingsObject) for managing application settings.


[Here](BMCoreClassesOverview) is a full list of all classes with a short description of their purpose.

The BMCore module relies on the following frameworks which should be linked in an executable containing this module:

- Foundation.framework
- libicucore.dylib
- libz.dylib
- CoreGraphics.framework
- SystemConfiguration.framework
- AudioToolbox.framework
- Security.framework
- UIKit.framework (AppKit.framework for MacOSX)


BMUICore
----------

A module with core functionality for iOS applications, dependent on [BMCore](BMCore). It contains:

- UIViewController base classes, such as [BMViewController](BMViewController), [BMTableViewController](BMTableViewController) and [BMNavigationController](BMNavigationController) offering drag to refresh, drag to load more and custom push animations amongst other things;
- UIViewController classes which use the [BMService](BMService) framework to asynchronously load their model, such as [BMServiceModelTableViewController](BMServiceModelTableViewController) and [BMEntityServiceModelTableViewController](BMEntityServiceModelTableViewController);
- Helper classes such as [BMImageHelper](BMImageHelper), [BMDialogHelper](BMDialogHelper) and [BMDeviceHelper](BMDeviceHelper);
- Base classes for UITableViewCells, such as [BMTableViewCell](BMTableViewCell) and [BMObjectPropertyTableViewCell](BMObjectPropertyTableViewCell);
- Asynchronous image loading support through [BMAsyncImageLoader](BMAsyncImageLoader);
- UIView/UIControl classes such as [BMTextField](BMTextField), [BMAnimatedImageView](BMAnimatedImageView), [BMAsyncLoadingImageButton](BMAsyncLoadingImageButton), [BMDraggableButton](BMDraggableButton), [BMBarButtonItem](BMBarButtonItem);
- Stylesheet support for view controllers through [BMStyleSheet](BMStyleSheet)
- Loading indicator support through [BMBusyView](BMBusyView)
- Categories on commons classes such as [UIWebView(BMCommons)](UIWebView(BMCommons)), [UIView(BMCommons)](UIView(BMCommons)), [UINavigationBar(BMCommons)](UINavigationBar(BMCommons)) and more;
- [BMAppDelegate](BMAppDelegate) base class which implements common application delegate methods and add supports for a loading indicator bound to [BMService](BMService) invocations through [BMServiceManager](BMServiceManager)

[Here](BMUICoreClassesOverview) is a full list of all classes with a short description of their purpose.

The [BMUICore](BMUICore) module depends on [BMCore](BMCore) and the frameworks listed as dependencies there. Additionally the following frameworks have to be linked:

- CoreMedia.framework
- AVFoundation.framework
- QuartzCore.framework


BMThree20
----------

A fork of the Three20 library with a subset of classes needed for the BMMedia library. 
This dependency is deprecated and may be removed in the future.

BMMedia
----------

A framework for displaying, selecting, loading and storing different kind of media (video, picture, audio):

- Service to get direct streaming information for YouTube videos: [BMGetYouTubeStreamInfoService](BMGetYouTubeStreamInfoService)
- Horizontally scrolling media thumbnail roll with support for snap and infinite scrolling: [BMMediaRollController](BMMediaRollController)
- Full screen media browser with support for editing captions and more: [BMFullScreenMediaBrowserViewController](BMFullScreenMediaBrowserViewController)
- Multi-selection capable media picker for selecting items from the Asset library: [BMMediaLibraryPickerController](BMFullScreenMediaBrowserViewController)
- Custom camera: [BMCameraController](BMCameraController)
- View to display web-base or native videos: [BMEmbeddedVideoView](BMEmbeddedVideoView)
- A thumbnail view with automatic overlay depending on the kind of media it displays: [BMMediaThumbnailView](BMMediaThumbnailView)
- BMMediaContainer model hierarchy for media objects with implementations such as [BMMediaItem](BMVideo), [BMVideo](BMVideo), [BMPicture](BMPicture) and [BMAudio](BMAudio).
- A persistent storage implementation based on [BMURLCache](BMURLCache) for storing media data: [BMURLCacheMediaStorage](BMURLCacheMediaStorage).
- An asynchronous loader for loading media data from a remote source: [BMAsyncMediaContainerLoader](BMAsyncMediaContainerLoader).
- A view controller for displaying thumbnails in a grid view: [BMThumbnailsViewController](BMThumbnailsViewController).
- Operation for saving/rescaling media in the background: [BMMediaSaveOperation](BMMediaSaveOperation), [BMPictureSaveOperation](BMPictureSaveOperation), [BMVideoSaveOperation](BMVideoSaveOperation).

[Here](BMMediaClassesOverview) is a full list of all classes with a short description of their purpose.

The [BMMedia](BMMedia) module depends on [BMThree20](BMThree20), [BMUICore](BMUICore) and [BMCore](BMCore) including the frameworks listed  as dependencies there. Additionally the following frameworks have to be linked:

- CoreLocation.framework
- MediaPlayer.framework
- AVFoundation.framework
- AssetsLibrary.framework


BMGoogle
----------

Module with support for authentication with Google. The module contains the following:

- Base [BMService](BMService) implementation for interacting with Google via GData: [BMGoogleService](BMGoogleService)
- Google authentication via OAuth: [BMGoogleAuthenticationController](BMGoogleAuthenticationController).

[Here](BMGoogleClassesOverview) is a full list of all classes with a short description of their purpose.

The [BMGoogle](BMGoogle) module depends on [BMCore](BMCore) library including the frameworks listed as dependencies there. Additionally this module requires the [GData iOS library](https://code.google.com/p/gdata-objectivec-client/) for accessing the Google API. 


BMYouTube
----------

Module with functionality to interact with the YouTube API:

- Various [BMService](BMService) implementations for interacting with the YouTube API, such as BMYouTubeService (base class), BMYouTubeUploadService, BMYouTubeListUserVideosService and BMYouTubeGetUserProfileService.
- NSValueTransformer implementations for converting GData model classes back and forth to BMMediaContainer model classes as included in the BMMedia framework.
- An implementation of BMMediaPickerController for selecting videos from a user's YouTube account: BMYouTubePickerController.
- A tableview controller for listing YouTube videos: BMYouTubeVideoListController.

[Here](BMYouTubeClassesOverview) is a full list of all classes with a short description of their purpose.

The [BMYouTube](BMYouTube) module depends on [BMMedia](BMMedia) and [BMGoogle](BMGoogle) libraries including the frameworks listed as dependencies there. 

BMUIExtensions
----------

Module with custom UIViews, UIViewControllers and related classes:

- BMPagedView for a paged view (functionality like the iOS home screen) with a similar API to UITableView.
- BMWebDialog for HTML based dialogs/alerts
- BMValidatingTextField, a UITextField with validation support
- Various BMTableViewCell classes such as BMDatePickerCell, BMImageViewCell, BMSliderCell, BMTextViewCell, BMTextFieldCell, BMSwitchCell, BMTimePickerCeell, BMValuePickerCell.
- BMAlphabeticListTableViewController for a table view in the style used by the contacts app (with a search bar and an alphabetical index).
- BMMultiSwitchViewController: a container view controller for switching between different view controllers with custom animations.
- BMInfoWebViewController for displaying web based information.
- Value selection view controllers, such as BMMultiSelectionViewController, BMDateSelectionViewController, BMEnumeratedValueSelectionViewController, BMTimeSelectionViewController.
- BMMailComposeController for instantiating an E-mail compose view controller.

[Here](BMUIExtensionsClassesOverview) is a full list of all classes with a short description of their purpose.

This module depends on [BMUICore](BMUICore) and all the dependencies listed there.

BMXML
----------

Module with Apple classes for interacting with XML Documents like: BMXMLDocument, BMXMLElement, BMXMLNode, BMXMLReader, BMXMLReaderSAX and BMXPathQuery.

[Here](BMXMLClassesOverview) is a full list of all classes with a short description of their purpose.

This module depends on the following frameworks:

- libxml2.dylib

BMRestKit
----------

Module with a full fledged framework for parsing either XML or JSON data in a streaming fashion and a framework for mapping this data to objects.
It also features automatic generation of client-side classes for REST/SOAP web service using a XSD or WSDL as source and is transparent to the transport used (either XML or JSON).
The module contains the following functionality:

- [BMParser](BMParser) with implementations [BMJSONParser](BMJSONParser) and [BMXMLParser](BMXMLParser) for a streaming SAX style parsing of either JSON or XML data.
- [BMParserHandler](BMParserHandler): base class for parsing data in SAX style.
- [BMObjectMappingParserHandler](BMObjectMappingParserHandler): class for mapping data to [BMMappableObject](BMMappableObject) implementations.
- [BMObjectMappingParserService](BMObjectMappingParserService): [BMService](BMService) implementation for parsing XML/JSON data (multi-threaded) and mapping it to [BMMappableObject](BMMappableObject) instances.
- [BMMappableObjectGenerator](BMMappableObjectGenerator): generator for generating pre-configured [BMMappable](BMMappable) object instances from an XSD or WSDL.
- [BMMappableObjectXMLSerializer](BMMappableObjectXMLSerializer) and [BMMappableObjectJSONSerializer](BMMappableObjectJSONSerializer) for converting objects back and forth to XML or JSON.

[Here](BMRestKitClassesOverview) is a full list of all classes with a short description of their purpose.

This module depends on [BMCore](BMCore), [BMXML](BMXML) and all the frameworks listed there. Additionally it has dependencies on:

- [YAJL](https://github.com/lloyd/yajl)
- CoreData.framework (needed for merging with core data objects)

BMCoreData
----------

Module with helper classes for use of CoreData as persistent storage:

- BMCoreDataStack: central registry for NSManagedObjectContext and NSManagedObjectModel which is aware of multi-threaded code. It also supports automatic version migration.
- BMCoreDataOperation: an NSOperation to perform CoreData operations in the background.
- BMCoreDataModelDescriptor, BMCoreDataStoreDescriptor and BMCoreDataStoreCollectionDescriptor: descriptors to manage and migrate complex hierarchies of CoreData models/storage files.
- BMCoreDataErrorHelper: helper methods for many common operations such as fetch requests, recursing through object graphs, etc.
- BMFetchedResultsTableViewController: a base class for tableview controllers that represent core data entities as cells.

[Here](BMCoreDataClassesOverview) is a full list of all classes with a short description of their purpose.

This module depends on [BMCore](BMCore) and [BMUICore](BMUICore) and all frameworks listed there. Additionally it has dependencies on:

- CoreData.framework

BMLocation
----------

Module with location/maps helper classes:

- BMMapsHelper: helper classes for maps/locations
- BMReverseGeocoder: better reverse geocoder implementation based on Google's API which also supports queuing and caching to prevent overload of the API.

[Here](BMLocationClassesOverview) is a full list of all classes with a short description of their purpose.

This module depends on [BMCore](BMCore) and [BMUICore](BMUICore) and all frameworks listed there. Additionally it has dependencies on:

- MapKit.framework
- [SBJSON](http://superloopy.io/json-framework)

