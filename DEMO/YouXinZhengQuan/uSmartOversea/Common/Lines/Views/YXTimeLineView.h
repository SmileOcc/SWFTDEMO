//
//  YXTimeLineView.h
//  YXKlineDemo
//
//  Created by rrd on 2018/8/30.
//  Copyright © 2018年 RRD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YXTimeLineChartType) {
    YXTimeLineChartTypeDefault,   //默认，当日分时
    YXTimeLineChartTypeHistory,   //历史分时
    YXTimeLineChartTypePreAfter   //盘前盘后
};


@class YXTimeLineData;
@class YXTimeLine;
@interface YXTimeLineView : UIView

//加载更多
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
 是否是横屏 默认NO
 */
@property (nonatomic, assign) BOOL isLandscape;

/**
 分时线类型
 */
@property (nonatomic, assign) YXTimeLineChartType chartType;

/**
 刷新
 */
- (void)reload;

/**
 开始长按的的回调
*/
@property (nonatomic, copy) void (^timeLineLongPressStartCallBack)(YXTimeLine *);

/**
 结束长按的回调;
 */
@property (nonatomic, copy) void (^timeLineLongPressEndCallBack)(void);
/**
 跳转至横屏回调;
 */
@property (nonatomic, copy) void (^pushToLandscapeRightCallBack)(void);

/**
 双击手势事件回调
 */
@property (nonatomic, copy) void (^doubleTapCallBack)(void);

@property (nonatomic, strong) YXTimeLineData *timeLineModel;

/**
 是否是港股指数
 */
@property (nonatomic, assign) BOOL isIndexStock;

// 是否是科创板
@property (nonatomic, assign) BOOL isGem;

// 最高价
@property (nonatomic, assign) double high;
// 最低价
@property (nonatomic, assign) double low;

//持仓成本价
@property (nonatomic, assign) double holdPrice;

//是否有订单数据
@property (nonatomic, assign) BOOL hasOrder;

// 1涨  -1跌  0平
@property (nonatomic, assign) NSInteger change;

//清空数据
- (void)cleanData;

@end
