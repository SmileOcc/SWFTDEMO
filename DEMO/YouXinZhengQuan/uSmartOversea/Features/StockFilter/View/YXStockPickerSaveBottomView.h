//
//  YXStockPickerSaveBottomView.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStockPickerSaveBottomView : UIView

@property (nonatomic, copy) dispatch_block_t onClickSave;
@property (nonatomic, copy) void (^onClickSelected)(void);
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *saveButton;

- (void)hiddenSaveButton;
@end

NS_ASSUME_NONNULL_END
