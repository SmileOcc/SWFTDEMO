//
//  YXKlineLongPressView.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/26.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXKLineOrderDetailView.h"
#import "YXKLineCompanyActionView.h"
@class YXKLine;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXKlineScreenOrientType){
    
    YXKlineScreenOrientTypePortrait = 1, //竖屏
    YXKlineScreenOrientTypeRight = 2, //横屏
};

@interface YXKlineLongPressView : UIView

@property (nonatomic, assign) YXKlineScreenOrientType oritentType;
@property (nonatomic, strong) YXKLine *kLineSingleModel;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, strong) YXKLineOrderDetailView *orderDetailView;
@property (nonatomic, strong) YXKLineCompanyActionView *companyActionView;
@property (nonatomic, assign) NSInteger decimalCount;
// 是否是科创板
@property (nonatomic, assign) BOOL isGem;

- (instancetype)initWithFrame:(CGRect)frame andType: (YXKlineScreenOrientType)type;

// 隐藏成交量
- (void)hiddenVolume;
// 隐藏成交额
- (void)hiddenAmount;

// 更新科创板的UI
- (void)updateGemUI;

//创建视图
- (void)setUpUI;
// 显示完整时间
@property (nonatomic, assign) BOOL showFullTime;

@end

NS_ASSUME_NONNULL_END
