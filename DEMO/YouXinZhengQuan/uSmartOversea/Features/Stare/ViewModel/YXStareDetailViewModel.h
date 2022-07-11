//
//  YXStareDetailViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXStareSignalModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStareDetailViewModel : YXViewModel

@property (nonatomic, assign) NSInteger type;
// 二级tab
@property (nonatomic, assign) NSInteger subTab;

// 行业的code
@property (nonatomic, strong) NSString *bkCode;
// 指数的code
@property (nonatomic, strong) NSString *indexCode;
//请求数据
@property (nonatomic, strong) RACCommand *loadDownRequestCommand;
@property (nonatomic, strong) RACCommand *loadUpRequestCommand;

@property (nonatomic, strong) RACCommand *loadPollingRequestCommand;

// 更新推送
@property (nonatomic, strong) RACCommand *updatePushSettingListRequestCommand;
// 获取设置列表
@property (nonatomic, strong) RACCommand *loadPushSettingListRequestCommand;

@property (nonatomic, strong) NSMutableArray <YXStareSignalModel *> *list;

// 推送设置的列表
@property (nonatomic, strong) NSArray <YXStarePushSettingModel *>  *pushList;

//@property (nonatomic, assign) QuoteLevel hkLevel;

@end

NS_ASSUME_NONNULL_END
