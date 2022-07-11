//
//  TableViewController.m
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTableViewController.h"
#import "YXTableViewModel.h"
#import "YXTableView.h"
#import "YXRefresh.h"
#import <objc/runtime.h>
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXTableViewController ()

@property (nonatomic, strong, readonly) YXTableViewModel *viewModel;
@property (nonatomic, strong, readwrite) YXTableView *tableView;

@end


@implementation YXTableViewController
@dynamic viewModel;


- (instancetype)initWithViewModel:(YXViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
//    self.tableView.delegate = nil;
//    self.tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];


    [self registerCells];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.mas_equalTo([self tableViewTop]);
        make.bottom.equalTo(self.view);
    }];
    
    //下拉刷新
    if (self.viewModel.shouldPullToRefresh) {
        @weakify(self)

        YXRefreshHeader *header = [[self refreshClass] headerWithRefreshingBlock:^{
            @strongify(self)
            [self loadFirstPage];
        }];
        //[header setStateTextColor:[QMUITheme textColorLevel2]];
        self.tableView.mj_header = header;
        
        [self showEmptyViewWithLoading];
        [self loadFirstPage];
    }

    if (!self.whiteStyle) {
        if (YXThemeTool.isDarkMode) {
            self.emptyIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        } else {
            self.emptyIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        }
    }
}

- (void)setWhiteStyle:(BOOL)whiteStyle {
    _whiteStyle = whiteStyle;
    if (_whiteStyle) {
        self.view.backgroundColor = [UIColor qmui_colorWithHexString:@"#FFFFFF"];
        self.tableView.backgroundColor = [[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.05];
        self.emptyIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [(YXRefreshAutoNormalFooter *)self.tableView.mj_footer setStateTextColor: [QMUITheme textColorLevel3]];
    }
}

- (void)loadFirstPage {
    @weakify(self)
    [[[self.viewModel.requestRemoteDataCommand execute:@(1)] deliverOnMainThread]
     subscribeNext:^(id x) {
         
     } error:^(NSError *error) {
         @strongify(self)
         [self hideEmptyView];
         [self.tableView.mj_header endRefreshing];
         [self.tableView.mj_footer resetNoMoreData];
     } completed:^{
         @strongify(self)
         [self hideEmptyView];
         [self.tableView.mj_header endRefreshing];
         
         if (self.viewModel.shouldInfiniteScrolling && self.tableView.mj_footer == nil) {
             if ([self.viewModel.dataSource count] > 0 && [self.viewModel.dataSource[0] count] > 0) {
                 YXRefreshAutoNormalFooter *footer = [YXRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                     @strongify(self)
                     if ([self.viewModel.dataSource count] > 0 && self.viewModel.dataSource[0].count > 0) {
                         ((MJRefreshAutoStateFooter *)self.tableView.mj_footer).refreshingTitleHidden = NO;
                         [self loadNextPage];
                     } else {
                         [self.tableView.mj_footer endRefreshing];
                     }
                 }];
                 if (self.whiteStyle) {
                     [footer setStateTextColor:[QMUITheme textColorLevel3]];
                 } else {
                     [footer setStateTextColor:[QMUITheme textColorLevel3]];
                 }
                 self.tableView.mj_footer = footer;
             }
         } else if ([self.viewModel.dataSource count] < 1 || [self.viewModel.dataSource[0] count] < 1) {
             self.tableView.mj_footer = nil;
         }
         
         if (self.viewModel.loadNoMore) {
             [self.tableView.mj_footer endRefreshingWithNoMoreData];
         } else {
             [self.tableView.mj_footer resetNoMoreData];
         }
     }];
}

- (void)loadNextPage {
    @weakify(self)
    [[[self.viewModel.requestRemoteDataCommand execute:@(self.viewModel.page+1)] deliverOnMainThread]
     subscribeNext:^(id x) {
     } error:^(NSError *error) {
         @strongify(self)
         [self.tableView.mj_footer endRefreshing];
     } completed:^{
         @strongify(self)
         if (self.viewModel.loadNoMore) {
             [self.tableView.mj_footer endRefreshingWithNoMoreData];
         } else {
             [self.tableView.mj_footer endRefreshing];
         }
     }];
}


- (CGFloat)tableViewTop {
    if (@available(iOS 13.0, *)) {
        return 0;
    } else {
        return YXConstant.navBarHeight;
    }
}

- (UITableViewStyle)tableViewStyle {
    return  UITableViewStylePlain;
}

- (CGFloat)rowHeight {
    return 44;
}


/**
 *  注册Cell
 */
- (void)registerCells{
    NSDictionary *cellIdentifiers = [self cellIdentifiers];
    @weakify(self)
    [cellIdentifiers enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * obj, BOOL *stop) {
        @strongify(self)
    
        [self.tableView registerClass:NSClassFromString(obj) forCellReuseIdentifier:key];

    }];
}


-(NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath{
    /**
     *  使用说明：
     *  该方法用于返回cell对应的identifier
     *
     *  使用方法：
     *  return @"";
     */
    NSUInteger section = aIndexPath.section;
    NSArray *cellClasses = [self cellClasses];
    
    NSAssert(section < [cellClasses count], @"section需小于cellClasses数组长度");
    
    Class cellClass = cellClasses[section];
    NSString *cellID = [NSString stringWithFormat:@"%@Identifier%zd", NSStringFromClass(cellClass), section];
    
    return cellID;
}

-(NSDictionary *)cellIdentifiers{
    /*
     *  使用说明：
     *  该方法用于处理Cell类型和Cell identifier的关联
     *
   
     *  格式：
     *      return [NSDictionary dictionaryWithObjectsAndKeys:@"YXTableViewCell",@"YXTableViewCell"];(默认方式)
     */
    NSMutableDictionary *cellIdentifiers = [@{} mutableCopy];
    NSArray *cellClasses = [self cellClasses];
    NSUInteger count = [cellClasses count];
    for (NSUInteger i = 0; i < count; i ++) {
        Class cellClass = cellClasses[i];
        NSString *cellID = [NSString stringWithFormat:@"%@Identifier%zd", NSStringFromClass(cellClass), i];
        cellIdentifiers[cellID] = NSStringFromClass(cellClass);
    }
    
    return [cellIdentifiers copy];
}

- (NSArray<Class> *)cellClasses {
   return @[[YXTableViewCell class]];
}

/**
 下拉刷新类型
 */
- (Class)refreshClass {
    return [YXRefreshHeader class];
}

- (void)bindViewModel {
    
    //当数组变化时刷新tableView
    @weakify(self)
    [[RACObserve(self.viewModel, dataSource)
      deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self)
         [self reloadData];
     }];
    
    //请求过程中 隐藏空白显示
    [self.viewModel.requestRemoteDataCommand.executing subscribeNext:^(NSNumber *executing) {
        @strongify(self)
        UIView *emptyDataSetView = [self.tableView.subviews.rac_sequence objectPassingTest:^(UIView *view) {
            return [NSStringFromClass(view.class) isEqualToString:@"DZNEmptyDataSetView"];
        }];
        emptyDataSetView.alpha = 1.0 - executing.floatValue;
    }];
}


- (void)reloadData {
    [self.tableView reloadData];
}


- (void)configureCell:(YXTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(YXModel *)object {
    cell.model = object;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    if (self.whiteStyle) {
        return;
    }

    if (YXThemeTool.isDarkMode) {
        self.emptyIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        self.emptyIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}

#pragma mark - DZNEmptyDataSetSource

- (UIImage *)customImageForEmptyDataSet {
    return [UIImage imageNamed:@"empty_noData"];
}

- (NSAttributedString *)customTitleForEmptyDataSet {
    return [[NSAttributedString alloc]
            initWithString:[YXLanguageUtility kLangWithKey:@"common_no_data"]
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16],
                         NSForegroundColorAttributeName: [QMUITheme textColorLevel3]}
            ];
}


- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    QMUIEmptyView *emptyView = [[QMUIEmptyView alloc] initWithFrame:self.view.bounds];
    [emptyView setLoadingViewHidden:YES];
    emptyView.imageViewInsets = UIEdgeInsetsMake(0, 0, 20, 0);
    emptyView.textLabelInsets = UIEdgeInsetsMake(0, 0, 12, 0);

    if (self.viewModel.dataSource == nil) {
        [emptyView setImage:[UIImage imageNamed:@"network_nodata"]];

        [emptyView setTextLabelText:[YXLanguageUtility kLangWithKey:@"common_loadFailed"]];
        [emptyView setTextLabelFont:[UIFont systemFontOfSize:16]];
        [emptyView setTextLabelTextColor:[QMUITheme textColorLevel3]];

        [emptyView setActionButtonTitle:[YXLanguageUtility kLangWithKey:@"common_click_refresh"]];
        [emptyView setActionButtonFont:[UIFont systemFontOfSize:14]];
        [emptyView setActionButtonTitleColor:[UIColor whiteColor]];
        emptyView.actionButton.contentEdgeInsets = UIEdgeInsetsMake(7, 23, 7, 23);
        [emptyView.actionButton setBackgroundColor:QMUITheme.mainThemeColor];
        [emptyView.actionButton addTarget:self action:@selector(clickRefreshButton) forControlEvents:UIControlEventTouchUpInside];
        emptyView.actionButton.layer.cornerRadius = 4;
        emptyView.actionButton.layer.masksToBounds = YES;
    } else {
        if ([self respondsToSelector:@selector(customImageForEmptyDataSet)]) {
            [emptyView setImage:[self customImageForEmptyDataSet]];
        }

        if ([self respondsToSelector:@selector(customTitleForEmptyDataSet)]) {
            NSAttributedString *attributedString = [self customTitleForEmptyDataSet];
            [emptyView setTextLabelText:attributedString.string];
            [emptyView setTextLabelFont:attributedString.yy_font ?: [UIFont systemFontOfSize:16]];
            [emptyView setTextLabelTextColor:attributedString.yy_color ?: [QMUITheme textColorLevel3]];
        }
    }

    CGSize size = emptyView.sizeThatContentViewFits;
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];

    return emptyView;
}

- (void)clickRefreshButton {
    if (self.viewModel.dataSource == nil) {
        [self showEmptyViewWithLoading];
        [self loadFirstPage];
    }
}

#pragma mark - DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.viewModel.dataSource == nil || self.viewModel.dataSource.count == 0 || (self.viewModel.dataSource.count == 1 && self.viewModel.dataSource.firstObject.count == 0);
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return self.viewModel.dataSource != nil;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        UITableView *view = (UITableView *)scrollView;
        if (view.tableHeaderView.mj_h > 0) {
            return view.tableHeaderView.mj_h + 40;
        }
    }
    return 40;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource ? self.viewModel.dataSource.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.viewModel.dataSource.count == 0) {
        return 0;
    }
    return [self.viewModel.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
    id object = self.viewModel.dataSource[indexPath.section][indexPath.row];
    [self configureCell:cell atIndexPath:indexPath withObject:(id)object];
    return cell;
}



#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel.didSelectCommand execute:indexPath];
}


- (YXTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:[self tableViewStyle]];
        _tableView.backgroundColor = [QMUITheme backgroundColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.rowHeight = [self rowHeight];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, CGFLOAT_MIN)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 13.0, *)) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _tableView;
}

@end
