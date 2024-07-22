//
//  ZFNativeSlideBannerCell.m
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeSlideBannerCell.h"
#import "ZFNativeBannerBranchCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFNativeBannerModel.h"
#import "ZFBannerModel.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFNativeSlideBannerCell ()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;
@end

@implementation ZFNativeSlideBannerCell
+ (ZFNativeSlideBannerCell *)sliderBannerCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFNativeSlideBannerCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
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
    return self.scrollerBannerArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFNativeBannerBranchCell *cell = [ZFNativeBannerBranchCell branchBannerCellWith:collectionView forIndexPath:indexPath];
    cell.branchBannerModel = self.scrollerBannerArray[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFNativeBannerModel *bannerModel = self.scrollerBannerArray[indexPath.item];
    CGFloat width = (KScreenWidth - 60)/2;
    CGFloat height = [bannerModel.bannerHeight floatValue] * width / [bannerModel.bannerWidth floatValue];
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.scrollerBannerArray.count > indexPath.item) {
        ZFNativeBannerModel *model = self.scrollerBannerArray[indexPath.item];
        ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
        bannerModel.deeplink_uri = model.deeplinkUri;
        if (self.sliderBannerClick) {
            self.sliderBannerClick(bannerModel);
        }
    }
}
#pragma mark - Setter
- (void)setScrollerBannerArray:(NSArray<ZFNativeBannerModel *> *)scrollerBannerArray {
    _scrollerBannerArray = scrollerBannerArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset         = UIEdgeInsetsMake(0, 0, 0, 0);
        _flowLayout.minimumLineSpacing         = 0.0f;
        _flowLayout.minimumInteritemSpacing    = 0.0f;
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
