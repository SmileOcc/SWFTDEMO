//
//  YXWarrantsStreetViewModel.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
@class YXCbbcDetailResponseModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXWarrantsStreetViewModel : YXTableViewModel

@property (nonatomic, copy) NSString *name; //股票名称
@property (nonatomic, copy) NSString *market; //股票市场
@property (nonatomic, copy) NSString *code; //股票代码

@property (nonatomic, copy) NSString *roc; //涨跌幅
@property (nonatomic, copy) NSString *change; //涨跌额
@property (nonatomic, copy) NSString *now; //现价
@property (nonatomic, copy) NSString *priceBase;

@property (nonatomic, copy) NSString *type1;

@property (nonatomic, strong) NSArray *range;
@property (nonatomic, strong) NSArray *date;
@property (nonatomic, assign) NSInteger rangeIndex;
@property (nonatomic, assign) NSInteger dateIndex;

@property (nonatomic, strong) RACCommand *rangesCommand;
@property (nonatomic, strong) RACCommand *detailCommand;

@property (nonatomic, strong, nullable) YXCbbcDetailResponseModel *responseModel;

@property (nonatomic, assign) int maxOutstanding;

@end

NS_ASSUME_NONNULL_END
