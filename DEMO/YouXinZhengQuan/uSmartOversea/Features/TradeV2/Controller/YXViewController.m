//
//  YXViewController.m
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//
#import "YXViewController.h"
#import "uSmartOversea-Swift.h"
#import "QMUIEmptyView.h"
#import "HLNetWorkReachability.h"
#import <YXKit/LogUtil.h>
#import <YYCategories.h>
#import <Masonry/Masonry.h>
#import "NSString+Check.h"

#define kYXSocketActivityWidth 28

@interface YXViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) YXViewModel *viewModel;
@property (nonatomic, strong, readwrite) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@property (nonatomic, strong, readwrite) YXStrongNoticeView *strongNoticeView;

@property (nonatomic, strong, readwrite) UIBarButtonItem *messageItem;

@property (nonatomic, assign) BOOL needShowStrongNotice;

@property (nonatomic, strong) UIActivityIndicatorView *socketActivityView;

@property (nonatomic, strong) YXProgressHUD *hud;

@end


@implementation YXViewController

#pragma mark - life
- (void)dealloc {
    LOG_INFO(kModuleViewController, @"------------------------- %@ dealloc", [self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    YXViewController *viewController = [super allocWithZone:zone];
    
    @weakify(viewController)
    [[viewController
      rac_signalForSelector:@selector(viewDidLoad)]
     subscribeNext:^(id x) {
         @strongify(viewController)
         [viewController bindViewModel];
     }];
    
    return viewController;
}

- (YXViewController *)initWithViewModel:(YXViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [QMUITheme foregroundColor];
    
    self.emptyIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
//    self.statusBarStyle = UIStatusBarStyleLightContent;
    
    if (@available(iOS 13.0, *)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    @weakify(self)
    // 显示正在加载中的对话框
    [[self.viewModel.requestShowLoadingSignal deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = x;
            if (dictionary[YXViewModel.loadingViewPositionKey]) {
                NSInteger flag = ((NSNumber *)dictionary[YXViewModel.loadingViewPositionKey]).integerValue;
                NSString *message = (NSString *)dictionary[YXViewModel.loadingMessageKey];
                switch (flag) {
                    case YXRequestViewPositionShowInController:
                        if (message) {
                            [self showLoading:message inController:self];
                        } else {
                            [self showLoading:nil inController:self];
                        }
                        break;
                    case YXRequestViewPositionHideInController:
                        [self hideHud];
                        break;
                    case YXRequestViewPositionShowInWindow:
                        [self showLoading:message];
                        break;
                    case YXRequestViewPositionHideInWindow:
                        [self hideHud];
                        break;
                    default:
                        break;
                }
            }
        }
    }];
    
    // 显示网络请求错误的对话框
    [[self.viewModel.requestShowErrorSignal deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        NSString *defaultMessage = [YXLanguageUtility kLangWithKey:@"network_timeout"];
        if (x == nil) {
            LOG_DEBUG(kOther, @"requestShowErrorSignal show defaultMessage");
            [self showError:defaultMessage inView:self.view];
            return;
        }
        if ([x isKindOfClass:[NSError class]]) {
            NSError *error = x;
            NSInteger code = error.code;
            NSDictionary *userInfo = error.userInfo;
            
            LOG_DEBUG(kOther, @"requestShowErrorSignal code = %ld", code);
            
            NSString *message = (NSString *)userInfo[NSLocalizedDescriptionKey];
            if (message == nil) {
                message = defaultMessage;
            }
            LOG_DEBUG(kOther, @"requestShowErrorSignal message = %@", message);
            
            if (userInfo[YXViewModel.loadingViewPositionKey]) {
                
                NSInteger flag = ((NSNumber *)userInfo[YXViewModel.loadingViewPositionKey]).integerValue;
                
                switch (flag) {
                    case YXRequestViewPositionShowInController:
                        [self showError:message inView:self.view];
                        break;
                    case YXRequestViewPositionShowInWindow:
                        [self showError:message];
                        break;
                    default:
                        break;
                }
            } else {
                [self showError:message inView:self.view];
            }
            
            return;
        }
        if ([x isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInfo = x;
            if (userInfo[YXViewModel.loadingViewPositionKey]) {
                
                NSInteger flag = ((NSNumber *)userInfo[YXViewModel.loadingViewPositionKey]).integerValue;
                
                switch (flag) {
                    case YXRequestViewPositionShowInController:
                        [self showError:defaultMessage inView:self.view];
                        break;
                    case YXRequestViewPositionShowInWindow:
                        [self showError:defaultMessage];
                        break;
                    default:
                        break;
                }
            } else {
                [self showError:defaultMessage inView:self.view];
            }
            
            return;
        }
    }];
}

// TODO: 定位偶现tabbar不显示的问题，初步怀疑可能是tabbar hidden为了YES
// 因此在首页、资讯、智投、个人中心和交易等页面设置一下tabbar的显示状态
- (void)setTabbarVisibleIfNeed {
    UITabBar *tabbar = self.tabBarController.tabBar;
    if (tabbar) {
        LOG_WARNING(kOther, @"[fix tabbar bugs] [tabbar: %@], [tabbar hidden : %d]", tabbar, tabbar.hidden);
        if (tabbar.hidden) {
            LOG_WARNING(kOther, @"[fix tabbar bugs] set tabbar hidden to NO");
            tabbar.hidden = NO;
        }
    }
}

- (UIActivityIndicatorView *)socketActivityView {
    if (_socketActivityView == nil) {
        _socketActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _socketActivityView.hidesWhenStopped = YES;
    }
    return _socketActivityView;
}

- (YXStrongNoticeView *)strongNoticeView {
    if (_strongNoticeView == nil) {
        self.needShowStrongNotice = YES;
        _strongNoticeView = [[YXStrongNoticeView alloc] initWithFrame:CGRectZero services:[YXMessageCenterService shared]];
        [self.view addSubview:_strongNoticeView];
        
        [_strongNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(32);
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
            } else {
                make.top.mas_equalTo(self.view).offset(YXConstant.navBarHeight);
            }
        }];
        
        @weakify(self)
        [RACObserve(_strongNoticeView, hidden) subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            BOOL hidden = [(NSNumber *)x boolValue];
            if (self.strongNoticeView.superview == nil) {
                return;
            }
            [self.strongNoticeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view);
                if (hidden) {
                    make.height.mas_equalTo(0);
                } else {
                    if (self.strongNoticeView.noticeType == YXStrongNoticeTypeNormal && self.strongNoticeView.isCurrencyExchange) {
                        make.height.mas_equalTo(52);
                    } else {
                        make.height.mas_equalTo(32);
                    }
                }
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
                } else {
                    make.top.mas_equalTo(self.view).offset(YXConstant.navBarHeight);
                }
            }];
        }];
    }
    return _strongNoticeView;
}

- (void)didInitialize {
    [super didInitialize];
    
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.forceToLandscapeRight) {
        [YXToolUtility forceToLandscapeRightOrientation];
    } else {
        [YXToolUtility forceToPortraitOrientation];
    }
    
    [self.viewModel.willAppearSignal sendNext:nil];
    
    YXAppDelegate *d = (YXAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self.navigationController.visibleViewController isKindOfClass:[YXAccountAssetViewController class]] || self.forceToLandscapeRight) {
        d.top_icon_forscreenshot.hidden = YES;
    }else {
        d.top_icon_forscreenshot.hidden = NO;
        [[UIApplication sharedApplication].delegate.window bringSubviewToFront:d.top_icon_forscreenshot];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.viewModel.didAppearSignal sendNext:nil];
   
    if (@available(iOS 15.0, *)) {
        if ([UIViewController currentViewController] == self) {
            UINavigationBarAppearance *app = [UINavigationBarAppearance new];
            [app configureWithOpaqueBackground];
            app.backgroundColor = QMUITheme.foregroundColor;
            app.shadowImage = [UIImage new];
            app.shadowColor = [UIColor clearColor];
            self.navigationController.navigationBar.scrollEdgeAppearance = app;
            self.navigationController.navigationBar.standardAppearance = app;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.viewModel.didDisappearSignal sendNext:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel.willDisappearSignal sendNext:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutEmptyView];
}

#pragma mark ------ pop animation ------
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [self didNaviToPopStart];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if(!parent){
        [self didNaviToPopEnd];
    }
}

- (void)didNaviToPopStart {
}

- (void)didNaviToPopEnd {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - action
- (void)backBtnAction {
    if (self.viewModel && self.viewModel.services) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (UIImage * _Nonnull)messageImage {
    return [UIImage imageNamed:@"com_message"];
}

- (void)messageButtonAction {
    // TODO: FIXME
    
    [(NavigatorServices *)self.viewModel.services tradeOrderMessageActionWith:self];
}

- (UIBarButtonItem *)messageItem {
    if (_messageItem == nil) {
        _messageItem = [UIBarButtonItem qmui_itemWithImage:[self messageImage] target:self action:@selector(messageButtonAction)];
        _messageItem.qmui_shouldShowUpdatesIndicator = !YXMessageButton.pointIsHidden;
        _messageItem.imageInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
        [YXMessageButton appendItemWithItem:_messageItem];
    }
    return _messageItem;
}

#pragma mark -- navbar

- (BOOL)preferredNavigationBarHidden {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (NSString *)backBarButtonItemTitleWithPreviousViewController:(UIViewController *)viewController {
    return @"";
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable {
    return YES;
}

- (UIImage *)qmui_navigationBarBackgroundImage {
    return [UIImage imageNamed:@"nav_bg"];
}

- (void)bindViewModel {}

#pragma mark- hud相关
- (void)showLoading:(NSString *)message {
    [self.hud showLoading:message in:self.view.window];
}

- (void)showText:(NSString *)message {
    [self.hud showMessage:message in:self.view.window hideAfter:1.5];
}

- (void)showError:(NSString *)message {
    [self.hud showError:message in:self.view.window hideAfter:1.5];
}

- (void)showSuccess:(NSString *)message {
    [self.hud showSuccess:message in:self.view.window hideAfter:1.5];
}

- (void)showLoading:(NSString *)message inView:(UIView *)view {
    [self.hud showLoading:message in:view];
}
- (void)showText:(NSString *)message inView:(UIView *)view {
    [self.hud showMessage:message in:view hideAfter:1.5];
}
- (void)showError:(NSString *)message inView:(UIView *)view {
    [self.hud showError:message in:view hideAfter:1.5];
}
- (void)showSuccess:(NSString *)message inView:(UIView *)view {
    [self.hud showSuccess:message in:view hideAfter:1.5];
}

- (void)showLoading:(NSString *)message inController:(UIViewController *)controller {
    [self.hud showLoadingInViewController:controller message:message];
}

- (void)hideHud {
    [self.hud hideHud];
}

- (YXProgressHUD *)hud {
    if (!_hud) {
        _hud = [[YXProgressHUD alloc] init];
        _hud.detailsLabel.font = [UIFont systemFontOfSize:16];
        _hud.contentColor = [UIColor whiteColor];
        _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        _hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    return _hud;
}

#pragma mark - Settter

- (void)setEmptyIndicatorViewStyle:(UIActivityIndicatorViewStyle)emptyIndicatorViewStyle {
    _emptyIndicatorViewStyle = emptyIndicatorViewStyle;
    if ([self.emptyView.loadingView isKindOfClass:[UIActivityIndicatorView class]]) {
        [(UIActivityIndicatorView *)self.emptyView.loadingView setActivityIndicatorViewStyle:emptyIndicatorViewStyle];
    }
}

//#pragma mark - set status style
//- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
//    _statusBarStyle = statusBarStyle;
//    [self setNeedsStatusBarAppearanceUpdate];
//}
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    [super preferredStatusBarStyle];
//    return self.statusBarStyle;
//}

@end
