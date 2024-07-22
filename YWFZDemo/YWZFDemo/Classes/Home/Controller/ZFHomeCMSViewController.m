//
//  ZFHomeCMSViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/12/8.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFHomeCMSViewController.h"
#import "ZFCMSViewModel.h"
#import "ZFCMSCycleBannerCell.h"
#import "ZFCMSSliderSecKillSectionView.h"
#import "ZFCMSSliderSKUBannerSectionView.h"
#import "ZFCMSSliderNormalBannerSectionView.h"
#import "ZFCMSNormalBannerCell.h"
#import "ZFCMSSkuBannerCell.h"
#import "UIColor+ExTypeChange.h"
#import "ZFCMSTextModuleCell.h"
#import "ZFGoodsDetailViewController.h"
#import "JumpManager.h"
#import "JumpModel.h"
#import "ZFCMSHomeAnalyticsAOP.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "SystemConfigUtils.h"
#import "BannerManager.h"
#import "ZF3DTouchHeader.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFBTSModel.h"
#import "ZFCommonRequestManager.h"
#import "ZFHomePageViewController.h"

#import "Masonry.h"
#import "ZFHomeCMSView.h"

@interface ZFHomeCMSViewController ()
@property (nonatomic, copy)   NSString              *tabType;//每个频道的ChannelId: 父控制器采用KVC方式赋值
@property (nonatomic, assign) BOOL                  changeShowFloatInputBarFlag;
@property (nonatomic, strong) ZFHomeCMSView         *homeCMSView;
@end

@implementation ZFHomeCMSViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.homeCMSView];
    [self.homeCMSView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];

    // 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    [self.homeCMSView zf_viewDidShow];
    self.homeCMSView.homeSectionModelArr = self.homeSectionModelArr;
    [self.homeCMSView addListViewRefreshKit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 刷新历史浏览记录
    [self.homeCMSView updateCMSHistoryGoods];
}

- (ZFHomeCMSView *)homeCMSView {
    if (!_homeCMSView) {
        _homeCMSView = [[ZFHomeCMSView alloc] initWithFrame:self.view.bounds
                                               firstChannel:self.firstChannelId
                                                    channel:self.tabType
                                                      title:self.title];
        @weakify(self)
        _homeCMSView.showFloatBannerBlock = ^(BOOL show) {
            @strongify(self)
            if (self.showFloatBannerBlock) {
                self.showFloatBannerBlock(show);
            }
        };
        _homeCMSView.showFloatInputBarBlock = ^(BOOL show, CGFloat offetY) {
            @strongify(self)
            if (self.showFloatInputBarBlock) {
                self.showFloatInputBarBlock(show, offetY);
            }
        };

    }
    return _homeCMSView;
}

/// 双击tabbar滚动到推荐商品标题栏目位置
- (void)repeatTouchTabBarToViewController {
    [self.homeCMSView scrollToRecommendPosition];
}

@end
