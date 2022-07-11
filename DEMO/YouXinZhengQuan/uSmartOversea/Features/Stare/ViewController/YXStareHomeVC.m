//
//  YXStareHomeVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareHomeVC.h"
#import "YXStareDetailVC.h"
#import "YXStareHomeViewModel.h"
#import "YXStareDetailViewModel.h"
#import "YXStareSettingViewModel.h"
#import "YXStareUtility.h"
#import <YXKit/YXKit.h>
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import "YXStareSettingVC.h"

@interface YXStareHomeVC ()

@property (nonatomic, strong) YXTabView *tabview;

@property (nonatomic, strong) YXPageView *pageView;

@property (nonatomic, strong) YXStareHomeViewModel *viewModel;

@end

@implementation YXStareHomeVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [YXLanguageUtility kLangWithKey:@"smart_watch"];
    
    // 重置
    [YXStareUtility resetMarketSubType:0];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initUI];
}

- (void)initUI {

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"monitor_push_setting"] style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarItemAction)];
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : QMUITheme.textColorLevel1} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : QMUITheme.textColorLevel1} forState:UIControlStateSelected];
    self.navigationItem.rightBarButtonItems = @[rightBarItem];


    [self.view addSubview:self.tabview];
    [self.view addSubview:self.pageView];

    [self.tabview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(40);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view.mas_top).offset(YXConstant.navBarHeight);
        }
    }];

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = QMUITheme.separatorLineColor;
    [self.view addSubview:line];

    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.tabview);
        make.height.mas_equalTo(1);
    }];
    
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.tabview.mas_bottom);
    }];
    
}

- (void)rightBarItemAction {
    YXStareSettingViewModel *viewModel = [[YXStareSettingViewModel alloc] initWithServices:self.viewModel.services params:@{}];
    YXStareSettingVC *vc = [[YXStareSettingVC alloc] initWithViewModel:viewModel];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 懒加载
- (YXTabView *)tabview {
    if (_tabview == nil) {
        NSArray *titles = @[[YXLanguageUtility kLangWithKey:@"community_hk_stock"], [YXLanguageUtility kLangWithKey:@"community_us_stock"], [YXLanguageUtility kLangWithKey:@"community_cn_stock"], [YXLanguageUtility kLangWithKey:@"option_and_hold"]];
        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.titleColor = QMUITheme.textColorLevel2;
        layout.lineWidth = 28;
        _tabview = [[YXTabView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 40) withLayout:layout];
        _tabview.titles = titles;
        _tabview.pageView = self.pageView;
        _tabview.backgroundColor = QMUITheme.foregroundColor;
        _tabview.defaultSelectedIndex = self.viewModel.type;
    }
    return _tabview;
}

- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] init];
        _pageView.parentViewController = self;
        _pageView.contentView.scrollEnabled = true;

        YXStareDetailViewModel *mode1 = [[YXStareDetailViewModel alloc] initWithServices:self.viewModel.services params:@{@"type": @(0)}];
        YXStareDetailViewModel *mode2 = [[YXStareDetailViewModel alloc] initWithServices:self.viewModel.services params:@{@"type": @(1)}];
        YXStareDetailViewModel *mode3 = [[YXStareDetailViewModel alloc] initWithServices:self.viewModel.services params:@{@"type": @(2)}];
        YXStareDetailViewModel *mode4 = [[YXStareDetailViewModel alloc] initWithServices:self.viewModel.services params:@{@"type": @(3)}];
        YXStareDetailVC *vc1 = [[YXStareDetailVC alloc] initWithViewModel:mode1];
        YXStareDetailVC *vc2 = [[YXStareDetailVC alloc] initWithViewModel:mode2];
        YXStareDetailVC *vc3 = [[YXStareDetailVC alloc] initWithViewModel:mode3];
        YXStareDetailVC *vc4 = [[YXStareDetailVC alloc] initWithViewModel:mode4];
        _pageView.viewControllers = @[vc1, vc2, vc3, vc4];
    }
    return _pageView;
}

@end
