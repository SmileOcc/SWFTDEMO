//
//  ZFBannerCollectionReusableView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFBannerCollectionView.h"
#import "ZFSubCategoryModel.h"
#import "ZFCateBannerCollectionViewCell.h"
#import "UIView+LayoutMethods.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"

@interface ZFBannerCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *bannerCollectionView;
@property (nonatomic, strong) ZFCateBranchBanner *branchBanner;

@end

@implementation ZFBannerCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)configWithModel:(ZFCateBranchBanner *)branceBanner {
    self.branchBanner = branceBanner;
    
    [self.bannerCollectionView removeFromSuperview];
    [self.contentView addSubview:self.bannerCollectionView];
    [self.bannerCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    [self.bannerCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.branchBanner.bannerArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width  = self.branchBanner.branch > 0 ? collectionView.width / self.branchBanner.branch : collectionView.width;
    return CGSizeMake(width, collectionView.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCateBannerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCateBannerCollectionViewCell class]) forIndexPath:indexPath];
    ZFCateBanner *cateBanner = self.branchBanner.bannerArray[indexPath.row];
    [cell configWithImageURL:cateBanner.image];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bannerHandle) {
        ZFCateBanner *cateBanner = self.branchBanner.bannerArray[indexPath.row];
        ZFBannerModel *bannerModel = [ZFBannerModel new];
        bannerModel.banner_width  = [NSString stringWithFormat:@"%f", cateBanner.width];
        bannerModel.banner_height = [NSString stringWithFormat:@"%f", cateBanner.height];
        bannerModel.bannerCountDown = [NSString stringWithFormat:@"%ld", cateBanner.bannerCountDown];
        bannerModel.isShowCountDown = [NSString stringWithFormat:@"%d", cateBanner.isShowCountDown];
        bannerModel.pic_url = cateBanner.image;
        bannerModel.deeplink_uri = cateBanner.url;
        self.bannerHandle(bannerModel, indexPath.row);
    }
}

- (UICollectionView *)bannerCollectionView {
    if (!_bannerCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        _bannerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _bannerCollectionView.backgroundColor = [UIColor clearColor];
        _bannerCollectionView.delegate   = self;
        _bannerCollectionView.dataSource = self;
        [_bannerCollectionView registerClass:[ZFCateBannerCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCateBannerCollectionViewCell class])];
    }
    return _bannerCollectionView;
}

@end
