//
//  YXExchangeDistributionCell.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXExchangeStatisticalSubModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXExchangeDistributionCell : UITableViewCell
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)refreshWithModel: (YXExchangeStatisticalSubModel *)model andMaxVolumn: (uint64_t)maxVolume andPriceBase: (NSInteger)priceBase;

@end

NS_ASSUME_NONNULL_END
