//
//  RecentViewModel.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostShowRecentViewModel.h"
#import "ZFGoodsModel.h"
#import "ZFCommunityPostShowRecentCell.h"
#import "ZFCommunityShowRecentVC.h"
#import "GoodListModel.h"
#import "ZFCommunityPostShowOrderListModel.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "Constants.h"

@interface ZFCommunityPostShowRecentViewModel ()
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) NSMutableArray *allGoodsIDArray;
@end

@implementation ZFCommunityPostShowRecentViewModel

- (void)requestRecentNetwork:(id)parmaters
                  completion:(void (^)(NSDictionary *pageInfo))completion
{
    if (completion) {
        completion(@{});
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityPostShowRecentCell *cell = [ZFCommunityPostShowRecentCell postRecentCellWithTableView:tableView andIndexPath:indexPath];
    ZFGoodsModel *model = self.dataArray[indexPath.row];
    ZFCommunityShowRecentVC *recentVC = (ZFCommunityShowRecentVC *)self.controller;
    [recentVC.recentDict[@"selectArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goods_id isEqualToString:model.goods_id]) {
            model.isSelected = YES;
        }
    }];
    cell.goodsListModel = model;
    
    @weakify(cell)
    cell.recentSelectBlock = ^(UIButton *selectBtn){
        @strongify(cell)
        
        [self.allGoodsIDArray removeAllObjects];
        @autoreleasepool {
            
            [recentVC.recentDict[@"hotArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [recentVC.recentDict[@"wishArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:wishModel.goods_id];
            }];
            
            [recentVC.recentDict[@"bagArray"] enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:bagModel.goods_id];
            }];
            
            [recentVC.recentDict[@"orderArray"] enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:orderModel.goods_id];
            }];
            
            [recentVC.recentDict[@"selectArray"] enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.allGoodsIDArray addObject:recentModel.goods_id];
            }];
        }
        
            if ([self.allGoodsIDArray containsObject:cell.goodsListModel.goods_id]) {
                if (!selectBtn.selected) {
                    YWLog(@"点击相同的商品");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Post_ViewModel_Alert_NoItem_Tip",nil), nil, ZFLocalizedString(@"OK", nil));
                }else{
                    selectBtn.selected = !selectBtn.selected;
                    
                    NSMutableArray *selectArray = recentVC.recentDict[@"selectArray"];
                    __block ZFGoodsModel *goodsModel = nil;
                    [selectArray enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([recentModel.goods_id isEqualToString:cell.goodsListModel.goods_id]) {
                            goodsModel = recentModel;
                            *stop = YES;
                        }
                    }];
                    
                    [recentVC.recentDict[@"selectArray"] removeObject:goodsModel];
                    [self.allGoodsIDArray removeObject:cell.goodsListModel.goods_id];
                    [self sendSelectCountChangeNotific:self.allGoodsIDArray.count];
                }

            } else{
                if (self.allGoodsIDArray.count >= 6) {
                    YWLog(@"超过6个了");
                    ShowAlertSingleBtnView(ZFLocalizedString(@"Community_ProductMax6",nil), nil, ZFLocalizedString(@"OK", nil));
                }else{
                    selectBtn.selected = !selectBtn.selected;
                    cell.goodsListModel.isSelected = selectBtn.selected;
                    [recentVC.recentDict[@"selectArray"] addObject:model];
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
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray= [NSArray new];
        _dataArray = [ZFGoodsModel selectAllGoods];        
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