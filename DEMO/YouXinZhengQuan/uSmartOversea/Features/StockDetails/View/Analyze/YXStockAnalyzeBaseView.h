//
//  YXStockAnalyzeBaseView.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStockAnalyzeBaseView : UIView

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, copy) void (^contentHeightChange)(CGFloat height);

@end

NS_ASSUME_NONNULL_END
