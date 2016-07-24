//
//  MMNumberKeyboard.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import "MMNumberKeyboard.h"
#import "MMNumberKeyboardButton+Styles.h"
#import "UIResponder+MMNFirstResponder.h"

// keyboard layout
static const NSInteger kNumberKeyboardRows     = 4;
static const CGFloat kNumberKeyboardRowHeight  = 55.0;
static const CGFloat kNumberKeyboardPadBorder  = 7.0;
static const CGFloat kNumberKeyboardPadSpacing = 8.0;


@interface MMNumberKeyboard () <UIInputViewAudioFeedback>

@property (strong, nonatomic) NSDictionary <NSNumber *, MMNumberKeyboardButton *> *buttonDictionary;
@property (strong, nonatomic) NSMutableArray *separatorViews;
@property (strong, nonatomic) NSLocale *locale;

@property (nonatomic, weak, readwrite) id <UIKeyInput> keyInput;

@property (copy, nonatomic) dispatch_block_t specialKeyHandler;

@end


@implementation MMNumberKeyboard

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame inputViewStyle:UIInputViewStyleKeyboard];
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle {
    self = [super initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle locale:(NSLocale *)locale {
    self = [self initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        _locale = locale;
    }
    return self;
}


#pragma mark - Buttons
- (MMNumberKeyboardButton *)p_backspaceButton {
    UIImage *backspaceImage = [[self.class p_keyboardImageNamed:@"MMNumberKeyboardDeleteKey.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    MMNumberKeyboardButton *backspaceButton = [MMNumberKeyboardButton mmn_keyboardButtonBackspaceWithImage:backspaceImage target:self action:@selector(p_backspaceRepeat:) forContinuousPressWithTimeInterval:0.15];
    return backspaceButton;
}

- (MMNumberKeyboardButton *)p_keyboadButtonDismiss {
    UIImage *dismissImage = [self.class p_keyboardImageNamed:@"MMNumberKeyboardDismissKey.png"];
    MMNumberKeyboardButton *dismissButton = [MMNumberKeyboardButton keyboardButtonWithStyle:MMNumberKeyboardButtonStyleGray];
    [dismissButton setImage:dismissImage forState:UIControlStateNormal];
    return dismissButton;
}

- (void)p_commonInit {
    NSMutableDictionary <NSNumber *, MMNumberKeyboardButton *> *buttonDictionary = [[NSMutableDictionary alloc] initWithCapacity:14];
    
//    NSDictionary <NSNumber *, MMNumberKeyboardButton *> * decimalNumbersDictionary = [MMNumberKeyboardButton mmn_keyboadButtonWithDecimalNumbersStartFrom:MMNumberKeyboardButtonTypeNumberMin to:MMNumberKeyboardButtonTypeNumberMax target:self action:@selector(p_tapInputDecimalNumberButton:)];
    NSDictionary <NSNumber *, MMNumberKeyboardButton *> * decimalNumbersDictionary = [MMNumberKeyboardButton mmn_keyboadButtonWithDecimalNumbersStartFrom:MMNumberKeyboardButtonTypeNumberMin to:MMNumberKeyboardButtonTypeNumberMax target:nil action:nil];
    
    [buttonDictionary addEntriesFromDictionary:decimalNumbersDictionary];
    
    MMNumberKeyboardButton *backspaceButton = [self p_backspaceButton];
    [buttonDictionary setObject:backspaceButton forKey:@(MMNumberKeyboardButtonTypeBackspace)];
    
    MMNumberKeyboardButton *specialButton = [self p_keyboadButtonDismiss];
    [buttonDictionary setObject:specialButton forKey:@(MMNumberKeyboardButtonTypeSpecial)];
    
    MMNumberKeyboardButton *doneButton = [MMNumberKeyboardButton mmn_keyboardButtonDoneWithTitle:UIKitLocalizedString(@"Done")];
    [buttonDictionary setObject:doneButton forKey:@(MMNumberKeyboardButtonTypeDone)];
    
    NSLocale *locale = self.locale ?: [NSLocale currentLocale];
    MMNumberKeyboardButton *decimalPointButton = [MMNumberKeyboardButton mmn_keyboardButtonDecimalPointWithLocale:locale];
    [buttonDictionary setObject:decimalPointButton forKey:@(MMNumberKeyboardButtonTypeDecimalPoint)];
    
    [buttonDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, MMNumberKeyboardButton * _Nonnull button, BOOL * _Nonnull stop) {
        [button setExclusiveTouch:YES];
        [button addTarget:self action:@selector(p_buttonPlayClick:) forControlEvents:UIControlEventTouchDown];
        
//        if ([key unsignedIntegerValue] > MMNumberKeyboardButtonTypeNumberMax) {
            [button addTarget:self action:@selector(p_buttonInput:) forControlEvents:UIControlEventTouchUpInside];
//        }
        
        [self addSubview:button];
    }];
    
    UIPanGestureRecognizer *highlightGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleHighlightGestureRecognizer:)];
    [self addGestureRecognizer:highlightGestureRecognizer];
    
    self.buttonDictionary = buttonDictionary;
    
    // Initialize an array for the separators.
    self.separatorViews = [NSMutableArray array];
    
    // Add default action.
    UIImage *dismissImage = [self.class p_keyboardImageNamed:@"MMNumberKeyboardDismissKey.png"];
    [self configureSpecialKeyWithImage:dismissImage target:self action:@selector(p_dismissKeyboard:)];
    
    // Size to fit.
    [self sizeToFit];
}


#pragma mark - Input.
- (void)p_handleHighlightGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        for (UIButton *button in self.buttonDictionary.objectEnumerator) {
            BOOL points = CGRectContainsPoint(button.frame, point) && !button.isHidden;
            
            if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                [button setHighlighted:points];
            }
            else {
                [button setHighlighted:NO];
            }
            
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded && points) {
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

#pragma mark - Click sound
- (void)p_buttonPlayClick:(UIButton *)button {
    [[UIDevice currentDevice] playInputClick];
}


#pragma mark - Handle input
- (void)p_tapInputDecimalNumberButton:(MMNumberKeyboardButton *)button {
    NSString *string = [button titleForState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(numberKeyboard:shouldInsertText:)]) {
        BOOL shouldInsert = [self.delegate numberKeyboard:self shouldInsertText:string];
        if (!shouldInsert) {
            return;
        }
    }
    
    [self.keyInput insertText:string];
}

- (void)p_tapDeleteBackwardButton:(MMNumberKeyboardButton *)button {
    BOOL shouldDeleteBackward = YES;
    
    if ([self.delegate respondsToSelector:@selector(numberKeyboardShouldDeleteBackward:)]) {
        shouldDeleteBackward = [self.delegate numberKeyboardShouldDeleteBackward:self];
    }
    
    if (shouldDeleteBackward) {
        [self.keyInput deleteBackward];
    }
}

- (void)p_tapDoneButton:(MMNumberKeyboardButton *)button {
    BOOL shouldReturn = YES;
    
    if ([self.delegate respondsToSelector:@selector(numberKeyboardShouldReturn:)]) {
        shouldReturn = [self.delegate numberKeyboardShouldReturn:self];
    }
    
    if (shouldReturn) {
        [self p_dismissKeyboard:button];
    }
}

- (void)p_tapInputDecimalPointButton:(MMNumberKeyboardButton *)button {
    NSString *decimalText = [button titleForState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(numberKeyboard:shouldInsertText:)]) {
        BOOL shouldInsert = [self.delegate numberKeyboard:self shouldInsertText:decimalText];
        if (!shouldInsert) {
            return;
        }
    }
    
    [self.keyInput insertText:decimalText];
}

- (void)p_tapDismissKeyboardButton:(MMNumberKeyboardButton *)button {
    dispatch_block_t handler = self.specialKeyHandler;
    if (handler) {
        handler();
    }
}

- (void)p_buttonInput:(MMNumberKeyboardButton *)button {
    __block MMNumberKeyboardButtonType presedButtonType = MMNumberKeyboardButtonTypeNone;
//    MMNumberKeyboardButtonType buttonType = button.type;
    
    [self.buttonDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, MMNumberKeyboardButton * _Nonnull obj, BOOL * _Nonnull stop) {
        MMNumberKeyboardButtonType k = [key unsignedIntegerValue];
        if (button == obj) {
            presedButtonType = k;
            *stop = YES;
        }
    }];
    
    if (presedButtonType == MMNumberKeyboardButtonTypeNone) {
        return;
    }
    
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    
    if (!keyInput) {
        return;
    }
    
    // Handle number.
    const NSInteger numberMin = MMNumberKeyboardButtonTypeNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonTypeNumberMax;
    
    if (presedButtonType >= numberMin && presedButtonType < numberMax) {
        [self p_tapInputDecimalNumberButton:button];
    }
    
    // Handle backspace.
    else if (presedButtonType == MMNumberKeyboardButtonTypeBackspace) {
        [self p_tapDeleteBackwardButton:button];
    }
    
    // Handle done.
    else if (presedButtonType == MMNumberKeyboardButtonTypeDone) {
        [self p_tapDoneButton:button];
    }
    
    // Handle special key.
    else if (presedButtonType == MMNumberKeyboardButtonTypeSpecial) {
        [self p_tapDismissKeyboardButton:button];
    }
    
    // Handle .
    else if (presedButtonType == MMNumberKeyboardButtonTypeDecimalPoint) {
        [self p_tapInputDecimalPointButton:button];
    }
}

- (void)p_backspaceRepeat:(MMNumberKeyboardButton *)button {
    id <UIKeyInput> keyInput = self.keyInput;
    
    if (![keyInput hasText]) {
        return;
    }
    
    [self p_buttonPlayClick:button];
    [self p_buttonInput:button];
}

- (id <UIKeyInput>)keyInput {
    id <UIKeyInput> keyInput = _keyInput;
    if (keyInput) {
        return keyInput;
    }
    
    keyInput = [UIResponder MM_currentFirstResponder];
    if (![keyInput conformsToProtocol:@protocol(UITextInput)]) {
        NSLog(@"Warning: First responder %@ does not conform to the UIKeyInput protocol.", keyInput);
        return nil;
    }
    
    _keyInput = keyInput;
    
    return keyInput;
}


#pragma mark - Default special action.
- (void)p_dismissKeyboard:(id)sender {
    UIResponder *firstResponder = self.keyInput;
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
}


#pragma mark - Public.
- (void)configureSpecialKeyWithImage:(UIImage *)image actionHandler:(dispatch_block_t)handler {
    if (image) {
        self.specialKeyHandler = handler;
    }
    else {
        self.specialKeyHandler = NULL;
    }
    
    UIButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonTypeSpecial)];
    [button setImage:image forState:UIControlStateNormal];
}

- (void)configureSpecialKeyWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    __weak typeof(self)weakTarget = target;
    __weak typeof(self)weakSelf = self;
    
    [self configureSpecialKeyWithImage:image actionHandler:^{
        __strong __typeof(&*weakTarget)strongTarget = weakTarget;
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        
        if (strongTarget) {
            NSMethodSignature *methodSignature = [strongTarget methodSignatureForSelector:action];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:action];
            if (methodSignature.numberOfArguments > 2) {
                [invocation setArgument:&strongSelf atIndex:2];
            }
            [invocation invokeWithTarget:strongTarget];
        }
    }];
}

- (void)setAllowsDecimalPoint:(BOOL)allowsDecimalPoint {
    if (allowsDecimalPoint != _allowsDecimalPoint) {
        _allowsDecimalPoint = allowsDecimalPoint;
        
        [self setNeedsLayout];
    }
}

- (void)setReturnKeyTitle:(NSString *)title {
    if (![title isEqualToString:self.returnKeyTitle]) {
        UIButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonTypeDone)];
        if (button) {
            NSString *returnKeyTitle = (title != nil && title.length > 0) ? title : [self defaultReturnKeyTitle];
            [button setTitle:returnKeyTitle forState:UIControlStateNormal];
        }
    }
}

- (NSString *)returnKeyTitle {
    UIButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonTypeDone)];
    if (button) {
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title != nil && title.length > 0) {
            return title;
        }
    }
    return [self defaultReturnKeyTitle];
}

- (NSString *)defaultReturnKeyTitle {
    return UIKitLocalizedString(@"Done");
}

- (void)setReturnKeyButtonStyle:(MMNumberKeyboardButtonStyle)style {
    if (style != _returnKeyButtonStyle) {
        _returnKeyButtonStyle = style;
        
        MMNumberKeyboardButton *button = self.buttonDictionary[@(MMNumberKeyboardButtonTypeDone)];
        if (button) {
            button.style = style;
        }
    }
}


#pragma mark - Layout.
NS_INLINE CGRect MMButtonRectMake(CGRect rect, CGRect contentRect, UIUserInterfaceIdiom interfaceIdiom){
    rect = CGRectOffset(rect, contentRect.origin.x, contentRect.origin.y);
    
    if (interfaceIdiom == UIUserInterfaceIdiomPad) {
        CGFloat inset = kNumberKeyboardPadSpacing / 2.0;
        rect = CGRectInset(rect, inset, inset);
    }
    
    return rect;
};

#if CGFLOAT_IS_DOUBLE
#define MMRound round
#else
#define MMRound roundf
#endif
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    NSDictionary *buttonDictionary = self.buttonDictionary;
    
    // Settings.
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const CGFloat spacing = (interfaceIdiom == UIUserInterfaceIdiomPad) ? kNumberKeyboardPadBorder : 0.0;
    const CGFloat maximumWidth = (interfaceIdiom == UIUserInterfaceIdiomPad) ? 400.0 : CGRectGetWidth(bounds);
    const BOOL allowsDecimalPoint = self.allowsDecimalPoint;
    
    const CGFloat width = MIN(maximumWidth, CGRectGetWidth(bounds));
    const CGRect contentRect = (CGRect){
        .origin.x = MMRound((CGRectGetWidth(bounds) - width) / 2.0),
        .origin.y = spacing,
        .size.width = width,
        .size.height = CGRectGetHeight(bounds) - (spacing * 2.0)
    };
    
    // Layout.
    const CGFloat columnWidth = CGRectGetWidth(contentRect) / 4.0;
    const CGFloat rowHeight = kNumberKeyboardRowHeight;
    
    CGSize numberSize = CGSizeMake(columnWidth, rowHeight);
    
    // Layout numbers.
    const NSInteger numberMin = MMNumberKeyboardButtonTypeNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonTypeNumberMax;
    
    const NSInteger numbersPerLine = 3;
    
    for (MMNumberKeyboardButtonType key = numberMin; key < numberMax; key++) {
        UIButton *button = buttonDictionary[@(key)];
        NSInteger digit = key - numberMin;
        
        CGRect rect = (CGRect){ .size = numberSize };
        
        if (digit == 0) {
            rect.origin.y = numberSize.height * 3;
            rect.origin.x = numberSize.width;
            
            if (!allowsDecimalPoint) {
                rect.size.width = numberSize.width * 2.0;
                [button setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, numberSize.width)];
            }
            
        }
        else {
            NSUInteger idx = (digit - 1);
            
            NSInteger line = idx / numbersPerLine;
            NSInteger pos = idx % numbersPerLine;
            
            rect.origin.y = line * numberSize.height;
            rect.origin.x = pos * numberSize.width;
        }
        
        [button setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
    }
    
    // Layout special key.
    UIButton *specialKey = buttonDictionary[@(MMNumberKeyboardButtonTypeSpecial)];
    if (specialKey) {
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        
        [specialKey setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
    }
    
    // Layout decimal point.
    UIButton *decimalPointKey = buttonDictionary[@(MMNumberKeyboardButtonTypeDecimalPoint)];
    if (decimalPointKey) {
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        rect.origin.x = numberSize.width * 2;
        
        [decimalPointKey setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
        
        decimalPointKey.hidden = !allowsDecimalPoint;
    }
    
    // Layout utility column.
    const int utilityButtonKeys[2] = { MMNumberKeyboardButtonTypeBackspace, MMNumberKeyboardButtonTypeDone };
    const CGSize utilitySize = CGSizeMake(columnWidth, rowHeight * 2.0);
    
    for (NSInteger idx = 0; idx < sizeof(utilityButtonKeys) / sizeof(int); idx++) {
        MMNumberKeyboardButtonType key = utilityButtonKeys[idx];
        
        UIButton *button = buttonDictionary[@(key)];
        CGRect rect = (CGRect){ .size = utilitySize };
        
        rect.origin.x = columnWidth * 3.0;
        rect.origin.y = idx * utilitySize.height;
        
        [button setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
    }
    
    // Layout separators if phone.
    if (interfaceIdiom == UIUserInterfaceIdiomPhone) {
        NSMutableArray *separatorViews = self.separatorViews;
        
        const NSUInteger totalColumns = 4;
        const NSUInteger totalRows = numbersPerLine + 1;
        const NSUInteger numberOfSeparators = totalColumns + totalRows - 1;
        
        if (separatorViews.count != numberOfSeparators) {
            const NSUInteger delta = (numberOfSeparators - separatorViews.count);
            const BOOL removes = (separatorViews.count > numberOfSeparators);
            if (removes) {
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, delta)];
                [[separatorViews objectsAtIndexes:indexes] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [separatorViews removeObjectsAtIndexes:indexes];
            }
            else {
                NSUInteger separatorsToInsert = delta;
                while (separatorsToInsert--) {
                    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
                    separator.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1f];
                    
                    [self addSubview:separator];
                    [separatorViews addObject:separator];
                }
            }
        }
        
        const CGFloat separatorDimension = 1.0 / (self.window.screen.scale ?: 1.0);
        
        [separatorViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *separator = obj;
            
            CGRect rect = CGRectZero;
            
            if (idx < totalRows) {
                rect.origin.y = idx * rowHeight;
                if (idx % 2) {
                    rect.size.width = CGRectGetWidth(contentRect) - columnWidth;
                } else {
                    rect.size.width = CGRectGetWidth(contentRect);
                }
                rect.size.height = separatorDimension;
            }
            else {
                NSInteger col = (idx - totalRows);
                
                rect.origin.x = (col + 1) * columnWidth;
                rect.size.width = separatorDimension;
                
                if (col == 1 && !allowsDecimalPoint) {
                    rect.size.height = CGRectGetHeight(contentRect) - rowHeight;
                } else {
                    rect.size.height = CGRectGetHeight(contentRect);
                }
            }
            
            [separator setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
        }];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const CGFloat spacing = (interfaceIdiom == UIUserInterfaceIdiomPad) ? kNumberKeyboardPadBorder : 0.0;
    
    size.height = kNumberKeyboardRowHeight * kNumberKeyboardRows + (spacing * 2.0);
    
    if (size.width == 0.0) {
        size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    return size;
}


#pragma mark - Audio feedback.
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}


#pragma mark - Accessing keyboard images.
+ (UIImage *)p_keyboardImageNamed:(NSString *)name {
    NSString *resource = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    
    if (resource) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        if (bundle) {
            NSString *resourcePath = [bundle pathForResource:resource ofType:extension];
            
            return [UIImage imageWithContentsOfFile:resourcePath];
        }
        else {
            return [UIImage imageNamed:name];
        }
    }
    return nil;
}

@end
