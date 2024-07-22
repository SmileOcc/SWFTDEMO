//
//  ZFCMSSliderSKUBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSSliderSKUBannerSectionView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFCMSSkuBannerCell.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCMSSliderSKUBannerSectionView ()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;

@end

@implementation ZFCMSSliderSKUBannerSectionView

+ (ZFCMSSliderSKUBannerSectionView *)reusableSkuBanner:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    ZFCMSSliderSKUBannerSectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.sliderSKUanalyticsAOP];
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
        make.top.leading.trailing.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Setter

- (void)setChannel_id:(NSString *)channel_id {
    _channel_id = channel_id;
    self.sliderSKUanalyticsAOP.channel_id = _channel_id;
}

- (void)setChannel_name:(NSString *)channel_name {
    _channel_name = channel_name;
    self.sliderSKUanalyticsAOP.channel_name = _channel_name;
}

- (void)setSectionModel:(ZFCMSSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    if (sectionModel.subType == ZFCMS_HistorSku_SubType) {
        self.titleLabel.hidden = NO;
        self.clearButton.hidden = NO;
        
        //FIXME: occ v460
        CGFloat bottomMagin = 0;//self.sectionModel.padding_bottom;
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(kHistorSkuHeaderHeight);
            make.bottom.mas_equalTo(self.contentView).offset(-bottomMagin);
        }];
    } else {
        if (_titleLabel && _clearButton) {
            _titleLabel.hidden = YES;
            _clearButton.hidden = YES;
            [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView).offset(0);
                make.bottom.mas_equalTo(self.contentView).offset(0);
            }];
        }
    }
    self.contentView.backgroundColor = sectionModel.bgColor;
    self.collectionView.backgroundColor = sectionModel.bgColor;
    [self.collectionView reloadData];
    
    if (sectionModel.sliderScrollViewOffsetX < 0) { //标识阿语滚到最后    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (self.collectionView.numberOfSections > indexPath.section) {
            NSInteger sectionRowCount = [self.collectionView numberOfItemsInSection:indexPath.section];
            if (sectionRowCount > indexPath.item) {
                [self.collectionView scrollToItemAtIndexPath:indexPath
                                            atScrollPosition:(UICollectionViewScrollPositionNone)
                                                    animated:NO];
            }
        }
    } else {
        [self.collectionView setContentOffset:CGPointMake(sectionModel.sliderScrollViewOffsetX, 0)];
    }
}

- (void)clearHistoryAction:(UIButton *)clearBtn {
    if (self.clickClearHistSkuBlock) {
        self.clickClearHistSkuBlock();
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionModel.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.list.count > indexPath.item) {
        ZFCMSSkuBannerCell *skuCell = [ZFCMSSkuBannerCell reusableSkuBannerCell:collectionView forIndexPath:indexPath];
        skuCell.itemModel = self.sectionModel.list[indexPath.item];
        skuCell.attributes = self.sectionModel.attributes;
        return skuCell;
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
        return CGSizeMake(imageWidth, imageHeight + kGoodsPriceHeight);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.clickSliderSkuBlock && self.sectionModel.list.count > indexPath.item) {
        ZFCMSItemModel *itemModel = self.sectionModel.list[indexPath.item];
        self.clickSliderSkuBlock(itemModel);
    }
}

// 两行之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.sectionModel.attributes.padding_left;
}

// 两个cell之间的上下间距
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor colorWithHex:0x000000];
        _titleLabel.text = ZFLocalizedString(@"Home_Channel_Recently_Title", nil);
        _titleLabel.hidden = YES;
        [self.contentView addSubview:_titleLabel];
        
        CGFloat topMagin = self.sectionModel.padding_top;
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16.0);
            make.top.mas_equalTo(self.contentView.mas_top).offset(topMagin);
            make.height.mas_equalTo(kHistorSkuHeaderHeight);
        }];
    }
    return _titleLabel;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_clearButton setTitleColor:[UIColor colorWithHex:0x2d2d2d] forState:UIControlStateNormal];
        _clearButton.layer.borderColor = [UIColor colorWithHex:0x999999].CGColor;
        _clearButton.layer.borderWidth = 1.0;
        [_clearButton setTitle:ZFLocalizedString(@"Home_Channel_Recently_Clear", nil) forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearHistoryAction:) forControlEvents:UIControlEventTouchUpInside];
        _clearButton.hidden = YES;
        [self.contentView addSubview:_clearButton];
        
        [_clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16.0);
            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
            make.height.mas_equalTo(26.0);
            make.width.mas_equalTo(64.0);
        }];
    }
    return _clearButton;
}

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
        
        [_collectionView registerClass:[ZFCMSSkuBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSSkuBannerCell class])];
    }
    return _collectionView;
}

-(ZFCMSRecentlyAnalyticsAOP *)sliderSKUanalyticsAOP
{
    if (!_sliderSKUanalyticsAOP) {
        _sliderSKUanalyticsAOP = [[ZFCMSRecentlyAnalyticsAOP alloc] init];
    }
    return _sliderSKUanalyticsAOP;
}

@end
