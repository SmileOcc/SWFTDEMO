//
//  YXKLineSecondaryView.h
//  uSmartOversea
//
//  Created by youxin on 2020/6/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStockConfig.h"
#import "YXLayerGenerator.h"
#import "YXAccessoryTitleGenerator.h"

#define kSecondaryTopFixMargin  35
NS_ASSUME_NONNULL_BEGIN

@interface YXKLineSecondaryView : UIView


/// 初始化方法
/// @param frame frame
/// @param status 副指标
/// @param titleGenerator 指标数值Label生成器
/// @param generator 指标layer生成器
- (instancetype)initWithFrame:(CGRect)frame
                    subStatus:(YXStockSubAccessoryStatus)status
               titleGenerator:(YXAccessoryTitleGenerator *)titleGenerator
               layerGenerator:(YXLayerGenerator *)generator;

@property (nonatomic, assign) YXStockSubAccessoryStatus subStatus;

@property (nonatomic, strong) UILabel *subMaxPriceLabel;

@property (nonatomic, strong) UILabel *subMidPriceLabel;

@property (nonatomic, strong) UILabel *subMinPriceLabel;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *titleLabel;
@end

NS_ASSUME_NONNULL_END
