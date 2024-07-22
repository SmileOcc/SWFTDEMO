//
//  CategorySubLevelController.m
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategorySubLevelController.h"
#import "CategorySubLevelCell.h"
#import "CategorySubLevelViewModel.h"
#import "CategoryListPageViewController.h"
#import "ZFSearchViewController.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface CategorySubLevelController ()
@property (nonatomic, strong) UICollectionView            *categoryView;
@property (nonatomic, strong) CategorySubLevelViewModel   *viewModel;
@end

@implementation CategorySubLevelController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self configureNavigationBar];
    [self configureSubViews];
    [self autoLayoutSubViews];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //谷歌统计
    [ZFAnalytics screenViewQuantityWithScreenName:[NSString stringWithFormat:@"Cate - %@", self.model.cat_name]];
}

#pragma mark - Initialize
- (void)configureNavigationBar {
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [searchButton setImage:ZFImageWithName(@"category_goodslist_search") forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    searchButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
    self.navigationItem.rightBarButtonItem = searchItem;
}

-(void)configureSubViews {
    self.title = self.model.cat_name;
    self.view.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.view addSubview:self.categoryView];
}

-(void)autoLayoutSubViews {
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)rightSearchBtnClick:(id)sender {
    ZFSearchViewController *searchViewController = [[ZFSearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Private Methods
- (void)loadData {
    [self.viewModel requestSubLevelDataWithParentID:self.model.cat_id completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.categoryView reloadData];
        });
    }];
}

#pragma mark - Getter
-(UICollectionView *)categoryView {
    if (!_categoryView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 7.5;
        layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
        CGFloat itemWidth = (KScreenWidth - 12 - 12 - 15) / 3;
        layout.itemSize = CGSizeMake(itemWidth, 138);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _categoryView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _categoryView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        [_categoryView registerClass:[CategorySubLevelCell class] forCellWithReuseIdentifier:[CategorySubLevelCell setIdentifier]];
        _categoryView.delegate = self.viewModel;
        _categoryView.dataSource = self.viewModel;
        _categoryView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _categoryView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _categoryView;
}

-(CategorySubLevelViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CategorySubLevelViewModel alloc] init];
        @weakify(self)
        _viewModel.handler = ^(CategoryNewModel *model) {
            @strongify(self)
            // firebase统计
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Category_Item_%@", model.cat_name] itemName:model.cat_name ContentType:@"Category_Sub_List" itemCategory:@"List"];
            
            CategoryListPageViewController *listPageVC = [[CategoryListPageViewController alloc] init];
            if ([model.cat_name isEqualToString:ZFLocalizedString(@"TopicHead_Cell_ViewAll", nil)]) {
                model.cat_name = self.title;
            }
            listPageVC.model = model;
            [self.navigationController pushViewController:listPageVC animated:YES];
        };
    }
    return _viewModel;
}

@end

