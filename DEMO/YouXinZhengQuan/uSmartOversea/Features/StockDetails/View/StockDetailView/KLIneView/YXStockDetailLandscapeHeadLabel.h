//
//  YXStockDetailLandscapeHeadLabel.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/12/26.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailLandscapeHeadLabel : UILabel

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *paraLabel;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat titleWidth;

- (void)setRightAlignment;

@end

NS_ASSUME_NONNULL_END
