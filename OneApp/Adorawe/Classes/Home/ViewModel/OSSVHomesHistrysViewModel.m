//
//  HomeHistoryViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomesHistrysViewModel.h"
#import "OSSVDetailsVC.h"
#import "OSSVHomeItemssCell.h"
#import "OSSVHomeItemsAdvsReusableView.h"
#import "OSSVHomeItemsModel.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVAdvsEventsManager.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "CommendModel.h"
#import "OSSVAccountsHistoyAnalyseAP.h"

@interface OSSVHomesHistrysViewModel ()

@property (nonatomic, strong) NSMutableArray *bannersArray;
@property (nonatomic, strong) OSSVHomeItemsModel *homeItemModel;
@property (nonatomic, strong) OSSVAccountsHistoyAnalyseAP    *accountHistoryAnalyticsManager;

@end

@implementation OSSVHomesHistrysViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.accountHistoryAnalyticsManager];
    }
    return self;
}
#pragma mark - NetRequset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    //浏览记录
    if (!STLJudgeEmptyArray([[OSSVCartsOperateManager sharedManager] commendList])) {
        
        NSArray *localLikeArrays = [[OSSVCartsOperateManager sharedManager] commendList];
        self.dataArray = localLikeArrays;
    }
    
    self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoNet;
    
    if (completion) {
        completion(nil);
    }    
}

#pragma mark - UICollectionViewDelegate
//指定单元格的个数 ，这个是一个组里面有多少单元格，e.g : 一个单元格就是一张图片
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
    //    if (self.dataArray.count > kSTLPageSize - 1) {
    if (self.dataArray.count > 0) {
        collectionView.mj_footer.hidden = NO;
    } else {
        collectionView.mj_footer.hidden = YES;
    }
    return self.dataArray.count;
}

//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // banner
    OSSVHomeItemssCell *cell = [OSSVHomeItemssCell homeItemCellWithCollectionView:collectionView andIndexPath:indexPath];
    cell.commendModel = self.dataArray[indexPath.row];
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat w = kGoodsWidth;
    CGFloat h = [OSSVHomeItemssCell homeItemRowHeightForHomeGoodListModel:nil];
    
    return CGSizeMake(w, h);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        //头部广告列表
        OSSVHomeItemsAdvsReusableView *headerView =  [OSSVHomeItemsAdvsReusableView homeItemHeaderWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
        headerView.bannersArray = self.bannersArray;
        
        @weakify(self)
        headerView.bannerBlock = ^(OSSVAdvsEventsModel *model) {
            @strongify(self)
            [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:model];

        };
        return headerView;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    headerView.hidden = YES;
    
    return headerView;
}


////定义每个UICollectionView 纵向的间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 1;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 1;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    CommendModel *model = self.dataArray[indexPath.row];
    OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
    goodsDetailsVC.goodsId = model.goodsId;
    goodsDetailsVC.wid = model.wid;
    goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceHistory;
    goodsDetailsVC.coverImageUrl = STLToString(model.goodsBigImg);
    [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
}

#pragma mark - DZNEmptyDataSetSource Methods
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
}

#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = [UIColor whiteColor];
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    imageView.userInteractionEnabled = YES;
    [customView addSubview:imageView];

    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(52 * DSCREEN_HEIGHT_SCALE);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];

    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont stl_buttonFont:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
    } else {
        [button setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
    }
    /**
        emptyOperationTouch
        emptyJumpOperationTouch
        暂时两个动态选择
     */
    [button addTarget:self action:@selector(emptyOperationTouch) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [customView addSubview:button];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
        make.centerX.mas_equalTo(customView.mas_centerX);
        make.width.mas_equalTo(@180);
        make.height.mas_equalTo(@40);
    }];
    return customView;
}

#pragma mark - 谷歌统计
- (void)analyticsHomeWithModel:(OSSVHomeItemsModel *)model
{
    NSArray *goodsList = model.goodList;
    if (goodsList.count == 0) {
        return;
    }
    NSString *event = nil;
    if (model.page != 1) {
        event = @"LoadMoreProducts";
    }
    
    //这里只有goodsid
    NSMutableArray *baseGoods = [[NSMutableArray alloc] init];
    for (OSSVHomeGoodsListModel *goodsModel in goodsList) {
        OSSVDetailsBaseInfoModel *baseInfoModel = [[OSSVDetailsBaseInfoModel alloc] init];
        baseInfoModel.goods_sn = goodsModel.goodsId;
        [baseGoods addObject:baseInfoModel];
    }
}

-(NSString *)channelScreenKeyWithChannelName:(NSString *)name {
    return [NSString stringWithFormat:@"Channel - %@",name];
}


#pragma mark - HeaderView 数据确定高度
/**
 *  对高度的思考
 本来通过 view 的自身 [self systemLayoutSizeFittingSize:] 获取高度是最好的，就不需要计算啦
 但是，此处 瀑布流 必须是你先知道高度，让后传传进入里面，才可以正常布局，否则压根就没有的
 同时涉及到很多动态布局，需要考虑，而且同时有一些View 不需要一起创建 ，所以里面并没有完全撑满
 所以，暂时只能先获取高度，然后在再布局。
 */
- (void)makeSureDiscoverHeaderHeight {
    
    // 高度的获取 ，其实是可以通过代理，在ViewModel 中 直接处理
    // 但是木有数据的时候，暂时先用 blcok, 避免View重叠的问题出现
    if (self.updateHeaderHeightBlock) {
        float allBannerHeight = 0;
        
        for (OSSVAdvsEventsModel *model in self.bannersArray) {
            float oneBannerHeight = SCREEN_WIDTH * [model.height floatValue] / [model.width floatValue];
            allBannerHeight += oneBannerHeight + 10;
        }
        self.updateHeaderHeightBlock(allBannerHeight);
    }
}


- (OSSVAccountsHistoyAnalyseAP *)accountHistoryAnalyticsManager {
    if (!_accountHistoryAnalyticsManager) {
        _accountHistoryAnalyticsManager = [[OSSVAccountsHistoyAnalyseAP alloc] init];
        _accountHistoryAnalyticsManager.source = STLAppsflyerGoodsSourceHistory;
    }
    return _accountHistoryAnalyticsManager;
}
@end
