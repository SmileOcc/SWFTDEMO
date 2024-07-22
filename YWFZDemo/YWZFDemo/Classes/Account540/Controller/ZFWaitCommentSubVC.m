//
//  ZFWaitCommentSubVC.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWaitCommentSubVC.h"
#import "ZFCommentListViewModel.h"
#import "ZFWaitCommentCell.h"
#import "ZFWriteReviewViewController.h"

#import "CouponItemViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"
#import "Constants.h"

@interface ZFWaitCommentSubVC () <ZFInitViewProtocol, UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headerTitlelabel;
@property (nonatomic, strong) NSMutableArray<ZFWaitCommentModel *> *modelArray;
@property (nonatomic, strong) ZFCommentListViewModel *viewModel;
@end

@implementation ZFWaitCommentSubVC

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
                                                      [self loadWaitCommentPageData:YES];
                                                  }];
}

#pragma mark - Private Method

- (void)loadWaitCommentPageData:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestWaitCommentPort:isFirstPage completion:^(NSArray *modelArray) {
        @strongify(self)
        if (isFirstPage) {
            [self.modelArray removeAllObjects];
            if (self.waitCommentCountBlock && self.viewModel.totalCount > 0) {
                NSString *title = [NSString stringWithFormat:@"%@(%ld)", ZFLocalizedString(@"Order_Awaiting_Comment",nil), self.viewModel.totalCount];
                self.waitCommentCountBlock(title);
            }
        }
        [self.modelArray addObjectsFromArray:modelArray];
        if (modelArray.count> 0 && modelArray.count < 5) {
            [self loadWaitCommentPageData:NO];
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
    ZFWriteReviewViewController *vc = [[ZFWriteReviewViewController alloc] init];
    vc.commentModel = commentModel;
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
    ZFWaitCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFWaitCommentCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.commentModel = self.modelArray[indexPath.section];
    @weakify(self);
    cell.touchReviewBlock = ^(ZFWaitCommentModel * _Nonnull model) {
        @strongify(self);
        [self reviewActionWithModel:model];
    };
    return cell;
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
        _tableView.rowHeight                      = 125;
        _tableView.dataSource                     = self;
        _tableView.delegate                       = self;
        _tableView.contentInset                   = UIEdgeInsetsMake(0, 0, 6, 0);
        _tableView.emptyDataTitle                 = ZFLocalizedString(@"Order_No_Comment_Items_Go_Shop",nil);
        _tableView.emptyDataImage                 = ZFImageWithName(@"blank_no_review");
        
        [_tableView registerClass:[ZFWaitCommentCell class] forCellReuseIdentifier:NSStringFromClass([ZFWaitCommentCell class])];
        
        //添加刷新控件,请求数据
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self loadWaitCommentPageData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self loadWaitCommentPageData:NO];
            
        } startRefreshing:YES];
    }
    return _tableView;
}

- (NSMutableArray<ZFWaitCommentModel *> *)modelArray {
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
