//
//  ZFAccountGoodsListView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"

@class ZFGoodsModel;

typedef NS_ENUM(NSInteger, ZFAccountRecommendSelectType) {
    ZFAccountSelect_RecommendType,
    ZFAccountSelect_HistoryType,
};

@interface ZFAccountGoodsListView : UIView

@property (nonatomic, strong) UICollectionView              *collectionView;

- (instancetype)initWithFrame:(CGRect)frame dataType:(ZFAccountRecommendSelectType)dataType;

@property (nonatomic, copy) void(^selectedGoodsBlock)(ZFGoodsModel *, ZFAccountRecommendSelectType);

/// 个人中心显示浏览历史记录
- (void)refreshRecentlyData;

- (void)resetPageIndexToFirst;

@end
