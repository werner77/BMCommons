//
//  BMMailComposeController.h
//  BMCommons
//
//  Created by Werner Altewischer on 29/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Controller for showing the mail composer view controller in a generic way (adds backward compatibility with iOS 3 and the ability to insert images as attachments).
 */
@interface BMMailComposeController : NSObject

@property (nullable, nonatomic, strong) NSString *subject;
@property (nullable, nonatomic, strong) NSArray *toRecipients;
@property (nullable, nonatomic, strong) NSArray *ccRecipients;
@property (nullable, nonatomic, strong) NSArray *bccRecipients;
@property (nullable, nonatomic, strong) NSString *messageBody;
@property (nullable, nonatomic, strong) UIColor *navigationBarColor;

/**
 Whether HTML mail should be used or not.
 */
@property (nonatomic, assign) BOOL htmlMessage;

//This class is intended to be retained by the view controller, to avoid a retain loop this property is non-retaining
@property (nullable, nonatomic, weak) UIViewController *viewController;

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

NS_ASSUME_NONNULL_END

