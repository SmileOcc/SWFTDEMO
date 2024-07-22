//
//  ZFCommunityLiveRecommendGoodsView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveRecommendGoodsView.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ZFBranchAnalytics.h"
#import "ZFAppsflyerAnalytics.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "ZFAnalytics.h"

#import "ZFCommunityLiveVideoGoodsCCell.h"
#import "ZFCommunityLiveVideoGoodsModel.h"


@interface ZFCommunityLiveRecommendGoodsView ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) NSArray *goods;

@property (nonatomic, strong) UIView                            *topView;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UIButton                          *closeButton;
@property (nonatomic, strong) UIView                            *lineView;

@property (nonatomic, strong) UICollectionView                  *collectionView;

@end

@implementation ZFCommunityLiveRecommendGoodsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.backgroundColor = ZFC0xFFFFFF();
        [self addSubview:self.topView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.closeButton];
        [self addSubview:self.lineView];
        [self addSubview:self.collectionView];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(40);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.topView.mas_centerX);
            make.centerY.mas_equalTo(self.topView.mas_centerY);
            make.width.mas_lessThanOrEqualTo(200);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.topView.mas_leading).offset(8);
            make.centerY.mas_equalTo(self.topView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(28, 28));
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self.topView);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.top.mas_equalTo(self.topView.mas_bottom);
        }];
        
    }
    return self;
}


- (void)updateGoodsData:(NSArray *)goods {
    if (_goods != goods) {
        _goods = goods;
        [self.collectionView reloadData];
    }
}

- (NSArray *)goods {
    if (!_goods) {
        _goods = @[];
    }
    return _goods;
}

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock(YES);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goods.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    @weakify(self)
    ZFCommunityLiveVideoGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoGoodsCCell class]) forIndexPath:indexPath];
    
    if (self.goods.count > indexPath.row) {
        ZFGoodsModel *goodsModel = self.goods[indexPath.row];
        cell.goodsModel = goodsModel;
    }
    
    
    cell.cartBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
        @strongify(self)
        if (self.addCartBlock) {
            self.addCartBlock(goodsModel);
        }
    };
    
    cell.findSimilarBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
        @strongify(self)
        if (self.similarGoodsBlock) {
            self.similarGoodsBlock(goodsModel);
        }
    };
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.goods.count > indexPath.row) {
        ZFGoodsModel *goodsModel = self.goods[indexPath.row];
        if (self.recommendGoodsBlock) {
            self.recommendGoodsBlock(goodsModel);
        }
    }
}


#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===


/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(300, 144);
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return  0;
}


#pragma mark - Property Method

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = ZFLocalizedString(@"Community_Lives_Live_Goods", nil);
        _titleLabel.textColor = ZFC0x2D2D2D();
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _lineView;
}

- (UICollectionView *)collectionView {
    if(!_collectionView){
        
        CHTCollectionViewWaterfallLayout *waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        waterfallLayout.minimumColumnSpacing = 13;
        waterfallLayout.minimumInteritemSpacing = 0;
        waterfallLayout.headerHeight = 0;
        waterfallLayout.columnCount = 1;
        
        CGRect frameRect = self.bounds;
        if (CGSizeEqualToSize(frameRect.size, CGSizeZero)) {
            frameRect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 150);
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:frameRect collectionViewLayout:waterfallLayout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[ZFCommunityLiveVideoGoodsCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoGoodsCCell class])];
    }
    return _collectionView;
}

@end
