//
//  YXSDDealStatisticalVModel.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXSDDealStatistalModel.h"
#import "YXStockDetailUtility.h"

NS_ASSUME_NONNULL_BEGIN

@class Secu;
@class YXQuoteRequest;
@class YXV2Quote;
@interface YXSDDealStatisticalVModel : YXViewModel

//symbol + market + name
@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, copy, readonly) NSString *market;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *pClose;

@property (nonatomic, strong) Secu *secu;

//行情model
@property (nonatomic, strong) YXV2Quote *quotaModel;

//加载基本盘面数据
@property (nonatomic, strong) RACCommand *loadBasicQuotaDataCommand;
@property (nonatomic, strong) RACSubject *loadBasicQuotaDataSubject;

@property (nonatomic, strong) YXQuoteRequest *quoteRequset;
@property (nonatomic, assign) YXTimeShareLineType timeShareType;
@property (nonatomic, strong) RACCommand *loadTradeDateCommand;

@end

NS_ASSUME_NONNULL_END
