//
//  YXBrokerDetailViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXStockAnalyzeBrokerListModel.h"
#import "YXBrokerDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXBrokerDetailViewModel : YXViewModel

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) NSString *symbol;

@property (nonatomic, assign) NSInteger selecIndex;

@property (nonatomic, strong) NSArray <YXStockAnalyzeBrokerStockInfo *> *brokerList;

@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) RACCommand *loadCommand;
@property (nonatomic, strong) RACCommand *loadMoreCommand;

@property (nonatomic, strong) YXBrokerDetailModel *model;



@end

NS_ASSUME_NONNULL_END
