//
//  YXTimeLineLongPressView.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/23.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXKlineLongPressView.h"
#import "YXKLineOrderDetailView.h"
@class YXTimeLine;

NS_ASSUME_NONNULL_BEGIN

@interface YXTimeLineLongPressView : UIView

@property (nonatomic, strong) YXTimeLine *timeSignalModel;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, assign) YXKlineScreenOrientType oritentType;
@property (nonatomic, strong) YXKLineOrderDetailView *orderDetailView;

- (instancetype)initWithFrame:(CGRect)frame andType: (YXKlineScreenOrientType)type;
- (instancetype)initWithFrame:(CGRect)frame andType: (YXKlineScreenOrientType)type andIsSmall: (BOOL)isSmall;
// 隐藏成交量
- (void)hiddenVolume;

// 隐藏成交额
- (void)hiddenAmount;

@end

NS_ASSUME_NONNULL_END
