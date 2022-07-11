//
//  YXKLineOrderLayer.h
//  uSmartOversea
//
//  Created by youxin on 2020/7/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, YXKLineOrderDirection) {
    YXKLineOrderDirectionBuy,
    YXKLineOrderDirectionSell,
    YXKLineOrderDirectionBoth,
};

typedef NS_ENUM(NSUInteger, YXKLineOrderStyle) {
    YXKLineOrderStyleDefault, //默认样式
    YXKLineOrderStyleArrow,   //底部箭头样式
    YXKLineOrderStyleDashLine     //底部虚线样式
};

typedef NS_ENUM(NSUInteger, YXKLineCompanyActionStyle) {
    YXKLineCompanyActionStyleFinancial, //公司财报
    YXKLineCompanyActionStyleDividend,  //公司分红
    YXKLineCompanyActionStyleBoth       //同一天 既有财报 也有 分红
};

NS_ASSUME_NONNULL_BEGIN

@interface YXKLineOrderLayer : CAShapeLayer

@property (nonatomic, assign) YXKLineOrderDirection orderDirection; //1-Buy, 2-Sell, 3-BuyAndSell

@property (nonatomic, assign) YXKLineOrderStyle drawStyle;

@property (nonatomic, assign) CGFloat startX;

@end


@interface YXKLineCompanyActionLayer : CALayer

@property (nonatomic, assign) YXKLineCompanyActionStyle actionStyle;

@end

NS_ASSUME_NONNULL_END
