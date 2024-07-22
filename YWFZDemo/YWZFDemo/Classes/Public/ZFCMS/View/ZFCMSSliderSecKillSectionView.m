//
//  ZFCMSSliderSecKillSectionView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSSliderSecKillSectionView.h"
#import "ZFBannerTimeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFCMSSecKillSkuCell.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCMSSliderSecKillSectionView ()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView                        *topContentView;
@property (nonatomic, strong) UILabel                       *titleLabel;
@property (nonatomic, strong) ZFBannerTimeView              *countDownView;
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, strong) UICollectionView              *collectionView;
@property (nonatomic, strong) ZFCMSItemModel                *countDownTimeModel;

@end

@implementation ZFCMSSliderSecKillSectionView

+ (ZFCMSSliderSecKillSectionView *)reusableSecKillView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    ZFCMSSliderSecKillSectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
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
    [self.contentView addSubview:self.topContentView];
    [self.topContentView addSubview:self.titleLabel];
    [self.topContentView addSubview:self.countDownView];
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(0);
        make.height.mas_equalTo(kSecKillSkuHeaderHeight);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topContentView.mas_leading).offset(-3);
        make.centerY.mas_equalTo(self.topContentView.mas_centerY);
        make.height.mas_equalTo(kSecKillSkuHeaderHeight);
        make.width.mas_lessThanOrEqualTo(KScreenWidth-125);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topContentView.mas_centerY);
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(6);
        make.trailing.mas_equalTo(self.topContentView.mas_trailing);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topContentView.mas_bottom).offset(0);
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
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
    
    self.titleLabel.text = ZFToString(sectionModel.attributes.text);
    self.titleLabel.font = ZFFontSystemSize(sectionModel.attributes.text_size);
    self.titleLabel.textColor = sectionModel.attributes.textColor;
    
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
    
    // 倒计时
    [self showCountDownView:self.sectionModel.list.firstObject];
}

/**
 * 显示倒计时数据
 */
- (void)showCountDownView:(ZFCMSItemModel *)countDownTimeModel {
    if (![countDownTimeModel isKindOfClass:[ZFCMSItemModel class]] ||
        [_countDownTimeModel isEqual:countDownTimeModel]) {
        return;
    }
    _countDownTimeModel = countDownTimeModel;
    if (_countDownView) {
        self.countDownView.hidden = YES;
    }
    
    unsigned long long timcountdownTime = [countDownTimeModel.countdown_time longLongValue];
    if (timcountdownTime > 0 && !ZFIsEmptyString(countDownTimeModel.countDownCMSTimerKey)) {
        YWLog(@"更新配置倒计时位置2===%@", countDownTimeModel.countDownCMSTimerKey);
        self.countDownView.hidden = NO;
        //开启倒计时任务
        [self.countDownView startCountDownTimerStamp:countDownTimeModel.countdown_time
                                        withTimerKey:countDownTimeModel.countDownCMSTimerKey];
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionModel.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.list.count > indexPath.item) {
        ZFCMSSecKillSkuCell *skuCell = [ZFCMSSecKillSkuCell reusableSecKillSkuCell:collectionView forIndexPath:indexPath];
        skuCell.itemModel = self.sectionModel.list[indexPath.item];
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
        CGFloat verticalCellInsideSpace = [ZFCMSSecKillSkuCell cmsVerticalHeightNoContainImage];

        return CGSizeMake(imageWidth, imageHeight + verticalCellInsideSpace);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.sliderSkuClick && self.sectionModel.list.count > indexPath.item) {
        ZFCMSItemModel *itemModel = self.sectionModel.list[indexPath.item];
        self.sliderSkuClick(itemModel);
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

- (UIView *)topContentView {
    if (!_topContentView) {
        _topContentView = [[UIView alloc] init];
        _topContentView.backgroundColor = [UIColor whiteColor];
    }
    return _topContentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor colorWithHex:0x000000];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (ZFBannerTimeView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFBannerTimeView alloc] init];
        _countDownView.hidden = YES;
    }
    return _countDownView;
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
        
        [_collectionView registerClass:[ZFCMSSecKillSkuCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSSecKillSkuCell class])];
    }
    return _collectionView;
}

-(ZFCMSRecentlyAnalyticsAOP *)sliderSKUanalyticsAOP {
    if (!_sliderSKUanalyticsAOP) {
        _sliderSKUanalyticsAOP = [[ZFCMSRecentlyAnalyticsAOP alloc] init];
    }
    return _sliderSKUanalyticsAOP;
}

@end
