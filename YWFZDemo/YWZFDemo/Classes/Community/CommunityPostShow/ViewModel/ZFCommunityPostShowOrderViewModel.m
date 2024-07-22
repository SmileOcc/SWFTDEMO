//
//  ZFCommunityPostShowOrderViewModel.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostShowOrderViewModel.h"
#import "PostOrderListApi.h"
#import "ZFCommunityPostShowOrderModel.h"
#import "ZFCommunityShowPostOrderCell.h"
#import "ZFCommunityShowOrderVC.h"
#import "GoodListModel.h"
#import "ZFGoodsModel.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFCommunityPostShowOrderViewModel ()
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic, strong) ZFCommunityPostShowOrderModel *collectionModel;
@property (nonatomic,strong) NSMutableArray *allGoodsIDArray;
@end

@implementation ZFCommunityPostShowOrderViewModel

- (void)requestOrderNetwork:(id)parmaters
               completion:(void (^)(NSDictionary *pageDic))completion
{
    NSInteger page = 1;
    if ([parmaters intValue] == 0) {
        // 假如最后一页的时候
        if ([self.collectionModel.page integerValue] == [self.collectionModel.total_page integerValue]) {
            if (completion) {
                NSDictionary *pageInfo = @{ kTotalPageKey  : @([self.collectionModel.total integerValue]),
                                            kCurrentPageKey: @([self.collectionModel.page integerValue]) };
                completion(pageInfo);
            }
            return; // 直接返回
        }
        page = [self.collectionModel.page integerValue] + 1;
    }

    @weakify(self)
    PostOrderListApi *api = [[PostOrderListApi alloc] initWithOrderWithPage:page pageSize:10];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        if (page == 1) {
            [self.dataArray removeAllObjects];
        }
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            self.collectionModel = [self dataAnalysisFromJson:requestJSON request:api];
            [self.dataArray addObjectsFromArray:self.collectionModel.data];
            if (completion) {
                NSDictionary *pageInfo = @{ kTotalPageKey  : @([self.collectionModel.total integerValue]),
                                            kCurrentPageKey: @([self.collectionModel.page integerValue]) };
                completion(pageInfo);
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request
{
    if ([request isKindOfClass:[PostOrderListApi class]]) {
        if ([json[@"statusCode"] integerValue] == 200) {
            return [ZFCommunityPostShowOrderModel yy_modelWithJSON:json[ZFResultKey]];
        } else {
             ShowToastToViewWithText(self.controller.view, json[@"msg"]);
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityShowPostOrderCell *cell = [ZFCommunityShowPostOrderCell postOrderCellWithTableView:tableView andIndexPath:indexPath];
    ZFCommunityPostShowOrderListModel *model = self.dataArray[indexPath.row];
    ZFCommunityShowOrderVC *orderVC = (ZFCommunityShowOrderVC *)self.controller;
    [orderVC.orderDict[@"selectArray"] enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goods_id isEqualToString:model.goods_id]) {
            model.isSelected = YES;
        }
    }];
    cell.goodsListModel = model;
    
    @weakify(cell)
    cell.orderSelectBlock = ^(UIButton *selectBtn){
        @strongify(cell)
        [self.allGoodsIDArray removeAllObjects];
        @autoreleasepool {
            
            [orderVC.orderDict[@"hotArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [orderVC.orderDict[@"wishArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:wishModel.goods_id];
            }];
            
            [orderVC.orderDict[@"bagArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [orderVC.orderDict[@"selectArray"] enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:orderModel.goods_id];
            }];
            
            [orderVC.orderDict[@"recentArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:recentModel.goods_id];
            }];
        }
        
            if ([self.allGoodsIDArray containsObject:cell.goodsListModel.goods_id]) {
                if (!selectBtn.selected) {
                    YWLog(@"点击相同的商品");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Post_ViewModel_Alert_NoItem_Tip",nil), nil, ZFLocalizedString(@"OK", nil));
                }else{
                    selectBtn.selected = !selectBtn.selected;
                    NSMutableArray *selectArray = orderVC.orderDict[@"selectArray"];
                    __block ZFCommunityPostShowOrderListModel *orderListModel = nil;
                    [selectArray enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([recentModel.goods_id isEqualToString:cell.goodsListModel.goods_id]) {
                            orderListModel = recentModel;
                            *stop = YES;
                        }
                    }];
                    [orderVC.orderDict[@"selectArray"] removeObject:orderListModel];
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
                    [orderVC.orderDict[@"selectArray"] addObject:model];
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
