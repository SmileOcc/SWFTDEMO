//
//  ZFGeshopCycleBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopCycleBannerCell.h"
#import "ZFGeshopSectionModel.h"
#import "SDCycleScrollView.h"
#import "YWCFunctionTool.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"
#import "ZFCommunityRemmondPageControl.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFAnalyticsExposureSet.h"

@interface ZFGeshopCycleBannerCell()<SDCycleScrollViewDelegate>
@property (nonatomic, strong) SDCycleScrollView *bannerScrollView;
@property (nonatomic, strong) ZFCommunityRemmondPageControl *pageControl;
@end

@implementation ZFGeshopCycleBannerCell

@synthesize sectionModel = _sectionModel;

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
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.bannerScrollView];
    [self.contentView addSubview:self.pageControl];
}

- (void)zfAutoLayoutView {
    [self.bannerScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-16);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (ZFGeshopSectionListModel *listModel in sectionModel.component_data.list) {
        if (!ZFIsEmptyString(listModel.image)) {
            [imageArray addObject:listModel.image];
        }
    }
    self.bannerScrollView.imageURLStringsGroup = imageArray;
    
    self.pageControl.hidden = (imageArray.count <= 1);
    [self.pageControl updateDotHighColor:ZFC0xFFFFFF()
                            defaultColor:ZFC0xFFFFFF_03()
                                  counts:imageArray.count
                            currentIndex:0];
}

#pragma mark - <SDCycleScrollViewDelegate>

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    [self.pageControl selectIndex:index];
    
    NSString *nativeThemeName = self.sectionModel.nativeThemeName;
    NSString *nativeThemeId = self.sectionModel.nativeThemeId;
    
    if (self.sectionModel.component_data.list.count > index) {
        ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[index];
        NSString *key = [ZFToString(self.sectionModel.component_id) stringByAppendingString:ZFToString(listModel.floor_id)];

        if (![[ZFAnalyticsExposureSet sharedInstance].nativeThemeAnalyticsArray containsObject:ZFToString(key)]) {

            [[ZFAnalyticsExposureSet sharedInstance].nativeThemeAnalyticsArray addObject:ZFToString(key)];
            
            // GIO统计
            ZFGeshopSectionModel *sectionModel = [[ZFGeshopSectionModel alloc] init];
            sectionModel.component_type = self.sectionModel.component_type;
            sectionModel.component_name = self.sectionModel.component_name;
            sectionModel.component_id = self.sectionModel.component_id;
            
            [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithThemeSectionListModel:listModel nativeThemeSectionModel:sectionModel pageName:nativeThemeName nativeThemeId:nativeThemeId];
        }
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (self.sectionModel.component_data.list.count <= index) return;
    ZFGeshopSectionListModel *bannerModel = self.sectionModel.component_data.list[index];
    if (self.sectionModel.clickCycleBannerBlock) {
        self.sectionModel.clickCycleBannerBlock(bannerModel);
    }
    NSString *nativeThemeName = self.sectionModel.nativeThemeName;
    NSString *nativeThemeId = self.sectionModel.nativeThemeId;
    
    ZFGeshopSectionModel *sectionModel = [[ZFGeshopSectionModel alloc] init];
    sectionModel.component_type = self.sectionModel.component_type;
    sectionModel.component_name = self.sectionModel.component_name;
    sectionModel.component_id = self.sectionModel.component_id;
    
    /// GIO统计
    [ZFGrowingIOAnalytics ZFGrowingIOBannerClickWithThemeSectionListModel:bannerModel nativeThemeSectionModel:sectionModel pageName:nativeThemeName nativeThemeId:nativeThemeId];
}

#pragma mark - Getter
- (SDCycleScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"index_banner_loading"]];
        _bannerScrollView.autoScrollTimeInterval = 5.0;
        _bannerScrollView.currentPageDotColor = ZFCOLOR(45, 45, 45, 1);
        _bannerScrollView.pageDotColor = ZFCOLOR(128, 128, 128, 1);
        _bannerScrollView.pageControlDotSize = CGSizeMake(7, 7);
        _bannerScrollView.showPageControl = NO;
        _bannerScrollView.isRightToLeft = [SystemConfigUtils isRightToLeftShow] ? YES : NO;
    }
    return _bannerScrollView;
}

- (ZFCommunityRemmondPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[ZFCommunityRemmondPageControl alloc] initWithFrame:CGRectZero];
        [_pageControl configeMaxWidth:20 minWidth:20 maxHeight:2 minHeight:2 limitCorner:0];
    }
    return _pageControl;
}

@end

