//
//  UITextField+STLCategory.m
// XStarlinkProject
//
//  Created by odd on 2020/7/1.
//  Copyright © 2020 XStarlinkProject. All rights reserved.
//

#import "UITextField+STLCategory.h"
#import <objc/runtime.h>

@implementation UITextField (STLCategory)

- (void)stlPlaceholderColor:(UIColor *)color {
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(self, ivar);
    placeholderLabel.textColor = color;
}

- (void)setPlaceholder:(NSString *)place color:(UIColor *)color {
    if (!STLIsEmptyString(place)) {
        
        NSMutableAttributedString *placeholderString = [[NSMutableAttributedString alloc] initWithString:place attributes:@{NSForegroundColorAttributeName : color}];
        
        self.attributedPlaceholder = placeholderString;
    }
}
@end
