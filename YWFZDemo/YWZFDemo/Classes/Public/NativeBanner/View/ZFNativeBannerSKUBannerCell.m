//
//  ZFNativeBannerSKUBannerCell.m
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerSKUBannerCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFNativeSKUBannerGoodsCell.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFNativeBannerSKUBannerCell ()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;
@end

@implementation ZFNativeBannerSKUBannerCell
+ (ZFNativeBannerSKUBannerCell *)SKUBannerCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFNativeBannerSKUBannerCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self.contentView setBackgroundColor:ZFCOLOR(247, 247, 247, 1)];
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFNativeSKUBannerGoodsCell *cell = [ZFNativeSKUBannerGoodsCell SKUGoodsListCellWith:collectionView forIndexPath:indexPath];
    cell.isShowViewMore = ((self.goodsList.count >= 12) && (indexPath.item == self.goodsList.count - 1)) ? YES : NO;
    cell.goodsModel = self.goodsList[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat bannerWidth = 97;
    CGFloat bannerHeight = (bannerWidth / KImage_SCALE) + 28;
    return CGSizeMake(bannerWidth, bannerHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.goodsList.count > indexPath.item) {
        ZFGoodsModel *model = self.goodsList[indexPath.item];
        if (self.skuBannerGoodsBlock) {
            self.skuBannerGoodsBlock(((self.goodsList.count >= 12) && (indexPath.item == self.goodsList.count - 1)) ? nil : model, (NSInteger)indexPath.item);
        }
    }
}

#pragma mark - Setter
- (void)setGoodsList:(NSArray<ZFGoodsModel *> *)goodsList {
    _goodsList = goodsList;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumInteritemSpacing = 5;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}


@end
