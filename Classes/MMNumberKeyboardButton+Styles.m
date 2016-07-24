//
//  MMNumberKeyboardButton+Styles.m
//  Demo
//
//  Created by Maksym Prokopchuk on 7/25/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMNumberKeyboardButton+Styles.h"

// buttons fonts
static const CGFloat kDoneButtonFontSize      = 17.0;
static const CGFloat kNumberButtonFontSize    = 28.0;
static NSString * const kNumberButtonFontName = @"HelveticaNeue-Light";

@implementation MMNumberKeyboardButton (Styles)

+ (instancetype)mmn_keyboardButtonDecimalNumberWithTitle:(NSString *)title font:(UIFont *)font target:(id)target action:(SEL)action {
    MMNumberKeyboardButton *button = [MMNumberKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleWhite
                                                                               title:title
                                                                                font:font];
    if (target && action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

+ (NSDictionary <NSNumber *, MMNumberKeyboardButton *> *)mmn_keyboadButtonWithDecimalNumbersStartFrom:(NSInteger)numberMin to:(NSInteger)numberMax target:(id)target action:(SEL)action {
    UIFont *buttonFont = nil;
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        buttonFont = [UIFont systemFontOfSize:kNumberButtonFontSize weight:UIFontWeightLight];
    }
    else {
        buttonFont = [UIFont fontWithName:kNumberButtonFontName size:kNumberButtonFontSize];
    }
    
    NSMutableDictionary <NSNumber *, MMNumberKeyboardButton *> *buttonDictionary = [NSMutableDictionary dictionary];
    
    for (MMNumberKeyboardButtonType key = numberMin; key < numberMax; key++) {
        NSString *title = [@(key - numberMin) stringValue];
        MMNumberKeyboardButton *button = [MMNumberKeyboardButton mmn_keyboardButtonDecimalNumberWithTitle:title font:buttonFont target:target action:action];
        [buttonDictionary setObject:button forKey:@(key)];
    }
    return [buttonDictionary copy];
}

+ (MMNumberKeyboardButton *)mmn_keyboardButtonDoneWithTitle:(NSString *)title {
    UIFont *font = [UIFont systemFontOfSize:kDoneButtonFontSize];
    MMNumberKeyboardButton *doneButton = [MMNumberKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleDone
                                                                                   title:title
                                                                                    font:font];
    return doneButton;
}

+ (MMNumberKeyboardButton *)mmn_keyboardButtonBackspaceWithImage:(UIImage *)image target:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval {
    MMNumberKeyboardButton *backspaceButton = [MMNumberKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleGray];
    [backspaceButton setImage:image forState:UIControlStateNormal];
    
    [backspaceButton addTarget:target action:action forContinuousPressWithTimeInterval:timeInterval];
    return backspaceButton;
}

+ (MMNumberKeyboardButton *)mmn_keyboardButtonDecimalPointWithLocale:(NSLocale *)locale {
    MMNumberKeyboardButton *decimalPointButton = [MMNumberKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleWhite];
    
    NSString *decimalSeparator = [locale objectForKey:NSLocaleDecimalSeparator];
    NSString *title = decimalSeparator ?: @".";
    [decimalPointButton setTitle:title forState:UIControlStateNormal];
    return decimalPointButton;
}

@end
