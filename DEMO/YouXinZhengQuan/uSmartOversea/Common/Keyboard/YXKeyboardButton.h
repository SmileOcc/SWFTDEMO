//
//  YXKeyboardButton.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YXKeyboardButtonType) {
    YXKeyboardButtonTypeNone = 10000,
    YXKeyboardButtonTypeNumber,
    YXKeyboardButtonTypeDelete,
    YXKeyboardButtonTypeResign,
    YXKeyboardButtonTypeDecimal,
    YXKeyboardButtonTypeComplete,
    YXKeyboardButtonType00,
    YXKeyboardButtonType000,
    YXKeyboardButtonTypeFull,
    YXKeyboardButtonTypeHalf,
    YXKeyboardButtonTypeOneThird,
    YXKeyboardButtonTypeQuarter,
};

NS_ASSUME_NONNULL_BEGIN

@interface YXKeyboardButton : UIButton

@property (nonatomic,assign) YXKeyboardButtonType KeyboardButtonType;

@end

NS_ASSUME_NONNULL_END
