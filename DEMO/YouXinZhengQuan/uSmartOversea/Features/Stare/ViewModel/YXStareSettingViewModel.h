//
//  YXStareSettingViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXStareSignalModel.h"

@class YXStareSignalSettingModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXStareSettingViewModel : YXViewModel

// 获取信号列表
@property (nonatomic, strong) RACCommand *loadSettingListRequestCommand;

// 获取设置列表
@property (nonatomic, strong) RACCommand *loadPushSettingListRequestCommand;
// 更新信号
@property (nonatomic, strong) RACCommand *updateSettingListRequestCommand;
// 更新推送
@property (nonatomic, strong) RACCommand *updatePushSettingListRequestCommand;

// 信号的列表
@property (nonatomic, strong) NSArray <YXStareSignalSettingModel *>  *signalList;

// 推送设置的列表
@property (nonatomic, strong) NSArray <YXStarePushSettingModel *>  *pushList;

@end

NS_ASSUME_NONNULL_END
