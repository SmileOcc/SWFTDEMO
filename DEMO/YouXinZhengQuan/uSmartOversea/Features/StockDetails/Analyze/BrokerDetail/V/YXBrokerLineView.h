//
//  YXBrokerLineView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBrokerDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXBrokerLineType) {
    YXBrokerLineTypeBroker = 0, // 经纪商
    YXBrokerLineTypeHkwolun = 1, // 港股通
    YXBrokerLineTypeSell = 2, // 卖空比例
};

@interface YXBrokerLineView : UIView

#pragma mark - 配置属性
/**
 显示的蜡烛数量
 */
@property (nonatomic, assign, readwrite) NSUInteger visibleCount;

/**
 显示的最小蜡烛数量
 */
@property (nonatomic, assign, readwrite) NSUInteger visibleMinCount;

/**
 显示的最大蜡烛数量
 */
@property (nonatomic, assign, readwrite) NSUInteger visibleMaxCount;

/**
 蜡烛间隔
 */
@property (nonatomic, assign, readwrite) double space;

/**
 刷新
 */
//- (void)reload;


- (void)resetData;

/**
 加载更多
 */
@property (nonatomic, copy) void (^loadMoreCallBack)(void);

@property (nonatomic, strong) YXBrokerDetailModel *klineModel;

- (instancetype)initWithFrame:(CGRect)frame andType:(YXBrokerLineType)type;

@end

NS_ASSUME_NONNULL_END
