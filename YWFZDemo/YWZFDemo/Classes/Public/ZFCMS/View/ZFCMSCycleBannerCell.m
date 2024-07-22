//
//  ZFCMSCycleBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSCycleBannerCell.h"
#import "ZFCMSSectionModel.h"
#import "SDCycleScrollView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"

@interface ZFCMSCycleBannerCell()<SDCycleScrollViewDelegate>
@property (nonatomic, strong) NSArray<ZFCMSItemModel *>      *adBannerArray;
@property (nonatomic, strong) SDCycleScrollView             *bannerScrollView;
@property (nonatomic, strong) ZFCMSSectionModel *sectionModel;
@end

@implementation ZFCMSCycleBannerCell

+ (ZFCMSCycleBannerCell *)cycleBannerCellWith:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath
{
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
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.bannerScrollView];
}

- (void)zfAutoLayoutView {
    [self.bannerScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - <SDCycleScrollViewDelegate>
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (self.adBannerArray.count <= index) return;
    ZFCMSItemModel *bannerModel  = self.adBannerArray[index];
    if (self.cycleBannerClick) {
        self.cycleBannerClick(bannerModel);
    }
}

//*用于AOP统计代码,详情见ZFHomeTopBannerAnalyticsManager*/
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{}

#pragma mark - Setter

- (void)updateCycleBanner:(ZFCMSSectionModel *)sectionModel indexPath:(NSIndexPath *)indexPath {
    if ([_sectionModel isEqual:sectionModel]) {
        return;
    }
    _sectionModel = sectionModel;
    self.adBannerArray = sectionModel.list;
    NSMutableArray *imageArray = [NSMutableArray array];
    for (ZFCMSItemModel *model in self.adBannerArray) {
        [imageArray addObject:model.image];
    }
    self.bannerScrollView.imageURLStringsGroup = imageArray;
    
    if (_sectionModel.type == ZFCMS_VerCycleBanner_Type) {
        self.bannerScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.bannerScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleNone;
        self.bannerScrollView.showPageControl = NO;
        self.bannerScrollView.isEnableScroll = NO;
        
    } else if (_sectionModel.type == ZFCMS_CycleBanner_Type) {
        self.bannerScrollView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.bannerScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        self.bannerScrollView.showPageControl = YES;
        self.bannerScrollView.isEnableScroll = (self.adBannerArray.count > 1) ? YES : NO;
    }
}

#pragma mark - Getter
- (SDCycleScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"index_banner_loading"]];
        _bannerScrollView.autoScrollTimeInterval = 5.0;
        _bannerScrollView.currentPageDotColor = ZFC0xFFFFFF();
        _bannerScrollView.pageDotColor = ZFC0x000000_A(0.4);
//        _bannerScrollView.pageDotImage = [UIImage imageNamed:@"cycle_banner_normal_dot"];
//        _bannerScrollView.currentPageDotImage = [UIImage imageNamed:@"cycle_banner_selected_dot"];
        _bannerScrollView.pageControlDotSize = CGSizeMake(8, 8);
        _bannerScrollView.onlyDisplayText = NO;
        _bannerScrollView.isRightToLeft = [SystemConfigUtils isRightToLeftShow] ? YES : NO;
    }
    return _bannerScrollView;
}

- (ZFCMSCycleBannerAnalyticsAOP *)analyticsAop {
    if (!_analyticsAop) {
        _analyticsAop = [[ZFCMSCycleBannerAnalyticsAOP alloc] init];
    }
    return _analyticsAop;
}

- (void)setChannel_name:(NSString *)channel_name {
    _channel_name = channel_name;
    self.analyticsAop.channel_name = channel_name;
}

@end

