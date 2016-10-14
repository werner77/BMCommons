//
//  BMDraggableButton.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMDraggableButton.h>

@interface BMDraggableButton(Private)

- (CGFloat)distanceFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;
- (BMDraggableButtonState)determineCurrentState;
- (void)snap:(BOOL)animated;

@end

@implementation BMDraggableButton {
    CGRect slidingRange;
    
    CGPoint offset;
    
    BMDraggableButtonState buttonState;
}

@synthesize slidingRange, buttonState;

#pragma mark - Overridded touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self.superview];
    
    offset = CGPointMake(location.x - self.center.x, location.y - self.center.y);   
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self.superview];
    
    location = CGPointMake(location.x - offset.x, location.y - offset.y);
    
    location.x = MIN(location.x, CGRectGetMaxX(slidingRange));
    location.y = MIN(location.y, CGRectGetMaxY(slidingRange));
    location.x = MAX(location.x, CGRectGetMinX(slidingRange));
    location.y = MAX(location.y, CGRectGetMinY(slidingRange));
    
    self.center = location;
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    BMDraggableButtonState newState = [self determineCurrentState];
    
    if (newState != self.buttonState) {
        buttonState = newState;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    [self snap:NO];
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self snap:NO];
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
}

- (void)setButtonState:(BMDraggableButtonState)newState {
    [self setButtonState:newState animated:NO];
}

- (void)setButtonState:(BMDraggableButtonState)newState animated:(BOOL)animated {
    if (buttonState != newState) {
        buttonState = newState;
        [self snap:animated];
    }
}

@end

@implementation BMDraggableButton(Private)

- (CGFloat)distanceFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    return sqrtf((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
}

- (BMDraggableButtonState)determineCurrentState {
    CGFloat distanceToMin = [self distanceFromPoint:self.center toPoint:CGPointMake(CGRectGetMinX(slidingRange), CGRectGetMinY(slidingRange))];
    CGFloat distanceToMax = [self distanceFromPoint:self.center toPoint:CGPointMake(CGRectGetMaxX(slidingRange), CGRectGetMaxY(slidingRange))];
    
    if (distanceToMin < distanceToMax) {
        return BMDraggableButtonStateMin;
    } else {
        return BMDraggableButtonStateMax;
    }
}

- (void)snap:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"snap" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    if (self.buttonState == BMDraggableButtonStateMin) {
        self.center = CGPointMake(CGRectGetMinX(slidingRange), CGRectGetMinY(slidingRange));
    } else {
        self.center = CGPointMake(CGRectGetMaxX(slidingRange), CGRectGetMaxY(slidingRange));
    }
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)updateHighlightedState:(NSNumber *)n {
    [self setHighlighted:[n boolValue]];
}

@end

