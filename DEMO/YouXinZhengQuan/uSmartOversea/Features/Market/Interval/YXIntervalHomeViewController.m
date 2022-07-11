//
//  YXIntervalHomeViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXIntervalHomeViewController.h"
#import "YXIntervalHomeViewModel.h"
#import "YXSubIntervalListViewModel.h"
#import "YXSubIntervalListViewController.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "NSDictionary+Category.h"

@interface YXIntervalHomeViewController ()<YXTabViewDelegate>


@property (nonatomic, strong) YXIntervalHomeViewModel *viewModel;

@property (nonatomic, strong) YXTabView *tabView;
@property (nonatomic, strong) YXPageView *pageView;
@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation YXIntervalHomeViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}


- (void)initUI {
    self.title = [YXLanguageUtility kLangWithKey:@"interval_title"];
    
    UIView *lineView = [UIView lineView];
    [self.view addSubview:self.tabView];
    [self.view addSubview:self.pageView];
    [self.tabView addSubview:lineView];
    
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.strongNoticeView.mas_bottom);
        make.height.mas_equalTo(40);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.tabView);
        make.height.mas_equalTo(1);
    }];
    
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tabView.mas_bottom);
    }];
    
    [self initChildViewControllers];
}


- (void)initChildViewControllers {
    
    NSString *market = [self.viewModel.params yx_stringValueForKey:@"market"];
    if ([market isEqualToString:kYXMarketUS]) {
        self.tabView.defaultSelectedIndex = 1;
    } else if ([market isEqualToString:kYXMarketHS]) {
        self.tabView.defaultSelectedIndex = 2;
    }
    
    YXSubIntervalListViewModel *viewModel1 = [[YXSubIntervalListViewModel alloc] initWithServices:self.viewModel.services params:@{@"market":@"hk"}];
    YXSubIntervalListViewController *vc1 = [[YXSubIntervalListViewController alloc] initWithViewModel:viewModel1];

    YXSubIntervalListViewModel *viewModel2 = [[YXSubIntervalListViewModel alloc] initWithServices:self.viewModel.services params:@{@"market":@"us"}];
    YXSubIntervalListViewController *vc2 = [[YXSubIntervalListViewController alloc] initWithViewModel:viewModel2];

    YXSubIntervalListViewModel *viewModel3 = [[YXSubIntervalListViewModel alloc] initWithServices:self.viewModel.services params:@{@"market":@"hs"}];
    YXSubIntervalListViewController *vc3 = [[YXSubIntervalListViewController alloc] initWithViewModel:viewModel3];

    self.tabView.titles = self.titles;
    self.pageView.viewControllers = @[vc1, vc2, vc3];

    [self.tabView reloadData];
    [self.pageView reloadData];
}


- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling {
    
}

#pragma mark - lazy load
- (YXTabView *)tabView {
    if (_tabView == nil) {
        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.lrMargin = 0;
        layout.tabMargin = 0;
        layout.titleColor = QMUITheme.textColorLevel3;
        layout.titleSelectedColor = QMUITheme.themeTextColor;
        layout.lineColor = QMUITheme.themeTextColor;
        layout.lineCornerRadius = 2;
        layout.lineWidth = 16;
        layout.lineHeight = 4;
        NSInteger count = self.titles.count;
        layout.tabWidth = (YXConstant.screenWidth)/count;
        layout.linePadding = 1;
        _tabView = [[YXTabView alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withLayout:layout];
      
        _tabView.backgroundColor = UIColor.whiteColor;
//        _tabView.titles = self.titles;
        _tabView.pageView = self.pageView;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 30, 1)];
        lineView.backgroundColor = [[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.05];
        [_tabView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_tabView);
            make.height.mas_equalTo(1);
        }];
    }
    
    return _tabView;
}

- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] initWithFrame:CGRectZero];
        _pageView.parentViewController = self;
        _pageView.contentView.scrollEnabled = YES;
    }
    return _pageView;
}

- (NSArray<NSString *> *)titles {
    if (_titles == nil) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];

        [arr addObject:[YXLanguageUtility kLangWithKey:@"community_hk_stock"]];
        [arr addObject:[YXLanguageUtility kLangWithKey:@"community_us_stock"]];
        [arr addObject:[YXLanguageUtility kLangWithKey:@"community_cn_stock"]];
        _titles = [arr copy];
    }
    return _titles;
}


@end
