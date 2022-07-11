//
//  YXKLineView.h
//  YXKlineDemo
//
//  Created by rrd on 2018/8/30.
//  Copyright © 2018年 RRD. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IsHKApp   1

#ifdef IsHKApp
#import "YXStockConfig.h"
#endif

@class YXKLineData;
@class YXKLine;

@interface YXKLineView : UIView

- (instancetype)initWithFrame:(CGRect)frame andIsLandscape:(BOOL)isLandscape;


@property (nonatomic, copy) void (^loadMoreDataHandler)(void);


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
 是否可以点击跳转
 */
@property (nonatomic, assign) BOOL canTapPush;

/**
 初始默认高度
 */
@property (nonatomic, assign, readonly) CGFloat defaultHeight;

@property (nonatomic, assign, readonly) CGFloat secondaryViewHeight;


/**
 主线的类型
 Y_StockChartcenterViewTypeKline = 1, //K线
 Y_StockChartcenterViewTypeTimeLine = 2,  //分时图
 Y_StockChartcenterViewTypeOther = 3  //其他
 */
@property (nonatomic, assign) Y_StockChartCenterViewType *mainViewType;

/**
 主参数指标
 */
@property (nonatomic, assign) YXStockMainAcessoryStatus mainAccessoryStatus;

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
 重置k线设置
 */
- (void)resetSetting;

// 重置k线图表选择的顺序
- (void)resetKLineSettingSore;

/**
 是否是港股指数
 */
@property (nonatomic, assign) BOOL isIndexStock;

- (void)resetSubAccessory:(YXStockSubAccessoryStatus)status;

- (void)resetMainAccessory:(YXStockMainAcessoryStatus)status;

/**
 绘制所有选中的副指标
 */
- (void)drawAllSecondaryView;

@property (nonatomic, assign) NSInteger decimalCount;

//持仓成本价
@property (nonatomic, assign) double holdPrice;

//隐藏历史分时按钮
@property (nonatomic, assign) BOOL hideHistoryTimeLine;

/**
 查看历史分时回调
 */
@property (nonatomic, copy) void (^queryQuoteCallBack)(YXKLineData *klineData, YXKLine *kline, NSInteger index);
//取消查看历史分时
@property (nonatomic, copy) void (^cancelQueryQuoteCallBack)(void);

//重置长按状态
- (void)resetLongPressState;

//移动长按十字线位置
- (void)moveCrossLineLayer:(BOOL)isLeftDirection;

/**
    趋势长盈的回调
 0 登录 1 升级  2 详情
 */
@property (nonatomic, copy) void (^usmartLineCallBack)(NSInteger type);

- (int)getMaxPriceValue;
- (int)getminPriceValue;
/**
    当前页面最新日期的变化的回调
 */
@property (nonatomic, copy) void (^lastDayChangeCallBack)(UInt64 time);

@end
