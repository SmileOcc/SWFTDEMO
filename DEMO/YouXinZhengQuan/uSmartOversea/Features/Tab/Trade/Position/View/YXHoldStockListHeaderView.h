//
//  YXHoldStockListHeaderView.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXSortButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YXSortBlock)(YXSortState state, YXMobileBrief1Type type);

@interface YXHoldStockListHeaderView : UIView

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, copy) YXSortBlock onClickSort;

- (void)setDefaultSortState:(YXSortState)state mobileBrief1Type:(YXMobileBrief1Type)type;

- (void)setSortState:(YXSortState)state mobileBrief1Type:(YXMobileBrief1Type)type;

- (instancetype)initWithFrame:(CGRect)frame sortTypes:(NSArray *)sortTypes;

- (void)scrollToVisibleMobileBrief1Type:(YXMobileBrief1Type)type animated:(BOOL)animated;

- (void)resetButtonsWithArr:(NSArray *)sortTypes;

@end

NS_ASSUME_NONNULL_END
