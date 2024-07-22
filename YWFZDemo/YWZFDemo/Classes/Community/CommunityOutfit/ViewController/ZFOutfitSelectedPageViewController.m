//
//  ZFOutfitSelectedViewController.m
//  Zaful
//
//  Created by QianHan on 2018/5/23.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitSelectedPageVC.h"
#import "ZFOutfitBuilderSingleton.h"
#import "ZFOutfitRefineContainerView.h"

@interface ZFCommunityOutfitSelectedPageVC ()

@property (nonatomic, strong) UIButton                         *refineButton;
@property (nonatomic, strong) ZFOutfitRefineContainerView      *refineView;
@end

@implementation ZFCommunityOutfitSelectedPageVC

- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal    = 14.0f;
        self.titleSizeSelected  = 14.0f;
        self.menuViewStyle      = WMMenuViewStyleLine;
        self.itemMargin         = 20.0f;
        self.titleColorSelected = [UIColor colorWithHex:0x2D2D2D];
        self.titleColorNormal   = [UIColor colorWithHex:0x999999];
        self.progressColor      = [UIColor colorWithHex:0x2D2D2D];
        self.progressHeight     = 2.0f;
        self.automaticallyCalculatesItemWidths = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"community_outfititem_select_title", nil);
    [self setupView];
}

- (void)setupView {
    [self setNavigationBar];
    if ([self.borderViewModel cateCount] <= 0) {
        [self showAgainRequestView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNavigationBar];
}

- (void)setNavigationBar {
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0.0, 0.0, NAVBARHEIGHT + 20.0, NAVBARHEIGHT);
    cancelBtn.contentHorizontalAlignment = [SystemConfigUtils isRightToLeftShow] ? UIControlContentHorizontalAlignmentRight :  UIControlContentHorizontalAlignmentLeft;
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = barItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refineButton];
}

#pragma mark - 网络请求
- (void)loadBoardAndCateWithFinishedHandle:(void (^)(void))finishedHandle {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.borderViewModel requestOutfitBorderWithFinished:^{
        @strongify(self)
        HideLoadingFromView(self.view);
        
        if ([self.borderViewModel cateCount] <= 0) {
            [self showAgainRequestView];
        }
        
        if (finishedHandle) {
            finishedHandle();
        }
        
        [self reloadData];
    }];
}

#pragma mark -WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return [self.borderViewModel cateCount];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return [self.borderViewModel cateTitleWithIndex:index];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    NSString *cateID = [self.borderViewModel cateIDWithIndex:index];
    ZFOutfitSelectedViewController *outfitSelectedViewController = [[ZFOutfitSelectedViewController alloc] initWithCateID:cateID];
    return outfitSelectedViewController;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0.0, KScreenWidth, 44.0);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    self.menuView.backgroundColor = [UIColor whiteColor];
    return CGRectMake(0.0, 44.0, KScreenWidth, KScreenHeight - 44.0 - self.navigationController.navigationBar.height - kiphoneXTopOffsetY);
}

#pragma mark - privete method
- (void)showAgainRequestView {
    self.emptyImage = [UIImage imageNamed:@"blankPage_requestFail"];
    self.emptyTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
    self.edgeInsetTop = -TabBarHeight;
    
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        [self loadBoardAndCateWithFinishedHandle:nil];
    }];
}

#pragma mark - event
- (void)cancelAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionRefine:(UIButton *)sender {
    if (!self.refineView.superview) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.refineView];
    }
    
    ZFOutfitSelectedViewController *outfitCtrl = (ZFOutfitSelectedViewController *)self.currentViewController;
    self.refineView.model = outfitCtrl.refineModel;
    self.refineView.hidden = NO;
    [self.refineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.refineView showViewAnimation:YES];
}

#pragma mark - setter/getter

- (UIButton *)refineButton {
    if (!_refineButton) {
        _refineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refineButton.frame = CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize);
        [_refineButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [_refineButton addTarget:self action:@selector(actionRefine:) forControlEvents:UIControlEventTouchUpInside];
        [_refineButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    return _refineButton;
}

- (ZFOutfitRefineContainerView *)refineView {
    if (!_refineView) {
        _refineView = [[ZFOutfitRefineContainerView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _refineView.hideBlock = ^{
            @strongify(self)
            [self.refineView removeFromSuperview];
        };
        _refineView.applyBlock = ^(NSDictionary * _Nonnull parms) {
            @strongify(self)
            [self.refineView hideViewAnimation:YES];
            ZFOutfitSelectedViewController *outfitCtrl = (ZFOutfitSelectedViewController *)self.currentViewController;
            [outfitCtrl refineSelectAttrData:ZFToString(parms[@"selected_attr_list"])];
        };
        _refineView.selectBlock = ^(BOOL selelct) {
            
        };
    }
    return _refineView;
}

@end
