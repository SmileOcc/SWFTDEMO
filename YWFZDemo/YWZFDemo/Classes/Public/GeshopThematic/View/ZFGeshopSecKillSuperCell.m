//
//  ZFGeshopSecKillSuperCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSecKillSuperCell.h"
#import "ZFBannerTimeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFGeshopSecKilGoodsCell.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "NSStringUtils.h"
#import "ZFGoodsDetailViewController.h"
#import "AnalyticsInjectManager.h"
#import "ZFGeshopNavtiveAOP.h"
#import "SystemConfigUtils.h"

@interface ZFGeshopSecKillSuperCell ()<ZFInitViewProtocol,UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) ZFGeshopNavtiveAOP            *nativeThemeAop;
@property (nonatomic, strong) YYAnimatedImageView           *topContentView;
@property (nonatomic, strong) UILabel                       *titleLabel;
@property (nonatomic, strong) UIView                        *countDownBgView;
@property (nonatomic, strong) UILabel                       *countDownTitleLabel;
@property (nonatomic, strong) ZFBannerTimeView              *countDownView;
@property (nonatomic, strong) UICollectionView              *collectionView;
@end

@implementation ZFGeshopSecKillSuperCell

@synthesize sectionModel = _sectionModel;

- (void)dealloc {
    [self removeNotification];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.nativeThemeAop];
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.topContentView];
    [self.topContentView addSubview:self.titleLabel];
    
    [self.topContentView addSubview:self.countDownBgView];
    [self.countDownBgView addSubview:self.countDownTitleLabel];
    [self.countDownBgView addSubview:self.countDownView];
    
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(80);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.topContentView);
        make.top.mas_equalTo(self.topContentView).offset(4);
        make.height.mas_equalTo(80/2);
    }];
    
    [self.countDownBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(-8);
        make.centerX.mas_equalTo(self.topContentView.mas_centerX);
        make.height.mas_equalTo(80/2);
    }];
    
    [self.countDownTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.countDownBgView.mas_top);
        make.leading.mas_equalTo(self.countDownBgView.mas_leading);
        make.bottom.mas_equalTo(self.countDownBgView.mas_bottom);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.countDownTitleLabel.mas_centerY);
        make.leading.mas_equalTo(self.countDownTitleLabel.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.countDownBgView.mas_trailing);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topContentView.mas_bottom).offset(0);
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    
    NSString *bg_color = self.sectionModel.component_style.bg_color;
    self.contentView.backgroundColor = [UIColor colorWithAlphaHexColor:bg_color
                                                             defaultColor:ZFCOLOR_WHITE];
    
    NSString *text_bg_color = self.sectionModel.component_style.text_bg_color;
    self.topContentView.backgroundColor = [UIColor colorWithAlphaHexColor:text_bg_color
                                                             defaultColor:ColorHex_Alpha(0xD8D8D8, 1)];
    
    NSString *titleColor = self.sectionModel.component_style.text_color;
    self.titleLabel.textColor = [UIColor colorWithAlphaHexColor:titleColor
                                                   defaultColor:ZFC0x333333()];
    
    NSString *statusColor = self.sectionModel.component_style.time_text_bg_color;
    self.countDownTitleLabel.textColor = [UIColor colorWithAlphaHexColor:statusColor
                                                            defaultColor:ZFC0x333333()];
    
    /// 秒杀标题
    NSString *navigator_title = sectionModel.component_data.title;
    if (ZFIsEmptyString(navigator_title)) {
        navigator_title = ZFLocalizedString(@"Flash_sale", nil);
    }
    self.titleLabel.text = navigator_title;
    
    ///秒杀状态
    [self refreshSecKillTitle];
    
    /// 秒杀倒计时
    [self showGeshopCountDownView:self.sectionModel.component_data];
    
    
    self.nativeThemeAop.selectedSort = @"SecKill";
    self.nativeThemeAop.nativeThemeId = sectionModel.nativeThemeId;
    self.nativeThemeAop.nativeThemeName = sectionModel.nativeThemeName;
    self.collectionView.backgroundColor = self.contentView.backgroundColor;
    [self.collectionView reloadData];
    
    /// 秒杀列表
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

/// 显示倒计时数据
- (void)showGeshopCountDownView:(ZFGeshopComponentDataModel *)countDownTimeModel {
    if (![countDownTimeModel isKindOfClass:[ZFGeshopComponentDataModel class]]) {
        return;
    }
    if (_countDownView) {
        self.countDownView.hidden = YES;
    }

    unsigned long long timcountdownTime = [countDownTimeModel.countdown_time longLongValue];
    if (timcountdownTime >= 0 && !ZFIsEmptyString(countDownTimeModel.geshopCountDownTimerKey)) {
        self.countDownView.hidden = NO;
        
        NSString *textBgColor = self.sectionModel.component_style.time_text_bg_color;
        self.countDownView.textBgColor = [UIColor colorWithAlphaHexColor:textBgColor
                                                            defaultColor:ZFC0x333333()];
        
        self.countDownView.dotColor = [UIColor colorWithAlphaHexColor:textBgColor
                                                         defaultColor:ZFCOLOR_WHITE];
        
        NSString *timeTextColor = self.sectionModel.component_style.time_text_color;
        self.countDownView.textColor = [UIColor colorWithAlphaHexColor:timeTextColor
                                                          defaultColor:ZFCOLOR_WHITE];
        
        
        YWLog(@"Geshop开启倒计时任务===%@", countDownTimeModel.geshopCountDownTimerKey);
        [self.countDownView startCountDownTimerStamp:countDownTimeModel.countdown_time
                                        withTimerKey:countDownTimeModel.geshopCountDownTimerKey];
    }
}

///秒杀状态
- (void)refreshSecKillTitle {
    long start_time = [self.sectionModel.component_data.tsk_begin_time longLongValue];
    long end_time = [self.sectionModel.component_data.tsk_end_time longLongValue];
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    long currentStamp = [dat timeIntervalSince1970];
    
    if (currentStamp < start_time) { //开没开始
        self.countDownTitleLabel.text = ZFLocalizedString(@"Starts_at", nil);
        
    } else if (currentStamp > start_time && currentStamp < end_time) { //已经开始
        self.countDownTitleLabel.text = ZFLocalizedString(@"Ends_in", nil);
        
    } else { //已经过期
        self.countDownTitleLabel.text = ZFLocalizedString(@"Already Ended", nil);
    }
}

#pragma mark - <倒计时>

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCountDownTimer) name:kTimerManagerUpdate object:nil];
}

///刷新倒计时
- (void)reloadCountDownTimer {
    NSString *startTimerKey = self.sectionModel.component_data.geshopCountDownTimerKey;
    if (!startTimerKey) return;
    
    double startTime = [[ZFTimerManager shareInstance] timeInterval:startTimerKey];
    double leftTimeStamp = [self.sectionModel.component_data.countdown_time doubleValue];
    int timeOut = leftTimeStamp - startTime;
    if(timeOut <= 0){ //倒计时结束刷新标题
        [self refreshSecKillTitle];
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionModel.component_data.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.component_data.list.count > indexPath.item) {
        ZFGeshopSecKilGoodsCell *skuCell = [ZFGeshopSecKilGoodsCell reusableSecKillSkuCell:collectionView forIndexPath:indexPath];
        skuCell.indexPath = indexPath;
        skuCell.sectionModel = self.sectionModel;
        return skuCell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (self.sectionModel.component_data.list.count > indexPath.item) {
        ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[indexPath.item];
        [self pushToGoodsDetailVC:listModel.goods_id indexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.sectionModel.sliderScrollViewOffsetX  = scrollView.contentOffset.x;
}

- (void)pushToGoodsDetailVC:(NSString *)goods_id indexPath:(NSIndexPath *)indexPath {
    ZFGoodsDetailViewController *goodsDetailVC = [[ZFGoodsDetailViewController alloc] init];
    goodsDetailVC.goodsId = ZFToString(goods_id);
    goodsDetailVC.sourceID = self.sectionModel.nativeThemeId;
    goodsDetailVC.sourceType = ZFAppsflyerInSourceTypeNativeTopic;
//    goodsDetailVC.analyticsSort = self.nativeThemeAop.selectedSort;
    goodsDetailVC.af_rank = indexPath.item + 1;
    [self.navigationController pushViewController:goodsDetailVC animated:YES];
}

#pragma mark - Getter

- (YYAnimatedImageView *)topContentView {
    if (!_topContentView) {
        _topContentView = [[YYAnimatedImageView alloc] init];
        _topContentView.contentMode = UIViewContentModeScaleAspectFill;
        _topContentView.backgroundColor = ZFC0xF2F2F2();
        _topContentView.clipsToBounds = YES;
    }
    return _topContentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.textColor = [UIColor colorWithHex:0x333333];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIView *)countDownBgView {
    if (!_countDownBgView) {
        _countDownBgView = [[UIView alloc] init];
    }
    return _countDownBgView;
}

- (UILabel *)countDownTitleLabel {
    if (!_countDownTitleLabel) {
        _countDownTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countDownTitleLabel.font = [UIFont systemFontOfSize:16.0];
        _countDownTitleLabel.textColor = [UIColor colorWithHex:0x333333];
        _countDownTitleLabel.textAlignment = NSTextAlignmentRight;
        _countDownTitleLabel.adjustsFontSizeToFitWidth = YES;
        _countDownTitleLabel.numberOfLines = 0;
    }
    return _countDownTitleLabel;
}

- (ZFBannerTimeView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFBannerTimeView alloc] init];
        _countDownView.hidden = YES;
    }
    return _countDownView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(140, 309);//固定宽高
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
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
        
        [_collectionView registerClass:[ZFGeshopSecKilGoodsCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFGeshopSecKilGoodsCell class])];
    }
    return _collectionView;
}

- (ZFGeshopNavtiveAOP *)nativeThemeAop {
    if (!_nativeThemeAop) {
        _nativeThemeAop = [[ZFGeshopNavtiveAOP alloc] init];
    }
    return _nativeThemeAop;
}
@end
