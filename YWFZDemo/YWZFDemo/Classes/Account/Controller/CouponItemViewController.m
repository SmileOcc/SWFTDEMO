//
//  CouponItemViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CouponItemViewController.h"
#import "CouponItemViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFEmptyView.h"
#import "ZFCMSRecommendViewModel.h"
#import "ZFGoodsDetailViewController.h"

@interface CouponItemViewController () <ZFInitViewProtocol>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headerTitlelabel;
@property (nonatomic, strong) CouponItemViewModel *viewModel;
@property (nonatomic, assign) CouponListContentType contentType;
@property (nonatomic, strong) ZFCMSRecommendViewModel *recommendViewModel;
@property (nonatomic, strong) NSMutableArray *recommendDataList;
@end

@implementation CouponItemViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"MyCoupon_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    self.contentType = CouponListContentType_CouponList;
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - Private Method

- (void)loadCouponItemPageData:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestCouponItemPageData:isFirstPage completion:^(NSDictionary *pageInfo) {
        @strongify(self)
        [self.tableView reloadData];
        if ([self.kind isEqualToString:@"1"]) {
            [self updateUIWithInfo:pageInfo];
        } else {
            [self.tableView showRequestTip:pageInfo];
        }
        NSInteger dataCount = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
        self.tableView.backgroundColor = (dataCount > 0) ? ColorHex_Alpha(0xFFFFFF, 1) : ColorHex_Alpha(0xF2F2F2, 1);
    }];
}

//获取推荐商品
- (void)requestRecommendProduct:(BOOL)first
{
    @weakify(self)
    [self.recommendViewModel requestCmsRecommendData:first parmaters:@{} completion:^(NSArray<ZFGoodsModel *> * _Nonnull array, NSDictionary * _Nonnull pageInfo) {
        //根据ABTEST区分显示行数
        @strongify(self)
        NSMutableArray *temProductList = [[NSMutableArray alloc] init];
        NSInteger subSize = 3;
        NSInteger count = 0;
        NSInteger totalCount = [array count];
        if (totalCount%subSize == 0) {
            count = (totalCount / subSize);
        }else{
            count = (totalCount / subSize) + 1;
        }
        for (int i = 0; i < count; i++) {
            NSInteger index = i * subSize;
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            NSInteger j = index;
            while (j < (subSize * (i + 1)) && j < totalCount) {
                [subArray addObject:array[j]];
                j++;
            }
            [temProductList addObject:subArray];
        }
        if (first) {
            [self.recommendDataList removeAllObjects];
        }
        [self.recommendDataList addObjectsFromArray:temProductList];
        self.viewModel.recommendDataList = [self.recommendDataList copy];
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageInfo];
    } failure:^(NSError * _Nonnull error) {
    }];
}

- (void)updateUIWithInfo:(NSDictionary *)pageInfo {
    if ([pageInfo[kTotalPageKey] integerValue] > 0) {
        self.contentType = CouponListContentType_CouponList;
        self.tableView.tableHeaderView = nil;
        [self.tableView showRequestTip:pageInfo];
    } else {
        ZFEmptyView *emptyView = [[ZFEmptyView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 272)];
        emptyView.imageBottomCenterYSpace = 15;
        emptyView.labelTopCenterYSpace = 35;
        emptyView.msg = ZFLocalizedString(@"MyCouponViewModel_NoData_TitleLabel",nil);
        emptyView.msgImage = [UIImage imageNamed:@"blankPage_noCoupon"];
        [emptyView reloadView];
        self.tableView.tableHeaderView = emptyView;
        self.contentType = CouponListContentType_RecommendList;
        [self requestRecommendProduct:YES];
    }
}

- (void)jumpToGoodsDetailViewControllerWithGoodsModel:(ZFGoodsModel *)goodsModel {
    ZFGoodsDetailViewController *goodsDetail = [[ZFGoodsDetailViewController alloc] init];
    goodsDetail.goodsId = goodsModel.goods_id;
    goodsDetail.sourceType = ZFAppsflyerInSourceTypeMyCouponListRecommend;
    [self.navigationController pushViewController:goodsDetail animated:YES];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    if ([self.kind isEqualToString:@"used"]) {
        [self.view addSubview:self.headerTitlelabel];
    }
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    if ([self.kind isEqualToString:@"used"]) {
        [self.headerTitlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(1);
            make.leading.trailing.mas_equalTo(self.view);
            make.height.mas_equalTo(60);
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerTitlelabel.mas_bottom);
            make.leading.trailing.bottom.mas_equalTo(self.view);
        }];
        
    } else {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsZero);
        }];
    }
}

#pragma mark - setter
- (void)setContentType:(CouponListContentType)contentType {
    _contentType = contentType;
    self.viewModel.contentType = contentType;
}

#pragma mark - getter
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor                = ZFCOLOR(245, 245, 245, 1.0);
        _tableView.rowHeight                      = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight             = 200;
        _tableView.separatorStyle                 = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator   = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.dataSource                     = self.viewModel;
        _tableView.delegate                       = self.viewModel;
        _tableView.contentInset                   = UIEdgeInsetsMake(0, 0, 15, 0);
        _tableView.emptyDataTitle                 = ZFLocalizedString(@"MyCouponViewModel_NoData_TitleLabel",nil);
        _tableView.emptyDataImage                 = ZFImageWithName(@"blankPage_noCoupon");
        
        //添加刷新控件,请求数据
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self loadCouponItemPageData:YES];
            
        } footerRefreshBlock:^{
            @strongify(self);
            if (self.contentType == CouponListContentType_RecommendList) {
                [self requestRecommendProduct:NO];
            } else {
                [self loadCouponItemPageData:NO];
            }
        } startRefreshing:YES];
    }
    return _tableView;
}

-(UILabel *)headerTitlelabel {
    if (!_headerTitlelabel) {
        _headerTitlelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _headerTitlelabel.text = ZFLocalizedString(@"MyCoupon_VC_Header_Label",nil);
        _headerTitlelabel.textAlignment = NSTextAlignmentCenter;
        _headerTitlelabel.font = [UIFont systemFontOfSize:16.0];
        _headerTitlelabel.numberOfLines = 2;
        _headerTitlelabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        _headerTitlelabel.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    }
    return _headerTitlelabel;
}

- (CouponItemViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CouponItemViewModel alloc]init];
        _viewModel.controller = self;
        _viewModel.kind = self.kind;
        @weakify(self)
        _viewModel.goodsClickBlock = ^(ZFGoodsModel *goodsModel) {
            @strongify(self)
            [self jumpToGoodsDetailViewControllerWithGoodsModel:goodsModel];
        };
    }
    return _viewModel;
}

-(ZFCMSRecommendViewModel *)recommendViewModel
{
    if (!_recommendViewModel) {
        _recommendViewModel = [[ZFCMSRecommendViewModel alloc] init];
        _recommendViewModel.controller = self;
    }
    return _recommendViewModel;
}

-(NSMutableArray *)recommendDataList
{
    if (!_recommendDataList) {
        _recommendDataList = [[NSMutableArray alloc] init];
    }
    return _recommendDataList;
}

@end
