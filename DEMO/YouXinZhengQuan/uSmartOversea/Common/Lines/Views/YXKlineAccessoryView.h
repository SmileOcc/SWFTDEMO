//
//  YXKlineAccessoryView.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/10/12.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStockDetailUtility.h"
#import "YXStockConfig.h"

@class YXV2Quote;

NS_ASSUME_NONNULL_BEGIN
//指标参数
@interface YXKlineAccessoryView : UIView

//复权类型
@property (nonatomic, copy) void (^adjustTypeCallBack)(YXKlineAdjustType tag);
//主指标
@property (nonatomic, copy) void (^mainParameterCallBack)(YXStockMainAcessoryStatus tag);
//副指标
@property (nonatomic, copy) void (^subParameterCallBack)(YXStockSubAccessoryStatus tag);
//筹码分布
@property (nonatomic, copy) void (^chipsCYQCallBack)(BOOL isSelect);

@property (nonatomic, assign) BOOL showCYQ; //是否展示筹码分布

@property (nonatomic, strong, nullable) YXV2Quote *quoteModel;

- (instancetype)initWithFrame:(CGRect)frame isLand:(BOOL)isLand;

//重置主副指标
- (void)resetMainAndSubStatus;

//设置幅图指标状态
- (void)resetSubStatus;

//k线设置更改后修改布局
- (void)setUpUI;

@end

NS_ASSUME_NONNULL_END
