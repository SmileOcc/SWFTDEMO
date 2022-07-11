//
//  YXStockPickerAddSelfBottomView.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStockPickerAddSelfBottomView : UIView

@property (nonatomic, assign) NSUInteger checkedCount;
@property (nonatomic, copy) dispatch_block_t onClickChange;
@property (nonatomic, copy) void (^onClickSelectedAll)(BOOL isAll);
@property (nonatomic, strong) UIButton *selectAllButton;
@end

NS_ASSUME_NONNULL_END
