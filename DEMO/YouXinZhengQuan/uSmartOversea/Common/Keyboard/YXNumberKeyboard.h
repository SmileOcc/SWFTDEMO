//
//  YXNumberKeyboard.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXKeyboardButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXNumberKeyboardType) {
    YXNumberKeyboardTypeNormal,
    YXNumberKeyboardTypeSecury,
    YXNumberKeyboardTypeCount,
    YXNumberKeyboardTypeStockPosition
};

typedef void(^ YXStockPositionBtnClickBlock)(YXKeyboardButtonType keyboardButtonType);

@interface YXNumberKeyboard : UIView

@property (nonatomic, assign) YXNumberKeyboardType keyboardType;

@property (nonatomic, copy) YXStockPositionBtnClickBlock stockPositionBtnClickBlock;

@end

NS_ASSUME_NONNULL_END
