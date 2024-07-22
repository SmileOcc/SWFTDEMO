//
//  ZFNewUserActivetyViewController.m
//  ZZZZZ
//
//  Created by mac on 2019/1/5.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserActivetyViewController.h"
#import "YNPageViewController.h"
#import "ZFNewUserGoodsController.h"
#import "ZFNewUserRushViewController.h"

#import "ZFNewUserCouponsView.h"
#import "ZFNewUserTitleView.h"
#import "ZFNewUserRushTitleView.h"

#import "ZFZFNewUserActivetyViewModel.h"
#import "ZFNativeBannerResultModel.h"
#import "ZFNewUserExclusiveModel.h"
#import "ZFNewUserSecckillModel.h"
#import "ZFNewUserHeckReceivingStatusModel.h"

#import "Constants.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"
#import "ZFRefreshHeader.h"
#import "YWCFunctionTool.h"
#import "UIView+LayoutMethods.h"
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "ZFTimerManager.h"
#import "YNPageScrollMenuButton.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFLocalizationString.h"

static NSString *const kZFZFNewUserActivetyViewControllerTimeKey = @"NewUserActivetyViewControllerTimeKey";

@interface ZFNewUserActivetyViewController () <YNPageViewControllerDataSource, YNPageViewControllerDelegate>
/** 抢购商品 */
@property (nonatomic, strong) YNPageViewController              *pageVC;
/** 商品列表 */
@property (nonatomic, strong) YNPageViewController              *pageSubVC;
/** 数据处理 */
@property (nonatomic, strong) ZFZFNewUserActivetyViewModel      *viewModel;
/** 头部视图 */
@property (nonatomic, strong) UIView                            *pageHeadView;
/** 优惠券视图 */
@property (nonatomic, strong) ZFNewUserCouponsView              *couponsView;
/** 商品列表标题 */
@property (nonatomic, strong) ZFNewUserTitleView                *userTitleView;
/** 商品列表标题 */
@property (nonatomic, strong) UILabel                           *userTitleLabel;
/** 快抢列表标题 */
@property (nonatomic, strong) ZFNewUserRushTitleView            *userRushTitleView;
/** 定时器 */
@property (nonatomic, weak) NSTimer                             *timer;
/** 首次进入 */
@property (nonatomic, assign) BOOL                              first;

@end

@implementation ZFNewUserActivetyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    [self startRequestNativeBannerData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZFTimerManager shareInstance] stopTimer:kZFZFNewUserActivetyViewControllerTimeKey];
}

#pragma mark - Request
- (void)requestDataCompletion:(void (^)(void))completion {
    @weakify(self);
    ShowLoadingToView(self.view);
    [self.viewModel requestCheckReceivingStatusWihtCompletion:^(ZFNewUserHeckReceivingStatusModel * _Nonnull bannerModel, BOOL isSuccess) {
        @strongify(self);
        if (!isSuccess) {
            return;
        }
        self.couponsView.heckReceivingStatusModel = bannerModel;
        if (self.viewModel.heckReceivingStatusModel.status == 4 || self.viewModel.heckReceivingStatusModel.status == 5) {
            self.userTitleLabel.text = self.viewModel.homeExclusiveModel.specialName;
            self.pageSubVC.headerView = self.userTitleLabel;
        } else {
            self.pageSubVC.headerView = self.pageHeadView;
        }
    }];
    
    [self.viewModel requestGetExclusiveListWihtCompletion:^(ZFNewUserExclusiveModel *homeExclusiveModel , BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
            [self.viewModel requestGetSecckillListWihtCompletion:^(ZFNewUserSecckillModel *bannerModel , BOOL isSuccess) {
                @strongify(self);
                HideLoadingFromView(self.view);
                if (isSuccess) {
                    [self removeEmptyView];
                    if (completion) {
                        completion();
                    }
                } else {
                    [self showEmptyView];
                }
            }];
        } else {
            HideLoadingFromView(self.view);
            [self showEmptyView];
        }
    }];
}

#pragma mark - Private method

- (void)showEmptyView {
    self.edgeInsetTop = 0;
    self.emptyImage = [UIImage imageNamed:@"blankPage_networkError"];
    self.emptyTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        ShowLoadingToView(self.view);
        [self startRequestNativeBannerData];
    }];
}


- (void)startRequestNativeBannerData {
    @weakify(self)
    [self requestDataCompletion:^{
        @strongify(self)
        
        // 需要重置NO,如首次进入一样
        self.first = NO;
        
        self.userTitleView.titleLabel.text = self.viewModel.homeExclusiveModel.specialName;
        self.userRushTitleView.titleLabel.text = self.viewModel.homeSecckillModel.specialName;
        [self makeSubPageVC];
        [self makePageVC];
        [self setupTimer];
    }];
}

- (void)reloadPageVC {
    @weakify(self);
    [self requestDataCompletion:^{
        @strongify(self)
        
        [self.pageVC removeSelfViewController];
        [self.pageSubVC removeSelfViewController];
        
        self.userTitleView.titleLabel.text = self.viewModel.homeExclusiveModel.specialName;
        self.userRushTitleView.titleLabel.text = self.viewModel.homeSecckillModel.specialName;
        
        self.pageSubVC.titlesM = self.viewModel.exclusiveTitleArr.mutableCopy;
        self.pageSubVC.controllersM = self.viewModel.exclusiveControllerArr.mutableCopy;
        [self.pageSubVC reloadData];
        
        self.pageVC.titlesM = self.viewModel.secckilltitleArr.mutableCopy;
        self.pageVC.subTitlesM = self.viewModel.secckillSubtitleArr.mutableCopy;
        self.pageVC.controllersM = self.viewModel.secckillcontrollerArr.mutableCopy;
        [self.pageVC reloadData];
        
        if (self.viewModel.homeSecckillModel.list.count > 0) {
            self.pageSubVC.bgScrollView.scrollEnabled = NO;
            [self makeRushTitleView];
            [self.pageVC addSelfToParentViewController:self];
        } else {
            self.pageSubVC.bgScrollView.scrollEnabled = YES;
            [self.pageSubVC addSelfToParentViewController:self];
        }
        
        [self setupTimer];
    }];
}

- (void)makeUI {
    
    //FIXME: occ Bug 1101
    self.pageHeadView.frame = CGRectMake(0, 0, KScreenWidth, 403);
    
    [self.pageHeadView addSubview:self.couponsView];
    [self.couponsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.pageHeadView);
        make.height.mas_equalTo(344);
    }];
    
    [self.pageHeadView addSubview:self.userTitleView];
    [self.userTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.pageHeadView);
        make.top.equalTo(self.couponsView.mas_bottom);
        make.height.mas_equalTo(59);
    }];
}

- (void)makeRushTitleView {
    
    [self.pageSubVC.view addSubview:self.userRushTitleView];
    [self.userRushTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.pageSubVC.view);
        make.height.mas_equalTo(60*ScreenWidth_SCALE);
    }];
    
    if (self.viewModel.homeExclusiveModel.list.count > 0) {
        [self countHeight:self.pageSubVC.pageIndex];
        self.userTitleView.hidden = NO;
    } else {
        self.pageSubVC.view.height = 374*ScreenWidth_SCALE;
        self.userTitleView.hidden = YES;
    }
}

- (void)pageHeadViewMakeRushTitleView {
    
    [self.pageHeadView addSubview:self.userRushTitleView];
    [self.userRushTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.pageHeadView);
        make.height.mas_equalTo(60*ScreenWidth_SCALE);
    }];
}

- (void)makeSubPageVC {
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle              = YNPageStyleSuspensionTopPause;
    configration.headerViewScaleMode    = YNPageHeaderViewScaleModeTop;
    configration.bounces                = YES;
    configration.normalItemColor        = ZFCOLOR(153, 153, 153, 1.0);
    configration.selectedItemColor      = ZFC0x2D2D2D();
    configration.lineColor              = ZFC0x2D2D2D();
    configration.selectedItemFont       = ZFFontSystemSize(16);
    configration.menuHeight             = 44;
    configration.showScrollLine         = self.viewModel.homeExclusiveModel.list.count > 0;
    configration.aligmentModeCenter     = NO;
    configration.scrollMenu             = self.viewModel.exclusiveTitleArr.count > 5 ? YES : NO;
    
    self.pageSubVC = [YNPageViewController pageViewControllerWithControllers:self.viewModel.exclusiveControllerArr
                                                                      titles:self.viewModel.exclusiveTitleArr
                                                                      config:configration];
    
    self.pageSubVC.bgScrollView.scrollEnabled = NO;
    self.pageSubVC.dataSource = self;
    self.pageSubVC.delegate = self;
    
    if (self.viewModel.heckReceivingStatusModel.status == 4 || self.viewModel.heckReceivingStatusModel.status == 5) {
        self.userTitleLabel.text = self.viewModel.homeExclusiveModel.specialName;
        self.pageSubVC.headerView = self.userTitleLabel;
    } else {
        self.pageSubVC.headerView = self.pageHeadView;
    }
    
    @weakify(self)
    ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self reloadPageVC];
        [self.pageSubVC.bgScrollView.mj_header endRefreshing];
    }];
    self.pageSubVC.bgScrollView.mj_header = header;
}

- (void)makePageVC {
   

    if (self.viewModel.homeSecckillModel.list.count > 0) {
        YNPageConfigration *configration = [YNPageConfigration defaultConfig];
        configration.pageStyle              = YNPageStyleSuspensionTopPause;
        configration.headerViewScaleMode    = YNPageHeaderViewScaleModeTop;
        configration.bounces                = YES;
        configration.normalItemColor        = ZFCOLOR(153, 153, 153, 1.0);
        configration.selectedItemColor      = ZFCOLOR(183, 96, 42, 1.0);
        configration.lineColor              = ZFCOLOR(183, 96, 42, 1.0);
        configration.selectedItemFont       = ZFFontSystemSize(16);
        configration.addButtonBackgroundColor  = ColorHex_Alpha(0xAF004B, 1.0);
        configration.scrollViewBackgroundColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        configration.showBottomLine         = NO;
        configration.menuHeight             = 44;
        configration.showScrollLine         = NO;
        configration.itemLeftAndRightMargin = 0;
        configration.itemMargin             = 0;
        configration.itemWidth              = 10;
        configration.converColor            = [UIColor blueColor];
        configration.normalItemBackgroundColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        configration.selectedItemBackgroundColor = ColorHex_Alpha(0xAF004B, 1.0);
        configration.aligmentModeCenter     = NO;
        configration.scrollMenu             = self.viewModel.secckilltitleArr.count > 4 ? YES : NO;
        
        self.pageVC = [YNPageViewController pageViewControllerWithControllers:self.viewModel.secckillcontrollerArr
                                                                       titles:self.viewModel.secckilltitleArr
                                                                    subTitles:self.viewModel.secckillSubtitleArr
                                                                       config:configration];
        
        self.pageVC.dataSource = self;
        self.pageVC.delegate = self;
        
        if (self.viewModel.homeExclusiveModel.list.count > 0) {
            self.pageVC.headerView = self.pageSubVC.view;
            [self makeRushTitleView];
        } else {
            if (self.viewModel.heckReceivingStatusModel.status == 4 || self.viewModel.heckReceivingStatusModel.status == 5) {
                self.userTitleLabel.text = self.viewModel.homeSecckillModel.specialName;
                self.pageVC.headerView = self.userTitleLabel;
            } else {
                self.pageVC.headerView = self.pageHeadView;
                [self pageHeadViewMakeRushTitleView];
            }
        }
        
        [self countHeight:self.pageSubVC.pageIndex];
        [self.pageVC addSelfToParentViewController:self];
        
        @weakify(self)
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self reloadPageVC];
            [self.pageVC.bgScrollView.mj_header endRefreshing];
        }];
        self.pageVC.bgScrollView.mj_header = header;
        
    } else {
        self.pageSubVC.bgScrollView.scrollEnabled = YES;
        [self.pageSubVC addSelfToParentViewController:self];
    }
    
   
}

- (void)countHeight:(NSInteger)index {
    if (self.viewModel.homeSecckillModel.list.count > 0 && self.viewModel.homeExclusiveModel.list.count > index) {
        ZFNewUserExclusiveListModel *model = self.viewModel.homeExclusiveModel.list[index];
        
        // 10 加个10的间隙
        CGFloat pageSubScrollViewHeight = (ceilf(model.goodsList.count/2.0) * 330) + 10;
        if (self.viewModel.heckReceivingStatusModel.status == 4 || self.viewModel.heckReceivingStatusModel.status == 5) {
            self.pageSubVC.view.height = 156*ScreenWidth_SCALE + pageSubScrollViewHeight;
            
        } else {
           self.pageSubVC.view.height = 470*ScreenWidth_SCALE + pageSubScrollViewHeight;
        }
        
        self.pageSubVC.pageScrollView.height = pageSubScrollViewHeight;
        CGSize pageSubScrollContentSize = self.pageSubVC.pageScrollView.contentSize;
        pageSubScrollContentSize.height = pageSubScrollViewHeight;
        self.pageSubVC.pageScrollView.contentSize = pageSubScrollContentSize;
        
    } else {
        self.pageSubVC.view.height = 0;
    }
    self.pageSubVC.bgScrollView.height = self.pageSubVC.view.height;
}

- (void)setupTimer {
    if (self.viewModel.remainingTime > 0) {
        [[ZFTimerManager shareInstance] startTimer:kZFZFNewUserActivetyViewControllerTimeKey];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTime) name:kTimerManagerUpdate object:nil];
    } else {
        //当没有倒计时的时候，要移除通知，不然会进入死循环.ps:别的页面也用了这个倒计时单例
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)reloadTime {
    int timeOut = self.viewModel.remainingTime - [[ZFTimerManager shareInstance] timeInterval:kZFZFNewUserActivetyViewControllerTimeKey];
    if(timeOut <= 0){
        [self reloadPageVC];
    }
}

#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController
                        pageForIndex:(NSInteger)index {
    UIViewController *vc = pageViewController.controllersM[index];
    if ([vc isKindOfClass:[ZFNewUserGoodsController class]]) {
        return (UIScrollView *)[(ZFNewUserGoodsController *)vc querySubScrollView];
    } else {
        return (UIScrollView *)[(ZFNewUserRushViewController *)vc querySubScrollView];
    }
}

#pragma mark - YNPageViewControllerDelegate
- (void)pageViewController:(YNPageViewController *)pageViewController didEndDecelerating:(UIScrollView *)scrollView {
    UIViewController *vc = pageViewController.controllersM[pageViewController.pageIndex];
    if ([vc isKindOfClass:[ZFNewUserGoodsController class]]) {
        if (self.first && self.viewModel.homeSecckillModel.list.count > 0) {
            [self countHeight:pageViewController.pageIndex];
            [self.pageVC reloadData];
        }
        self.first = YES;
    }
}

- (void)pagescrollMenuViewItemOnClick:(UIButton *)label index:(NSInteger)index {
    if ([label isKindOfClass:[YNPageScrollMenuButton class]]) {
        YNPageScrollMenuButton *button = (YNPageScrollMenuButton *)label;
        if (button.btnType == YNPageScrollMenuButtonTypeSubTitle) {
            return;
        }
    }
    if (self.viewModel.homeExclusiveModel.list.count > index && self.viewModel.homeSecckillModel.list.count > 0) {
        [self countHeight:index];
        [self.pageVC reloadData];
    }
}

#pragma mark - Property Method
- (ZFZFNewUserActivetyViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFZFNewUserActivetyViewModel alloc] init];
    }
    return _viewModel;
}

- (UIView *)pageHeadView {
    if (!_pageHeadView) {
        _pageHeadView = [[UIView alloc] init];
    }
    return _pageHeadView;
}

- (ZFNewUserCouponsView *)couponsView {
    if (!_couponsView) {
        _couponsView = [[ZFNewUserCouponsView alloc] init];
        @weakify(self);
        _couponsView.successBlock = ^{
            @strongify(self)
            [self reloadPageVC];
        };
    }
    return _couponsView;
}

- (ZFNewUserTitleView *)userTitleView {
    if (!_userTitleView) {
        _userTitleView = [[ZFNewUserTitleView alloc] init];
    }
    return _userTitleView;
}

- (ZFNewUserRushTitleView *)userRushTitleView {
    if (!_userRushTitleView) {
        _userRushTitleView = [[ZFNewUserRushTitleView alloc] init];
    }
    return _userRushTitleView;
}

- (UILabel *)userTitleLabel {
    if (!_userTitleLabel) {
        _userTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
        _userTitleLabel.textAlignment = NSTextAlignmentCenter;
        _userTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _userTitleLabel;
}


@end
