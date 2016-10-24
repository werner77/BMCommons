//
//  BMClickableTableViewCell.m
//  BehindMedia
//
//  Created by Werner Altewischer on 27/10/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTableViewCell.h>
#import <BMCommons/BMUICore.h>

@implementation BMTableViewCell {
	BOOL clickEnabled;
	NSObject *__weak target;
	SEL selector;
	UITableViewCellSelectionStyle enabledSelectionStyle;
	UITableViewCellSelectionStyle disabledSelectionStyle;
	NSString *customReuseIdentifier;
}

@synthesize target, selector, enabledSelectionStyle, disabledSelectionStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		self.enabledSelectionStyle = BMSTYLEVAR(tableViewCellSelectionStyle);
		self.disabledSelectionStyle = UITableViewCellSelectionStyleNone;
        self.clickEnabled = YES;
        
        UIColor *c = BMSTYLEVAR(tableViewCellTextColor);
        if (c) {
            self.textLabel.textColor = c;
        }
        UIFont *f = BMSTYLEVAR(tableViewCellTextFont);
        if (f) {
            self.textLabel.font = f;
        }
        c = BMSTYLEVAR(tableViewCellDetailTextColor);
        if (c) {
            self.detailTextLabel.textColor = c;
        }
        f = BMSTYLEVAR(tableViewCellDetailTextFont);
        if (f) {
            self.detailTextLabel.font = f;
        }        
	}
	return self;
}

- (id)init {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {

		self.enabledSelectionStyle = self.selectionStyle;
		self.disabledSelectionStyle = UITableViewCellSelectionStyleNone;
        self.clickEnabled = YES;
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(customReuseIdentifier);
}

- (void)onClick {
	if (self.clickEnabled && self.target && self.selector) {
		BM_IGNORE_SELECTOR_LEAK_WARNING(
		[self.target performSelector:self.selector withObject:self];
		)
	}
}

- (BOOL)clickEnabled {
	return clickEnabled;
}

- (void)setClickEnabled:(BOOL)enabled {
	clickEnabled = enabled;
	if (!enabled) {
		self.selectionStyle = self.disabledSelectionStyle;
	} else {
		self.selectionStyle = self.enabledSelectionStyle;
	}
}

- (void)setReuseIdentifier:(NSString *)identifier  {
	if (identifier != customReuseIdentifier) {
		customReuseIdentifier = identifier;
	}
}

- (NSString *)reuseIdentifier {
	if (customReuseIdentifier) {
		return customReuseIdentifier;
	} else {
		return [super reuseIdentifier];
	}
}


@end
