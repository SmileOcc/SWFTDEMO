//
//  YXStockLineMenuView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASPopover.h"
NS_ASSUME_NONNULL_BEGIN


@interface YXStockPopover : ASPopover


@end

@interface YXStockLineMenuView : UIView

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles;

@property (nonatomic, copy) void (^clickCallBack)(UIButton *);

@property (nonatomic, assign) NSInteger selectIndex;

// 清楚选择
- (void)cleanSelect;

@end

NS_ASSUME_NONNULL_END
