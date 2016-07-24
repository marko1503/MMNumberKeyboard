//
//  UIResponder+MMNFirstResponder.h
//  Demo
//
//  Created by Maksym Prokopchuk on 7/24/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (MMNFirstResponder)

+ (id)MM_currentFirstResponder;
- (void)MM_findFirstResponder:(id)sender;

@end
