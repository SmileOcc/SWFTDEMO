//
//  OSSVAccountsTableFootView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAccountsGoodsListsView.h"
#import "OSSVAccountsMainsView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectedGoodsBlock)(id goods, AccountGoodsListType, NSInteger index,NSString *requestId);


@interface OSSVAccountsTableFootView : UIView

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
