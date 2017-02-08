//
//  MMNumberKeyboardButton.m
//  Demo
//
//  Created by Maksym Prokopchuk on 7/24/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMNumberKeyboardButton.h"

@interface MMNumberKeyboardButton ()

//@property (nonatomic, assign, readwrite) MMNumberKeyboardButtonStyle style;

@property (nonatomic, assign, readwrite) MMNumberKeyboardButtonType type;

@property (strong, nonatomic) NSTimer *continuousPressTimer;
@property (assign, nonatomic) NSTimeInterval continuousPressTimeInterval;

@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *highlightedFillColor;

@property (strong, nonatomic) UIColor *controlColor;
@property (strong, nonatomic) UIColor *highlightedControlColor;

@end

@implementation MMNumberKeyboardButton

- (void)dealloc {
    [self _cancelContinousPressIfNeeded];
}


+ (instancetype)keyboardButtonWithStyle:(MMNumberKeyboardButtonStyle)style {
    MMNumberKeyboardButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.style = style;
    
    return button;
}

+ (instancetype)keyboardButtonWithStyle:(MMNumberKeyboardButtonStyle)style title:(NSString *)title font:(UIFont *)font {
    MMNumberKeyboardButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.style = style;
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    
    return button;
}


#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _buttonStyleDidChange];
    }
    return self;
}

- (void)setStyle:(MMNumberKeyboardButtonStyle)style {
    if (style != _style) {
        _style = style;
        
        [self _buttonStyleDidChange];
    }
}

- (void)_buttonStyleDidChange {
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const MMNumberKeyboardButtonStyle style = self.style;
    
    UIColor *fillColor = nil;
    UIColor *highlightedFillColor = nil;
    if (style == MMNumberKeyboardButtonStyleWhite) {
        fillColor = [UIColor whiteColor];
        highlightedFillColor = [UIColor colorWithRed:0.82f green:0.837f blue:0.863f alpha:1];
    }
    else if (style == MMNumberKeyboardButtonStyleGray) {
        if (interfaceIdiom == UIUserInterfaceIdiomPad) {
            fillColor =  [UIColor colorWithRed:0.674f green:0.7f blue:0.744f alpha:1];
        }
        else {
            fillColor = [UIColor colorWithRed:0.81f green:0.837f blue:0.86f alpha:1];
        }
        highlightedFillColor = [UIColor whiteColor];
    }
    else if (style == MMNumberKeyboardButtonStyleDone) {
        fillColor = [UIColor colorWithRed:0 green:0.479f blue:1 alpha:1];
        highlightedFillColor = [UIColor whiteColor];
    }
    
    UIColor *controlColor = nil;
    UIColor *highlightedControlColor = nil;
    if (style == MMNumberKeyboardButtonStyleDone) {
        controlColor = [UIColor whiteColor];
        highlightedControlColor = [UIColor blackColor];
    }
    else {
        controlColor = [UIColor blackColor];
        highlightedControlColor = [UIColor blackColor];
    }
    
    [self setTitleColor:controlColor forState:UIControlStateNormal];
    [self setTitleColor:highlightedControlColor forState:UIControlStateSelected];
    [self setTitleColor:highlightedControlColor forState:UIControlStateHighlighted];
    
    self.fillColor = fillColor;
    self.highlightedFillColor = highlightedFillColor;
    self.controlColor = controlColor;
    self.highlightedControlColor = highlightedControlColor;
    
    if (interfaceIdiom == UIUserInterfaceIdiomPad) {
        CALayer *buttonLayer = [self layer];
        buttonLayer.cornerRadius = 4.0f;
        buttonLayer.shadowColor = [UIColor colorWithRed:0.533f green:0.541f blue:0.556f alpha:1].CGColor;
        buttonLayer.shadowOffset = CGSizeMake(0, 1.0f);
        buttonLayer.shadowOpacity = 1.0f;
        buttonLayer.shadowRadius = 0.0f;

        [self _updateButtonAppearance];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self _updateButtonAppearance];
    }
}

- (void)_updateButtonAppearance {
    if (self.isHighlighted || self.isSelected) {
        self.backgroundColor = self.highlightedFillColor;
        self.imageView.tintColor = self.controlColor;
    } else {
        self.backgroundColor = self.fillColor;
        self.imageView.tintColor = self.highlightedControlColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self _updateButtonAppearance];
}

#pragma mark - Continuous press.

- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval {
    self.continuousPressTimeInterval = timeInterval;
    
    [self addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL begins = [super beginTrackingWithTouch:touch withEvent:event];
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (begins && continuousPressTimeInterval > 0) {
        [self _beginContinuousPressDelayed];
    }
    
    return begins;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    [self _cancelContinousPressIfNeeded];
}

- (void)_beginContinuousPress {
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (!self.isTracking || continuousPressTimeInterval == 0) {
        return;
    }
    
    self.continuousPressTimer = [NSTimer scheduledTimerWithTimeInterval:continuousPressTimeInterval target:self selector:@selector(_handleContinuousPressTimer:) userInfo:nil repeats:YES];
}

- (void)_handleContinuousPressTimer:(NSTimer *)timer {
    if (!self.isTracking) {
        [self _cancelContinousPressIfNeeded];
        return;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_beginContinuousPressDelayed {
    [self performSelector:@selector(_beginContinuousPress) withObject:nil afterDelay:self.continuousPressTimeInterval * 2.0f];
}

- (void)_cancelContinousPressIfNeeded {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_beginContinuousPress) object:nil];
    
    NSTimer *timer = self.continuousPressTimer;
    if (timer) {
        [timer invalidate];
        
        self.continuousPressTimer = nil;
    }
}

@end
