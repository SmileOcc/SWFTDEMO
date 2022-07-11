//
//  YXSDWeavesDetailVModel.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
//#import "YXSocketSingleton.h"
@class Secu;
@class YXV2Quote;
@class YXQuoteRequest;

NS_ASSUME_NONNULL_BEGIN

@interface YXSDWeavesDetailVModel : YXViewModel

//symbol + market + name
@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, copy, readonly) NSString *market;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) double pClose;
@property (nonatomic, assign, readonly) double lastPrice;

@property (nonatomic, strong) Secu *secu;

@property (nonatomic, strong) RACSubject *loadTickDataSubject;

//行情model
@property (nonatomic, strong) YXV2Quote *quotaModel;
@property (nonatomic, assign, readonly) int extra;

//加载tick数据
@property (nonatomic, strong) RACCommand *loadTickDataCommand;
//加载基本盘面数据
@property (nonatomic, strong) RACCommand *loadBasicQuotaDataCommand;
@property (nonatomic, strong) RACSubject *loadBasicQuotaDataSubject;

@property (nonatomic, strong) YXQuoteRequest *quoteRequset;
@property (nonatomic, strong) YXQuoteRequest *tickRequset;

@end

NS_ASSUME_NONNULL_END
