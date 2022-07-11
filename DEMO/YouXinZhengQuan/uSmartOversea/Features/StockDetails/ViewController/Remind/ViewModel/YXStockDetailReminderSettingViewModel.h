//
//  YXStockDetailReminderSettingViewModel.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/20.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXReminderModel.h"
#import "uSmartOversea-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@class YXMyReminderDataModel;
@interface YXStockDetailReminderSettingViewModel : YXViewModel

//跳转到"我的提醒"
@property (nonatomic, strong) RACCommand *pushToMyRemindsCommand;


//保存提醒数据
@property (nonatomic, strong) RACCommand *remindSettingSaveCommand;

//market + symbol
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;

//@property (nonatomic, assign) BOOL fromReminderSetting;

@property (nonatomic, strong) YXReminderModel* reminderModel;
@property (nonatomic, strong) NSArray *formArr;



@end

NS_ASSUME_NONNULL_END
