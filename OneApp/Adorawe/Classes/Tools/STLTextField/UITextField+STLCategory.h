//
//  UITextField+STLCategory.h
// XStarlinkProject
//
//  Created by odd on 2020/7/1.
//  Copyright © 2020 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (STLCategory)

- (void)stlPlaceholderColor:(UIColor *)color;

- (void)setPlaceholder:(NSString *)place color:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
