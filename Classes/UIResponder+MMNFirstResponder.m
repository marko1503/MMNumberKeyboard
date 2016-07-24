//
//  UIResponder+MMNFirstResponder.m
//  Demo
//
//  Created by Maksym Prokopchuk on 7/24/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "UIResponder+MMNFirstResponder.h"

static __weak id currentFirstResponder;

@implementation UIResponder (MMNFirstResponder)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
+ (id)MM_currentFirstResponder
{
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(MM_findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
#pragma clang diagnostic pop

- (void)MM_findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end
