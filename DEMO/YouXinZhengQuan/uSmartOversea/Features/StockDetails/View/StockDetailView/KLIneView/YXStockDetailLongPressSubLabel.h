//
//  YXStockDetailLongPressSubLabel.h
//  uSmartOversea
//
//  Created by youxin on 2021/4/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailLongPressSubLabel : UILabel

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *paraLabel;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat maxTitleWidth;

- (void)setRightAlignment;

@end
NS_ASSUME_NONNULL_END
