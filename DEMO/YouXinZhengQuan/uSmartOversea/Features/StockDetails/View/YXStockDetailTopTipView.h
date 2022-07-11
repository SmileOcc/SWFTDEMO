//
//  YXStockDetailTopTipView.h
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailTopTipView : UIView

@property (nonatomic, assign) BOOL isTrade; //是否是交易界面
@property (nonatomic, assign) BOOL isTradeBmp; //是否是交易界面的bmp
@property (nonatomic, copy) void (^closeCallBack)(void);

- (void)resetTitle;

@end

NS_ASSUME_NONNULL_END
