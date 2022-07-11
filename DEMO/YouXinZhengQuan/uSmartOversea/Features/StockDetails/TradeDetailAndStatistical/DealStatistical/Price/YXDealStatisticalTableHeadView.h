//
//  YXDealStatisticalTableHeadView.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXAnalysisStatisticData;

NS_ASSUME_NONNULL_BEGIN

@interface YXDealStatisticalTableHeadView : UIView

@property (nonatomic, strong) YXAnalysisStatisticData *statisData;

@property (nonatomic, copy) void (^refreshCount)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
