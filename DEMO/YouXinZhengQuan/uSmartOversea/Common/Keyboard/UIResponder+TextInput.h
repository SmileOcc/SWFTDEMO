//
//  UIResponder+YXKeyBoardFirstResponder.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (TextInput)

+ (void)inputText:(NSString *)text;

+ (UIView<UITextInput> *)currentTextInput;

- (void)registerTextInputNotifications;
- (void)unregisterTextInputNotifications;

@end

NS_ASSUME_NONNULL_END
