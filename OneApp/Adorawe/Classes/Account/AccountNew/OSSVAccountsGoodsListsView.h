//
//  STLAccountHistoryListView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface OSSVAccountsGoodsListsView : UIView

@property (nonatomic, strong) UICollectionView              *collectionView;

- (instancetype)initWithFrame:(CGRect)frame dataType:(AccountGoodsListType)dataType;

@property (nonatomic, copy) void(^selectedGoodsBlock)(id goodsModel, AccountGoodsListType, NSInteger index,NSString *requestId);

/// 个人中心显示浏览历史记录
- (void)refreshRecentlyData;

- (void)resetPageIndexToFirst;

- (BOOL)collectionViewScrollsTopState;

- (void)startFirstRequest;
@end

NS_ASSUME_NONNULL_END
