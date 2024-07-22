//
//  ZFCommunityHomeVC.m
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeVC.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityPostCategoryViewController.h"
#import "ZFCommunityMessageListVC.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "UITabBarController+ZFExtension.h"
#import "UIView+ZFBadge.h"

#import "ZFCommunityPostSuccessView.h"

#import "ZFCommunityViewModel.h"
#import "ZFCommunityPostResultModel.h"
#import "ZFCommunityAccountViewModel.h"
#import "ZFCommunityAccountInfoModel.h"

#import "ZFThemeManager.h"
#import "ZFTabBarController.h"
#import <YYWebImage/UIButton+YYWebImage.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "NSStringUtils.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"

#import "UIButton+ZFButtonCategorySet.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFFireBaseAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "AccountManager.h"
#import "Constants.h"

#import "ZFCommunityLiveVideoVC.h"
#import "ZFCommunityLiveListVC.h"
#import "ZFCommunityHomeCMSView.h"
#import "ZFCommunityFloatingPostView.h"
#import "ZFCommunityZmPostView.h"
#import "SystemConfigUtils.h"
#import "ZFStatistics.h"
#import "ZFGrowingIOAnalytics.h"

@interface ZFCommunityHomeVC ()

@property (nonatomic, strong) UIButton                     *userBtn;
@property (nonatomic, strong) UIButton                     *messageBtn;
@property (nonatomic, strong) UIImageView                  *rankImageView;

@property (nonatomic, strong) ZFCommunityPostSuccessView   *postSuccessView;

@property (nonatomic, strong) ZFCommunityPostResultModel   *model;
@property (nonatomic, strong) ZFCommunityAccountViewModel  *accountModel;

@property (nonatomic, strong) ZFCommunityHomeCMSView       *homeCMS1View;
@property (nonatomic, strong) ZFCommunityZmPostView        *zmPostView;


@property (nonatomic, strong) ZFCommunityFloatingPostMenuView *floatingPostMenuView;
//@property (nonatomic, strong) ZFCommunityFloatingPostView     *floatingPostMenuView2;

@end

@implementation ZFCommunityHomeVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController.navigationBar setShadowImage:nil];//恢复导航线条
    if (_zmPostView) {
        [_zmPostView hiddenViewAnimation:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    /** 运营 3.5.0已取消这个功能  */
    [self refreshAccountAvatorView];
    
    // 刷新历史浏览记录
    [self.homeCMS1View updateCMSHistoryGoods];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Z-Me";
    [self createNavBarItems];
    [self requestMessageCountInfo];
    [self requestAccountInfo];
    
    [self.view addSubview:self.homeCMS1View];
    [self.view addSubview:self.floatingPostMenuView];

    [self.homeCMS1View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.offset(0);
        make.width.mas_equalTo(KScreenWidth);
    }];
    [self.homeCMS1View zf_viewDidShow];
    
    
    //occ测试数据
    ZFCommunityLiveListVC *vc = [[ZFCommunityLiveListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(communityPostSuccessAction:) name:kCommunityPostSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutChangeValue:) name:kLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kChangeUserInfoNotification object:nil];    
}


#pragma mark - Request
///请求未读消息数
- (void)requestMessageCountInfo{
    
    //消息 只调一次
    if ([AccountManager sharedManager].isSignIn) {
        @weakify(self)
        NSString *userID = ZFToString([[AccountManager sharedManager] account].user_id);
        [ZFCommunityViewModel requestMessageCountNetwork:userID completion:^(NSInteger msgCount) {
            @strongify(self)
            [self showNewMessage:msgCount];
        } failure:^(id obj) {
        }];
    }
}
///社区头像V
- (void)requestAccountInfo {
    if ([AccountManager sharedManager].isSignIn) {
        
        NSString *userID = ZFToString([[AccountManager sharedManager] account].user_id);
        NSDictionary *dic = @{kRequestUserIdKey : userID};
        
        @weakify(self)
        [self.accountModel requestNetwork:dic completion:^(id obj) {
            @strongify(self)

            if ([obj isKindOfClass:[ZFCommunityAccountInfoModel class]]) {
                ZFCommunityAccountInfoModel *accountInfoModel = (ZFCommunityAccountInfoModel *)obj;
                
                if ([accountInfoModel.identify_type integerValue] > 0) {
                    if (!ZFIsEmptyString(accountInfoModel.identify_icon)) {
                        self.rankImageView.hidden = NO;
                        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:accountInfoModel.identify_icon] options:kNilOptions];
                    }

                }
            }
        } failure:^(id obj) {
            
        }];
    }
}

#pragma mark - Action

/// 监听: 重复单击当前控制器的TabbarItem
- (void)repeatTapTabBarCurrentController {
    [self.homeCMS1View scrollToTopOrRefresh];
}

/**
 * 是否显示浮窗banner按钮
 */
//- (void)showFloatMenuView:(BOOL)directionUp {
//
//    if (!directionUp) {
//        CGFloat floatingX = self.floatingPostMenuView.x >= KScreenWidth / 2.0 ? KScreenWidth-(56+13) : 13;
//
//        if (self.floatingPostMenuView.x == floatingX) {
//            self.floatingPostMenuView.userInteractionEnabled = YES;
//            return;
//        }
//
//        [UIView animateWithDuration:0.6 animations:^{
//            self.floatingPostMenuView.alpha = 1.0;
//            self.floatingPostMenuView.x = floatingX;
//        } completion:^(BOOL finished) {
//            self.floatingPostMenuView.userInteractionEnabled = YES;
//        }];
//    } else {
//        CGFloat floatingX = self.floatingPostMenuView.x >= KScreenWidth / 2.0 ? KScreenWidth-13 : (13-56);
//        if (self.floatingPostMenuView.x == floatingX) {
//            return;
//        }
//        self.floatingPostMenuView.userInteractionEnabled = NO;
//        [UIView animateWithDuration:0.6 animations:^{
//            self.floatingPostMenuView.alpha = 0.5;
//            self.floatingPostMenuView.x = floatingX;
//        }];
//    }
//}

- (void)showFloatMenuView:(BOOL)directionUp {

    if (!directionUp) {
        CGFloat floatingY = KScreenHeight - NAVBARHEIGHT -TabBarHeight - kiphoneXTopOffsetY - 56 - 24;
        
        if (self.floatingPostMenuView.y == floatingY) {
            self.floatingPostMenuView.userInteractionEnabled = YES;
            return;
        }
        
        [UIView animateWithDuration:0.6 animations:^{
            self.floatingPostMenuView.alpha = 1.0;
            self.floatingPostMenuView.y = floatingY;
        } completion:^(BOOL finished) {
            self.floatingPostMenuView.userInteractionEnabled = YES;
        }];
    } else {
        CGFloat floatingY = KScreenHeight - NAVBARHEIGHT -TabBarHeight - kiphoneXTopOffsetY - 56 - 24;
        floatingY += (56 + 11);
        if (self.floatingPostMenuView.y == floatingY) {
            return;
        }
        self.floatingPostMenuView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.6 animations:^{
            self.floatingPostMenuView.alpha = 0.5;
            self.floatingPostMenuView.y = floatingY;
        }];
    }
}


- (void)bannerJumpToSelectType:(ZFCommunityHomeSelectType)type {
    self.homeCMS1View.selectIndex = type;
}


///导航左侧按钮事件
- (void)messageBtnAction:(UIButton *)sender {
    
    //查看过消息,清除消息数
    @weakify(self);
    void (^hasReadmsgCountBlock)(void) = ^(){
        @strongify(self);
        [self showNewMessage:0];
    };
    
    [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeCommunityHomePage Completion:^{
        @strongify(self)
        //布局导航右侧按钮
        [self refreshAccountAvatorView];
        
        //跳转到用户消息页面
        [self pushToViewController:NSStringFromClass([ZFCommunityMessageListVC class])
                       propertyDic:@{@"hasReadmsgCountBlock":hasReadmsgCountBlock}];
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_button_name" : @"community_message",  //点击的菜单名
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_homepage",    // 当前页面名称
                                          @"af_first_entrance" : @"community_homepage"  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_community_message_click" withValues:appsflyerParams];
    }];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:@"click_message" itemName:@"message" ContentType:@"community_message" itemCategory:@"button"];
}

///导航右侧按钮事件
- (void)accountButtonAction:(UIButton *)sender {
    @weakify(self);
    [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeCommunityHomePage Completion:^{
        @strongify(self)
        //重新布局导航右侧按钮
        [self refreshAccountAvatorView];
        
        //跳转到社区用户页面
        ZFCommunityAccountViewController *zmeVC = [[ZFCommunityAccountViewController alloc] init];
        zmeVC.userName = [[AccountManager sharedManager] userNickname];
        zmeVC.userId = ZFToString(USERID);
        [self.navigationController pushViewController:zmeVC animated:YES];
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_button_name" : @"community_account",  //点击的菜单名
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_homepage",    // 当前页面名称
                                          @"af_first_entrance" : @"community_homepage"  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_community_account_click" withValues:appsflyerParams];
//        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceCommunity,
//                                                   GIOSndNameEvar : GIOSourceCommunityAccount
//        }];
    }];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:@"click_account" itemName:@"account" ContentType:@"community_account" itemCategory:@"button"];
}


- (void)communityAccountAction:(NSString *)userId {
    ZFCommunityAccountViewController *accountVC = [[ZFCommunityAccountViewController alloc] init];
    accountVC.userId = userId;
    [self.navigationController pushViewController:accountVC animated:YES];
}

///布局导航右侧按钮
- (void)refreshAccountAvatorView {
    
    if ([AccountManager sharedManager].isSignIn) {
        NSURL *avatarUrl = [NSURL URLWithString:[AccountManager sharedManager].account.avatar];
        [self.userBtn yy_setImageWithURL:avatarUrl
                                forState:UIControlStateNormal
                             placeholder:ZFImageWithName(@"public_user_small")
                                 options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                              completion:nil];
        
    } else {
        [self showNewMessage:0];
        [self.userBtn setImage:ZFImageWithName(@"public_user_small") forState:UIControlStateNormal];
    }
}


//消息红点处理
- (void)showNewMessage:(NSInteger)count{
    
    if (count > 0) {
        self.messageBtn.badgeBgColor = ZFC0xFE5269();
        [self.messageBtn showBadgeWithStyle:WBadgeStyleRedDot value:count];
        self.messageBtn.badgeCenterOffset = CGPointMake(-5, 5);
        [self.tabBarController showBadgeOnItemIndex:TabBarIndexCommunity];
        
    } else {
        [self.messageBtn clearBadge];
        [self.tabBarController hideBadgeOnItemIndex:TabBarIndexCommunity];
    }
}

///发帖
- (void)showZmPostView {
    @weakify(self);
    [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeCommunityHomePage Completion:^{
        @strongify(self)
        [self.zmPostView showHotTopicView];
        [self.zmPostView show];
    }];
}

#pragma mark - <NSNotificationCenter>

///注销登录通知
- (void)logoutChangeValue:(NSNotification *)nofi {
    [self refreshAccountAvatorView];
    [self showNewMessage:0];
}

///登录通知
- (void)loginChangeValue:(NSNotification *)nofi {
    //登录后布局导航右侧按钮
    [self refreshAccountAvatorView];
    //登录后刷新未读消息数
    [self requestMessageCountInfo];
    [self requestAccountInfo];
}

///引导用户评论app
- (void)communityPostSuccessAction:(NSNotification *)notification {
    NSDictionary *noteDict = notification.object;
    self.model = [[noteDict ds_arrayForKey:@"model"] firstObject];
    //NSInteger type = [noteDict ds_integerForKey:@"review_type"];
    
    //0:默认, 1:H5页面人脸识别发帖(不需要从社区主页进入帖子详情页面)
    NSInteger comeFromeType = [noteDict ds_integerForKey:@"comeFromeType"];
    if (comeFromeType != 1) {
        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:self.model.reviewId title:nil];

        [self.navigationController pushViewController:detailViewController animated:NO];
    }
    
    if ([NSStringUtils isEmptyString:self.model.msg] || !self.postSuccessView) {
        if (self.model.is_show_popup) {
            //引导评论App方法
            [self showAppStoreCommentWithContactUs:self.model.contact_us];
        }
        return ;
    }
    self.postSuccessView.hidden = NO;
    self.postSuccessView.postSuccessMessage = self.model.msg;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.postSuccessView.hidden = YES;
        [self.postSuccessView removeFromSuperview];
        self.postSuccessView = nil;
        if (self.model.is_show_popup) {
            //引导评论App方法
            [self showAppStoreCommentWithContactUs:self.model.contact_us];
        }
    });
}


#pragma mark - getter/setter


- (ZFCommunityAccountViewModel *)accountModel {
    if (!_accountModel) {
        _accountModel = [[ZFCommunityAccountViewModel alloc] init];
    }
    return _accountModel;
}


- (void)createNavBarItems {
    
    self.view.backgroundColor = ZFCOLOR_WHITE;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //左侧按钮, (在 P上有位置偏移需要微调)
    CGFloat offsetX = 0;
    if (KScreenHeight == 736.0f) {
        offsetX = -5;
    }
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    
    UIImage *leftImage = [UIImage imageNamed:@"community_userMessage"];
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBtn setImage:leftImage forState:UIControlStateNormal];
    [messageBtn setFrame:CGRectMake(offsetX, 0, NavBarButtonSize, NavBarButtonSize)];
    messageBtn.adjustsImageWhenHighlighted = NO;
    [messageBtn addTarget:self action:@selector(messageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:messageBtn];
    
    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItems = @[messageItem];
    self.messageBtn = messageBtn;
    
    //右侧按钮
    UIView *userBtnBackgroudView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
    userBtnBackgroudView.tag = 2018;//不要删除:特殊处理社区主页右上角不处理换肤, 因为头像PDF是全色块
    UIImage *rightImage = [UIImage imageNamed:@"public_user_small"];
    UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    userBtn.frame = CGRectMake(0, 0, 24, 24);
    userBtn.layer.cornerRadius = 12;
    userBtn.clipsToBounds = YES;
    userBtn.adjustsImageWhenHighlighted = NO;
    [userBtn setImage:rightImage forState:UIControlStateNormal];
    [userBtn addTarget:self action:@selector(accountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [userBtn setEnlargeEdge:20];//扩大点击区域
    [userBtnBackgroudView addSubview:userBtn];
    self.userBtn = userBtn;
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.rankImageView.frame = CGRectMake(0, 14, 10, 10);
    } else {
        self.rankImageView.frame = CGRectMake(14, 14, 10, 10);
    }
    [userBtnBackgroudView addSubview:self.rankImageView];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:userBtnBackgroudView];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rankImageView.backgroundColor = [UIColor clearColor];
        _rankImageView.userInteractionEnabled = YES;
        _rankImageView.hidden = YES;
    }
    return _rankImageView;
}


- (ZFCommunityPostSuccessView *)postSuccessView {
    if (!_postSuccessView) {
        _postSuccessView = [[ZFCommunityPostSuccessView alloc] initWithFrame:self.view.window.bounds];
        [self.view.window addSubview:self.postSuccessView];
    }
    return _postSuccessView;
}


- (ZFCommunityHomeCMSView *)homeCMS1View {
    if (!_homeCMS1View) {
        _homeCMS1View = [[ZFCommunityHomeCMSView alloc] init];
        
        @weakify(self)
        _homeCMS1View.menuTopBlock = ^(BOOL isTop) {
            @strongify(self)
        };
        
        _homeCMS1View.scrollDirectionUpBlock = ^(BOOL directionUp) {
            @strongify(self)
            [self showFloatMenuView:directionUp];
        };
    }
    return _homeCMS1View;
}

- (ZFCommunityZmPostView *)zmPostView {
    if (!_zmPostView) {
        _zmPostView = [[ZFCommunityZmPostView alloc] init];
        
        _zmPostView.showsBlock = ^{
            // firebase
            [ZFStatistics eventType:ZF_CommunityTabbar_ImagePicker_type];
        };
        _zmPostView.outfitsBlock = ^{
            
        };
    }
    return _zmPostView;
}

- (ZFCommunityFloatingPostMenuView *)floatingPostMenuView {
    if (!_floatingPostMenuView) {
        _floatingPostMenuView = [[ZFCommunityFloatingPostMenuView alloc] initWithFrame:CGRectMake(KScreenWidth - 69,KScreenHeight - NAVBARHEIGHT -TabBarHeight - kiphoneXTopOffsetY - 56 - 24, 56, 56)];
        @weakify(self)
        _floatingPostMenuView.tapBlock = ^{
            @strongify(self)
            [self showZmPostView];
        };
    }
    return _floatingPostMenuView;
}

//- (ZFCommunityFloatingPostView *)floatingPostMenuView2 {
//    if (!_floatingPostMenuView2) {
//        _floatingPostMenuView2 = [[ZFCommunityFloatingPostView alloc] initWithFrame:CGRectMake(13,KScreenHeight - NAVBARHEIGHT -TabBarHeight - kiphoneXTopOffsetY - 66, 56, 56)];
//    }
//    return _floatingPostMenuView2;
//}

@end
