//
//  YXEditStockBottomView.h
//  uSmartOversea
//
//  Created by ellison on 2018/10/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickSelectedAllBlock)(BOOL);

NS_ASSUME_NONNULL_BEGIN

@interface YXEditSecuBottomView : UIView

@property (nonatomic, assign) NSUInteger checkedCount;
@property (nonatomic, copy) dispatch_block_t onClickChange;
@property (nonatomic, copy) dispatch_block_t onClickDelete;
@property (nonatomic, copy) ClickSelectedAllBlock onClickSelectedAll;
@property (nonatomic, strong) QMUIButton *selectAllButton;

@end

NS_ASSUME_NONNULL_END
