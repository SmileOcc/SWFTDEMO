//
//  ZFMyCommentSubVC.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFMyCommentSubVC.h"
#import "ZFCommentListViewModel.h"
#import "ZFMyCommentCell.h"
#import "ZFSubmitReviewsViewController.h"
#import "CouponItemViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"
#import "ZFGoodsDetailViewController.h"

@interface ZFMyCommentSubVC () <ZFInitViewProtocol, UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headerTitlelabel;
@property (nonatomic, strong) NSMutableArray<ZFMyCommentModel *> *modelArray;
@property (nonatomic, strong) ZFCommentListViewModel *viewModel;
@end

@implementation ZFMyCommentSubVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFC0xF2F2F2();
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotifycation];
    
    // 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
}

- (void)addNotifycation {
    [[NSNotificationCenter defaultCenter] addObserverForName:kRefreshWaitCommentListData
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self loadCommentPageData:YES];
                                                  }];
}

#pragma mark - Private Method

- (void)loadCommentPageData:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestMyCommentPort:isFirstPage completion:^(NSArray *modelArray) {
        @strongify(self)
        if (isFirstPage) {
            [self.modelArray removeAllObjects];
            NSString *title = [NSString stringWithFormat:@"%@(%ld)", ZFLocalizedString(@"Order_My_Comment",nil), self.viewModel.totalCount];
            if (self.myCommentCountBlock && self.viewModel.totalCount > 0) {
                self.myCommentCountBlock(title);
            }
        }
        [self.modelArray addObjectsFromArray:modelArray];
        if (modelArray.count> 0 && modelArray.count < 5) {
            [self loadCommentPageData:NO];
        }
        [self.tableView reloadData];
        
        NSNumber *totalPage = @(self.viewModel.currentPage);
        if (modelArray.count > 0) {
            totalPage = @(self.viewModel.currentPage + 1);
        }
        [self.tableView showRequestTip:@{ kTotalPageKey  : totalPage,
                                          kCurrentPageKey: @(self.viewModel.currentPage)} ];
    }];
}

- (void)reviewActionWithModel:(ZFWaitCommentModel *)commentModel {
    ZFSubmitReviewsViewController *vc = [[ZFSubmitReviewsViewController alloc] init];
    vc.orderId = commentModel.order_id;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - tablegateDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.modelArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFMyCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFMyCommentCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.commentModel = self.modelArray[indexPath.section];
    
    @weakify(self)
    cell.TapGoodsBlock = ^(NSString * _Nonnull goodsId) {
        @strongify(self)
        [self jumpGoodsDetail:goodsId];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.modelArray.count > indexPath.section) {
        ZFMyCommentModel *commentModel = self.modelArray[indexPath.section];
        ZFSubmitReviewsViewController *vc = [[ZFSubmitReviewsViewController alloc] init];
        vc.orderId = commentModel.order_id;
        vc.goodsId = commentModel.goods_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)jumpGoodsDetail:(NSString *)goodsId {
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = goodsId;
//    detailVC.sourceID = self.virtualType;
//    //occ v3.7.0hacker 添加 ok
//    detailVC.analyticsProduceImpression = self.analyticsProduceImpression;
//    detailVC.transformSourceImageView = imageView;
//    detailVC.analyticsSort = self.viewModel.analyticsSort;
//    detailVC.sourceType = ZFAppsflyerInSourceTypeVirtualCategoryList;
//    detailVC.isNeedProductPhotoBts = YES;
//    detailVC.af_rank = model.af_rank;
    self.navigationController.delegate = detailVC;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(6, 0, 6, 0));
    }];
}

#pragma mark - getter
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle                 = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor                = ZFC0xF2F2F2();
        _tableView.showsVerticalScrollIndicator   = NO;
        _tableView.dataSource                     = self;
        _tableView.delegate                       = self;
        _tableView.rowHeight                      = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight             = 250;
        _tableView.contentInset                   = UIEdgeInsetsMake(0, 0, 6, 0);
        _tableView.emptyDataTitle                 = ZFLocalizedString(@"Order_No_Commented_Items_Shop",nil);
        _tableView.emptyDataImage                 = ZFImageWithName(@"blank_no_review");
        
        [_tableView registerClass:[ZFMyCommentCell class] forCellReuseIdentifier:NSStringFromClass([ZFMyCommentCell class])];
        
        //添加刷新控件,请求数据
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self loadCommentPageData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self loadCommentPageData:NO];
            
        } startRefreshing:YES];
    }
    return _tableView;
}

- (NSMutableArray<ZFMyCommentModel *> *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (ZFCommentListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommentListViewModel alloc]init];
    }
    return _viewModel;
}

@end
