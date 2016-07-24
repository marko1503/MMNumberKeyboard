//
//  MMNumberKeyboardButton.h
//  Demo
//
//  Created by Maksym Prokopchuk on 7/24/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Specifies the style of a keyboard button.
 */
typedef NS_ENUM(NSUInteger, MMNumberKeyboardButtonStyle) {
    /**
     *  A white style button, such as those for the number keys.
     */
    MMNumberKeyboardButtonStyleWhite,
    
    /**
     *  A gray style button, such as the backspace key.
     */
    MMNumberKeyboardButtonStyleGray,
    
    /**
     *  A done style button, for example, a button that completes some task and returns to the previous view.
     */
    MMNumberKeyboardButtonStyleDone
};

typedef NS_ENUM(NSUInteger, MMNumberKeyboardButtonType) {
    MMNumberKeyboardButtonTypeNumberMin,
    MMNumberKeyboardButtonTypeNumberMax = MMNumberKeyboardButtonTypeNumberMin + 10, // Ten digits.
    MMNumberKeyboardButtonTypeBackspace,
    MMNumberKeyboardButtonTypeDone,
    MMNumberKeyboardButtonTypeSpecial,
    MMNumberKeyboardButtonTypeDecimalPoint,
    MMNumberKeyboardButtonTypeNone = NSNotFound,
};


@interface MMNumberKeyboardButton : UIButton

+ (instancetype)keyboardButtonWithStyle:(MMNumberKeyboardButtonStyle)style;
+ (instancetype)keyboardButtonWithStyle:(MMNumberKeyboardButtonStyle)style title:(NSString *)title font:(UIFont *)font;

// The style of the keyboard button.
@property (nonatomic, assign) MMNumberKeyboardButtonStyle style;

@property (nonatomic, assign, readonly) MMNumberKeyboardButtonType type;

// Notes the continuous press time interval, then adds the target/action to the UIControlEventValueChanged event.
- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval;

@end
