

//
//  SeachResultViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSeachsResultsViewModel.h"
#import "OSSVHomeItemssCell.h"
#import "OSSVSearchAip.h"

#import "OSSVDetailsVC.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVSearchResultAnalyseAP.h"
#import "OSSVSearchsRecommendsAip.h"
#import "OSSVSearchsRecommdHeader.h"
#import "OSSVAddCollectApi.h"
#import "OSSVDelCollectApi.h"
#import "Adorawe-Swift.h"

@interface OSSVSeachsResultsViewModel()

@property (nonatomic, strong) NSMutableArray                *dataArray;

@property (nonatomic, strong) OSSVSearchResultAnalyseAP   *searchResultAnalyticsAOP;
@property (nonatomic, assign) BOOL                          isRecommend;/// 如果没有搜索数据 就展示推荐数据

@end

@implementation OSSVSeachsResultsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.searchResultAnalyticsAOP];
    }
    return self;
}


#pragma mark - NetRequset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
         @strongify(self)
        NSArray *array = (NSArray *)parmaters;
        NSString *searchKey = array.firstObject;
        NSInteger page = [array[1] integerValue];
        if ([array[1] integerValue] == 0) {
            // 假如最后一页的时候
            if (self.searchModel.page == self.searchModel.pageCount) {
                if (completion) {
                    completion(STLNoMoreToLoad);
                }
                return; // 直接返回
            }
            page = self.searchModel.page  + 1;
        }else{
            self.isRecommend = NO;
        }
        
        if (self.isRecommend) {
            [self recommendGoodListRequestWithSearchkey:searchKey Page:page pageSize:kSTLPageSize Completion:completion failure:failure];
            return;
        }
        
        self.searchResultAnalyticsAOP.sourceKey = searchKey;

        OSSVSearchAip *searchApi = [[OSSVSearchAip alloc] initWithSearchKeyWord:STLToString(searchKey) page:page pageSize:kSTLPageSize];
        searchApi.deepLinkId = self.deeplinkId;
        
        @weakify(self)
        [searchApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self);
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.searchModel = [self dataAnalysisFromJson: requestJSON request:searchApi];
            
            //self.searchModel.searchKey = searchKey;
            //self.searchResultAnalyticsAOP.searchModel = self.searchModel;
            NSString *searchEngine = self.searchModel.search_engine;
            NSString *thirdId = @"starlink";
            if ([searchEngine isEqualToString:@"hw"]) {
                thirdId = [NSString stringWithFormat:@"HW-%@",STLToString(self.searchModel.btm_sid)];
            }else if ([searchEngine isEqualToString:@"btm"]){
                thirdId = [NSString stringWithFormat:@"BT-%@",STLToString(self.searchModel.btm_sid)];
            }else{
                thirdId = [NSString stringWithFormat:@"%@",STLToString(self.searchModel.btm_sid)];
            }
            //这里拼好了 后面直接用
            self.searchModel.btm_sid = thirdId;
            NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceSearchResult sourceID:searchKey],
                                      kAnalyticsUrl:STLToString(searchKey),
                                      kAnalyticsKeyWord:STLToString(searchKey),
                                      kAnalyticsThirdPartId:STLToString(thirdId)
                };
            self.searchResultAnalyticsAOP.sourecDic = [dic mutableCopy];
            
            if (page == 1) {
                self.dataArray = [NSMutableArray arrayWithArray:self.searchModel.goodList];
                [self.searchResultAnalyticsAOP refreshDataSource];
                
                if (self.dataArray.count > 0) {
                    self.emptyViewShowType = EmptyViewShowTypeHide;
                    if (completion) {
                        completion(nil);
                    }
                }else{
                    // 走推荐商品逻辑
                    [self recommendGoodListRequestWithSearchkey:searchKey Page:page pageSize:kSTLPageSize Completion:completion failure:failure];
                }
                
            } else {
                NSInteger oldCount = self.dataArray.count; // 记录上一个
                if (self.searchModel.goodList.count > 0) {
                    [self.dataArray addObjectsFromArray:self.searchModel.goodList];
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for(NSInteger i = oldCount;i < self.dataArray.count; i++){
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    if (completion) {
                        completion(indexPaths.copy);
                    }
                    return;
                } else {
                    //为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
                    if (completion) {
                        completion(STLNoMoreToLoad);
                    }
                }
            }
            
         
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoNet;
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        @strongify(self)
        self.emptyViewShowType = EmptyViewShowTypeNoNet;
        if (failure) {
            failure(nil);
        }
    }];
     
}

// 没有搜索到数据  采用推荐数据
- (void)recommendGoodListRequestWithSearchkey:(NSString *)searchKey Page:(NSInteger)page pageSize:(NSInteger)pageSize Completion:(void (^)(id))completion failure:(void (^)(id))failure{
    @weakify(self);
    OSSVSearchsRecommendsAip *searchApi = [[OSSVSearchsRecommendsAip alloc] initWithSearchRecommendWithKeyword:searchKey Page:page pageSize:pageSize];
    
    [searchApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self);
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        self.searchModel = [self dataAnalysisFromJson: requestJSON request:searchApi];
        self.isRecommend = YES;
        if (page == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.searchModel.goodList];
            [self.searchResultAnalyticsAOP refreshDataSource];
            
//            if (self.dataArray.count > 0) {
                if (completion) {
                    completion(nil);
                }
//            }else{
//                // 走推荐商品逻辑
//                [self recommendGoodListRequestWithPage:page pageSize:kSTLPageSize Completion:completion failure:failure];
//            }
            
        } else {
            NSInteger oldCount = self.dataArray.count; // 记录上一个
            if (self.searchModel.goodList.count > 0) {
                [self.dataArray addObjectsFromArray:self.searchModel.goodList];
                NSMutableArray *indexPaths = [NSMutableArray array];
                for(NSInteger i = oldCount;i < self.dataArray.count; i++){
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                if (completion) {
                    completion(indexPaths.copy);
                }
                return;
            } else {
                //为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
                if (completion) {
                    completion(STLNoMoreToLoad);
                }
            }
        }
        
     
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        @strongify(self)
        if (failure) {
            failure(nil);
        }
    }];
}
- (NSInteger)currentPageGoodsCount {
    if (self.searchModel && self.searchModel.goodList.count > 0) {
        return self.searchModel.goodList.count;
    }
    return 0;
}
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
    if ([request isKindOfClass:[OSSVSearchAip class]] || [request isKindOfClass:[OSSVSearchsRecommendsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVSearchingModel yy_modelWithJSON:json[kResult]];
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark - UICollectionViewDataSource
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
    OSSVHomeItemssCell *cell = [OSSVHomeItemssCell homeItemCellWithCollectionView:collectionView andIndexPath:indexPath];
    if (self.dataArray.count > indexPath.row) {
        cell.model = self.dataArray[indexPath.row];
    }
    @weakify(self);
    __weak typeof (cell) weakCell = cell;
    cell.collectBlock = ^(OSSVHomeGoodsListModel *goodListModel) {
        @strongify(self);
        [self collectionGoodsWithModle:goodListModel index:indexPath.row complete:^{
            weakCell.model = goodListModel;
        }];
    };
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //满减活动
//    CGFloat height = [HomeItemCell homeItemRowHeightForHomeGoodListModel:self.dataArray[indexPath.row]];
    
    OSSVHomeGoodsListModel *oneModel = self.dataArray[indexPath.row];
    OSSVHomeGoodsListModel *twoModel = nil;
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
    
    CGFloat height = [OSSVHomeItemssCell homeItemRowHeightOneModel:oneModel twoModel:twoModel];
    
    return CGSizeMake(kGoodsWidth, height);
    
}

//定义每个UICollectionView 纵向的间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 1;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 1;
//}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVHomeGoodsListModel *model = self.dataArray[indexPath.row];
    [ABTestTools.shared goodsImpressionWithKeyWord:STLToString(self.keyword)
                                      keyWordsType:STLToString(self.keyWordType)
                                       positionNum:indexPath.row+1
                                           goodsSn:STLToString(model.goods_sn)
                                         goodsName:STLToString(model.goodsTitle)
                                             catId:STLToString(model.cat_id)
                                           catName:STLToString(model.cat_name)];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    OSSVHomeGoodsListModel *goodsModel = self.dataArray[indexPath.row];
    
    OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
    advEventModel.url = self.deeplinkUrl;
    
    NSDictionary *sensorsDic = @{@"key_word":STLToString(self.keyword),
                             @"key_word_type":STLToString(self.keyWordType),
                                 @"goods_sn":STLToString(goodsModel.goods_sn),
                                 @"goods_name":STLToString(goodsModel.goodsTitle),
                                 @"action_type":@([advEventModel advActionType]),
                                 @"url":STLToString([advEventModel advActionUrl]),
                                 @"position_number":@(indexPath.row+1),
                                 @"third_part_id":STLToString(self.searchModel.btm_sid),
    };
    
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchResultClick" parameters:sensorsDic];
    
    //数据GA埋点曝光 列表商品 点击
    // item
    NSMutableDictionary *item = [@{
      kFIRParameterItemID: STLToString(goodsModel.goods_sn),
      kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
      kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
      //产品规格
      kFIRParameterItemVariant: @"",
      kFIRParameterItemBrand: @"",
      kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
      kFIRParameterCurrency: @"USD",
      kFIRParameterQuantity: @(1)
    } mutableCopy];

    // Add items indexes
    item[kFIRParameterIndex] = @(indexPath.row+1);

    // Prepare ecommerce parameters
    NSMutableDictionary *itemList = [@{
      kFIRParameterItemListID: STLToString(goodsModel.cat_id),
      kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
      @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
      @"position": @"ProductList_RegularProduct"
    } mutableCopy];

    // Add items array
    itemList[kFIRParameterItems] = @[item];

    // Log select item event
    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectItem parameters:itemList];
    
    
    CGFloat price = [goodsModel.shop_price floatValue];;
    // 0 > 闪购 > 满减
    if (!STLIsEmptyString(goodsModel.specialId)) {//0元
        price = [goodsModel.shop_price floatValue];
        
    } else if (STLIsEmptyString(goodsModel.specialId) && goodsModel.flash_sale &&  [goodsModel.flash_sale.is_can_buy isEqualToString:@"1"] && [goodsModel.flash_sale.active_status isEqualToString:@"1"]) {//闪购
        price = [goodsModel.flash_sale.active_price floatValue];
    }

    NSDictionary *items = @{
        @"item_id": STLToString(goodsModel.goods_sn),
        @"item_name": STLToString(goodsModel.goodsTitle),
        @"item_category": STLToString(goodsModel.cat_name),
        @"price": @(price),
        @"itemBrand" : @""

    };
    
    NSDictionary *itemsDic = @{@"items":@[items],
                               @"currency": @"USD",
                               @"item_list_id":STLToString(goodsModel.goods_sn),
                               @"item_list_name": STLToString(self.keyword),
                               @"position": @"ProductList_RegularProduct",
                               @"screen_group" : [NSString stringWithFormat:@"ProductList_%@", STLToString(self.keyword)]
                            
    };
    [OSSVAnalyticsTool analyticsGAEventWithName:@"select_item" parameters:itemsDic];
    
    self.controller.currentPageCode = STLToString(goodsModel.goods_sn);
    OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
    goodsDetailsVC.goodsId = goodsModel.goodsId;
    goodsDetailsVC.wid = goodsModel.wid;
    goodsDetailsVC.coverImageUrl = goodsModel.goodsImageUrl;
    goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceSearchResult;
    goodsDetailsVC.searchKey = self.keyword;
    goodsDetailsVC.searchPositionNum = indexPath.row + 1;
//    self.searchModel.btm_sid = @"123456";
    goodsDetailsVC.searchModel = self.searchModel;
    goodsDetailsVC.coverImageUrl = STLToString(goodsModel.goodsImageUrl);
    NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceSearchResult sourceID:@""],
                          kAnalyticsUrl:STLToString(self.keyword),
                          kAnalyticsPositionNumber:@(indexPath.row+1),
                          kAnalyticsKeyWord:STLToString(self.controller.transmitMutDic[kAnalyticsKeyWord]),
                          kAnalyticsThirdPartId:STLToString(self.searchModel.btm_sid)
    };
    [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
    [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
    
    [ABTestTools.shared searchResultClickWithKeyWord:STLToString(self.keyword)
                                        keyWordsType:STLToString(self.keyWordType)
                                         positionNum:indexPath.row+1
                                             goodsSn:STLToString(goodsModel.goods_sn)
                                           goodsName:STLToString(goodsModel.goodsTitle)
                                               catId:STLToString(goodsModel.cat_id)
                                             catName:STLToString(goodsModel.cat_name)];
    
    [BytemCallBackApi sendCallBackWithApiKey:STLToString(self.searchModel.btm_apikey) index:STLToString(self.searchModel.btm_index) sid:STLToString(self.searchModel.btm_sid) pid:STLToString(goodsModel.spu) skuid:STLToString(goodsModel.goods_sn) action:0 searchEngine:STLToString(self.searchModel.search_engine)];
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section{
    if (self.isRecommend) {
        return [OSSVSearchsRecommdHeader contentH];
    }
    return 0.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (self.isRecommend) {
            OSSVSearchsRecommdHeader *headerCell = (OSSVSearchsRecommdHeader*)[collectionView
                    dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"STLSearchRecommendHeader" forIndexPath:indexPath];
            return headerCell;
        }
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    headerView.hidden = YES;
    return headerView;
}


#pragma mark - Collection
- (void)requestCollectAddNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVAddCollectApi *api = [[OSSVAddCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];

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

#pragma mark  收藏
- (void)collectionGoodsWithModle:(OSSVHomeGoodsListModel *)model index:(NSInteger)index complete:(void(^)(void))complete{
    
    if (USERID) {
        if (model.is_collect) {
            @weakify(self)
        //取消收藏
            [self requestCollectDelNetwork:@[model.goodsId,model.wid] completion:^(id obj) {
                @strongify(self)
                [self alertMessage:STLLocalizedString_(@"removedWishlist",nil)];
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
        
                [self alertMessage:STLLocalizedString_(@"addedWishlist",nil)];
                
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
                
                NSDictionary *itemsDic = @{@"items":@[items],
                                           @"currency": @"USD",
                                           @"value":  @(price),
                                           @"position": @"ProductList",
                                           @"screen_group":[NSString stringWithFormat:@"ProductList_%@", STLToString(self.keyword)]

                };
                
                [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_wishlist" parameters:itemsDic];

                NSDictionary *sensorsDic = @{@"goods_sn":STLToString(model.goods_sn),
                                            @"goods_name":STLToString(model.goodsTitle),
                                             @"cat_id":STLToString(model.cat_id),
                                             @"cat_name":STLToString(model.cat_name),
                                             @"original_price":@([STLToString(model.market_price) floatValue]),
                                             @"present_price":@(price),
                                             @"entrance":@"collect_goods",
                                             kAnalyticsKeyWord:STLToString(self.keyword),
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
        [self.controller presentViewController:signVC animated:YES completion:^{
        }];
    }
    
    
}

#pragma mark - Cancel the collection
- (void)requestCollectDelNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVDelCollectApi *api = [[OSSVDelCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
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

- (OSSVSearchResultAnalyseAP *)searchResultAnalyticsAOP {
    if (!_searchResultAnalyticsAOP) {
        _searchResultAnalyticsAOP = [[OSSVSearchResultAnalyseAP alloc] init];
        _searchResultAnalyticsAOP.source = STLAppsflyerGoodsSourceSearchResult;
    }
    return _searchResultAnalyticsAOP;
}

@end
