//
//  YXStockDetailAnalyzeViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "YXHkVolumnModel.h"
#import "YXBrokerDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailAnalyzeViewModel : YXViewModel

@property (nonatomic, strong) NSString *symbol;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, assign) int64_t preClose;

@property (nonatomic, assign) BOOL greyFlag;

@property (nonatomic, assign) BOOL isStock;

@property (nonatomic, assign) BOOL isWarrantCbbc;

@property (nonatomic, strong) RACCommand *brokerListDataCommand;

@property (nonatomic, strong) RACCommand *brokerShareHoldingDataCommand;


@property (nonatomic, strong) RACCommand *pushToBrokerDetailCommand;

@property (nonatomic, strong) RACCommand *pushToBrokerHoldingDetailCommand;


@property (nonatomic, strong) RACSubject *brokerTimerSubject;

@property (nonatomic, assign) int brokerType;

@property (nonatomic, assign) int level;

@property (nonatomic, strong) RACCommand *loadSellCommand;
@property (nonatomic, strong) RACCommand *loadSellMoreCommand;
@property (nonatomic, strong) YXBrokerDetailModel *sellModel;

@property (nonatomic, strong) RACCommand *loadHKVolumnCommand;
@property (nonatomic, strong) RACCommand *loadHKVolumnMoreCommand;
@property (nonatomic, strong) YXBrokerDetailModel *HKVolumnModel;

@property (nonatomic, assign) BOOL isHKVolumn;

@property (nonatomic, strong) RACCommand *loadHKVolumnChangeCommand;
@property (nonatomic, strong) YXHkVolumnModel *hkVolumnChangeModel;

@property (nonatomic, strong) RACCommand *diagnoseScoreDataCommand;

@property (nonatomic, strong) RACCommand *diagnoseNumberDataCommand;

// 剩余可访问的诊股个数
@property (nonatomic, assign) NSInteger number_surplus;
// 最大访问诊股数
@property (nonatomic, assign) NSInteger number_max;

//跳转到诊股详情
@property (nonatomic, strong) RACCommand *pushToAnalyzeDetailCommand;

//跳转技术洞察详情
@property (nonatomic, strong) RACCommand *pushToTechnicalDetailCommand;


@property (nonatomic, strong) RACCommand *technicalInsightDataCommand;

//跳转到筹码分布详情
@property (nonatomic, strong) RACCommand *pushToChipDetailCommand;

//跳转筹码分布解释web
@property (nonatomic, strong) RACCommand *pushToChipExplainCommand;

//登录跳转
@property (nonatomic, strong) RACCommand *loginCommand;

// 估值
@property (nonatomic, strong) RACCommand *estimateDataCommand;

//轮证评分
@property (nonatomic, strong) RACCommand *warrantCbbcScoreDataCommand;

// 开启定时器
- (void)openTimer;

- (void)closeTimer;

@end

NS_ASSUME_NONNULL_END
