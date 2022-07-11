//
//  YXStockDetailBrokerRatioVC.h
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewController.h"
#import "YXStockDetailBrokerRatioVModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailBrokerRatioVC : YXViewController

@property (nonatomic, strong, readonly) YXStockDetailBrokerRatioVModel *viewModel;
- (void)loadHttpDataWithTimer;
@end

NS_ASSUME_NONNULL_END
