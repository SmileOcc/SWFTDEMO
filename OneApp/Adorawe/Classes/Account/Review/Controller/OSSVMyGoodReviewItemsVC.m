//
//  OSSVMyGoodReviewItemsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMyGoodReviewItemsVC.h"
#import "OSSVWritesReviewsVC.h"
#import "OSSVChecksReviewsVC.h"
#import "OSSVDetailsVC.h"
#import "OSSVAccounteGoodseReviewsAip.h"
#import "OSSVGoodssReviewssModel.h"
#import "Adorawe-Swift.h"

@interface OSSVMyGoodReviewItemsVC ()<STLReviewsGoodsTableViewDelegate>

@property (nonatomic, strong) OSSVGoodssReviewssModel   *goodsReviewsModel;
/**评论的个数：涨位数，告诉告诉后台*/
@property (nonatomic, assign) NSInteger               reviewdCount;
@end

@implementation OSSVMyGoodReviewItemsVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reviewdCount = 0;
    [self.view addSubview:self.reviewsTableView];
    
    [self.reviewsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    //occ阿语适配 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    
    [self requestDatasfirst:YES more:NO];
    self.view.backgroundColor = OSSVThemesColors.col_F5F5F5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Request

- (void)refreshData {
    [self requestDatasfirst:NO more:NO];
}

- (void)requestDatasfirst:(BOOL)first more:(BOOL)loadMore{
    
    NSInteger page = self.goodsReviewsModel.currentPage;
    page = loadMore ? page + 1 : 1;
    
    NSDictionary *paramsDic = @{@"reviewed":@(self.reviewdCount),
                                @"type":@(self.type),
                                @"page":@(page),
                                @"page_size":@(kSTLPageSize)};
    
    OSSVAccounteGoodseReviewsAip *OSSVReviewsApi = [[OSSVAccounteGoodseReviewsAip alloc] initWithDict:paramsDic];
    if (first) {
        [OSSVReviewsApi.accessoryArray addObject:[[STLRequestAccessory alloc] init]];
    }

    @weakify(self)
    [OSSVReviewsApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        self.reviewsTableView.dataType = self.type;
        [self.reviewsTableView.mj_footer endRefreshing];
        [self.reviewsTableView.mj_header endRefreshing];
        
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        self.goodsReviewsModel = [self dataAnalysisFromJson: requestJSON request:OSSVReviewsApi];
        
        if (!loadMore) {
            self.reviewdCount = 0;
            [self.reviewsTableView.goodsDatas removeAllObjects];
        }
        
        [self.reviewsTableView.goodsDatas addObjectsFromArray:self.goodsReviewsModel.goodsList];
        
        [self.reviewsTableView reloadData];

        if (self.goodsReviewsModel.goodsList.count < kSTLPageSize) {//不能加载更多
            [self.reviewsTableView showRequestTip:@{kTotalPageKey  : @(1),
                                                 kCurrentPageKey: @(1)}];
        } else {
            [self.reviewsTableView showRequestTip:@{kTotalPageKey  : @(1),
                                                 kCurrentPageKey: @(0)}];
        }

        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        [self.reviewsTableView reloadData];
        [self.reviewsTableView showRequestTip:nil];
        
    }];
}


#pragma mark - private methods

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVAccounteGoodseReviewsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVGoodssReviewssModel yy_modelWithJSON:json[kResult]];
        }
    }
    return nil;
}

#pragma mark - STLReviewsGoodsTableViewDelegate

- (void)STL_ReviewsGoodsTableView:(OSSVReviewssGoodssTableView *)tableView refresh:(BOOL)refresh {
    [self refreshData];
}
- (void)STL_ReviewsGoodsTableView:(OSSVReviewssGoodssTableView *)tableView indexPath:(NSIndexPath *)indexPath {

    if (tableView.goodsDatas.count > indexPath.row) {
        
        OSSVAccounteOrdersDetaileGoodsModel *goodsModel = tableView.goodsDatas[indexPath.row];
        
        if (goodsModel.isReview== 1) {
            OSSVChecksReviewsVC *checkReviewCtrl = [[OSSVChecksReviewsVC alloc] init];
            checkReviewCtrl.goodsModel = goodsModel;
            [self.navigationController pushViewController:checkReviewCtrl animated:YES];
            
        } else {
            [GATools logReviewsWithAction:@"Write_review" content:[NSString stringWithFormat:@"Product_%@",goodsModel.goodsName]];
            OSSVWritesReviewsVC *writeReviewCtrl = [[OSSVWritesReviewsVC alloc] init];
            writeReviewCtrl.goodsModel = goodsModel;
            writeReviewCtrl.orderId = STLToString(goodsModel.orderId);
            
            @weakify(self)
            writeReviewCtrl.block = ^{
                @strongify(self)
                // 评论成功回调
                //记录评论个数
                self.reviewdCount++;
                [self.reviewsTableView.goodsDatas removeObject:goodsModel];
                
                [self.reviewsTableView reloadData];
                [self.reviewsTableView showRequestTip:@{kTotalPageKey  : @(1),
                                                     kCurrentPageKey: @(0)}];
                
                if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_MyGoodsReviewItemViewController:refresh:)]) {
                    [self.myDelegate STL_MyGoodsReviewItemViewController:self refresh:YES];
                }
            };
            [self.navigationController pushViewController:writeReviewCtrl animated:YES];
        }
    }
}

- (void)STL_ReviewsGoodsTableView:(OSSVReviewssGoodssTableView *)tableView selectIndexPath:(NSIndexPath *)indexPath {
    if (tableView.goodsDatas.count > indexPath.row) {
        
        OSSVAccounteOrdersDetaileGoodsModel *goodsModel = tableView.goodsDatas[indexPath.row];
        
        OSSVDetailsVC *goodDetail = [[OSSVDetailsVC alloc] init];
        goodDetail.goodsId = goodsModel.goodsId;
        goodDetail.wid     = goodsModel.wid;
        goodDetail.coverImageUrl = STLToString(goodsModel.goodsThumb);
        [self.navigationController pushViewController:goodDetail animated:YES];
    }
    
}


#pragma mark - LazyLoad

- (OSSVReviewssGoodssTableView *)reviewsTableView {
    if (!_reviewsTableView) {
        _reviewsTableView = [[OSSVReviewssGoodssTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _reviewsTableView.frame = self.view.bounds;
        _reviewsTableView.myDelegate = self;
        
        if (self.type == 1) {
            _reviewsTableView.emptyDataTitle = STLLocalizedString_(@"no_reviews",nil);
        } else {
            _reviewsTableView.emptyDataTitle = STLLocalizedString_(@"no_prod_to_reviews",nil);
        }
        _reviewsTableView.blankPageImageViewTopDistance = 40;
        _reviewsTableView.emptyDataImage = [UIImage imageNamed:@"myReview_bank"];
        
        @weakify(self)
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self requestDatasfirst:NO more:NO];
        }];
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;

        // 隐藏状态
        header.stateLabel.hidden = YES;
        _reviewsTableView.mj_header = header;
        
        _reviewsTableView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self requestDatasfirst:NO more:YES];
        }];
    }
    return _reviewsTableView;
}
@end
