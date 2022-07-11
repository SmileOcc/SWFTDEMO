//
//  YXGroupSettingView.h
//  uSmartOversea
//
//  Created by ellison on 2018/11/27.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXSecuProtocol.h"

typedef enum : NSUInteger {
    YXGroupSettingTypeModify,   // 修改分组
    YXGroupSettingTypeAdd // 添加到分组
} YXGroupSettingType;

#define kCustomSecuGroupAddStockNotification  @"kCustomSecuGroupAddStockNotification"

NS_ASSUME_NONNULL_BEGIN

@class YXSecuGroup;
@interface YXGroupSettingView : UIView

- (instancetype)initWithSecus:(NSArray<YXSecuIDProtocol> *)secus secuName:(NSString *)secuName currentOperationGroup:(YXSecuGroup *)group settingType:(YXGroupSettingType)type;

@property (nonatomic, copy) void (^addResultCallback) (BOOL result);

- (void)sureButtonAction;

@end

NS_ASSUME_NONNULL_END
