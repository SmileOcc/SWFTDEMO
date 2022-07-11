//
//  YXDealStatisticalPieChartView.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXDealStatisticalPieChartView : UIView

- (void)setForPieViewData:(NSArray *)dataArray andColor:(NSArray *)colorArr;

- (void)deletePieView;

// 饼之间的间隙
@property (nonatomic, assign) CGFloat sliceSpace;

@end

NS_ASSUME_NONNULL_END
