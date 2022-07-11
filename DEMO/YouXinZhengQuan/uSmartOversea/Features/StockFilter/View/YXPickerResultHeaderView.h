//
//  YXPickerResultHeaderView.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXPickerResultSortButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXPickerResultHeaderView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, copy) void (^onClickSort)(YXSortState state, NSInteger type);

@property (nonatomic, assign) BOOL isNormal;

@property (nonatomic, assign) BOOL needIcon; //左边是否有市场图标来调整间距

@property (nonatomic, strong) NSDictionary *namesDictionary;

- (void)setDefaultSortState:(YXSortState)state filterType:(NSInteger)type;

- (void)setSortState:(YXSortState)state filterType:(NSInteger)type;

- (instancetype)initWithFrame:(CGRect)frame sortTypes:(NSArray *)sortTypes;

- (void)scrollToVisibleFilterType:(NSInteger)type animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
