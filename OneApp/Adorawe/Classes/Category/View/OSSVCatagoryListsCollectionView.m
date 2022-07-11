//
//  OSSVCatagoryListsCollectionView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryListsCCell.h"
#import "OSSVCatagoryListsCollectionView.h"
#import "OSSVCategoryListsAnalyseAP.h"
#import "OSSVAddCollectApi.h"
#import "OSSVDelCollectApi.h"
#import "BaseViewModel.h"

@interface OSSVCatagoryListsCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) OSSVCategoryListsAnalyseAP   *categoryListAnalyticsManager;
@property (nonatomic, strong) BaseViewModel                 *baseViewModel;

@end

@implementation OSSVCatagoryListsCollectionView

#pragma mark - public methods

- (void)viewDidShow {
    
}
- (void)refreshDataView:(BOOL)isRefresh {
    if (isRefresh) {
        [self.categoryListAnalyticsManager refreshDataSource];
    }
    
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.categoryListAnalyticsManager];

        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[OSSVCategoryListsCCell class] forCellWithReuseIdentifier:identifier];
    }
    return self;
}

- (void)setAnalyticDic:(NSMutableDictionary *)analyticDic {
    _analyticDic = analyticDic;
    self.categoryListAnalyticsManager.sourecDic = analyticDic;
}


#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
    if (self.dataArray.count > 0){
        collectionView.mj_footer.hidden = NO;
    } else {
        collectionView.mj_footer.hidden = YES;
    }
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVCategoryListsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryListsCCell.class) forIndexPath:indexPath];
    if (self.dataArray.count > indexPath.row) {    
        cell.model = self.dataArray[indexPath.row];
    }
    @weakify(cell)
    cell.collectBlock = ^(OSSVCategoriyDetailsGoodListsModel *goodListModel) {
        [self collectionGoodsWithModle:goodListModel index:indexPath.row complete:^{
            @strongify(cell)
            cell.model = goodListModel;
        }];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat height = [OSSVCategoryListsCCell categoryListCCellRowHeightForListModel:self.dataArray[indexPath.row]];
    
    OSSVCategoriyDetailsGoodListsModel *oneModel = self.dataArray[indexPath.row];
    OSSVCategoriyDetailsGoodListsModel *twoModel = nil;
    NSInteger count = indexPath.row % 2;
    if (count == 0) {
        if (self.dataArray.count > indexPath.row+1) {
            twoModel = self.dataArray[indexPath.row+1];
        }
    } else {
        if (indexPath.row > 0) {
            twoModel = self.dataArray[indexPath.row-1];
        }
    }
    
    CGFloat height = [OSSVCategoryListsCCell categoryListCCellRowHeightOneModel:oneModel twoModel:twoModel];

    CGFloat w = kGoodsWidth;
    return CGSizeMake(w, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    OSSVCategoriyDetailsGoodListsModel *model = self.dataArray[indexPath.row];
    [self.myDelegate didDeselectGoodListModel:model];
    
    CGFloat price = [model.shop_price floatValue];;
    // 0 > 闪购 > 满减
    if (!STLIsEmptyString(model.specialId)) {//0元
        price = [model.shop_price floatValue];
        
    } else if (STLIsEmptyString(model.specialId) && model.flash_sale &&  [model.flash_sale.is_can_buy isEqualToString:@"1"] && [model.flash_sale.active_status isEqualToString:@"1"]) {//闪购
        price = [model.flash_sale.active_price floatValue];
    }

    NSDictionary *items = @{
        @"item_id": STLToString(model.goods_sn),
        @"item_name": STLToString(model.goodsTitle),
        @"item_category": STLToString(model.cat_name),
        @"price": @(price),
        @"itemBrand" : @""

    };
    
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSDictionary *itemsDic = @{@"items":@[items],
                               @"currency": @"USD",
                               @"item_list_id":STLToString(model.goods_sn),
                               @"item_list_name": STLToString(self.currentTitle),
                               @"position": @"ProductList_RegularProduct",
                               @"screen_group" : [NSString stringWithFormat:@"ProductList_%@", STLToString(pageName)]
                            
    };
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"select_item" parameters:itemsDic];

}


- (OSSVCategoryListsAnalyseAP *)categoryListAnalyticsManager {
    if (!_categoryListAnalyticsManager) {
        _categoryListAnalyticsManager = [[OSSVCategoryListsAnalyseAP alloc] init];
        _categoryListAnalyticsManager.source = STLAppsflyerGoodsSourceCategoryList;
    }
    return _categoryListAnalyticsManager;
}

- (BaseViewModel *)baseViewModel{
    if (!_baseViewModel) {
        _baseViewModel = [BaseViewModel new];
    }
    return _baseViewModel;
}

#pragma mark  收藏
- (void)collectionGoodsWithModle:(OSSVCategoriyDetailsGoodListsModel *)model index:(NSInteger)index complete:(void(^)(void))complete{
    
    if (USERID) {
        if (model.is_collect) {
            @weakify(self)
        //取消收藏
            [self requestCollectDelNetwork:@[model.goodsId,model.wid] completion:^(id obj) {
                @strongify(self)
                [self.baseViewModel alertMessage:STLLocalizedString_(@"removedWishlist",nil)];
                if (complete) {
                    model.is_collect = 0;
                    complete();
                }
                
                NSString *pageName = [UIViewController currentTopViewControllerPageName];
                NSDictionary *itemsDic = @{@"screen_group" : [NSString stringWithFormat:@"ProductList_%@", pageName],
                                           @"action"       : @"Remove",
                                           @"content"      : STLToString(model.goodsTitle)
                };
                [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:itemsDic];

            } failure:^(id obj) {
            }];
        } else {
            
            //收藏
            @weakify(self)
            [self requestCollectAddNetwork:@[model.goodsId,model.wid] completion:^(id obj) {
                @strongify(self)
        
                [self.baseViewModel alertMessage:STLLocalizedString_(@"addedWishlist",nil)];
                
                // 谷歌统计 收藏
                [OSSVAnalyticsTool appsFlyeraAddToWishlistWithProduct:model fromProduct:YES];
                
                
                //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
                //GA
                CGFloat price = [model.shop_price floatValue];;
                // 0 > 闪购 > 满减
                if (!STLIsEmptyString(model.specialId)) {//0元
                    price = [model.shop_price floatValue];
                    
                } else if (STLIsEmptyString(model.specialId) && model.flash_sale &&  [model.flash_sale.is_can_buy isEqualToString:@"1"] && [model.flash_sale.active_status isEqualToString:@"1"]) {//闪购
                    price = [model.flash_sale.active_price floatValue];
                }

                NSDictionary *items = @{
                    @"item_id": STLToString(model.goods_sn),
                    @"item_name": STLToString(model.goodsTitle),
                    @"item_category": STLToString(model.cat_name),
                    @"price": @(price),
                    @"quantity": @(1),
                    @"itemBrand" : @""

                };
                NSString *pageName = [UIViewController currentTopViewControllerPageName];
                NSDictionary *itemsDic = @{@"items":@[items],
                                           @"currency": @"USD",
                                           @"value":  @(price),
                                           @"position": @"ProductList",
                                           @"screen_group" : [NSString stringWithFormat:@"ProductList_%@", STLToString(pageName)]
                                        
                };
                
                [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_wishlist" parameters:itemsDic];

                NSDictionary *sensorsDic = @{@"goods_sn":STLToString(model.goods_sn),
                                            @"goods_name":STLToString(model.goodsTitle),
                                             @"cat_id":STLToString(model.cat_id),
                                             @"cat_name":STLToString(model.cat_name),
                                             @"original_price":@([STLToString(model.market_price) floatValue]),
                                             @"present_price":@(price),
                                             @"entrance":@"collect_goods",
                                             @"position_number":@(index+1)
                        };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsCollect" parameters:sensorsDic];
                
                if (complete) {
                    model.is_collect = 1;
                    complete();
                }
            } failure:^(id obj) {

            }];
        };
    } else {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self);
        signVC.signBlock = ^{
            @strongify(self);
        };
        [self.viewController presentViewController:signVC animated:YES completion:^{
        }];
    }
    
    
}

#pragma mark - Cancel the collection
- (void)requestCollectDelNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVDelCollectApi *api = [[OSSVDelCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.viewController.view]];
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

//收藏接口
- (void)requestCollectAddNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVAddCollectApi *api = [[OSSVAddCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.viewController.view]];

    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}
@end
