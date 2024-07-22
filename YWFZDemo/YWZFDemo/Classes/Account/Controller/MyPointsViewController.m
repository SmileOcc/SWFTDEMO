//
//  DRewardsViewController.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/28.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "MyPointsViewController.h"
#import "MyPointsCell.h"
#import "PointsModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MyPointViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFWebViewViewController.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIScrollView+ZFBlankPageView.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFThemeFontManager.h"

@interface MyPointsViewController () <ZFInitViewProtocol>
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) UIView                *headerView;
@property (nonatomic, strong) UIButton              *pointCountButton;
@property (nonatomic, strong) UILabel               *rewardsLabel;
@property (nonatomic, strong) UILabel               *expireTipsLabel;
@property (nonatomic, strong) UIButton              *pointTipsBtn;
@property (nonatomic, strong) MyPointViewModel      *viewModel;
@end

@implementation MyPointsViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = ZFLocalizedString(@"MyPoints_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addHeaderFooterView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showPointsNavF7F7F7Color:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showPointsNavF7F7F7Color:NO];
}

#pragma mark -====== 处理换肤逻辑 ======
// 处理导航背景色
- (void)showPointsNavF7F7F7Color:(BOOL)showF7F7F7Color {
    if ([AccountManager sharedManager].needChangeAppSkin) return;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (showF7F7F7Color) {
        navBar.barTintColor = ZFC0xF7F7F7();
    } else {
        navBar.barTintColor = ZFCOLOR_WHITE;
    }
}

#pragma mark - action methods

- (void)questionBtnClick {
    ZFWebViewViewController *web = [[ZFWebViewViewController alloc] init];
    web.title = ZFLocalizedString(@"MyPoints_WhatPoints_VC_Title",nil);
    NSString *appH5BaseURL = [YWLocalHostManager appH5BaseURL];
    web.link_url = [NSString stringWithFormat:@"%@z-points/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - private methods

- (void)addHeaderFooterView {
    @weakify(self);
    [self.tableView addHeaderRefreshBlock:^{
        @strongify(self);
        [self requestPointsPageData:YES];
        
    } footerRefreshBlock:^{
        @strongify(self);
        [self requestPointsPageData:NO];
        
    } startRefreshing:YES];
}

#pragma mark - private methods

/**
 * 分页请求积分数据
 */
- (void)requestPointsPageData:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestPointsListData:isFirstPage completion:^(NSDictionary *pageInfo, BOOL isSuccess) {
        @strongify(self)
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageInfo];
        
        self.headerView.hidden = !isSuccess;
        if (isSuccess && self.viewModel.currentPage == 1) {
            [self refreshPointData];
        }
    }];
}

- (void)refreshPointData {
    [self.pointCountButton setImage:ZFImageWithName(@"my_all_points") forState:(UIControlStateNormal)];
    [self.pointCountButton setTitle:self.viewModel.pointCountText forState:(UIControlStateNormal)];
    [self.pointCountButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleLeft) imageTitleSpace:5];
    self.rewardsLabel.text = self.viewModel.rewardsText;
    self.expireTipsLabel.text = self.viewModel.expireTipsText;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat maxX = CGRectGetMaxX(self.rewardsLabel.frame);
        if (maxX > KScreenWidth) {
            [self.rewardsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.pointCountButton.mas_bottom);
                make.leading.mas_equalTo(self.pointCountButton.mas_leading);
                make.trailing.mas_equalTo(self.headerView.mas_trailing).offset(-11);
            }];
            [self.pointCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 11 *2);
            }];
        }
        [self.view layoutIfNeeded];
    });
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.pointCountButton];
    [self.headerView addSubview:self.rewardsLabel];
    [self.headerView addSubview:self.expireTipsLabel];
    [self.headerView addSubview:self.pointTipsBtn];
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
    }];
    
    [self.pointCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_top).offset(24);
        make.leading.mas_equalTo(self.headerView.mas_leading).offset(11);
        //make.width.mas_lessThanOrEqualTo(KScreenWidth - 11 *2);
    }];
  
    [self.rewardsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.pointCountButton.mas_bottom).offset(-9);;
        make.leading.mas_equalTo(self.pointCountButton.mas_trailing).offset(9);
        // make.trailing.mas_equalTo(self.headerView.mas_trailing).offset(-11);
    }];
    
    [self.expireTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rewardsLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.pointCountButton.mas_leading);
        make.trailing.mas_equalTo(self.headerView.mas_trailing).offset(-11);
    }];
    
    [self.pointTipsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.expireTipsLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.pointCountButton.mas_leading);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 11 *2);
        make.bottom.mas_equalTo(self.headerView.mas_bottom).offset(-24);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-0);
    }];
}

#pragma mark - getter

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self.viewModel;
        _tableView.dataSource = self.viewModel;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorColor = ZFC0xDDDDDD();
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.estimatedRowHeight = 88;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        
        //处理数据空白页
        _tableView.emptyDataImage = [UIImage imageNamed:@"ic_point"];
        _tableView.emptyDataTitle = ZFLocalizedString(@"MyPoints_EmptyData_Tip",nil);
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = ZFC0xF7F7F7();
        _headerView.userInteractionEnabled = YES;
        _headerView.hidden = YES;
    }
    return _headerView;
}

- (UIButton *)pointCountButton{
    if (!_pointCountButton) {
        _pointCountButton = [[UIButton alloc] init];
        _pointCountButton.titleLabel.font = ZFFontBoldNumbers(30);
        [_pointCountButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:(UIControlStateNormal)];
        UIImage *image = [UIImage imageNamed:@"my_all_points"];
        [_pointCountButton setImage:image forState:(UIControlStateNormal)];
        [_pointCountButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleLeft) imageTitleSpace:5];
        _pointCountButton.adjustsImageWhenHighlighted = NO;
        _pointCountButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;//标题过长换行
    }
    return _pointCountButton;
}

- (UILabel *)rewardsLabel{
    if (!_rewardsLabel) {
        _rewardsLabel = [[UILabel alloc] init];
        _rewardsLabel.textColor = ZFC0x2D2D2D();
        _rewardsLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _rewardsLabel;
}

- (UILabel *)expireTipsLabel{
    if (!_expireTipsLabel) {
        _expireTipsLabel = [[UILabel alloc] init];
        _expireTipsLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _expireTipsLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _expireTipsLabel;
}

- (UIButton *)pointTipsBtn {
    if (!_pointTipsBtn) {
        _pointTipsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pointTipsBtn.titleLabel.font = ZFFontSystemSize(12);
        [_pointTipsBtn setTitleColor:ZFCOLOR(153, 153, 153, 1) forState:(UIControlStateNormal)];
        [_pointTipsBtn setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
        [_pointTipsBtn setTitle:ZFLocalizedString(@"Point_learn_how_get_points", nil) forState:(UIControlStateNormal)];
        [_pointTipsBtn zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight) imageTitleSpace:5];
        [_pointTipsBtn addTarget:self action:@selector(questionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pointTipsBtn;
}

- (MyPointViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MyPointViewModel alloc]init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

@end
