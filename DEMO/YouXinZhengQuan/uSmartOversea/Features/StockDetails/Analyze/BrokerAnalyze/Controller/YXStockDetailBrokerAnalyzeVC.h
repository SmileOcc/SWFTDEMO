//
//  YXStockDetailBrokerAnalyzeVC.h
//  uSmartOversea
//
//  Created by youxin on 2020/3/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailBrokerAnalyzeVC : YXViewController

- (void)refreshControllerData;

@property (nonatomic, assign) CGFloat contentHieght;

@property (nonatomic, copy) void (^contentHeightDidChange)(CGFloat height);

@end

NS_ASSUME_NONNULL_END
