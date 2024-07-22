//
//  ZFCollocationBuySubViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollocationBuySubViewController.h"
#import "ZFCollocationGoodsCell.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCollocationBuyModel.h"
#import "ZFPiecingOrderViewModel.h"
#import "ZFCellHeightManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFCollocationBuyViewModel.h"
#import "SystemConfigUtils.h"
#import "ZFCollocationBuySubViewAOP.h"
#import "ZFGrowingIOAnalytics.h"

#define kCarPiecingOrderCellIdentifer   @"kCarPiecingOrderCellIdentifer"

@interface ZFCollocationBuySubViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZFCollocationBuySubViewAOP *collocationAnalyticsAop;
@end

@implementation ZFCollocationBuySubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.collocationAnalyticsAop];
    
    // 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
}

#pragma mark - Getter
- (void)setGoodsModelArray:(NSArray<ZFCollocationGoodsModel *> *)goodsModelArray {
    _goodsModelArray = goodsModelArray;
    [self.tableView reloadData];
    [self.tableView showRequestTip:@{}];
}

#pragma mark - tableviewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.goodsModelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFCollocationGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCollocationGoodsCell class]) forIndexPath:indexPath];
    if (indexPath.row <= self.goodsModelArray.count - 1) {
        ZFCollocationGoodsModel *goodsModel = self.goodsModelArray[indexPath.row];
        if ([goodsModel isKindOfClass:[ZFCollocationGoodsModel class]]) {
            cell.goodsModel = goodsModel;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCollocationGoodsModel *goodsModel = self.goodsModelArray[indexPath.row];
    
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = goodsModel.goods_id;
    detailVC.sourceType = ZFAppsflyerInSourceTypeCollocation;/** 搭配购商品*/
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(goodsModel.cat_id),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type),
                                      @"af_page_name" : @"additem_page",
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    
    ZFGoodsModel *model = [ZFGoodsModel new];
    model.goods_id = goodsModel.goods_id;
    model.goods_sn = goodsModel.goods_sn;
    model.goods_title = goodsModel.goods_title;
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"商品详情" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeOther,
        GIOGoodsNameEvar : @"recommend_collocation"
    }];
}

#pragma mark - getter/setter

-(UITableView *)tableView {
    if (!_tableView) {
        if (self.contentViewHeight <= 0) {
            self.contentViewHeight = self.view.bounds.size.height;
        }
        CGRect rect = CGRectMake(0, 0, KScreenWidth, self.contentViewHeight);
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = 130;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 11, 0, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:[ZFCollocationGoodsCell class] forCellReuseIdentifier:NSStringFromClass([ZFCollocationGoodsCell class])];
        //处理数据空白页
        _tableView.emptyDataImage = [UIImage imageNamed:@"ic_point"];
        _tableView.emptyDataTitle = ZFLocalizedString(@"MyPoints_EmptyData_Tip",nil);
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

-(ZFCollocationBuySubViewAOP *)collocationAnalyticsAop {
    if (!_collocationAnalyticsAop) {
        _collocationAnalyticsAop = [[ZFCollocationBuySubViewAOP alloc] init];
    }
    return _collocationAnalyticsAop;
}

@end
