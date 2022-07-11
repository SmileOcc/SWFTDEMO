//
//  YXNoticeAppViewModel.h
//  YouXinZhengQuan
//
//  Created by suntao on 2021/1/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

/*
  值    说明
  quote_smart    智能盯盘
  quote_stock    股价提醒
  hot_stock      今日热股
  smart_policy    智投策略
  news    0:全量资讯 1：精编资讯 2: 核心资讯 10: 不接收推送
  live    直播
  上述字段除特殊说明外，0标识开关打开，1表示开关关闭
 */
typedef NS_ENUM(NSInteger,YXNewsNoticeType) {
    YXNewsNoticeTypeAll = 0 ,
    YXNewsNoticeTypeSelected = 1,
    YXNewsNoticeTypeImportant = 2,
    YXNewsNoticeTypeOff = 10
};

NS_ASSUME_NONNULL_BEGIN

@class YXNoticeGroupSettingModel;
@class YXStarePushSettingModel;

@interface YXNoticeAppViewModel : YXViewModel

//-----------设置的推送-------
@property (nonatomic, strong) NSMutableArray <YXNoticeGroupSettingModel *>*settingList;

@property (nonatomic, strong) RACCommand *updateSettingCommand;

@property (nonatomic, strong) RACSubject *getSettingSubject;

@property (nonatomic, assign) NSInteger newsTypeValue;
//获取app推送的状态值
-(void) loadServiceData ;
- (void)resetData;

//-----------盯盘精灵的推送-------

// 获取设置列表
@property (nonatomic, strong) RACCommand *smLoadPushSettingListRequestCommand;
// 更新推送
@property (nonatomic, strong) RACCommand *smUpdatePushSettingListRequestCommand;
// 推送设置的列表
@property (nonatomic, strong) NSArray <YXStarePushSettingModel *>  *smPushList;


@end

NS_ASSUME_NONNULL_END
