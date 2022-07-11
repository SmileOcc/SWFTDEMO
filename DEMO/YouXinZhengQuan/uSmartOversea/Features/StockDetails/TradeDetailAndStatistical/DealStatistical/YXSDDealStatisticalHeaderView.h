//
//  YXSDDealStatisticalHeaderView.h
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXSDDealStatisticalHeaderView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
// 买卖方向：0：全部，1：主动买入，2：主动卖出 ，3：主动买入&卖出 ，4：中性盘
@property (nonatomic, assign) NSInteger bidOrAskType;

@property (nonatomic, copy) void (^refreshData)(NSInteger sortType, NSInteger sortMode);

- (void)resetSelectBtn;


@end

NS_ASSUME_NONNULL_END
