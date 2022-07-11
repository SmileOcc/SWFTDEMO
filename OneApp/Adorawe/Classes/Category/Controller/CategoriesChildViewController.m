//
//  CategoriesChildViewController.m
//  Yoshop
//
//  Created by 党宝平 on 16/7/4.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "CategoriesChildViewController.h"
#import "CategoriesChildViewModel.h"
#import "CategoriesChildCell.h"
#import "SearchViewController.h"

@interface CategoriesChildViewController ()
@property (nonatomic, strong) CategoriesChildViewModel        *viewModel;
@property (nonatomic, strong) UICollectionView                *subClassCollectionView;
@property (nonatomic, strong) UIButton                        *categoriesSearchBtn;
@property (nonatomic, strong) YYAnimatedImageView             *searchImageView;
@property (nonatomic, strong) CategoriesChildModel            *chiledModel;
@property (nonatomic, strong) UIScrollView                    *emptyBackView;
@end

@implementation CategoriesChildViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.firstEnter) {// 谷歌统计
        self.firstEnter = YES;
        [YSAnalytics screenViewQuantityWithScreenName:[NSString stringWithFormat:@"Cate - %@", _childCatName]];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createSearchView];
    [self initEmptySubViews];
    [self requestData];
    
    if (_childCatName) {
        NSDictionary *dic = @{@"eventType" :@(EventTypeCategoryShown),@"category" :_childCatName,};
        [[YSRemarketing shareManager] remarketingEvent:dic];
    }
}


#pragma mark - MakeUI

- (void)initView{

    if (!_subClassCollectionView) {
        [self.view addSubview:self.subClassCollectionView];
        [self.subClassCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    } else {
        [self.subClassCollectionView reloadData];
    }
}

- (void)createSearchView{
    [self.navigationItem setTitleView:self.categoriesSearchBtn];
    [self.categoriesSearchBtn addSubview:self.searchImageView];
}


#pragma mark - Request

- (void)requestData {
    @weakify(self)
    [self.viewModel requestNetwork:self.childCatId completion:^(id obj) {
        @strongify(self)
        self.chiledModel = obj;
        if (self.chiledModel) {
            [self initView];
            [self.emptyBackView removeFromSuperview];
        }else {
            self.emptyBackView.hidden = NO;
        }
    } failure:^(id obj) {
        @strongify(self)
        self.emptyBackView.hidden = NO;
    }];
}


#pragma mark - Action
//当空白的时候点击
- (void)emptyCategoriesTapAction {
    self.emptyBackView.hidden = YES;
    [self requestData];
}

- (void)categoriesChildSearchBtnClick {
    SearchViewController * searchVC = [[SearchViewController alloc] init];
    searchVC.enterName = @"Catetory";
    searchVC.catId = self.childCatId;
    [self.navigationController pushViewController:searchVC animated:YES];
    
    //occccccc
    [YSAnalytics firebaseLogEventWithName:@"categories_search" parameters:@{}];
}


#pragma mark - LazyLoad

- (CategoriesChildViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [CategoriesChildViewModel new];
        _viewModel.controller = self;
        _viewModel.childCatName = self.childCatName;
    }
    return _viewModel;
}

- (UICollectionView *)subClassCollectionView {
    if (!_subClassCollectionView) {

        PlainFlowLayout *flowLayout = [[PlainFlowLayout alloc] init];
        flowLayout.naviHeight = - 64;

        _subClassCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _subClassCollectionView.backgroundColor = YSCOLOR_241_241_241;
        _subClassCollectionView.delegate = self.viewModel;
        _subClassCollectionView.dataSource = self.viewModel;
        _subClassCollectionView.scrollEnabled = YES;
        _subClassCollectionView.alwaysBounceVertical = YES;

        [_subClassCollectionView registerClass:[CategoriesChildCell class] forCellWithReuseIdentifier:@"cell"];
        [_subClassCollectionView registerClass:[CategoriesChildHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [_subClassCollectionView registerClass:[CategoriesChildFootView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];

    }
    return _subClassCollectionView;
}

- (UIButton *)categoriesSearchBtn {
    if (!_categoriesSearchBtn) {
        _categoriesSearchBtn = [[UIButton alloc]initWithFrame:CGRectMake(25, 27, SCREEN_WIDTH - 50, 30)];
        _categoriesSearchBtn.layer.masksToBounds = YES;
        _categoriesSearchBtn.layer.cornerRadius = 2;
        _categoriesSearchBtn.backgroundColor = YSCOLOR_237_237_237;
        [_categoriesSearchBtn setTitle:[NSString stringWithFormat:@"   %@",NSLocalizedString_(@"search", nil)] forState:UIControlStateNormal];
        [_categoriesSearchBtn setTitleColor:YSCOLOR_153_153_153 forState:UIControlStateNormal];
        _categoriesSearchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_categoriesSearchBtn addTarget:self action:@selector(categoriesChildSearchBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _categoriesSearchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    }
    return _categoriesSearchBtn;
}

- (YYAnimatedImageView *)searchImageView {
    if (!_searchImageView) {
        _searchImageView = [[YYAnimatedImageView alloc]initWithFrame:CGRectMake(self.categoriesSearchBtn.bounds.size.width -40, 7, 16, 16)];
        _searchImageView.backgroundColor = [UIColor clearColor];
        _searchImageView.image = [UIImage imageNamed:@"search_icon"];
    }
    return _searchImageView;
}

#pragma mark - 空白View
- (void)initEmptySubViews {
    
    self.emptyBackView = [[UIScrollView alloc] init];
    self.emptyBackView.hidden = YES;
    [self.view addSubview:self.emptyBackView];
    [self.emptyBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    [self.emptyBackView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyBackView.mas_top).offset(85);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = YSBlACK_COLOR;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = NSLocalizedString(@"load_failed", nil);
    [self.emptyBackView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = YSMAIN_COLOR;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:YSCOLOR_51_51_51 forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(emptyCategoriesTapAction) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [self.emptyBackView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
}

@end
