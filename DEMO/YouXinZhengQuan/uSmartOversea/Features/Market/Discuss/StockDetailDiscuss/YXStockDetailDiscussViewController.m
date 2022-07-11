//
//  YXStockDetailDiscussViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockDetailDiscussViewController.h"
#import "YXStockDetailDiscussViewModel.h"
#import "YXReportViewModel.h"
#import "YXCommentViewModel.h"
#import "YXCommentViewController.h"
//#import "YXNavigationController.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import <IGListKit/IGListKit.h>
#import "YXReportViewController.h"

@interface YXStockDetailDiscussViewController ()<IGListAdapterDataSource, IGListAdapterPerformanceDelegate>

@property (nonatomic, strong) YXStockDetailDiscussViewModel *viewModel;
@property (nonatomic, strong) IGListAdapter *adapter;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger page_size;


@property (nonatomic, strong) QMUIButton *reportButton;
@property (nonatomic, strong) QMUIButton *stickButton;

@property (nonatomic, strong) YXCommentDetailNoDataView *noDataView;

@property (nonatomic, strong) YXStockDetailGuessUpOrDownInfo *guessInfoModel;
//@property (nonatomic, strong) YXCommunityHeaderView *headerView;
@property (nonatomic, assign) BOOL local;
@end

@implementation YXStockDetailDiscussViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    [self loadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)bindViewModel {
    
}

-(void)initUI {
    self.view.backgroundColor = QMUITheme.foregroundColor;

    @weakify(self);
    self.dataSource = [NSMutableArray array];
//    [self.view addSubview:self.guessUpOrDownView];
//    [self.view addSubview:self.headerView];
//    [self.guessUpOrDownView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_top).offset(14);
//        make.left.equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_right);
//        make.height.equalTo(@0);
//    }];
//
//    if ([self.viewModel.market isEqualToString:@"sg"]) {
//        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.guessUpOrDownView.mas_bottom).offset(14);
//            make.left.equalTo(self.view.mas_left);
//            make.right.equalTo(self.view.mas_right);
//            make.height.equalTo(@0);
//        }];
//        self.headerView.hidden = YES;
//    } else {
//        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.guessUpOrDownView.mas_bottom).offset(14);
//            make.left.equalTo(self.view.mas_left);
//            make.right.equalTo(self.view.mas_right);
//            make.height.equalTo(@45);
//        }];
//        self.headerView.hidden = NO;
//    }

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    
    // 刷新
    self.collectionView.mj_header = [YXRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];

    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.reportButton];
    [self.view addSubview:self.stickButton];
    
    [self.stickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-8);
        make.size.mas_equalTo(CGSizeMake(68, 68));
        make.bottom.equalTo(self.view).offset(- 20 - YXConstant.safeAreaInsetsBottomHeight);
    }];
    
    [self.reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-8);
        make.size.mas_equalTo(CGSizeMake(68, 68));
        make.bottom.equalTo(self.view).offset(- 88 - YXConstant.safeAreaInsetsBottomHeight);
    }];
    

}


-(void)loadData {
    if ([YXUserManager shared].curDiscussionTab == YXDiscussionSelectedTypeSingaporeTab) {
        self.local = true;
    } else {
        self.local = false;
    }
    if ([self.viewModel.market isEqualToString:@"sg"]) {
        self.local = true;
    }
    [self loadHotCommentData:NO];
    
    [self loadGussStockInfo];
}


- (void)loadHotCommentData:(BOOL)isloadMore {
    @weakify(self);
    if (!isloadMore) {
        self.page = 1;
        self.page_size = 20;
        self.offset = 0;
    }
    
    NSString * stockId = [NSString stringWithFormat:@"%@%@",self.viewModel.market,self.viewModel.symbol];
    [YXSquareCommentManager queryStockCommentListWithPage:self.page pageSize:self.page_size offset:self.offset stockId:stockId local:self.local completion:^(YXSquareHotCommentModel * _Nullable model) {
        @strongify(self);
        if (isloadMore) {
            [self.collectionView.mj_footer endRefreshing];
        } else {
            [self.collectionView.mj_header endRefreshing];
        }
        
        self.page = model.query_token.page;
        self.page_size = model.query_token.page_size;
        self.offset = model.query_token.offset;
        
        [self.dataSource removeAllObjects];
       
        if (model.post_list.count > 0) {
            if (isloadMore) {
                [self.viewModel.hotCommentList addObjectsFromArray:model.post_list] ;
            } else {
                @weakify(self)
                YXRefreshAutoNormalFooter *footer = [YXRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                    @strongify(self)
                    [self loadHotCommentData:YES];
                }];
                [footer setTitle:@"" forState:MJRefreshStateNoMoreData];

                self.collectionView.mj_footer = footer;
                self.viewModel.hotCommentList = [NSMutableArray arrayWithArray:model.post_list];
            }
        } else {
            if (isloadMore) {

            } else {
                [self.viewModel.hotCommentList removeAllObjects];
            }
        }
        
        [self configDataSource];
        
        if (self.viewModel.hotCommentList.count >= model.total) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.collectionView.mj_footer resetNoMoreData];
        }
        //通过performUpdatesAnimated调用IGListKit的刷新
        [self.adapter performUpdatesAnimated:YES completion:nil];
    }];
}

- (void)loadGussStockInfo {
    
    if (!self.viewModel.supportGuess) {
        return;
    }

    YXStockDetailGuessStockRequestModel *requestModel = [[YXStockDetailGuessStockRequestModel alloc] init];
    requestModel.code = self.viewModel.symbol;
    requestModel.market = self.viewModel.market;
    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
    [request startWithBlockWithSuccess:^(__kindof YXResponseModel * _Nonnull responseModel) {
        if (responseModel.code == YXResponseStatusCodeSuccess) {
            YXStockDetailGuessUpOrDownInfo *model = [YXStockDetailGuessUpOrDownInfo yy_modelWithDictionary:responseModel.data];
            model.market = self.viewModel.market;
            model.code = self.viewModel.symbol;
            self.guessInfoModel = model;
            [self configDataSource];
        }
        [self.adapter performUpdatesAnimated:YES completion:nil];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [self.adapter performUpdatesAnimated:YES completion:nil];
    }];
    

}

- (void)configDataSource {
    NSMutableArray *arrM = [NSMutableArray array];
    if (self.guessInfoModel) {
        [arrM addObject:self.guessInfoModel];
    }
    
    if (![self.viewModel.market isEqualToString:@"sg"]) {
        [arrM addObject:[NSNumber numberWithInt:-1]];
    }
    
    [arrM addObjectsFromArray:self.viewModel.hotCommentList];
    
    self.dataSource = arrM;
    
    if (self.guessInfoModel) {
        self.noDataView.frame = CGRectMake(0, 140+45+20, YXConstant.screenWidth, self.view.mj_h - (140+45+20));
    } else {
        self.noDataView.frame = CGRectMake(0, 45, YXConstant.screenWidth, self.view.mj_h);
    }
    self.noDataView.hidden = self.viewModel.hotCommentList.count > 0;
    
    if(self.viewModel.hotCommentList.count > 0) {
        self.collectionView.scrollEnabled = YES;
    } else {
        self.collectionView.scrollEnabled = NO;
    }
}

-(void)publishPostHandle {

    if (![YXUserManager isLogin]) {
        [(NavigatorServices *)self.viewModel.services pushToLoginVCWithCallBack:^(NSDictionary<NSString *,id> * _Nonnull dic) {
                            
        }];
        return;
    }
    YXReportViewModel *viewModel = [[YXReportViewModel alloc] initWithServices:self.viewModel.services params:nil];
    @weakify(self)
    viewModel.successBlock = ^{
        @strongify(self);
        [ self loadHotCommentData:NO];
    };
    YXSecu *secu = [[YXSecu alloc] init];
    secu.market = self.viewModel.market;
    secu.symbol = self.viewModel.symbol;
    
    secu.name = self.viewModel.name;
    
    viewModel.secu = secu;

    [self.viewModel.services pushViewModel:viewModel animated:YES];
}

#pragma mark - ListAdapterMoveDelegate

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {

    return [self.dataSource qmui_filterWithBlock:^BOOL(id  _Nonnull item) {
        return [item conformsToProtocol:@protocol(IGListDiffable)];
    }];
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {

    @weakify(self);
    if ([object isKindOfClass:[YXSquareStockPostListModel class]]) {
        YXCommentSectionController * hotCommentVC = [[YXCommentSectionController alloc] init];
        hotCommentVC.refreshDataBlock = ^(id _Nullable model, CommentRefreshDataType type) {
            @strongify(self);
            if (type == CommentRefreshDataTypeDeleteData) { //直接删除
                NSInteger index = [self.viewModel.hotCommentList indexOfObject:object];
                [self.viewModel.hotCommentList removeObjectAtIndex: index];
            } else if(type == CommentRefreshDataTypeRefreshDataReplace) {
                if (model) {
                    NSInteger commentIndex = [self.viewModel.hotCommentList indexOfObject:object];
                    [self.viewModel.hotCommentList replaceObjectAtIndex:commentIndex withObject:model];                    
                }
            }
            
            [self configDataSource];
            [self.adapter performUpdatesAnimated:NO completion:nil];
        };
            
        return hotCommentVC;
    }else if ( [object isKindOfClass:[NSNumber class]] ){
        YXStockDetailAreaViewController* areaVc = [[YXStockDetailAreaViewController alloc] init];
        @weakify(self);
        [areaVc setSelectCallBack:^(NSInteger index) {
            @strongify(self);
            if (index == 0) {
                self.local = false;
                [YXUserManager shared].curDiscussionTab = YXDiscussionSelectedTypeGlobalTab;
            } else if (index == 1) {
                self.local = true;
                [YXUserManager shared].curDiscussionTab = YXDiscussionSelectedTypeSingaporeTab;
            }
            [self loadHotCommentData:NO];
        }];
        return areaVc;
    }else if ( [object isKindOfClass:[YXStockDetailGuessUpOrDownInfo class]] ){
        YXStockDetailGuessUpOrDownViewController* guessUpOrDownVc = [[YXStockDetailGuessUpOrDownViewController alloc] init];
        guessUpOrDownVc.market = self.viewModel.market;
        guessUpOrDownVc.name = self.viewModel.name;

        @weakify(self)
        guessUpOrDownVc.refreshData = ^(){
         @strongify(self)
            [self loadData];
        };
        return guessUpOrDownVc;
    }
    
    return [[YXSquareSectionHeaderViewController alloc] init];

}



- (void)listAdapter:(IGListAdapter *)listAdapter didCallScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.stickButton.hidden = (offsetY < 100) ? YES : NO;
    
    if (self.didCallScroll) {
        self.didCallScroll(scrollView);
    }
}

- (void)listAdapterWillCallSize:(IGListAdapter *)listAdapter {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallDequeueCell:(nonnull UICollectionViewCell *)cell onSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallDisplayCell:(nonnull UICollectionViewCell *)cell onSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallEndDisplayCell:(nonnull UICollectionViewCell *)cell onSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didCallSizeOnSectionController:(nonnull IGListSectionController *)sectionController atIndex:(NSInteger)index {
    
}


- (void)listAdapterWillCallDequeueCell:(nonnull IGListAdapter *)listAdapter {
    
}


- (void)listAdapterWillCallDisplayCell:(nonnull IGListAdapter *)listAdapter {
    
}


- (void)listAdapterWillCallEndDisplayCell:(nonnull IGListAdapter *)listAdapter {
    
}


- (void)listAdapterWillCallScroll:(nonnull IGListAdapter *)listAdapter {
    
}


- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    
    return nil;
}

#pragma mark - lazy load
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _collectionView;
}

- (QMUIButton *)reportButton {
    if (_reportButton == nil) {
        _reportButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_reportButton setImage:[UIImage imageNamed:@"comment_report_write"] forState:UIControlStateNormal];
        @weakify(self)
        [_reportButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            [self publishPostHandle];
        }];
    }
    return _reportButton;
}

- (QMUIButton *)stickButton {
    if (_stickButton == nil) {
        _stickButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_stickButton setImage:[UIImage imageNamed:@"comment_stick"] forState:UIControlStateNormal];
        @weakify(self)
        [_stickButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];

        }];
        _stickButton.hidden = YES;
    }
    return _stickButton;
}

- (IGListAdapter *)adapter {
    if (_adapter == nil) {
        _adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
        _adapter.performanceDelegate = self;
    }
    return _adapter;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


- (YXCommentDetailNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXCommentDetailNoDataView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, YXConstant.screenHeight)];
        _noDataView.topOffset = 50;
        _noDataView.emptyImageView.image = [UIImage imageNamed:@"empty_noData"];
        _noDataView.titleLabel.text = [YXLanguageUtility kLangWithKey:@"comment_post_noData"];
        [_noDataView.subTitleButton setTitle: [YXLanguageUtility kLangWithKey:@"comment_publish_now"] forState:UIControlStateNormal];
        @weakify(self)
        _noDataView.clickActionBlock = ^{
            @strongify(self)
            [self publishPostHandle];
        };
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

//- (YXCommunityHeaderView *)headerView {
//    if (!_headerView) {
//        _headerView = [[YXCommunityHeaderView alloc] init];
//        @weakify(self);
//        [_headerView setSelectCallBack:^(NSInteger index) {
//            @strongify(self);
//            if (index == 0) {
//                self.local = false;
//                [YXUserManager shared].curDiscussionTab = YXDiscussionSelectedTypeGlobalTab;
//            } else if (index == 1) {
//                self.local = true;
//                [YXUserManager shared].curDiscussionTab = YXDiscussionSelectedTypeSingaporeTab;
//            }
//            [self loadHotCommentData:NO];
//        }];
//    }
//    return _headerView;
//}


@end
