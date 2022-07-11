//
//  YXDealStatisticalTableViewCell.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>
#import "YXTableViewCell.h"

@class YXAnalysisStatisticPrice;

NS_ASSUME_NONNULL_BEGIN

@interface YXDealStatisticalTableViewCell : YXTableViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

- (void)refreshWith:(YXAnalysisStatisticPrice *)statisPrice priceBase:(int64_t)priceBase pClose:(NSString *)pClose maxVolume:(int32_t)maxVolume;

@end

NS_ASSUME_NONNULL_END
