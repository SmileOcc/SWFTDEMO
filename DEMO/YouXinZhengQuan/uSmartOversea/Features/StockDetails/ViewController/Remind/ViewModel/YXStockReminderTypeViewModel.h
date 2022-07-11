//
//  YXStockReminderTypeViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
#import "YXReminderModel.h"


// 控制器的类型
typedef NS_ENUM(NSUInteger, YXReminderVCType) {
    YXReminderVCTypeNew = 0, // 新增的
    YXReminderVCTypeEditPrice = 1, // 编辑股价
    YXReminderVCTypeEditForm = 2, // 编辑形态
};


NS_ASSUME_NONNULL_BEGIN

@interface YXStockReminderTypeViewModel : YXTableViewModel

//market + symbol
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;

@property (nonatomic, strong) NSArray <YXReminderModel *> *formArr;

@property (nonatomic, assign) YXReminderType selecType;


@property (nonatomic, assign) YXReminderVCType addType;

@property (nonatomic, assign) BOOL comeFromPop;


- (BOOL)isEnableWithType: (YXReminderType)type;

@end

NS_ASSUME_NONNULL_END
