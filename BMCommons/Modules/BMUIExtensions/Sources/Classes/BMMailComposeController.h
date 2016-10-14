//
//  BMMailComposeController.h
//  BMCommons
//
//  Created by Werner Altewischer on 29/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#if BM_MAIL_ENABLED

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

/**
 Controller for showing the mail composer view controller in a generic way (adds backward compatibility with iOS 3 and the ability to insert images as attachments).
 */
@interface BMMailComposeController : NSObject<MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate,
						UINavigationControllerDelegate, UIActionSheetDelegate> {	
	NSString *subject;
	NSArray *toRecipients;
	NSArray *ccRecipients;
	NSArray *bccRecipients;
	NSString *messageBody;	
	BOOL htmlMessage;
	
	UIViewController *__weak viewController;
	
	UIImagePickerController *imagePicker;
	MFMailComposeViewController *mailComposer;
    UIColor *navigationBarColor;
}

@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSArray *toRecipients;
@property (nonatomic, strong) NSArray *ccRecipients;
@property (nonatomic, strong) NSArray *bccRecipients;
@property (nonatomic, strong) NSString *messageBody;	
@property (nonatomic, strong) UIColor *navigationBarColor;

/**
 Whether HTML mail should be used or not.
 */
@property (nonatomic, assign) BOOL htmlMessage;

@property (nonatomic, readonly) MFMailComposeViewController *mailComposer;

//This class is intended to be retained by the view controller, to avoid a retain loop this property is non-retaining
@property (nonatomic, weak) UIViewController *viewController;

/**
 Initializes with the specified parent view controller (view controller that should be used to present the mail composer/image picker from).
 */
- (id)initWithViewController:(UIViewController *)theViewController;

/**
 Compose a mail (shows the MailComposeViewContoller).
 */
- (void)composeMail;

/**
 Compose a mail by first picking an image and adding it as an attachment to the mail.
 */
- (void)composeMailWithImage;	

@end

#endif
