//
//  ZFSearchMapPageViewController.m
//  ZZZZZ
//
//  Created by YW on 23/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMapPageViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCategoryNavigationView.h"
#import "ZFSearchMapPreView.h"
#import "ZFSearchMapViewModel.h"
#import "ZFSearchMapResultViewController.h"
#import "WMPanGestureRecognizer.h"
#import "ZFSearchMapCropViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFThemeManager.h"
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFBTSManager.h"
#import "SystemConfigUtils.h"

static CGFloat const kPreViewHeight       = 72.0;
static CGFloat const kTabMenuHeight       = 44.0f;

@interface ZFSearchMapPageViewController()<ZFInitViewProtocol, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView                                *headerBackgroundView;
@property (nonatomic, strong) UIButton                              *backButton;//请求慢时不能点击放回
@property (nonatomic, strong) ZFCategoryNavigationView              *navigationView;
@property (nonatomic, strong) ZFSearchMapPreView                    *searchMapPreView;
@property (nonatomic, strong) UIView                                *bottomLine;
@property (nonatomic, strong) ZFSearchMapViewModel                  *viewModel;
@property (nonatomic, strong) WMPanGestureRecognizer                *panGesture;
@property (nonatomic, assign) CGPoint                               lastPoint;
@property (nonatomic, assign) CGFloat                               viewTop;
@property (nonatomic, strong) NSURLSessionDataTask                  *dataTask;
@property (nonatomic, strong) UIImage                               *cropImage;
/** 添加一个透明视图让事件传递到顶层,使其能够侧滑返回 */
@property (nonatomic, strong) UIView                                *leftHoledSliderView;
@property (nonatomic) CGRect                                        cutFrame;
@property (nonatomic, copy) NSString                                *searchImagePolicy;
@end

@implementation ZFSearchMapPageViewController
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal    = 14.0f;
        self.titleSizeSelected  = 14.0f;
        self.menuViewStyle      = WMMenuViewStyleLine;
        self.itemMargin         = 20.0f;
        self.titleColorSelected = ZFCOLOR(45, 45, 45, 1.0);
        self.titleColorNormal   = ZFCOLOR(153, 153, 153, 1.0);
        self.progressColor      = ZFCOLOR(45, 45, 45, 1.0);
        self.progressHeight     = 2.0f;
        self.automaticallyCalculatesItemWidths = YES;
        self.viewTop = kPreViewHeight + kTabMenuHeight + kiphoneXTopOffsetY;
        self.sourceType = ZFAppsflyerInSourceTypeSearchResult;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.cropImage = [self.sourceImage copy];
    self.cutFrame  = CGRectZero;
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addGestures];
    [self requestSearchSDKGoodsOfBts];
//    [self addAnalysics];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    self.navigationView.badgeCount = [NSString stringWithFormat:@"%lu", [badgeNum integerValue]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    HideLoadingFromView(self.view);
}

-(void)popBackVC {
    [self.dataTask cancel];
    if(![self popToSpecifyVCSuccess:@"ZFCategoryParentViewController"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Request

/**
 *  V4.6.0 当前页面上的bts必须放放到页面上来请求
 *  A:码隆识图接口商品找相似, B/C:内部识图接口商品找相似 (V4.5.7原始默认版本B)
 */
- (void)requestSearchSDKGoodsOfBts {    
    self.searchImagePolicy = kZFBts_C;
    [self requestMenuTitleData];
}

- (void)requestMenuTitleData {
    if (ZFIsEmptyString(self.searchImagePolicy)) {
        self.searchImagePolicy = kZFBts_B;
    }
    ShowLoadingToView(self.view);
     @weakify(self)
    self.dataTask = [self.viewModel requestSearchSDKWithImage:self.sourceImage
                                            searchImagePolicy:self.searchImagePolicy
                                                   completion:^(BOOL isSuccess){
        @strongify(self)
        HideLoadingFromView(self.view);
        
        if (isSuccess) {
            [self removeEmptyView];
            [self reloadData];
            [self.view bringSubviewToFront:self.leftHoledSliderView];
            [self addSeparetorView];
        }else{
            [self showAgainRequestView];
            self.searchMapPreView.totalNum = @"0";
        }
    }];
    [self.view bringSubviewToFront:self.backButton];
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self.view addSubview:self.headerBackgroundView];
    [self.headerBackgroundView addSubview:self.navigationView];
    [self.headerBackgroundView addSubview:self.searchMapPreView];
    [self.view addSubview:self.leftHoledSliderView];
}

- (void)zfAutoLayoutView {
    self.navigationView.frame = CGRectMake(0, 0, KScreenWidth, kTabMenuHeight + kiphoneXTopOffsetY);
    self.searchMapPreView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationView.frame), KScreenWidth, kPreViewHeight);
    self.headerBackgroundView.frame = CGRectMake(0.0, 0.0, KScreenWidth, self.navigationView.height + self.searchMapPreView.height);
}

- (void)addGestures {
    self.panGesture = [[WMPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnView:)];
    [self.view addGestureRecognizer:self.panGesture];
}

- (void)panOnView:(WMPanGestureRecognizer *)recognizer {
    if (self.viewModel.tabMenuTitles.count <= 0) {
        return;
    }
    
    CGPoint currentPoint = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = currentPoint;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat targetPoint = velocity.y < 0 ? kiphoneXTopOffsetY + kPreViewHeight : kiphoneXTopOffsetY + kTabMenuHeight + kPreViewHeight;
        NSTimeInterval duration = fabs((targetPoint - self.viewTop) / velocity.y);
        
        if (fabs(velocity.y) * 1.0 > fabs(targetPoint - self.viewTop)) {
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.viewTop = targetPoint;
            } completion:nil];
            return;
        }
    }
    CGFloat yChange = currentPoint.y - self.lastPoint.y;
    if ((yChange > 0.0f && self.viewTop <= self.headerBackgroundView.height)
        || (yChange < 0.0f && self.viewTop >= self.headerBackgroundView.height - kTabMenuHeight)) {
        self.viewTop += yChange;
    }
    
    self.lastPoint = currentPoint;
}

//- (void)addAnalysics {
//    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
//    valuesDic[AFEventParamContentType] = @"no keyword";
//    valuesDic[@"af_search_page"] = @"pic_search";
//    [ZFAnalytics appsFlyerTrackEvent:@"af_search" withValues:valuesDic];
//}

- (void)setViewTop:(CGFloat)viewTop {
    _viewTop = viewTop;
    if (_viewTop <= kiphoneXTopOffsetY + kPreViewHeight) {
        _viewTop = kiphoneXTopOffsetY + kPreViewHeight;
    }
    
    if (_viewTop >= kiphoneXTopOffsetY + kTabMenuHeight + kPreViewHeight) {
        _viewTop = kiphoneXTopOffsetY + kTabMenuHeight + kPreViewHeight;
    }
    
    self.headerBackgroundView.frame = ({
        CGRect oriFrame = self.headerBackgroundView.frame;
        oriFrame.origin.y = _viewTop - self.headerBackgroundView.height;
        oriFrame;
    });
    CGFloat alpha = 1.0;
    alpha = (self.headerBackgroundView.y + kTabMenuHeight) / (kTabMenuHeight);
    [self.navigationView subViewWithAlpa:alpha];
    
    [self forceLayoutSubviews];
}

#pragma mark -WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return [self.viewModel tabMenuTitles].count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return [[self.viewModel tabMenuTitles] stringWithIndex:index];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    ZFSearchMapResultViewController *resultVC = [[ZFSearchMapResultViewController alloc] init];
    resultVC.pageArrays = [self.viewModel queryPageArray:index];
    resultVC.pageTitle = [self.viewModel tabMenuTitles][index];
    resultVC.totalCount = [self.viewModel queryCategoryArrayCount:index];
    resultVC.sourceType = self.sourceType;
    return resultVC;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat menuHeight = self.viewModel.tabMenuTitles.count == 1 ? 0.0f : kTabMenuHeight;
    menuView.backgroundColor = ZFCOLOR_WHITE;
    return CGRectMake(0, _viewTop, KScreenWidth, menuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY;
    if (self.viewModel.tabMenuTitles.count == 1) {
        originY = _viewTop + 0.0;
    } else {
        originY = _viewTop + kTabMenuHeight;
    }
    return CGRectMake(0, originY, KScreenWidth, KScreenHeight - originY);
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    NSInteger index = [info ds_integerForKey:@"index"];
    self.searchMapPreView.totalNum = [NSString stringWithFormat:@"%ld",[self.viewModel queryCategoryArrayCount:index]];
}

#pragma mark - Private method
- (void)jumpToCropVC:(UIImage *)image {
    @weakify(self);
    ZFSearchMapCropViewController *cropVC = [[ZFSearchMapCropViewController alloc] initWithCutFrame:self.cutFrame];
    cropVC.sourceImage = self.cropImage;
    cropVC.confirmHandler = ^(UIImage *cropImage, CGRect cutFrame) {
        @strongify(self);
        self.searchMapPreView.sourceImage = cropImage;
        self.sourceImage = cropImage;
        [self requestSearchSDKGoodsOfBts];
        self.cutFrame    = cutFrame;
    };
    [self.navigationController pushViewController:cropVC animated:YES];
}

- (void)showAgainRequestView {
    @weakify(self)
    self.emptyImage = [UIImage imageNamed:@"blankPage_noSearchData"];
    self.emptyTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
    self.edgeInsetTop = CGRectGetMaxY(self.searchMapPreView.frame);
    [self showEmptyViewHandler:^{
        @strongify(self)
        [self requestSearchSDKGoodsOfBts];
    }];
}

- (void)addSeparetorView {
    [self.bottomLine removeFromSuperview];
    [self.menuView addSubview:self.bottomLine];
    [self.menuView bringSubviewToFront:self.bottomLine];
    BOOL isHiddenMenu = [self.viewModel tabMenuTitles].count == 1;
    self.menuView.progressView.hidden = isHiddenMenu ? YES : NO;
    self.bottomLine.hidden = isHiddenMenu ? YES : NO;
}

#pragma mark - Getter
- (UIView *)headerBackgroundView {
    if (!_headerBackgroundView) {
        _headerBackgroundView = [[UIView alloc] init];
    }
    return _headerBackgroundView;
}

- (ZFCategoryNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[ZFCategoryNavigationView alloc] init];
        _navigationView.inputPlaceHolder = ZFLocalizedString(@"inputPlaceHolder", nil);
        
        // 换肤: by maownagxin
        [_navigationView zfChangeSkinToCustomNavgationBar];
        
        @weakify(self);
        _navigationView.categoryBackCompletionHandler = ^{
            @strongify(self);
            [self popToSpecifyVCSuccess:@"ZFCategoryParentViewController"];
        };
        _navigationView.categoryJumpCartCompletionHandler = ^{
            @strongify(self);
            [self pushToViewController:@"ZFCartViewController" propertyDic:nil];
        };
        _navigationView.categoryActionSearchInputCompletionHandler = ^{
            @strongify(self);
            [self pushToViewController:@"ZFSearchViewController" propertyDic:nil];
        };
        _navigationView.categoryActionSearchImageCompletionHandler = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navigationView;
}

- (ZFSearchMapPreView *)searchMapPreView {
    if (!_searchMapPreView) {
        _searchMapPreView = [[ZFSearchMapPreView alloc] init];
        _searchMapPreView.sourceImage = self.sourceImage;
        @weakify(self);
        _searchMapPreView.cropImageHandler = ^(UIImage *image) {
            @strongify(self);
            [self jumpToCropVC:image];
        };
    }
    return _searchMapPreView;
}

/**
 * 显示一个占位的返回按钮, 防止请求时loading会盖住整个页面
 */
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        CGFloat height = IPHONE_X_5_15 ? 94 : 64;
        CGFloat x = [SystemConfigUtils isRightToLeftShow] ? (KScreenWidth - height) : 0;
        _backButton.frame = CGRectMake(x, 0, 64, height);
        [_backButton addTarget:self action:@selector(popBackVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    return _backButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.frame = CGRectMake(0.0, kTabMenuHeight - 0.5, self.view.width, 0.5);
        _bottomLine.backgroundColor = [UIColor colorWithHex:0xdddddd];
    }
    return _bottomLine;
}

- (ZFSearchMapViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFSearchMapViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (UIView *)leftHoledSliderView {
    if (!_leftHoledSliderView) {
        _leftHoledSliderView = [[UIView alloc] init];
        _leftHoledSliderView.frame = CGRectMake(0, 0, 20, KScreenHeight - kiphoneXTopOffsetY - 44);
        _leftHoledSliderView.backgroundColor = [UIColor clearColor];
    }
    return _leftHoledSliderView;
}

@end
