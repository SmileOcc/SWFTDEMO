//
//  YXBrokerAnalyzeView.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBrokerLineView.h"
#import "YXHkVolumnSectionHeaderView.h"
#import "YXStockAnalyzeBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXBrokerAnalyzeView : YXStockAnalyzeBaseView

@property (nonatomic, assign, readonly) CGFloat lineHeight;

@property (nonatomic, strong) YXBrokerLineView *lineView;
///港股通才有
@property (nonatomic, strong) YXHkVolumnSectionHeaderView *volumnChangeView;

- (instancetype)initWithFrame:(CGRect)frame andType:(YXBrokerLineType)type;

@end

NS_ASSUME_NONNULL_END
