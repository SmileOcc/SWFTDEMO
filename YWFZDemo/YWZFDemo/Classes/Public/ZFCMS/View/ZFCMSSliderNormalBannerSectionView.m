//
//  ZFCMSSliderBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSSliderNormalBannerSectionView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFCMSNormalBannerCell.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCMSSliderNormalBannerSectionView ()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;
@end

@implementation ZFCMSSliderNormalBannerSectionView

+ (ZFCMSSliderNormalBannerSectionView *)reusableNormalBanner:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath{
    ZFCMSSliderNormalBannerSectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFCMSSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    self.contentView.backgroundColor = sectionModel.bgColor;
    self.collectionView.backgroundColor = sectionModel.bgColor;
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(sectionModel.sliderScrollViewOffsetX, 0)];
}

-(void)setChannel_id:(NSString *)channel_id
{
    _channel_id = channel_id;
    self.analyticsAOP.channel_id = _channel_id;
}

- (void)setChannel_name:(NSString *)channel_name {
    _channel_name = channel_name;
    self.analyticsAOP.channel_name = _channel_name;
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionModel.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.list.count > indexPath.item) {
        ZFCMSNormalBannerCell *cell = [ZFCMSNormalBannerCell reusableNormalBannerCell:collectionView forIndexPath:indexPath];
        cell.itemModel = self.sectionModel.list[indexPath.item];
        return cell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionModel.list.count > indexPath.item) {
        CGFloat display_count = [self.sectionModel.display_count floatValue];
        // 水平外边距
        CGFloat horizontalOutsideMagin = self.sectionModel.padding_left + self.sectionModel.padding_right;
        // 水平内边距
        CGFloat horizontalInsideMagin = self.sectionModel.attributes.padding_left + self.sectionModel.attributes.padding_right;
        // 水平总边距
        CGFloat allMagin = horizontalOutsideMagin + horizontalInsideMagin * ceil(display_count);
        
        CGFloat imageWidth = (KScreenWidth - allMagin) / display_count;
        CGFloat imageHeight = ([self.sectionModel.prop_h floatValue] * imageWidth) / [self.sectionModel.prop_w floatValue];
        return CGSizeMake(imageWidth, imageHeight);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.normalBannerClick && self.sectionModel.list.count > indexPath.item) {
        ZFCMSItemModel *itemModel = self.sectionModel.list[indexPath.item];
        self.normalBannerClick(itemModel);
    }
}

// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.sectionModel.attributes.padding_left;
}

// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.sectionModel.attributes.padding_top;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(self.sectionModel.padding_top + self.sectionModel.attributes.padding_top,
                            self.sectionModel.padding_left + self.sectionModel.attributes.padding_left,
                            self.sectionModel.padding_bottom + self.sectionModel.attributes.padding_bottom,
                            self.sectionModel.padding_right + self.sectionModel.attributes.padding_right);

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.sectionModel.sliderScrollViewOffsetX  = scrollView.contentOffset.x;
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        [_collectionView registerClass:[ZFCMSNormalBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSNormalBannerCell class])];
    }
    return _collectionView;
}

-(ZFCMSSKUBannerAnalyticsAOP *)analyticsAOP
{
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCMSSKUBannerAnalyticsAOP alloc] init];
    }
    return _analyticsAOP;
}

@end
