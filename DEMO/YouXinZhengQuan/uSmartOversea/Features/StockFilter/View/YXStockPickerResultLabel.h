//
//  YXStockPickerResultLabel.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YXStockPickerList;
@interface YXStockPickerResultLabel : UILabel
//
@property (nonatomic, assign) NSInteger filterType;

@property (nonatomic, assign) YXStockPickerList *model;

+ (instancetype)labelWithFilterType:(NSInteger)filterType;

@end

NS_ASSUME_NONNULL_END
