//
//  ZFCommunityShowHotViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityShowHotViewModel.h"
#import "ZFCommunityShowPostGoodsCell.h"
#import "ZFCollectionListModel.h"
#import "ZFCommunityShowHotVC.h"
#import "GoodListModel.h"
#import "ZFCommunityPostShowOrderListModel.h"
#import "ZFGoodsModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "PostGoodsManager.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFCommunityShowHotViewModel ()
@property (nonatomic,strong) NSMutableArray               *dataArray;
@property (nonatomic, strong) ZFCollectionListModel       *collectionModel;
@property (nonatomic,strong) NSMutableArray               *allGoodsIDArray;
@end


@implementation ZFCommunityShowHotViewModel

- (void)requestPageData:(BOOL)firstPage
             completion:(void (^)(NSDictionary *pageInfo))completion
{
    NSInteger currentPage = firstPage ? 1 : ++self.collectionModel.page;
    NSDictionary *info = @{
                           @"page"        : @(currentPage),
                           @"page_size"   : @(20),
                           @"sess_id"     : ISLOGIN ? @"" : SESSIONID,
                           };
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.parmaters = info;
    requestModel.url = API(Port_communityHotList);
    
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Port_communityHotList requestTime:ZFRequestTimeBegin];
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Port_collect requestTime:ZFRequestTimeEnd];
        
        self.collectionModel = [ZFCollectionListModel yy_modelWithJSON:responseObject[ZFResultKey]];
        NSArray *currentPageArray = self.collectionModel.data;
        if (self.collectionModel && currentPageArray.count > 0) {
            if (firstPage) {
                self.dataArray = [NSMutableArray arrayWithArray:currentPageArray];
            }else{
                [self.dataArray addObjectsFromArray:currentPageArray];
            }
            self.collectionModel.data = self.dataArray;
        }
        
        // 谷歌统计
        [ZFAnalytics showCollectionProductsWithProducts:self.collectionModel.data position:0 impressionList:@"Wishlist" screenName:@"Wishlist" event:nil];
        if (completion) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self.collectionModel.total_page),
                                        kCurrentPageKey: @(self.collectionModel.page) };
            completion(pageInfo);
        }
        
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.controller.view, error.domain);
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityShowPostGoodsCell *cell = [ZFCommunityShowPostGoodsCell postGoodsCellWithTableView:tableView andIndexPath:indexPath];
    ZFGoodsModel *model = self.dataArray[indexPath.row];
    ZFCommunityShowHotVC *hotVC = (ZFCommunityShowHotVC *)self.controller;
    [hotVC.hotDict[@"selectArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goods_id isEqualToString:model.goods_id]) {
            model.isSelected = YES;
        }
    }];
    cell.goodsListModel = model;
    
    @weakify(cell)
    cell.wishlistSelectBlock = ^(UIButton *selectBtn){
        @strongify(cell)
        [self.allGoodsIDArray removeAllObjects];
        @autoreleasepool {
            [hotVC.hotDict[@"selectArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:wishModel.goods_id];
            }];
            
            [hotVC.hotDict[@"wishArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [hotVC.hotDict[@"bagArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [hotVC.hotDict[@"orderArray"] enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:orderModel.goods_id];
            }];
            
            [hotVC.hotDict[@"recentArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:recentModel.goods_id];
            }];
        }
        
        if ([self.allGoodsIDArray containsObject:cell.goodsListModel.goods_id]) {
            if (!selectBtn.selected) {
                YWLog(@"点击相同的商品");
                ShowAlertSingleBtnView(ZFLocalizedString(@"Post_ViewModel_Alert_NoItem_Tip",nil), nil, ZFLocalizedString(@"OK", nil));
            }else{
                selectBtn.selected = !selectBtn.selected;
                NSMutableArray *selectArray = hotVC.hotDict[@"selectArray"];
                __block ZFGoodsModel *goodsModel = nil;
                [selectArray enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([recentModel.goods_id isEqualToString:cell.goodsListModel.goods_id]) {
                        goodsModel = recentModel;
                        *stop = YES;
                    }
                }];
                
                [hotVC.hotDict[@"selectArray"] removeObject:goodsModel];
                [self.allGoodsIDArray removeObject:cell.goodsListModel.goods_id];
                [self sendSelectCountChangeNotific:self.allGoodsIDArray.count];
            }
        }else{
            if (self.allGoodsIDArray.count >= 6) {
                YWLog(@"超过6个了");
                ShowAlertSingleBtnView(ZFLocalizedString(@"Community_ProductMax6",nil), nil, ZFLocalizedString(@"OK", nil));
            }else{
                selectBtn.selected = !selectBtn.selected;
                cell.goodsListModel.isSelected = selectBtn.selected;
                [hotVC.hotDict[@"selectArray"] addObject:model];
                [PostGoodsManager sharedManager].isFirstTimeEnter = NO;
                [self sendSelectCountChangeNotific:(self.allGoodsIDArray.count + 1)];
            }
        }
    };
    return cell;
}

- (void)sendSelectCountChangeNotific:(NSInteger)count {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPostSelectGoodsCountNotification object:[NSString stringWithFormat:@"%ld",(long)count]];

}

#pragma mark - Setter/Getter
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray= [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray *)allGoodsIDArray {
    if (!_allGoodsIDArray) {
        _allGoodsIDArray= [NSMutableArray new];
    }
    return _allGoodsIDArray;
}

@end
