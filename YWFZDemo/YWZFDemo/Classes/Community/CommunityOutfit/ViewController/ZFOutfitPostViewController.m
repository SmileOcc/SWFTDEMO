//
//  ZFOutfitPostViewController.m
//  Zaful
//
//  Created by QianHan on 2018/5/23.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitPostVC.h"
#import "ZFOutfitSelectedPageViewController.h"
#import "ZFOutfitPostEnsureViewController.h"
#import "ZFOutfitBuilderSingleton.h"
#import "ZFOutfitBuilderView.h"
#import "UIImage+ZFExtended.h"
#import "ZFBreathView.h"

#import "ZFCommunityPostTagViewModel.h"
#import "ZFOutfitBorderViewModel.h"
#import "ZFInitViewProtocol.h"

@interface ZFCommunityOutfitPostVC ()<ZFInitViewProtocol>

@property (nonatomic, strong) ZFOutfitSelectedPageViewController  *outfitSelectedViewController;
// 穿搭画布
@property (nonatomic, strong) ZFOutfitBuilderView                 *outfitBuilderView;
@property (nonatomic, strong) UIButton                            *closeButton;
@property (nonatomic, strong) UIButton                            *nextButton;
@property (nonatomic, strong) ZFBreathView                        *breathView;
// 添加视图
@property (nonatomic, strong) UIButton                            *addOutfitsButton;
@property (nonatomic, strong) UIView                              *iphoneXBottomView;
@end

@implementation ZFCommunityOutfitPostVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.outfitSelectedViewController.borderViewModel outfitBorderImageURLs].count > 0) {
        [self.outfitBuilderView initOutfitCanvasWithImageURLs:[self.outfitSelectedViewController.borderViewModel outfitBorderImageURLs]];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"community_createoutfit_title", nil);
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotification];
    [self requestBorder];
}


#pragma mark - 初始化数据

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    
    self.outfitSelectedViewController = [[ZFOutfitSelectedPageViewController alloc] init];
    self.outfitSelectedViewController.borderViewModel = [ZFOutfitBorderViewModel new];
    
    [self addPostButton];
    [self addCloseButton];
    
    [self.view addSubview:self.addOutfitsButton];
    [self.view addSubview:self.iphoneXBottomView];
    [self.view addSubview:self.outfitBuilderView];

    // 添加操作提示
    NSString *firstTip = @"firstTip";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isShowed = [userDefaults boolForKey:firstTip];

    if (!isShowed) {
        [userDefaults setBool:YES forKey:firstTip];

        [self.addOutfitsButton addSubview:self.breathView];
        [self.breathView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.addOutfitsButton.mas_centerX);
            make.centerY.mas_equalTo(self.addOutfitsButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
    }
}

- (void)zfAutoLayoutView {
    
    [self.iphoneXBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(kiphoneXHomeBarHeight);
    }];
    
    [self.addOutfitsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.iphoneXBottomView.mas_top);
        make.height.mas_equalTo(48);
    }];
    
    [self.outfitBuilderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.addOutfitsButton.mas_top);
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
    barItemBtn.titleLabel.font             = [UIFont systemFontOfSize:16.0];
    [barItemBtn setTitleColor:ColorHex_Alpha(0xffa800, 1.0) forState:UIControlStateNormal];
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
    @weakify(self)
    [self.outfitSelectedViewController loadBoardAndCateWithFinishedHandle:^{
        @strongify(self)
        
        [self.outfitBuilderView initOutfitCanvasWithImageURLs:[self.outfitSelectedViewController.borderViewModel outfitBorderImageURLs]];
    }];
}

#pragma mark - 事件响应
- (void)cancelAction {
    [self.outfitBuilderView hideTipView];
    
    if (self.outfitBuilderView.editStatus == ZFOutfitsEditStatusEditing) {
        [ZFAlertView alertWithTitle:nil message:ZFLocalizedString(@"community_outfit_leave_message", nil) cancelButtonTitle:nil cancelButtonBlock:nil otherButtonBlock:^(NSInteger buttonIndex, id buttonTitle) {
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
    ZFOutfitPostEnsureViewController *ensureVC = [[ZFOutfitPostEnsureViewController alloc] init];
    ensureVC.postImage = [self.outfitBuilderView imageOfOutfitsView];
    ensureVC.topicLabel = ZFToString(self.topicLabel);
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

- (void)addOutfitsAction {
    [self.outfitBuilderView hideTipView];
    
    if ([[ZFOutfitBuilderSingleton shareInstance] selectedCount] >= 15) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"community_outfistpost_counttost", nil));
        return;
    }
    for (UIView *view in self.addOutfitsButton.subviews) {
        if ([view isKindOfClass:[ZFBreathView class]]) {
            [view removeFromSuperview];
        }
    }
    ZFNavigationController *navigationController  = [[ZFNavigationController alloc] initWithRootViewController:self.outfitSelectedViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
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

#pragma mark - getter/setter
- (UIButton *)addOutfitsButton {
    if (!_addOutfitsButton) {
        _addOutfitsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addOutfitsButton.backgroundColor = [UIColor colorWithHex:0xFFA800];
        _addOutfitsButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_addOutfitsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addOutfitsButton setTitle:ZFLocalizedString(@"community_add_outfit", nil) forState:UIControlStateNormal];
        [_addOutfitsButton addTarget:self action:@selector(addOutfitsAction) forControlEvents:UIControlEventTouchUpInside];
        
        _addOutfitsButton.layer.shadowOffset  = CGSizeMake(0, -1.0f);
        _addOutfitsButton.layer.shadowOpacity = 0.2;
        _addOutfitsButton.layer.shadowColor   = [UIColor blackColor].CGColor;
    }
    return _addOutfitsButton;
}

- (ZFBreathView *)breathView {
    if (!_breathView) {
        _breathView = [[ZFBreathView alloc] initWithFrame:CGRectMake(0.0, 0.0, 48, 48)];
        _breathView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(addOutfitsAction)];
        [_breathView addGestureRecognizer:tap];
    }
    return _breathView;
}

- (ZFOutfitBuilderView *)outfitBuilderView {
    if (!_outfitBuilderView) {
        _outfitBuilderView = [[ZFOutfitBuilderView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _outfitBuilderView.completionPhoneBlock = ^(BOOL isAdd) {
            @strongify(self)
            self.nextButton.enabled = [[ZFOutfitBuilderSingleton shareInstance] selectedCount] > 0;
        };
    }
    return _outfitBuilderView;
}

- (UIView *)iphoneXBottomView {
    if (!_iphoneXBottomView) {
        _iphoneXBottomView = [[UIView alloc] init];
        _iphoneXBottomView.backgroundColor = [UIColor blackColor];
    }
    return _iphoneXBottomView;
}

@end
