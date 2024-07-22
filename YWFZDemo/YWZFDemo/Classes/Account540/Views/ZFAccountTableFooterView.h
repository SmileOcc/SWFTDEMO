//
//  ZFAccountTableFooterView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAccountGoodsListView.h"
@class ZFGoodsModel;
typedef void(^SelectedGoodsBlock)(ZFGoodsModel *_Nullable, ZFAccountRecommendSelectType);


NS_ASSUME_NONNULL_BEGIN

@interface ZFAccountTableFooterView : UIView


- (instancetype)initWithFrame:(CGRect)frame
           selectedGoodsBlock:(SelectedGoodsBlock)selectedGoodsBlock;

@property (nonatomic, copy) void (^selectIndexCompletion)(NSInteger index);

- (void)selectCustomIndex:(NSInteger)index;

- (void)setScrollToTopAction;

/// 刷新浏览历史记录
- (void)refreshHistoryListData;

- (void)refreshRecommendToFirst;

@end

NS_ASSUME_NONNULL_END
