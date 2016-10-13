//
//  BMMailComposeController.m
//  BMCommons
//
//  Created by Werner Altewischer on 29/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#if BM_MAIL_ENABLED

#import "BMMailComposeController.h"
#import "BMDialogHelper.h"
#import "BMBusyView.h"
#import <BMCommons/BMCore.h>
#import <BMCommons/BMStringHelper.h>

@interface BMMailComposeController(Private)

- (void)displayComposerSheetWithImage:(UIImage *)imageAttachment;
- (void)launchMailApp;	
- (void)tryLaunchMailApp;

@end


@implementation BMMailComposeController

@synthesize subject, toRecipients, ccRecipients, bccRecipients, messageBody, viewController, htmlMessage, mailComposer;
@synthesize navigationBarColor;

- (id)initWithViewController:(UIViewController *)theViewController {
	if ((self = [super init])) {
		self.viewController = theViewController;
        self.navigationBarColor = self.viewController.navigationController.navigationBar.tintColor;
	}
	return self;
}

- (void)dealloc {
    mailComposer.delegate = nil;
    imagePicker.delegate = nil;

    [mailComposer dismissViewControllerAnimated:NO completion:nil];
	[imagePicker dismissViewControllerAnimated:NO completion:nil];
	
	BM_RELEASE_SAFELY(mailComposer);
	BM_RELEASE_SAFELY(imagePicker);
	
	self.viewController = nil;
}

- (void)composeMail {
	if (!mailComposer && !imagePicker) {
		Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
		if (mailClass != nil && [mailClass canSendMail]) {
			[self displayComposerSheetWithImage:nil];
		} else {
			[self tryLaunchMailApp];
		}
	}
}

- (void)composeMailWithImage { 
	if (!mailComposer && !imagePicker) {
		Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
		if (mailClass != nil && [mailClass canSendMail]) {
			imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.delegate = self;
			[self.viewController presentViewController:imagePicker animated:YES completion:nil];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] init];
			alert.title = @"Sorry";
			alert.message = @"This function can not be performed at this time";
			[alert show];
		}
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate implementation


// Dismisses the email composition interface when users tap Cancel or Send. 
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {    
    mailComposer.delegate = nil;
	BM_RELEASE_SAFELY(mailComposer);
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
	
	imagePicker.delegate = nil;
	BM_RELEASE_SAFELY(imagePicker);
	
	UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [BMBusyView showBusyView];
    
	[self performSelector:@selector(displayComposerSheetWithImage:) withObject:image afterDelay:0.5];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	imagePicker.delegate = nil;
	BM_RELEASE_SAFELY(imagePicker);
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self launchMailApp];
	}
}

@end

@implementation BMMailComposeController(Private)

-(void)displayComposerSheetWithImage:(UIImage *)imageAttachment {
	if (!mailComposer) {
		mailComposer = [[MFMailComposeViewController alloc] init];
		if (self.navigationBarColor) {
			mailComposer.navigationBar.tintColor = self.navigationBarColor;
		}
        //mailComposer.navigationBar.barStyle = self.navigationBarStyle;
        mailComposer.mailComposeDelegate = self;
		[mailComposer setSubject:self.subject];    
		[mailComposer setToRecipients:self.toRecipients];
		[mailComposer setCcRecipients:self.ccRecipients];    
		[mailComposer setBccRecipients:self.bccRecipients];
		
		if (imageAttachment) {
			NSData *imageData = UIImageJPEGRepresentation(imageAttachment, 0.8);
			[mailComposer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"image.jpg"];
		}
		
		[mailComposer setMessageBody:self.messageBody isHTML:self.htmlMessage];
		
        [self.viewController presentViewController:mailComposer animated:YES completion:nil];
	}
    [BMBusyView hideBusyView];
}

- (NSString *)csvString:(NSArray*)mailArray {
    NSMutableString *s = [NSMutableString string];
    BOOL first = YES;
    for (id object in mailArray) {
        if (first) {
            [s appendString:@","];
            first = NO;
        }
        [s appendString:[object description]];
    }
    return s;
}

- (void)tryLaunchMailApp {
	
	UIViewController *vc = self.viewController;
	UITabBarController *tc = nil;
	
	while (vc != nil) {
		if ([vc isKindOfClass:[UITabBarController class]]) {
			tc = (UITabBarController *)vc;
			break;
		}
		vc = vc.parentViewController;
	}
	
	UIView *v = tc ? tc.view : self.viewController.view;
	[BMDialogHelper dialogYesNoWithTitle:BMLocalizedString(@"txtExitToMail", nil) 
							   withDelegate:self 
								   withView:v];
}

// Launches the Mail application on the device.
-(void)launchMailApp {
    NSString *urlString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", 
						   [[self csvString:toRecipients] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
						   [self.subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
						   [self.messageBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

@end

#endif
