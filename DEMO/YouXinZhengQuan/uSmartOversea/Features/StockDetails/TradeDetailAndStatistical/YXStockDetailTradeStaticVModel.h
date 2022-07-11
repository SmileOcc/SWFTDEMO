//
//  YXStockDetailTradeStaticVModel.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXSDWeavesDetailVModel.h"
#import "YXSDDealStatisticalVModel.h"
#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailTradeStaticVModel : YXTableViewModel//YXViewModel

@property (nonatomic, strong, readonly) YXSDWeavesDetailVModel *weavesVModel;
@property (nonatomic, strong, readonly) YXSDDealStatisticalVModel *staticVModel;

@property (nonatomic, strong) NSString *market;

@end

NS_ASSUME_NONNULL_END
