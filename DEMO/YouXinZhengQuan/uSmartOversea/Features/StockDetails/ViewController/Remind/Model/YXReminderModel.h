//
//  YXReminderModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXAuthorityReminderTool.h"

@class YXV2Quote;

NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(NSUInteger, YXReminderType) {
    YXReminderTypeNone = 0,
    YXReminderTypePriceUp = 1,
    YXReminderTypePricDown = 2,
    YXReminderTypeDayUp = 3,
    YXReminderTypeDayDown = 4,
    YXReminderTypePriceFiveMinUp = 5,
    YXReminderTypePriceFiveMinDown = 6,
    YXReminderTypeTurnoverMore = 50,
    YXReminderTypeVolumnMore = 51,
    YXReminderTypeTurnoverRateMore = 52,
    YXReminderTypeOvertopSellOne = 53,
    YXReminderTypeOvertopSellOneTurnover = 54,
    YXReminderTypeOvertopBuyOne = 55,
    YXReminderTypeOvertopBuyOneTurnover = 56,
    YXReminderTypeClassicTechnical = 11,
    YXReminderTypeKline = 12,
    YXReminderTypeIndex = 13,
    YXReminderTypeShock = 14,
    YXReminderTypeAnnouncement = 15,
    YXReminderTypePositive = 16,
    YXReminderTypeBad = 17,
    YXReminderTypeFinancialReport = 18,
};

@interface YXReminderModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;

// 形态
@property (nonatomic, assign) YXReminderType formShowType;

@property (nonatomic, assign) YXReminderType ntfType;

@property (nonatomic, strong, nullable) NSNumber *ntfValue;

// 通知类型: 1-仅提醒一次, 2-每日一次, 3-持续提醒
@property (nonatomic, assign) int notifyType;
// 状态: 1-开启状态, 2-关闭状态
@property (nonatomic, assign) int status;

@property (nonatomic, strong) NSString *id;

@property (nonatomic, strong) NSString *notifyStr;

@end


@interface YXReminderListModel : NSObject <YXAuthorityReminderToolGroupingDelegate>


@property (nonatomic, strong) NSString *stockCode;

@property (nonatomic, strong) NSString *stockMarket;

@property (nonatomic, strong) YXV2Quote *quotaModel;

@property (nonatomic, strong) NSArray <YXReminderModel *>*stockForms;

@property (nonatomic, strong) NSArray <YXReminderModel *>*stockNtfs;

@property (nonatomic, assign) BOOL isUnfold;

@end

NS_ASSUME_NONNULL_END
