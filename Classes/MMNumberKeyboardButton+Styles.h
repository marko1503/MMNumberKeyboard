//
//  MMNumberKeyboardButton+Styles.h
//  Demo
//
//  Created by Maksym Prokopchuk on 7/25/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMNumberKeyboardButton.h"

@interface MMNumberKeyboardButton (Styles)

+ (instancetype)mmn_keyboardButtonDecimalNumberWithTitle:(NSString *)title font:(UIFont *)font target:(id)target action:(SEL)action;

+ (NSDictionary <NSNumber *, MMNumberKeyboardButton *> *)mmn_keyboadButtonWithDecimalNumbersStartFrom:(NSInteger)numberMin to:(NSInteger)numberMax target:(id)target action:(SEL)action;

+ (MMNumberKeyboardButton *)mmn_keyboardButtonDoneWithTitle:(NSString *)title;

+ (MMNumberKeyboardButton *)mmn_keyboardButtonBackspaceWithImage:(UIImage *)image target:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval;

+ (MMNumberKeyboardButton *)mmn_keyboardButtonDecimalPointWithLocale:(NSLocale *)locale;

@end
