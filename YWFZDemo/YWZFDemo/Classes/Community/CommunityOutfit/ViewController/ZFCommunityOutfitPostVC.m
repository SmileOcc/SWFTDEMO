//
//  ZFCommunityOutfitPostVC.m
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitPostVC.h"
#import "ZFCommunityOutfitPostEnsureVC.h"
#import "ZFWebViewViewController.h"

#import "ZFOutfitBuilderSingleton.h"
#import "ZFOutfitBuilderView.h"
#import "UIImage+ZFExtended.h"

#import "ZFCommunityPostTagViewModel.h"
#import "ZFCommunityOutfitBorderViewModel.h"
#import "ZFCommunityViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFApiDefiner.h"

#import "ZFCommunityOutiftConfigurateView.h"
#import "ZFCommunityOutfitBottomMenuView.h"


static CGFloat kZfCommunityOutfitBottomMenuHeight = 44.0;

@interface ZFCommunityOutfitPostVC ()<ZFInitViewProtocol>

@property (nonatomic, strong) ZFCommunityOutiftConfigurateView    *configurateView;
@property (nonatomic, strong) ZFCommunityOutfitBottomMenuView     *bottomMenuView;

// 穿搭画布
@property (nonatomic, strong) ZFOutfitBuilderView                 *outfitBuilderView;
@property (nonatomic, strong) UIButton                            *closeButton;
@property (nonatomic, strong) UIButton                            *nextButton;
// 添加视图
@property (nonatomic, strong) UIView                              *iphoneXBottomView;

// 盖住导航栏视图
@property (nonatomic, strong) UIView                              *coverNavBarView;

// 穿搭画布 + 事件操作：高度
@property (nonatomic, assign) CGFloat                             outfitBuilderViewHeight;
// 配置弹窗内容高度
@property (nonatomic, assign) CGFloat                             configurateContentHeight;
// 配置弹窗显示一个间隙值
@property (nonatomic, assign) CGFloat                             configurateContentTopSpace;
// 底部空白间隙
@property (nonatomic, assign) CGFloat                             bottomIphoneXSpace;


@property (nonatomic, strong) ZFCommunityViewModel                *communityViewModel;


@end

@implementation ZFCommunityOutfitPostVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showConfigurateVierw:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"community_createoutfit_title", nil);
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotification];
    [self requestBorder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadHotLabelDatas];
    });

}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFC0xF2F2F2();
    
    self.configurateContentTopSpace = 0;
    self.outfitBuilderViewHeight = KScreenWidth - 16 + [ZFOutfitBuilderView bottomOperateHeight];
    self.bottomIphoneXSpace = IPHONE_X_5_15 ? 34 : 0;
    self.configurateContentHeight = KScreenHeight - self.bottomIphoneXSpace - kZfCommunityOutfitBottomMenuHeight - 44 - self.configurateContentTopSpace - kiphoneXTopOffsetY;
    
    
    [self addPostButton];
    [self addCloseButton];
    
    [self.view addSubview:self.outfitBuilderView];
    [self.view addSubview:self.configurateView];
    [self.view addSubview:self.bottomMenuView];
    [self.view addSubview:self.iphoneXBottomView];
}

- (void)zfAutoLayoutView {
    
    [self.outfitBuilderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.outfitBuilderViewHeight);
    }];
    
    [self.iphoneXBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(self.bottomIphoneXSpace);
    }];
    
   
    [self.bottomMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.iphoneXBottomView.mas_top);
        make.height.mas_equalTo(kZfCommunityOutfitBottomMenuHeight);
    }];
    
    [self.configurateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(self.outfitBuilderViewHeight);
        make.height.mas_equalTo(self.configurateContentHeight);
    }];
  
}

- (void)addCloseButton {
    UIButton *barItemBtn                  = [UIButton buttonWithType:UIButtonTypeCustom];
    barItemBtn.frame                      = CGRectMake(0.0, 0.0, self.navigationController.navigationBar.height + 20.0, self.navigationController.navigationBar.height);
    barItemBtn.titleLabel.font            = [UIFont systemFontOfSize:16.0];
    [barItemBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [barItemBtn setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
    [barItemBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    barItemBtn.contentHorizontalAlignment = [SystemConfigUtils isRightToLeftShow] ? UIControlContentHorizontalAlignmentRight :  UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barItem              = [[UIBarButtonItem alloc] initWithCustomView:barItemBtn];
    self.navigationItem.leftBarButtonItem = barItem;
    self.closeButton                      = barItemBtn;
}

- (void)addPostButton {
    UIButton *barItemBtn                   = [UIButton buttonWithType:UIButtonTypeCustom];
    barItemBtn.frame                       = CGRectMake(0.0, 0.0, self.navigationController.navigationBar.height + 20.0, self.navigationController.navigationBar.height);
    barItemBtn.titleLabel.font             = [UIFont boldSystemFontOfSize:16.0];
    [barItemBtn setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    [barItemBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [barItemBtn setTitle:ZFLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [barItemBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    barItemBtn.contentHorizontalAlignment  = [SystemConfigUtils isRightToLeftShow] ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *barItem               = [[UIBarButtonItem alloc] initWithCustomView:barItemBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    self.nextButton                        = barItemBtn;
    self.nextButton.enabled                = NO;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOutfitItemNotice:) name:kAddOutfitItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outfitItemCountChangeNotice:) name:kOutfitItemCountChange object:nil];
}

#pragma mark - 网络请求
/**
 请求画布和分类
 */
- (void)requestBorder {
//    @weakify(self)
//    [self.outfitSelectedViewController loadBoardAndCateWithFinishedHandle:^{
//        @strongify(self)
//
//        [self.outfitBuilderView initOutfitCanvasWithImageURLs:[self.outfitSelectedViewController.borderViewModel outfitBorderImageURLs]];
//    }];
    
}

- (void)loadHotLabelDatas {
    
    [self.communityViewModel requestReviewTopicList:nil completion:^(NSArray<ZFCommunityHotTopicModel *> *results) {
        
    }];
}
#pragma mark - 事件响应
- (void)cancelAction {
    
    if (self.outfitBuilderView.editStatus == ZFOutfitsEditStatusEditing) {
        [YSAlertView alertWithTitle:nil message:ZFLocalizedString(@"community_outfit_leave_message", nil) cancelButtonTitle:nil cancelButtonBlock:nil otherButtonBlock:^(NSInteger buttonIndex, id buttonTitle) {
            if (buttonIndex == 1) {
                [[ZFOutfitBuilderSingleton shareInstance] deallocSingleton];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        } otherButtonTitles:ZFLocalizedString(@"community_outfit_leave_cancel", nil), ZFLocalizedString(@"community_outfit_leave_confirm", nil), nil];
    } else {
        [[ZFOutfitBuilderSingleton shareInstance] deallocSingleton];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)nextAction {
    ZFCommunityOutfitPostEnsureVC *ensureVC = [[ZFCommunityOutfitPostEnsureVC alloc] init];
    ensureVC.postImage = [self.outfitBuilderView imageOfOutfitsView];
    ensureVC.selectHotTopicModel = self.selectHotTopicModel;
    
    @weakify(self)
    ensureVC.successBlock = ^(NSDictionary *noteDict) {

        @strongify(self)
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshPopularNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshTopicNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityPostSuccessNotification object:noteDict];
        }];
    };
    [self.navigationController pushViewController:ensureVC animated:YES];
}


- (void)addOutfitItemNotice:(NSNotification *)note {
    if ([[note object] isKindOfClass:[ZFOutfitItemModel class]]) {
        ZFOutfitItemModel *outfitItemModel = [note object];
        self.outfitBuilderView.editStatus  = ZFOutfitsEditStatusEditing;
        [self.outfitBuilderView addNewItemWithItemModel:outfitItemModel];
        self.nextButton.enabled = [[ZFOutfitBuilderSingleton shareInstance] selectedCount] > 0;
    }
}

- (void)outfitItemCountChangeNotice:(NSNotification *)note {
    self.nextButton.enabled = [[ZFOutfitBuilderSingleton shareInstance] selectedCount] > 0;
}


- (void)coverBarTap:(UITapGestureRecognizer *)tapGesture {
    [self.configurateView actionShow];
}

/**
 是否显示选择搭配弹窗

 @param isShow: YES 显示
 */
- (void)showConfigurateVierw:(BOOL)isShow {
    
    CGFloat topDistantc = isShow ? self.configurateContentTopSpace : self.outfitBuilderViewHeight;
    if (self.coverNavBarView.superview) {
        [self.coverNavBarView removeFromSuperview];
        self.coverNavBarView.alpha = 0.0;
    }

    [UIView animateWithDuration:0.25 animations:^{
        [self.configurateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(topDistantc);
        }];
        [self.configurateView updateContentView:isShow];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (isShow) {
            [WINDOW addSubview:self.coverNavBarView];
            [UIView animateWithDuration:0.25 animations:^{
                self.coverNavBarView.alpha = 1.0;
                [self.configurateView updateTopMarkAlppa:1];
            }];
        } else {
            [self.configurateView updateTopMarkAlppa:0];
        }
    }];
    
    // 防止异常操作，需要隐藏window上的筛选视图
    if (!isShow && self.configurateView) {
        [self.configurateView hideRefineView];
    }
}

- (void)handleSelectGoods:(ZFGoodsModel *)goodModel {
    
}

- (void)handleSelectBorder:(ZFCommunityOutfitBorderModel *)borderModel {
    [self.outfitBuilderView changeBorderItemModel:nil];
}

- (void)outfitRuleAction:(NSString *)name {
    
    ZFWebViewViewController *web = [[ZFWebViewViewController alloc]init];
    web.title = ZFLocalizedString(@"Community_outfit_rules", nil);
    web.link_url = [NSString stringWithFormat:@"%@&is_app=1&lang=%@",ZFCommunityOutfitRuleUrl,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - getter/setter

- (ZFCommunityViewModel *)communityViewModel {
    if (!_communityViewModel) {
        _communityViewModel = [[ZFCommunityViewModel alloc] init];
    }
    return _communityViewModel;
}

- (ZFOutfitBuilderView *)outfitBuilderView {
    if (!_outfitBuilderView) {
        _outfitBuilderView = [[ZFOutfitBuilderView alloc] initWithFrame:CGRectZero];
        _outfitBuilderView.backgroundColor = ZFC0xF2F2F2();
        @weakify(self)
        _outfitBuilderView.completionPhoneBlock = ^(BOOL isAdd) {
            @strongify(self)
            self.nextButton.enabled = [[ZFOutfitBuilderSingleton shareInstance] selectedCount] > 0;
        };
        
        _outfitBuilderView.outfitRuleBlock = ^(NSString *name) {
            @strongify(self)
            [self outfitRuleAction:name];
        };
    }
    return _outfitBuilderView;
}

- (ZFCommunityOutiftConfigurateView *)configurateView {
    if (!_configurateView) {
        
        _configurateView = [[ZFCommunityOutiftConfigurateView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.configurateContentHeight)];
        @weakify(self)
        _configurateView.tapShowBlock = ^(BOOL isShow) {
            @strongify(self)
            [self showConfigurateVierw:isShow];
        };
        
        _configurateView.selectGoodsBlock = ^(ZFGoodsModel *goodModel) {
            @strongify(self)
            [self handleSelectGoods:goodModel];
        };
        
        _configurateView.selectBorderBlock = ^(ZFCommunityOutfitBorderModel *borderModel) {
            @strongify(self)
            [self handleSelectBorder:borderModel];
        };
        
    }
    return _configurateView;
}

- (ZFCommunityOutfitBottomMenuView *)bottomMenuView {
    if (!_bottomMenuView) {
        _bottomMenuView = [[ZFCommunityOutfitBottomMenuView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 48)];
        _bottomMenuView.datasArray = @[ZFLocalizedString(@"Community_outfit_goods", nil),ZFLocalizedString(@"Community_outfit_border", nil)];

        _bottomMenuView.backgroundColor = ZFC0xFFFFFF();
        
        [_bottomMenuView addDropShadowWithOffset:CGSizeMake(0, -2)
                               radius:2
                                color:[UIColor blackColor]
                              opacity:0.1];
        @weakify(self)
        _bottomMenuView.selectBlock = ^(NSInteger index) {
            @strongify(self)
            [self.configurateView selectBottomMenuIndex:index];
        };
    }
    return _bottomMenuView;
}


- (UIView *)coverNavBarView {
    if (!_coverNavBarView) {
        _coverNavBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44 + kiphoneXTopOffsetY + self.configurateContentTopSpace)];
        _coverNavBarView.backgroundColor = ZFC0x000000_04();
        _coverNavBarView.alpha = 0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverBarTap:)];
        [_coverNavBarView addGestureRecognizer:tap];
    }
    return _coverNavBarView;
}

- (UIView *)iphoneXBottomView {
    if (!_iphoneXBottomView) {
        _iphoneXBottomView = [[UIView alloc] init];
        _iphoneXBottomView.backgroundColor = ZFC0xFFFFFF();
    }
    return _iphoneXBottomView;
}

@end
