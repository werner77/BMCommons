//
//  BMSwitch.m
//  BMCommons
//
//  Created by Werner Altewischer on 05/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMSwitch.h"

#define SWITCH_DISPLAY_WIDTH		94.0
#define SWITCH_WIDTH				149.0
#define SWITCH_HEIGHT				27.0

#define RECT_FOR_OFF		CGRectMake(-55.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)
#define RECT_FOR_ON			CGRectMake(0.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)
#define RECT_FOR_HALFWAY	CGRectMake(-27.5, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)

#define SWITCH_ON_IMAGE @"BMUICore.bundle/switch_on.png"
#define SWITCH_OFF_IMAGE @"BMUICore.bundle/switch_off.png"
#define FOREGROUND_IMAGE @"BMUICore.bundle/switch_fg.png"

#define LABEL_MARGIN 20.0

@interface BMSwitch ()
@property (nonatomic, strong, readwrite) UIImageView* backgroundImage;
@property (nonatomic, strong, readwrite) UIImageView* switchImage;
- (void)setupUserInterface;
- (void)toggle;
- (void)animateSwitch:(BOOL)toOn;
- (void)setOnLabel:(UILabel *)theLabel;
- (void)setOffLabel:(UILabel *)theLabel;
@end


@implementation BMSwitch
@synthesize backgroundImage = _backgroundImage;
@synthesize switchImage = _switchImage;
@synthesize offLabel = _offLabel;
@synthesize onLabel = _onLabel;

/**
 * Destructor
 */

- (void)commonInit {
    _on = NO;
    _hitCount = 0;
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.autoresizesSubviews = NO;
    self.autoresizingMask = 0;
    self.opaque = YES;
    
    [self setupUserInterface];
    self.switchImage.frame = RECT_FOR_OFF;
    self.backgroundImage.image = [UIImage imageNamed:SWITCH_OFF_IMAGE];
    self.onLabel.text = @"ON";
    self.offLabel.text = @"OFF";
}

/** 
 * Constructor
 */
- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, SWITCH_DISPLAY_WIDTH, SWITCH_HEIGHT)]) 
	{
		[self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

/**
 * Setup the user interface
 */
- (void)setupUserInterface
{
	// Background image
	UIImageView* bg = [[UIImageView alloc] initWithFrame:RECT_FOR_ON];
	bg.image = [UIImage imageNamed:SWITCH_ON_IMAGE];
	bg.backgroundColor = [UIColor clearColor];
	bg.contentMode = UIViewContentModeLeft;
	self.backgroundImage = bg;
	
	// Switch image
	UIImageView* foreground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)];
	foreground.image = [UIImage imageNamed:FOREGROUND_IMAGE];
	foreground.contentMode = UIViewContentModeLeft;
	
	self.onLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,SWITCH_WIDTH/2-LABEL_MARGIN,SWITCH_HEIGHT)];
	self.onLabel.font = [UIFont boldSystemFontOfSize:16];
	self.onLabel.textAlignment = NSTextAlignmentCenter;
	self.onLabel.textColor = [UIColor whiteColor];
	self.onLabel.backgroundColor = [UIColor clearColor];
	
	[foreground addSubview:self.onLabel];
	
	self.offLabel = [[UILabel alloc] initWithFrame:CGRectMake(SWITCH_WIDTH/2 + LABEL_MARGIN,0,SWITCH_WIDTH/2 - LABEL_MARGIN,SWITCH_HEIGHT)];
	self.offLabel.font = [UIFont boldSystemFontOfSize:16];
	self.offLabel.textAlignment = NSTextAlignmentCenter;
	self.offLabel.textColor = [UIColor grayColor];
	self.offLabel.backgroundColor = [UIColor clearColor];
	
	[foreground addSubview:self.offLabel];
	
	self.switchImage = foreground;

	// Check for user input
	[self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[self addSubview:self.backgroundImage];
	[self.backgroundImage addSubview:self.switchImage];
}

/**
 * Drawing Code
 */
- (void)drawRect:(CGRect)rect 
{
	// nothing
}

/**
 * Configure it into a certain state
 */
- (void)setOn:(BOOL)on animated:(BOOL)animated
{
	if (on != _on) {
		_on = on;
		
		if (animated) {
			[self animateSwitch:_on];
		} else {
			if (_on)
			{
				self.switchImage.frame = RECT_FOR_ON;
				self.backgroundImage.image = [UIImage imageNamed:SWITCH_ON_IMAGE];
			}
			else
			{
				self.switchImage.frame = RECT_FOR_OFF;
				self.backgroundImage.image = [UIImage imageNamed:SWITCH_OFF_IMAGE];
			}
		}
	}
}

- (void)setOn:(BOOL)on {
	[self setOn:on animated:NO];
}

/**
 * Check if on
 */
- (BOOL)isOn
{
	return _on;
}

/**
 * Capture user input
 */
- (void)buttonPressed:(id)target
{
	// We use a hit count to properly queue up multiple hits on the button while we are animating.
	if (_hitCount == 0)
	{
        [self becomeFirstResponder];
		_hitCount++;
		[self toggle];
	}
	else
	{
		_hitCount++;
		// Do not animate, this will happen when other animation finishes
	}
}

/**
 * Toggle ison
 */
- (void)toggle
{
	_on = !_on;
	[self animateSwitch:_on];
}

/**
 * Animate the switch by sliding halfway and then changing the background image and then sliding the rest of the way.
 */
- (void)animateSwitch:(BOOL)toOn
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];

	self.switchImage.frame = RECT_FOR_HALFWAY;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationHasFinished:finished:context:)];

	if (toOn)
	{
		self.switchImage.frame = RECT_FOR_ON;
		self.backgroundImage.image = [UIImage imageNamed:SWITCH_ON_IMAGE];
	}
	else
	{
		self.switchImage.frame = RECT_FOR_OFF;
		self.backgroundImage.image = [UIImage imageNamed:SWITCH_OFF_IMAGE];
	}
	[UIView commitAnimations];
	
	[UIView commitAnimations];
}

/**
 * Remove the view no longer visible
 */
- (void)animationHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	
	// We use a hit count to properly queue up multiple hits on the button while we are animating.
	if (_hitCount > 1)
	{
		_hitCount--;
		[self toggle];
	}
	else
	{
		_hitCount--;
	}
}

- (void)setOnLabel:(UILabel *)theLabel {
	if (_onLabel != theLabel) {
		_onLabel = theLabel;
	}
}

- (void)setOffLabel:(UILabel *)theLabel {
	if (_offLabel != theLabel) {
		_offLabel = theLabel;
	}
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


@end
