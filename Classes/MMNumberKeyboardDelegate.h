//
//  MMNumberKeyboardDelegate.h
//  Demo
//
//  Created by Maksym Prokopchuk on 7/24/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMNumberKeyboard;

/**
 *  The @c MMNumberKeyboardDelegate protocol defines the messages sent to a delegate object as part of the sequence of editing text. All of the methods of this protocol are optional.
 */
@protocol MMNumberKeyboardDelegate <NSObject>

@optional

/**
 *  Asks whether the specified text should be inserted.
 *
 *  @param numberKeyboard The keyboard instance proposing the text insertion.
 *  @param text           The proposed text to be inserted.
 *
 *  @return Returns	@c YES if the text should be inserted or @c NO if it should not.
 */
- (BOOL)numberKeyboard:(MMNumberKeyboard *)numberKeyboard shouldInsertText:(NSString *)text;

/**
 *  Asks the delegate if the keyboard should process the pressing of the return button.
 *
 *  @param numberKeyboard The keyboard whose return button was pressed.
 *
 *  @return Returns	@c YES if the keyboard should implement its default behavior for the return button; otherwise, @c NO.
 */
- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard;

/**
 *  Asks the delegate if the keyboard should remove the character just before the cursor.
 *
 *  @param numberKeyboard The keyboard whose return button was pressed.
 *
 *  @return Returns	@c YES if the keyboard should implement its default behavior for the delete backward button; otherwise, @c NO.
 */
- (BOOL)numberKeyboardShouldDeleteBackward:(MMNumberKeyboard *)numberKeyboard;

@end
