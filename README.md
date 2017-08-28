# BMCommons

[![CI Status](http://img.shields.io/travis/werner77/BMCommons.svg?style=flat)](https://travis-ci.org/werner77/BMCommons)
[![Version](https://img.shields.io/cocoapods/v/BMCommons.svg?style=flat)](http://cocoapods.org/pods/BMCommons)
[![License](https://img.shields.io/cocoapods/l/BMCommons.svg?style=flat)](http://cocoapods.org/pods/BMCommons)
[![Platform](https://img.shields.io/cocoapods/p/BMCommons.svg?style=flat)](http://cocoapods.org/pods/BMCommons)

The BMCommons framework is a framework for developing iOS applications as developed by Werner Altewischer for Behind Media.
It is a general purpose framework consisting of multiple sub modules.

## Modules

### BMCore

A module with core functionality that can be used for both MacOSX and iOS applications. It contains:

- A lot of helper classes for different things such as BMApplicationHelper, BMErrorHelper, BMSecurityHelper, BMEncodingHelper, BMEncryptionHelper, BMErrorHelper, BMStringHelper, BMDateHelper and more;
- Extensions of Foundation classes such as BMTwoWayDictionary and BMOrderedDictionary
- Categories on Foundation classes such as NSString(BMCommons)), NSDateFormatter(BMCommons)), NSNumber(BMCommons)), NSData(Encryption)), NSData(Compression)), NSArray(BMCommons)) and more;
- A streaming networking library with among other classes BMHTTPRequest, BMURLCache and BMAsyncDataLoader;
- Proxy support via BMProxy and BMImmutableProxy;
- The core classes of the BMService framework such as BMServiceManager, BMAbstractService, BMHTTPService and BMCompositeService;
- Base input stream classes such as BMAbstractInputStream, BMBufferedInputStream, BMURLConnectionInputStream and BMHTTPMultiPartBodyInputStream;
- Caching through BMCache and BMURLCache;
- An extension of NSOperationQueue for multi-threading through BMOperationQueue;
- Extended localization support through BMLocalization (allowing in-app locale changes)
- BMApplicationContext class acting as a registry for singleton objects and initialization point for the application.
- BMSettingsRegistry, BMSettingsObject and BMAbstractSettingsObject for managing application settings.

### BMUICore

A module with core functionality for iOS applications, dependent on BMCore. It contains:

- UIViewController base classes, such as BMViewController, BMTableViewController and BMNavigationController offering drag to refresh, drag to load more and custom push animations amongst other things;
- UIViewController classes which use the BMService framework to asynchronously load their model, such as BMServiceModelTableViewController and BMEntityServiceModelTableViewController;
- Helper classes such as BMImageHelper, BMDialogHelper and BMDeviceHelper;
- Base classes for UITableViewCells, such as BMTableViewCell and BMObjectPropertyTableViewCell;
- Asynchronous image loading support through BMAsyncImageLoader;
- UIView/UIControl classes such as BMTextField, BMAnimatedImageView, BMAsyncLoadingImageButton, BMDraggableButton, BMBarButtonItem;
- Stylesheet support for view controllers through BMStyleSheet
- Loading indicator support through BMBusyView
- Categories on commons classes such as UIWebView(BMCommons)), UIView(BMCommons)), UINavigationBar(BMCommons)) and more;
- BMAppDelegate base class which implements common application delegate methods and add supports for a loading indicator bound to BMService invocations through BMServiceManager

### BMUIExtensions

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

Here is a full list of all classes with a short description of their purpose.

This module depends on BMUICore.

### BMXML

Module with classes for interacting with XML Documents like: BMXMLDocument, BMXMLElement, BMXMLNode, BMXMLReader, BMXMLReaderSAX and BMXPathQuery.

### BMRestKit

Module with a full fledged framework for parsing either XML or JSON data in a streaming fashion and a framework for mapping this data to objects.
It also features automatic generation of client-side classes for REST/SOAP web service using a XSD or WSDL as source and is transparent to the transport used (either XML or JSON).
The module contains the following functionality:

- BMParser with implementations BMJSONParser and BMXMLParser for a streaming SAX style parsing of either JSON or XML data.
- BMParserHandler: base class for parsing data in SAX style.
- BMObjectMappingParserHandler: class for mapping data to BMMappableObject implementations.
- BMObjectMappingParserService: BMService implementation for parsing XML/JSON data (multi-threaded) and mapping it to BMMappableObject instances.
- BMMappableObjectGenerator: generator for generating pre-configured BMMappable object instances from an XSD or WSDL.
- BMMappableObjectXMLSerializer and BMMappableObjectJSONSerializer for converting objects back and forth to XML or JSON.

Here is a full list of all classes with a short description of their purpose.

This module depends on BMCore and BMXML. Additionally it has dependencies on:

- YAJL

### BMCoreData

Module with helper classes for use of CoreData as persistent storage:

- BMCoreDataStack: central registry for NSManagedObjectContext and NSManagedObjectModel which is aware of multi-threaded code. It also supports automatic version migration.
- BMCoreDataOperation: an NSOperation to perform CoreData operations in the background.
- BMCoreDataModelDescriptor, BMCoreDataStoreDescriptor and BMCoreDataStoreCollectionDescriptor: descriptors to manage and migrate complex hierarchies of CoreData models/storage files.
- BMCoreDataErrorHelper: helper methods for many common operations such as fetch requests, recursing through object graphs, etc.
- BMFetchedResultsTableViewController: a base class for tableview controllers that represent core data entities as cells.

Here is a full list of all classes with a short description of their purpose.

This module depends on BMCore and BMUICore.

## API version

Be advised that not all APIs can be considered final and may be subject to change.
That's why the BMCommons framework is still in the 0.x version territory. 
This is not to say that the software is instable as it is and has been used by many production apps in the app store by the author.
 
The most mature sub modules in terms of API and documentation are BMCore, BMXML and BMRestKit. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BMCommons is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BMCommons/<sub module>"
```

where sub module is one of the following:

- BMCore
- BMUICore
- BMXML
- BMRestKit
- BMCoreData
- BMUIExtensions

## Author

Werner Altewischer

## License

BMCommons is available under the MIT license. See the LICENSE file for more info.
