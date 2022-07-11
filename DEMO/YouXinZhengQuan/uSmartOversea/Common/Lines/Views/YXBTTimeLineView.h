//
//  YXBTTimeLineView.h
//  uSmartOversea
//
//  Created by youxin on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStockConfig.h"

@class YXKLineData;
@class YXKLine;

@interface YXBTTimeLineView : UIView

- (instancetype)initWithFrame:(CGRect)frame andIsLandscape:(BOOL)isLandscape;


@property (nonatomic, copy) void (^loadMoreDataHandler)(void);


#pragma mark - 配置属性

/**
 蜡烛间隔
 */
@property (nonatomic, assign, readwrite) double space;


/**
 是否可以点击跳转
 */
@property (nonatomic, assign) BOOL canTapPush;

/**
 刷新
 */
- (void)reload;

/**
 开始长按的的command
 */
@property (nonatomic, copy) void (^klineLongPressStartCallBack)(YXKLine *);

/**
 结束长按的command;
 */
@property (nonatomic, copy) void (^klineLongPressEndCallBack)(void);


/**
 跳转至横屏command;
 */
@property (nonatomic, copy) void (^pushToLandscapeRightCallBack)(void);

/**
 双击手势事件回调
 */
@property (nonatomic, copy) void (^doubleTapCallBack)(void);


/**
 加载更多
 */
@property (nonatomic, copy) void (^loadMoreCallBack)(void);



/**
 点击副图
 */
@property (nonatomic, copy) void (^clickSubAccessoryView)(void);


/**
 数据模型
 */
@property (nonatomic, strong) YXKLineData *klineModel;

/**
 绘制所有选中的副指标
 */
- (void)drawAllSecondaryView;

//持仓成本价
@property (nonatomic, assign) double holdPrice;

//小数位数
@property (nonatomic, assign) NSInteger decimalCount;

// 最高价
@property (nonatomic, assign) double high;
// 最低价
@property (nonatomic, assign) double low;

// 最低价
@property (nonatomic, assign) YXRtLineType lineType;

// 1涨  -1跌  0平
@property (nonatomic, assign) NSInteger change;

@end
