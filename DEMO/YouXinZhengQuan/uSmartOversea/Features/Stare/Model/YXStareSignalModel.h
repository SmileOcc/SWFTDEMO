//
//  YXStareSignalModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStareSignalSubModel : NSObject

@property (nonatomic, strong)  NSString * _Nullable multiple;
@property (nonatomic, strong)  NSString * _Nullable amplitude;

@property (nonatomic, strong)  NSString * _Nullable price;
@property (nonatomic, strong)  NSString * _Nullable lots;


@property (nonatomic, strong)  NSString * _Nullable tradePrice;

@end

@interface YXStareSignalModel : NSObject
//1利好 0中性 -1利空
@property (nonatomic, strong) NSString *color;

@property (nonatomic, strong) NSString *describe;

@property (nonatomic, assign) long seqNum;
//监控指标类型，取值参见枚举SignalType.
@property (nonatomic, assign) int signalId;
//信号名称
@property (nonatomic, strong) NSString *signalName;

@property (nonatomic, strong) NSString *stockCode;

@property (nonatomic, strong) NSString *stockName;

@property (nonatomic, assign) long unixTime;

@property (nonatomic, strong) NSString *unixTimeStr;

@property (nonatomic, strong) YXStareSignalSubModel * _Nullable subModel;

@end



@interface YXStareSignalSettingModel : NSObject

@property (nonatomic, assign) NSInteger Defult;
@property (nonatomic, assign) NSInteger SignalId;
@property (nonatomic, strong) NSString *SignalName;

@end

@interface YXStarePushSettingSubModel : NSObject

@property (nonatomic, assign) BOOL status;

@property (nonatomic, strong) NSString *identifier;

// 0 自选股  1 行业  2 智能筛选 3 次新股  4 微信 5 持仓  (客户端自己临时加)
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, assign) BOOL isShow;

// 行业名字(客户端自己临时加)
@property (nonatomic, strong) NSString *name;

@end


@interface YXStarePushSettingModel : NSObject

// 0 自选股  1 行业  2 智能筛选 3 次新股  4 微信 5 持仓
@property (nonatomic, assign) NSInteger type;

// 二级列表
@property (nonatomic, strong) NSArray <YXStarePushSettingSubModel *> *list;

@end




NS_ASSUME_NONNULL_END
